# Google Play yayın paketi — 16 Kasım 2026

Henüz Play Console hesabı veya yayın kaydı yoktur. Bu dosya yayın hazırlığıdır; Google incelemesi ve onayı yerine geçmez.

## Hazır mağaza bilgileri

- Ad taslağı: Color Chain: Sayı Zinciri
- Kategori taslağı: Oyun / Bulmaca
- Dil: Türkçe (tr-TR)
- Destek e-postası: colorchain39@gmail.com (kullanıcının verdiği herkese açık adres)
- Gizlilik URL: https://halilacikgozz.github.io/color-chain-game/privacy.html
- Uygulama kimliği: com.halilacikgozz.colorchain
- Dağıtım: GooglePlay export preset'i / play_store özelliği
- Hedef Android API: 36; minimum Android API: 24
- Mağaza paketi: color-chain.aab

## Hesap sahibinin tamamlayacağı işlemler

1. https://play.google.com/console/ adresinde kendi Google hesabınla geliştirici hesabı aç. Gerçekte bireysel geliştiriciysen kişisel, bir tüzel kişiliği temsil ediyorsan kuruluş türünü seç. Bilgilerin doğru olmalı. Google sözleşmesini inceleyip kabul etme, 25 ABD doları kayıt ücretini ödeme ve kimlik/cihaz doğrulama işlemlerini kendin tamamla. Şifre, ödeme bilgisi veya kimlik belgesini sohbete gönderme.
2. Uygulama kaydını oluştur. Fiyatlandırma ve hedef kitleyi hesap sahibi kesinleştirecek. Hedef kitle yaş grubu çocukları kapsıyorsa ek Families kuralları değerlendirilmelidir; IARC içerik derecesi formunun sonucudur ve önceden tahmin edilerek beyan edilmez.
3. İlk yüklemeden ÖNCE uygulama imzası kararını tamamla (aşağıdaki bölüm). Paket adını kaydettikten sonra değiştirmek yeni uygulama demektir.
4. AAB'yi önce dahili test kanalına yükle. Metinleri ve görselleri ekle; reklam, veri güvenliği, uygulama erişimi ve içerik derecelendirmesi formlarını gerçek özelliklere göre tamamla.
5. Yeni kişisel hesapta en az 12 kişinin 14 gün kesintisiz katıldığı kapalı test yap; gerçek cihaz geri bildirimlerini topla ve düzeltmeleri yayımla. Bu süre araçla veya sahte testçiyle atlanamaz.
6. Koşullar sağlandıktan sonra üretim erişimine başvur; ardından yayın incelemesine gönder. Uygulamanın yayımlandığı ancak Play Console yayın durumundan doğrulanabilir.

## İmza ve mevcut deneme APK'sı

AAB mevcut kişisel test anahtarıyla release modunda imzalanır. Bu, Google Play'deki kalıcı imzalama kurulumunun tamamlandığı anlamına gelmez. Anahtar yalnızca Actions önbelleğinde bulunuyor; uzun vadeli güvenli yedeği hâlâ gerekli. Anahtar hiçbir açık kaynak dosyasına, indirilebilir açık pakete veya sohbete konmamalıdır.

Google Play App Signing'e ilk katılımda Google yeni bir uygulama imza anahtarı oluşturursa, önceden telefonuna yüklediğin deneme APK'sıyla imza farklı olabilir. Bu durumda mağaza sürümü eskisinin üzerine kurulamaz. Kayıtlarını kaybetmemek için mevcut uygulamayı silme. Mevcut imzayı korumak isteniyorsa ilk yayından önce Console'un desteklediği güvenli mevcut anahtar aktarımı (PEPK) yolu ve kalıcı yedek hazırlanmalıdır; bu hesap ve imzalama adımı henüz tamamlanmadı. Google'ın yönettiği uygulama imzası kullanıldığında yükleme anahtarı ile uygulama imza anahtarının görevleri farklıdır.

## Veri güvenliği ve uygulama içeriği taslağı

Aşağıdakiler yalnızca ayrı GooglePlay paketinin mevcut kodu ve doğrulanmış izinleri içindir; deneme APK'sı ile karıştırılmamalıdır:

- Uygulama içinde veri toplanması/paylaşılması: yok.
- Hesap oluşturma/giriş: yok; uygulama erişimi için hesap gerekmez.
- Reklam/analiz SDK'sı: yok.
- Uygulama içi satın alma: yok; elmaslar oynayarak kazanılır.
- Oyun kaydı: cihazda; uygulamayı kaldırma/veri temizleme ile silinir.
- Destek için kullanıcının gönüllü gönderdiği e-posta, Gmail ve geliştiricinin destek sürecindedir; oyun otomatik e-posta göndermez.
- Google Play sürümü internet izni ve dış APK güncelleyicisi içermez. Güncelleme düğmesi yalnızca kendi Google Play kaydını açar.
- Uygulama şiddet, cinsel içerik, kullanıcı sohbeti veya kullanıcı içeriği paylaşma alanı içermez; kesin yaş derecesi IARC formuyla belirlenir.

Bu beyanlar kod veya SDK'lar değiştiğinde yeniden incelenmelidir. Formların son gönderimini hesap sahibi gerçek yayın ayarlarıyla kontrol eder.

## Paket kontrolleri

CI ayrı Godot 4.7.2 motoruyla test yapar; AAB hedef API 36, release/debug durumu, paket/sürüm kimliği, internet/kurulum izni bulunmaması, harici APK güncelleyicisinin dışlanması ve 64-bit ELF 16 KB LOAD hizalamasını inceler. Bundletool doğrulaması ve evrensel APK zip hizalama denetimi de yapılır. Fiziksel Android 16 / 16 KB sayfalı cihaz ve Play Console ön yayın raporu ayrıca gerekir.

## Birincil kaynaklar

- Hesap/ücret: https://support.google.com/googleplay/android-developer/answer/6112435
- Yeni kişisel hesap testleri: https://support.google.com/googleplay/android-developer/answer/14151465
- Hedef API: https://support.google.com/googleplay/android-developer/answer/11926878
- Gizlilik ve formlar: https://support.google.com/googleplay/android-developer/answer/9859455
- Harici güncelleme yasağı: https://support.google.com/googleplay/android-developer/answer/16559646
- 16 KB uyumluluk: https://developer.android.com/guide/practices/page-sizes
- İmzalama: https://developer.android.com/studio/publish/app-signing

## Görseller

`graphics/icon-512.png` 512×512 RGB mağaza simgesidir. `graphics/feature-1024x500.png` 1024×500 RGB tanıtım görselidir. İki `phone-*-web-preview.png` dosyası oyunun gerçek web arayüzünden alınmış, 376×720 boyutunda ekran görüntüsü taslaklarıdır. Fiziksel Android cihazından alınmış gibi sunulmaz; nihai mağaza görselleri Play test paketinin gerçek cihaz görüntüleriyle doğrulanmalıdır.
