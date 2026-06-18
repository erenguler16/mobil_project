# EcoToken Mobil Uygulaması

EcoToken, bireylerin günlük çevre dostu aktivitelerini takip etmelerini sağlayan ve bu süreci oyunlaştırarak (gamification) kullanıcı motivasyonunu artıran bir mobil uygulamadır. Kullanıcılar gerçekleştirdikleri eylemleri doğrular, EcoToken kazanır ve global sıralamada rekabet eder.

---

## 🚀 Proje Özeti
Sürdürülebilirlik uygulamalarındaki "sıkıcı veri girişi" problemini çözmek amacıyla geliştirilen EcoToken; kullanıcıların sağladığı karbon ve enerji tasarrufunu anlık olarak hesaplar. Klasik istatistik ekranları yerine, kullanıcının ilerlemesine göre şekillenen dinamik bir harita ve arayüz sunar.

## ✨ Temel Özellikler

- **Aktivite Doğrulama ve Hesaplama:** Güneş enerjisi, rüzgar enerjisi veya geri dönüşüm gibi aktiviteler sisteme girilir. Yüklenen kanıt görselleri üzerinden analiz simülasyonu yapılarak kazanılan kWh enerji ve TL tasarrufu otomatik hesaplanır.
- **Oyunlaştırılmış Harita Yapısı:** Standart alt alta listeler yerine, `CustomPaint` kullanılarak matematiksel eğrilerle (Bezier) çizilmiş, interaktif ve kıvrımlı bir harita (Snake Path) tasarımı mevcuttur.
- **Dinamik Gelişim Ekranı:** Kullanıcının uygulamadaki karbon tasarruf puanı arttıkça (örneğin 50 kg, 200 kg sınırları geçildikçe) ekranın arka planı ve teması değişir. Kötü endüstriyel bir manzaradan, temiz bir doğaya doğru görsel bir geçiş sağlanır.
- **Karanlık/Aydınlık Mod Adaptasyonu:** UI/UX tasarımı cihazın temasıyla tam entegredir. Karanlık modda göz yormayan özel gri tonları ve şeffaflık (opacity) ayarları kullanılarak arayüz bozulmaları engellenmiştir.
- **Sanal Ekonomi ve Sıralama:** Kullanıcıların kazandığı EcoToken'lar gerçek zamanlı olarak liderlik tablosuna yansır ve uygulama içi markette sergilenir.

---

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Kullanım Amacı |
| :--- | :--- |
| **Flutter & Dart SDK** | Cross-Platform (iOS/Android) mobil uygulama geliştirme |
| **Firebase Cloud Firestore** | Kullanıcı verilerinin ve puanlarının gerçek zamanlı veritabanı yönetimi |
| **Firebase Authentication** | Güvenli kullanıcı kaydı ve oturum açma işlemleri |
| **CustomPaint** | Harita arayüzündeki özel grafik ve yol çizimleri |
| **Image Picker** | Cihaz galerisinden aktivite kanıt görsellerinin alınması |

---

## 📁 Proje Mimarisi (Feature-Driven)

Kod karmaşasını önlemek ve sürdürülebilirliği artırmak için projede modüler klasör yapısı kullanılmıştır:

```text
lib/
├── auth/            # Kullanıcı giriş ve kayıt ekranları
├── map/             # Oyunlaştırılmış harita ve dinamik arka plan ekranları
├── rewards/         # Başarımlar, market ve liderlik tablosu
├── home/            # Veri giriş paneli ve simülasyon (Action Screen)
├── widgets/         # Proje genelinde tekrar kullanılan UI bileşenleri
└── app_state.dart   # State yönetimi ve Firebase veri senkronizasyonu
