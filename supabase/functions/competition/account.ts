export function parseRecoveryCode(value: unknown): {id:string,password:string} {
 if(typeof value!=='string')throw Error('Geçersiz kurtarma kodu');
 const match=/^CC1\.([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.([A-Za-z0-9_-]{43})$/.exec(value.trim());
 if(!match)throw Error('Kurtarma kodunu eksiksiz gir.');
 return {id:match[1],password:match[2]};
}
export function createRecoveryCode(id:string): string {
 const bytes=crypto.getRandomValues(new Uint8Array(32));
 const secret=btoa(String.fromCharCode(...bytes)).replaceAll('+','-').replaceAll('/','_').replaceAll('=','');
 return `CC1.${id}.${secret}`;
}
