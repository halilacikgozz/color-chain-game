# Oyun incelemesi — 10 Ekim 2026

Uygulananlar: Türkçe karakter destekli benzersiz oyuncu adı, ligde ad gösterimi, hamlesiz tur sonuç ekranı, gökkuşağına duyarlı gerçek hamle kontrolü, günlük yarışın eski sürümlerle uyumlu sunucu doğrulaması, lig yanıtında ekran yenileme, animasyon tercihinin saklanması, bölüm sonucunda kalan hedeflerin doğru gösterimi.

## Öncelikli öneriler

1. **Hesap kurtarma:** Kullanıcı adı anonim cihaz kimliğine bağlıdır; giriş yöntemi değildir. Uygulama silinince veya cihaz değişince oyuncu kimliği ve yerel ilerleme geri gelmez. E-posta/Google ile isteğe bağlı hesap bağlama ve bulut ilerleme kaydı önerilir.
2. **Ödülleri sadeleştirme:** Profil yıldızları, bölüm yıldızları, deneyim ve kristaller birlikte fazla kavram oluşturuyor. Bölüm yıldızları ile deneyimi koruyup genel yıldız göstergesini kaldırmak değerlendirilebilir. Koleksiyon görünümleri ile temalar tek görünüm ekranında birleşebilir.
3. **Rekabeti açıklama:** Haftalık lig yalnızca günlük en iyi skorların toplamını kullanır. Serbest oyun puanlarının lige eklenmediği başlangıç ekranında açık olmalı. Günün UTC sınırı Türkiye saatiyle 03:00; geri sayım ve gün değişimi bildirimi faydalı.
4. **Bölüm dengesi:** Sabit açılışları kullanan otomatik strateji 8. ve 18. bölümde hamlesiz kalabiliyor. Bu, bütün stratejilerin çözümsüz olduğu anlamına gelmez. Fiziksel oyuncu denemeleriyle zorluk ayarlanmalı; isteğe bağlı bir defalık karıştırma yalnızca bölüm modunda düşünülebilir.
5. **Android deneyimi:** Fiziksel telefonda klavye, sistem geri tuşu, düşük bellek ve kare süresi kontrol edilmeli. Önce 5–10 dakikalık orta seviye telefon testi yapılmalı. APK test imzası Actions önbelleğinde tutuluyor; kalıcı özel imza yedeği oluşturulmalı.
6. **Ad güvenliği:** Benzersizlik ve biçim denetimi var; isim moderasyonu, raporlama ve ad değiştirme sıklığı sınırı henüz yok.
7. **Sunucu dayanıklılığı:** İnternet gidince günlük gönderim sonucu saklanıp yeniden denenmeli. Sunucu son günün UTC tarihini kabul ediyor; gece sınırında eski gün turunun gönderilmesi reddedilebilir.

## Doğrulama kapsamı

Godot otomatik kurallar ve 30 bölüm koşumları, günlük puan tekrar hesaplama, kullanıcı adı biçimi, gökkuşağı hamle kontrolü ve otomatik başlamayan sonuç ekranı kontrolleri. Bölüm koşumları kazanma veya gerçekten hamlesiz sonuçlanmayı kontrol eder; her bölümü insan gibi oynayarak bitirme garantisi vermez. Fiziksel Android performansı bu ortamda doğrulanamaz.

Önerilen kaldırmalar bu inceleme kapsamında uygulanmadı.
