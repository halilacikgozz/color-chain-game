# Color Chain

Godot 4.4.1 ile hazırlanmış, telefon ve bilgisayar için 7×7 zincir oyunu prototipi.

## Renk Bahçesi: bölüm yolculuğu

Oyun sade ana menüyle açılır. Bölüm Yolculuğu ayrı haritayı açar. Günlük Etkinlik altın kupa kartıyla günlük yarışı, Koleksiyon albüm kartıyla görünümleri, Haftalık Sıralama madalya kartıyla çevrimiçi ligi açar. Geniş Serbest Oyna düğmesi doğrudan süre ve hamle sınırı olmayan rahat modu başlatır. Dişli simgesi ses ve animasyon ayarlarını açar. İlk bölümü geçerek sıradakini aç.

- Bölümler sınırlı hamlede puan hedefine ulaşmayı ister; dördüncü bölümden itibaren tüm buzları da kırmalısın.
- Buzlar hücrelerde kalır. O hücredeki taşı zincirle veya özel taş etkisiyle temizlemek buzu kırar.
- Bomba, şimşek ve gökkuşağı ilerleyen bölümlerde tanıtılır. İlk bölümler üç, sonraki bölümler dört renktir.
- Kalan hamlelerin en az yarısıyla bitirirsen 3, en az beşte biriyle 2, diğer başarılarla 1 bölüm yıldızı kazanırsın. En iyi sonuç korunur.
- İlk tamamlamada +50 deneyim kazanılır. Bölüm yıldızları görev yıldızlarından ayrıdır.
- Onuncu bölümü bitirince Çiçek Bahçesi teması açılır; ödüller ekranından seçebilirsin.
- Can, bekleme ve deneme sınırı yoktur. Bölüm başlangıçları tekrarlanabilir; başarısız olunca yeniden deneyebilirsin.
- Haritadaki Serbest oyuna geç düğmesi önceki süreli/rahat oyunu açar. Harita düğmesiyle yolculuğa dön.
- Bölüm ilerlemesi, yıldızlar ve tema aynı cihazda kaydedilir; önceki deneyim ve rekorlar korunur.

## Üç dünya, günlük yarış ve koleksiyon

- 30 bölüm: Renk Bahçesi → Buz Vadisi → Neon Şehir. Önceki dünyanın finalini geçerek sonraki dünyayı aç.
- Buz Vadisi iki kat buz içerir; aynı hücreye iki ayrı hamlede ulaş. Neon Şehir'in ışıklı enerji düğümlerini temizle.
- Yeni bölüm görevleri: bomba/şimşek/gökkuşağı etkinleştirme, uzun zincir ve enerji düğümleri. Puan, buz ve görev birlikte tamamlanmalıdır.
- Bomba + şimşek üç satır ve bir sütunu temizler. Gökkuşağı + bomba/şimşek hedef rengin taşlarını o özel türe dönüştürüp zincirleme etkinleştirir.
- Günlük yarış UTC gününe göre aynı tahta, 20 hamle ve x1 çarpan verir. Efektler rastgele tahta akışını değiştirmez. Tekrar deneme sınırsızdır; 500 puan günde bir 40 kristal +50 deneyim verir.
- Bölümün ilk başarısı 25 kristal verir. Koleksiyonda İnci Halkası, Kristal Kesim, Altın Yörünge açılabilir; satın alınan görünümler tekrar seçilirken ücret alınmaz.
- Canlı harita, hareketli kar/şehir ışıkları, zincirde akan ışık, iniş sekmesi, son üç hamle vurgusu, yıldızların sırayla gelişi ve kutlama konfeti eklendi.
- Zincir uzadıkça ses tonu yükselir; koleksiyondaki Ses düğmesinden kapanır. Sade efektler hareket ve sesi azaltır.
- Gerçek haftalık lig için Supabase bağlantısı gerekir. Kurulum `supabase/README.md` içinde. Sunucu bağlanmadan lig sıralaması gösterilmez. Günlük hamleler sunucuda tekrar oynatılarak doğrulanır.

## Oynanış

