# Çevrimiçi yarış kurulumu

1. Supabase panelinde `color-chain-game` projesini oluştur.
2. Authentication → Providers → Anonymous Sign-Ins seçeneğini etkinleştir.
3. SQL Editor'da `migrations/001_competition.sql` içeriğini çalıştır.
4. Edge Functions'ta `competition` fonksiyonunu oluştur. Bu klasördeki `functions/competition/index.ts` ve `replay.ts` dosyalarını ekle. Supabase URL ve service role anahtarı fonksiyon ortamında kalır. JWT gateway doğrulamasını kapat; fonksiyon her isteği `auth.getUser` ile kendisi doğrular.
5. Projenin URL'sini ve **publishable/anon** anahtarını depo kökündeki `competition.json` dosyasına koy. Service role veya secret anahtarını oyuna koyma.
6. Oyunda günlük yarışı bitirip Haftalık lige gönder düğmesine bas. İkinci cihazla aynı grupta sonuçların görüntülendiğini doğrula.

Ligler 20 kişilik gruplara ayrılır. Günlük en iyi puanlar haftalık toplamı oluşturur. Haftalar Pazartesi UTC başlar; ilk 5 sonraki katılımında Bronz → Gümüş → Altın → Elmas ilerler. Eşit puanlar oyuncu kimliğiyle kararlı sıralanır. Lig üyeliği işlem kilidi altında atanır. Hamle geçmişi sunucuda tekrar oynatılır, gönderilen puan sayısına güvenilmez. Yalnızca o günün 20 hamlesi kabul edilir. Tarayıcıdaki oturum silinirse anonim oyuncu kimliği değişir.

Veritabanı tabloları RLS ile istemci erişimine kapalıdır. Edge Function doğrulanmış kullanıcı kimliğiyle servis rolünü kullanır. Üretimde anonim kayıt için CAPTCHA ve istek hız sınırı eklenmelidir. Lig ödülleri şu an yükselme ve rozetlerdir; istemci kristalleri çevrimiçi para birimi değildir.

Hesap/proje bağlantısı tamamlanana kadar oyun açıkça bağlantı olmadığını gösterir; yerel skorları çevrimiçi oyuncu sıralaması olarak sunmaz.
