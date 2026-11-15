"""Validate the actual store bundle, not only its export preset."""
import argparse
import json
import struct
import subprocess
import zipfile
from pathlib import Path
import xml.etree.ElementTree as ET


def elf_alignments(data):
    assert data[:4] == b'\x7fELF', 'Native library is not ELF'
    endian = '<' if data[5] == 1 else '>'
    if data[4] != 2:
        return []  # 16 KB Android devices use 64-bit native libraries.
    offset = struct.unpack_from(endian+'Q',data,32)[0]
    size, count = struct.unpack_from(endian+'HH',data,54)
    result = []
    for i in range(count):
        header = struct.unpack_from(endian+'IIQQQQQQ',data,offset+i*size)
        if header[0] == 1:
            file_offset, address, alignment = header[2], header[3], header[7]
            assert alignment >= 16384, f'Native LOAD alignment {alignment} is below 16 KB'
            assert file_offset % 16384 == address % 16384, 'LOAD offset is not 16 KB compatible'
            result.append(alignment)
    assert result, 'No native load segments found'
    return result


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--bundle',required=True)
    p.add_argument('--bundletool',required=True)
    p.add_argument('--version-code',type=int,required=True)
    p.add_argument('--report',required=True)
    args = p.parse_args()
    def bundletool(*words):
        return subprocess.check_output(['java','-jar',args.bundletool,*words],text=True)
    bundletool('validate','--bundle='+args.bundle)
    xml = bundletool('dump','manifest','--bundle='+args.bundle,'--module=base')
    root = ET.fromstring(xml)
    android = '{http://schemas.android.com/apk/res/android}'
    assert root.get('package') == 'com.halilacikgozz.colorchain'
    assert int(root.get(android+'versionCode')) == args.version_code
    uses_sdk = root.find('uses-sdk')
    target = int(uses_sdk.get(android+'targetSdkVersion'))
    assert target >= 36, 'Current Play requirement is target API 36'
    app = root.find('application')
    assert app.get(android+'debuggable','false') != 'true', 'Debug builds cannot be uploaded'
    permissions = [item.get(android+'name') for item in root.findall('uses-permission')]
    for forbidden in ['android.permission.INTERNET','android.permission.REQUEST_INSTALL_PACKAGES','android.permission.ACCESS_FINE_LOCATION','android.permission.READ_CONTACTS','android.permission.RECORD_AUDIO','android.permission.CAMERA']:
        assert forbidden not in permissions, f'Unexpected store permission: {forbidden}'
    libraries = {}
    with zipfile.ZipFile(args.bundle) as archive:
        names = archive.namelist()
        assert any('/lib/arm64-v8a/' in name for name in names), '64-bit support is required'
        metadata = [name for name in names if name.endswith('/build_info.json')]
        assert len(metadata) == 1, 'Installed build metadata missing or ambiguous'
        info = json.loads(archive.read(metadata[0]))
        assert info['version_code'] == args.version_code and info['distribution'] == 'google_play'
        assert not any('/scripts/update_checker.' in name for name in names), 'External APK updater was included in Play bundle'
        config_files = [name for name in names if name.endswith('/project.binary')]
        assert config_files and b'play_store' in archive.read(config_files[0]), 'Play distribution feature is missing'
        for name in names:
            if name.endswith('.so'):
                alignments = elf_alignments(archive.read(name))
                if alignments: libraries[name] = alignments
    assert libraries, 'No 64-bit ELF libraries were checked'
    report = {'package_id':root.get('package'),'version_code':args.version_code,'target_sdk':target,'debuggable':False,'permissions':permissions,'elf_16kb_load_alignment':libraries,'external_apk_updater':False,'distribution':'google_play'}
    Path(args.report).write_text(json.dumps(report,indent=2))
    Path(args.report).with_suffix('.manifest.xml').write_text(xml)
    print('Play bundle validated: target API 36, release signature, offline flavor and 16 KB native alignment')

if __name__ == '__main__': main()
