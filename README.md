# Color Chain

Godot 4.4.1 ile hazırlanmış, telefon ve bilgisayar için 7×7 zincir oyunu prototipi.

## Oynanış

- Fareye basılı tutarak veya parmağınla sürükleyerek aynı renk taşları bağla.
- Yalnızca yatay/dikey komşular seçilebilir; çapraz seçim yoktur.
- En az 3 taşı seçip bırak: taş başına 10 puan, üçüncüden sonraki her taş için 5 ek puan. Hızlı zincirlerde kombo çarpanı uygulanır.
- Bir önceki taşa dönerek zinciri kısalt. Aynı taş tekrar seçilemez.
- Taşlar aşağı düşer, üstten yenileri gelir. Animasyon sırasında seçim kilitlenir.
- Hamle kalmazsa tahta otomatik yenilenir; skor korunur.
- Yeniden başlat düğmesi skoru sıfırlar ve yeni tahta oluşturur; animasyon sırasında da çalışır.
- Escape veya uygulamadan ayrılmak etkin seçimi iptal eder.
- Renklerin üzerindeki rakamlar taş türlerini ayırt etmeye yardımcı olur.

## Heyecan ve efektler

- **60 saniyelik tur:** süre ilk geçerli zincirden sonra başlar. Uygulama odağı kaybolduğunda duraklar.
- **Kombo:** 4 saniye içinde yeni bir geçerli zincir yap; çarpan x5'e kadar yükselir. Kısa zincir kombo serisini bitirir.
- **Süre bonusu:** 5+ taş, `min(5, taş sayısı - 2)` saniye kazandırır. Kalan süre en fazla 60 saniyedir.
- **Rahat mod:** alttaki Mod düğmesi süre sınırını kaldırır; mod değişimi yeni tur başlatır.
- **Animasyonlar:** seçilen taşlarda parıltı, küçülerek patlama, renkli parçacıklar, yükselen puanlar ve hafif tahta sarsıntısı.
- **Sade efekt seçeneği:** alttaki Efektler düğmesi parıltı, parçacık ve sarsıntıyı kapatır; temel düşme/patlama kalır.
- **Tur özeti:** süre bitince puan, en uzun zincir ve başarılı hamle sayısı gösterilir.
- **Rekor:** bu tarayıcıda/cihazda saklanır. Tarayıcı verilerinin silinmesi veya gizli mod kalıcılığı etkileyebilir; modlar ortak rekor kullanır.

## Kalıcı hedefler ve ödüller

Üstteki **Hedefler ve ödüller** yazısına dokunarak ilerleme ekranını aç. Bu ekran açıkken tur duraklar.

- Her geçerli zincir `taş sayısı × 3 + kombo × 2` deneyim kazandırır. Her 100 deneyimde bir seviye yükselir.
- Aktif görevi tamamlamak **1 yıldız + 30 deneyim** kazandırır. Bir hamle yalnızca o sırada aktif olan göreve sayılır.
- Görevler; zincir uzunluğu, başarılı hamle sayısı, kombo, toplam kazanılan puan ve temizlenen taş hedefleri arasında döner. Sonraki döngülerde hedefler artar.
- **3 yıldızda Neon**, **6 yıldızda Pastel** teması açılır. Yıldızlar harcanmaz. Açılan temayı ödüller ekranından seç.
- Görev ilerlemesi, deneyim, yıldızlar ve seçilen tema tur yenilendiğinde korunur; her geçerli hamlede bu cihazda kaydedilir.
- **60 saniyelik modun rekoru ayrı tutulur:** 100 puan Bronz, 300 Gümüş, 750 Altın, 1500 Elmas madalya verir. Rahat mod görev ve deneyim kazandırır, süreli madalya rekoruna sayılmaz.
- Görev ve seviyeler bu cihazdaki kişisel ilerlemedir. Başka oyuncularla ortak bir çevrimiçi sıralama bulunmaz.
- Önceki sürümün genel rekoru korunur; ayrı süreli rekor yeni sürümdeki süreli hamlelerle oluşur.

## Özel taşlar

- **Bomba:** 5–6 taşlık zincirden kazanılır; çevresindeki 3×3 alanı temizler. Altın renkli halka ve şok dalgası animasyonu vardır.
- **Şimşek:** 7–8 taşlık zincirden kazanılır; bulunduğu satırın tamamını temizler. Satır boyunca elektrik animasyonu oynar.
- **Gökkuşağı:** 9 veya daha uzun zincirden kazanılır. Her renkle bağlanır; zincirdeki ilk normal taşın rengini seçer ve tahtadaki o renkteki tüm taşları temizler. Farklı iki normal rengi tek zincirde birleştirmez.
- Gökkuşağı ile başlayan seçimde ilk normal taş rengi belirler. Geri izleyerek o taşı kaldırırsan yeniden renk seçebilirsin. Yalnızca gökkuşağı taşlarından oluşan zincirde ilk taşın alttaki rengi kullanılır.
- Görseller: gölgeli bomba gövdesi, yanan fitil ve kıvılcımlar; ışıklı şimşek ve dönen elektrik yayları; çok renkli gökkuşağı halkası ve yıldız çekirdeği.
- Animasyonlar: katmanlı patlama halkaları ve radyal kıvılcımlar, dallanan elektrik şeritleri, aynı renkteki hedeflere uzanan gökkuşağı izleri.
- Ödül, zincirin son taşının yerinde oluşur ve düşme sırasında diğer taşlarla birlikte hareket eder. Bu hamlede yeni kazanılan taş etkinleşmez.
- Özel taş aynı rengin en az 3 taşlık geçerli zincirine katıldığında etkinleşir. Kısa zincir etkisini tetiklemez.
- Patlamanın ulaştığı başka özel taşlar da etkinleşir; her hücre bir kez sayılır. Seçili zincirin dışındaki temizlenen her taş kombo öncesinde 10 ek puan verir.
- Her yeni turda sol üstte aynı renkte üç taş ve bir başlangıç bombası bulunur.
- Sade efektlerde özel taşların simgeleri ve oyun etkileri korunur; şok dalgası ve elektrik çizgileri kapatılır.
- Özel taşlar o tura aittir; turu yenilemek tahtayı sıfırlar. Seviye, yıldız ve tema kayıtları korunur.

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

Bu depodaki `main` dalına yapılan değişiklikler, testler geçtikten sonra aynı oyun adresine otomatik yayınlanır.

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
