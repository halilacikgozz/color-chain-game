# Color Chain — Sayı Zinciri

Oyun doğrudan **5 sütun × 7 satırlık kare sayı tahtasına** açılır. Önceki ana menü, adalar, bölümler, koleksiyon, günlük etkinlik ve haftalık lig bu sürümün akışından çıkarılmıştır.

- Aynı değerli en az iki kareyi sürükleyerek bağla. Yatay, dikey ve çapraz komşular seçilebilir; geri sürükleme seçimi kısaltır.
- Seçilen toplam yukarı doğru 2'nin kuvvetine tamamlanır: iki 4 → 8, üç 4 → 16, dört 4 → 16, beş 4 → 32. Birleşme son karede gerçekleşir, boşluklar aşağı düşerek dolar.
- Seçim sırasında oluşacak kare ve gerçek toplam ayrı gösterilir. Puan gerçek toplam kadar artar.
- Sayılar ondalık metinle tam hassasiyetle saklanır; int64 veya kayan nokta sınırı yoktur. Bellek ve hesaplama süresi pratik sınırdır. K/M/B gösterimi kısaltmadır; yaklaşık değerler ≈ ile belirtilir.
- Tek dokunuş hiçbir pencere açmaz.
- Her puan hedefi **20 elmas** kazandırır. İlk hedef 1.000, sonraki hedefler iki katıdır. İlk kurulumda 90 elmas verilir; yeni tur elmasları yenilemez.
- **Çekiç (15 elmas):** seçilen kareyi kaldırıp boşluğu doldurur.
- **Karıştır (20 elmas):** taşları değiştirmeden yerlerini karıştırır ve eş değerli bir çift varsa oynanabilir eşleşme oluşturur. Hiç çift yoksa ücret alınmaz.
- **Mıknatıs (25 elmas):** seçilen kareyle aynı sayıdaki tüm kareleri birleştirir. Eş yoksa ücret alınmaz.
- Elmaslar gerçek para ile satılmaz; reklam, ödeme, sahte çevrim içi sıralama veya işlevsiz ödül çarkı yoktur.
- Hamle bitince sonuç ekranı gösterilir. Oyuncu yeni turu kendisi başlatır veya yardımcı hamle seçer.
- Sağ üst ayarlardan ses, animasyon, oyun kuralları ve yeni tur seçeneklerine ulaşılır. Animasyonlar yalnızca birleşme, düşme ve kısa hedef ödülünde çalışır; boşta sürekli animasyon yoktur.

## Kayıtlar

Tahta, puan, rekor, elmas ve ayarlar bu cihazda `user://number_chain_v3.json` içinde saklanır. Önceki `number_chain_v2.json` veya `number_chain_v1.json` ilk açılışta okunur; eski dosyalar silinmez veya değiştirilmez. 49 kareli eski tahtanın alt 35 taşı yeni tahtaya aktarılır, kalan 14 taş yedekte tutulup sonraki dolumlarda oyuna geri döner. Eski keyfi sayılar üst 2 kuvvetine yükseltilir. Puan ve rekor korunur.

Tarayıcı kaydı ve APK kaydı ayrıdır. Bu sürümde bulut/e-posta hesapları ve rekabet sunucusu kullanılmaz. Önceki klasik Color Chain kodu ve Supabase kaynakları geçmiş çalışma referansı olarak depoda bulunur; uygulamadan erişilmez ve klasik oyun betikleri/bölüm görselleri dışa aktarıma dahil edilmez.

## Çalıştırma ve kontroller

Godot **4.4.1** ile `project.godot` dosyasını açıp F6 yerine **F5** ile çalıştır. Açılış sahnesi `scenes/number_chain.tscn` dosyasıdır; `scenes/main.tscn` de aynı sayı oyununa yönelir.

```sh
godot --headless --editor --path . --import
godot --headless --path . --script tests/test_numbers.gd
```