- Fareye basılı tutarak veya parmağınla sürükleyerek aynı renk taşları bağla.
- Yalnızca yatay/dikey komşular seçilebilir; çapraz seçim yoktur.
- En az 3 taşı seçip bırak: taş başına 10 puan, üçüncüden sonraki her taş için 5 ek puan. Hızlı zincirlerde kombo çarpanı uygulanır.
- Bir önceki taşa dönerek zinciri kısalt. Aynı taş tekrar seçilemez.
- Taşlar aşağı düşer, üstten yenileri gelir. Animasyon sırasında seçim kilitlenir.
- Hamle kalmazsa tahta otomatik yenilenir; skor korunur.
- Yeniden başlat düğmesi skoru sıfırlar ve yeni tahta oluşturur; animasyon sırasında da çalışır.
- Escape veya uygulamadan ayrılmak etkin seçimi iptal eder.
- Rakamların yerine dört Renk Canlısı vardır: pembe Kıvrım (sedefli şerit), turkuaz Akış (üç sıvı çekirdeği), sarı Nabız (ışık halkaları), mor Yörünge (iki dönen çekirdek). Renk ve iç şekil birlikte taş türünü ayırt eder. Seçilince hareketleri aynı ritme geçer; Kıvrım zincirin yönüne uzanır, Akış birleşir, Nabız ve Yörünge hızlanır. Sade efektlerde şekiller sabit kalır.

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
- Her yeni serbest turda sol üstte aynı renkte üç taş ve bir başlangıç bombası bulunur.
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


### Ada yolculuğu

Bölüm Yolculuğu artık deniz üzerinde Palmiye Adası, Buz Vadisi ve Yeraltı Adası'nı gösteren 2.5D bir harita açar. Her ada kayıtlı tamamlanan bölüm sayısını, yıldızlarını ve kilit durumunu gösterir. Adalara dokunarak bölümlerini inceleyebilir, önceki dünyanın finalini geçerek ilerleyebilirsiniz.

Ada arka planı imagegen ile oluşturuldu. Arka plan üzerindeki isimler, ilerleme ve etkileşimler Godot tarafından çizilir. `assets/island-map.txt`, görselin JPEG verisinin Base64 biçimidir ve web export içinde paketlenir.


Adaların bölüm ekranları da artık onaylı tematik 2.5D manzaraları kullanır: tropik patika, kristalli buz vadisi ve lav mağaraları. Her adanın 10 bölümü 1–5 ve 6–10 sayfalarında seçilir. Durak numaraları, yıldızlar, kilitler ve sıradaki bölüm işareti kayıtlı ilerlemeye göre çizilir; bölüm kuralları ve mevcut kayıtlar korunur.


### Mobil performans

Boncuklar boşta hareket etmez. Her renk ve özel taş kabuğu 64×64 piksel görsele bir defa çizilir, sonra aynı görseller paylaşılır; tema değişince önbellek yenilenir. Boştaki tahta ve ana menü sürekli yeniden çizilmez. Seçim, patlama ve düşme korunur; geçici parçacıklar en fazla 48, özel efekt dalgaları en fazla 6 ile sınırlıdır. Harita animasyonları 15, etkileşim efektleri 30 çizim/saniye ile güncellenir; düşme tween'i kendi çizim güncellemelerini korur. Gerçek Android cihazında FPS ölçümü yapılmadı.


### Android APK

[Telefon için APK indir](https://halilacikgozz.github.io/color-chain-game/downloads/color-chain.apk). Dosyayı Android'de açıp tarayıcıya bu uygulama için kurulum izni vererek yükleyin. Bu, mağaza dağıtımı için hazırlanmış bir Play sürümü değil, doğrudan kurulan kişisel test APK'sıdır. ARMv7 ve ARM64 desteklenir; oyun dikey ekranda çalışır. Yalnızca çevrim içi lig için internet izni istenir. Tarayıcı kaydı ve APK kaydı ayrıdır; çevrim dışı bölümler oynanabilir, lig internet ister.

Actions, Java 17 ve Android SDK 34 ile APK'yı export eder; imza, paket adı ve ARM kitaplıklarını doğrular. Test imza anahtarı repo dışında Actions önbelleğinde tutulur. Önbellek silinirse aynı anahtarın korunması için yedeği gerekir; farklı anahtarla oluşturulan APK mevcut kurulumun üzerine güncellenemez. İndirilen APK `color-chain-android` Actions çıktısında da bulunur. Gerçek Android cihazında kurulum/oynama testi kullanıcı tarafından yapılır.
