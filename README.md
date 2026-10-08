# Color Chain

Godot 4.4.1 ile hazırlanmış, telefon ve bilgisayar için 7×7 zincir oyunu prototipi.

## Oynanış

- Fareye basılı tutarak veya parmağınla sürükleyerek aynı renk taşları bağla.
- Yalnızca yatay/dikey komşular seçilebilir; çapraz seçim yoktur.
- En az 3 taşı seçip bırak: taş başına 10 puan, üçüncüden sonraki her taş için 5 ek puan.
- Bir önceki taşa dönerek zinciri kısalt. Aynı taş tekrar seçilemez.
- Taşlar aşağı düşer, üstten yenileri gelir. Animasyon sırasında seçim kilitlenir.
- Hamle kalmazsa tahta otomatik yenilenir; skor korunur.
- Yeniden başlat düğmesi skoru sıfırlar ve yeni tahta oluşturur; animasyon sırasında da çalışır.
- Escape veya uygulamadan ayrılmak etkin seçimi iptal eder.
- Renklerin üzerindeki rakamlar taş türlerini ayırt etmeye yardımcı olur.

## Godot'ta aç

1. Godot **4.4.1 Standard** sürümünü aç (C#/.NET gerekmez).
2. Import ile bu klasördeki `project.godot` dosyasını seç.
3. F6/F5 ile oyna. Godot düzenleyicisinde dokunmayı denemek için gerçek telefon web sürümünü kullan.

Proje harici görsel, yazı tipi veya eklenti gerektirmez. Dikey 480×800 tasarım farklı ekranlarda ölçeklenir.

## GitHub'a yükle ve yayınla

Hedef depo: https://github.com/halilacikgozz/color-chain-game

Bu klasörün **içeriği** depo kökünde olmalı; `project.godot` bir alt klasörde kalmamalı. `.github/workflows/deploy.yml` ve `.gitignore` gizli dosyalarını da yükle. ZIP'i tek dosya olarak yüklemek projeyi yayınlamaz; önce aç.

Git kullanıyorsan mevcut depoyu klonla, dosyaları klonlanan klasöre kopyala ve `main` dalına gönder:

```sh
git clone https://github.com/halilacikgozz/color-chain-game.git
cd color-chain-game
# Hazırlanan proje klasörünün içeriğini buraya kopyala.
git add .
git commit -m "Add playable Godot Color Chain prototype"
git push origin main
```

GitHub deposunda **Settings → Pages → Build and deployment → Source → GitHub Actions** seç. Ardından `main` dalına gönder veya Actions sekmesinden **Build and publish Color Chain → Run workflow** çalıştır.

İş akışı Godot ve export şablonlarını kurar, oyun kurallarını test eder, web sürümünü üretir ve Pages'e dağıtır. Pull request'lerde test ve export çalışır; yayın yapılmaz. Depo varsayılan dalı `main` değilse workflow'daki iki dal listesini güncelle.

Başarılı dağıtımdan sonra hedef oyun adresi:
https://halilacikgozz.github.io/color-chain-game/

Bu dosyaların hazırlanması, GitHub'a yükleme veya canlı yayın yapıldığı anlamına gelmez.

## Yerel web testi

Godot'ta **Editor → Manage Export Templates** üzerinden 4.4.1 şablonlarını kur. **Project → Export → Web → Export Project** ile `build/web/index.html` üret. Komut satırı alternatifi:

```sh
mkdir -p build/web
godot --headless --editor --path . --import
godot --headless --path . --script tests/test_game.gd
godot --headless --path . --export-release Web build/web/index.html
python3 -m http.server 8000 --directory build/web
```

Tarayıcıda http://localhost:8000 aç. HTML dosyasına çift tıklamak yerine web sunucusu kullan. WebGL 2.0 ve WebAssembly destekleyen tarayıcı gerekir. Web export tek iş parçacıklıdır; Pages üzerinde özel COOP/COEP başlıkları gerektirmez.

## Kontrol listesi

- Fare ve telefonda dokunma ile 3+ zincir, kısa zincirin reddi, farklı renk ve çapraz seçim reddi.
- Geri izleme, doğru skor, taşların düşmesi ve 49 taşın korunması.
- Animasyon sırasında yeniden başlatma, ikinci parmağın mevcut seçimi bozmaması.
- Dar/geniş ekranda tahta ve düğmenin görünmesi; tarayıcı dışına çıkınca seçimin iptali.

`tests/test_game.gd` temel kuralları, düşme sırasını, hamlesiz tahta kurtarmayı ve animasyon sırasında yeniden başlatmayı kontrol eder. Gerçek mobil dokunma ve görsel düzen ayrıca cihaz üzerinde kontrol edilmelidir.

## Dosyalar

- `scripts/game.gd`: seçim, skor, tahta, animasyon ve çizim.
- `scenes/main.tscn`: ana sahne.
- `export_presets.cfg`: tek iş parçacıklı Web export.
- `.github/workflows/deploy.yml`: test, export ve Pages yayını.

Kaynaklar: [Godot web export](https://docs.godotengine.org/en/4.4/tutorials/export/exporting_for_web.html), [GitHub Pages iş akışları](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).