Testler doğrudan açılış, 35 kare, dört çapraz yön, hızlı/parmak kimliği farklı dokunma, odak kaybı, büyük sayı hassasiyeti, düşme, üç yardımcı hamle, elmas ücretleri, puan hedefi, eski kayıt aktarımı ve hamlesiz bitişi kontrol eder. Gerçek Android cihazında dokunma, ses ve performans ayrıca denenmelidir.

## Yayın

`main` dalına gönderilen değişiklik GitHub Actions ile test edilir, web sürümü ve ARMv7/ARM64 Android APK oluşturulur. Web GitHub Pages'e yayınlanır. APK indirme sayfası: `android.html`.

Android paket kimliği `com.halilacikgozz.colorchain` korunur. Mevcut anahtar GitHub Actions önbelleğinde tutulan kişisel test anahtarıdır. Mağaza yayını için kalıcı ve güvenli imzalama kurulmalıdır; önbellek kaybı anahtarın değişmesine ve yerinde güncellemenin engellenmesine yol açabilir.

Görsel yön, kullanıcının paylaştığı ekran görüntüsündeki koyu zemin, kare sayılar, büyük puan ve alt araç diziliminden esinlenir. Marka görselleri veya maskot kopyalanmaz. Uzun zincirlerde üst 2 kuvvetine tamamlama bu oyunun açık uyarlama kuralıdır; başka oyunun tüm kurallarının birebir doğrulandığı iddia edilmez.

## APK içinden güncelleme

Bu özelliği içeren APK bir kez mevcut uygulamanın üzerine kurulmalıdır; eski APK'ya uzaktan kod eklenmez. Android uygulama açılışından üç saniye sonra, beş dakikada bir açıkken ve yeniden öne geldiğinde (beş dakikalık aralık dolmuşsa) HTTPS üzerinden `update.json` sürüm bilgisini kontrol eder. İstek zaman aşımı 10 saniyedir; internet olmadığında oyun çalışmaya devam eder. Kontrol sırasında hesap, e-posta veya oyun kaydı gönderilmez.

Yalnızca yüklü sürümden yüksek sürüm kodu teklif edilir. Bildirim sürükleme veya düşme animasyonunu bölmez. **Daha sonra** aynı sürümün otomatik bildirimini 24 saat erteler; ayarlardan yine açılabilir. Ayarlarda yüklü sürüm ve **Güncellemeleri denetle** bulunur. **Güncellemeyi indir** sabit HTTPS APK adresini sistem tarayıcısında açar; kullanıcı indirilen APK'yı açıp Android kurulum ekranında Güncelle'yi seçer. Sessiz kurulum yapılmaz ve uygulama kendini silmez. Tarayıcı sürümünde APK bildirimleri otomatik gösterilmez.

Her başarılı Actions yayını aynı artan sürüm kodunu APK'ya ve `update.json` dosyasına yazar. Önceki APK'nın imza sertifikası yeni APK'yla karşılaştırılır; eşleşmezse yayın durur. İmza anahtarı bulunamazsa yeni anahtar üretilmez. Mevcut kişisel test anahtarı hâlâ Actions önbelleğindedir; uzun süreli dağıtım için bu mevcut anahtarın güvenli kalıcı yedeği gereklidir. GitHub Actions önbelleği kalıcı anahtar kasası değildir.

`tests/test_updates.gd` yeni/eşit/eski sürüm, bozuk bilgi, farklı paket veya indirme adresi, çevrim dışı yanıt, 24 saat erteleme, gerçek yerel HTTP isteği, hamle sırasında bildirim erteleme ve ayarlardan elle açma davranışlarını kontrol eder. Gerçek telefonda indirme ve Android paket kurulumunun uçtan uca doğrulanması ayrıca gerekir.

Kaynaklar: [Godot HTTPRequest](https://docs.godotengine.org/en/4.4/classes/class_httprequest.html), [Android uygulama güncellemeleri](https://developer.android.com/google/play/app-updates), [Android web üzerinden dağıtım](https://developer.android.com/distribute/marketing-tools/alternative-distribution).
