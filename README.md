# Eyup Mert / Location Based Case

Konum tabanlı takip özelliği barındıran, MapKit destekli bir iOS örnek uygulamasıdır. Uygulama, kullanıcının konumunu izleyerek her 100 metrelik hareketinde haritaya bir işaretleyici (marker) ekler ve bu konum bilgilerini kalıcı olarak saklar. Uygulama hem ön planda hem de arka planda konum takibi yapabilir.

## 📌 Özellikler

- ✅ Kullanıcının konumunu takip eder
- ✅ Her 100 metrede bir haritaya marker ekler
- ✅ Marker’a tıklandığında adres bilgisi gösterilir
- ✅ Konum izleme başlatılıp durdurulabilir
- ✅ Rota sıfırlanabilir ve saklanan noktalar temizlenebilir
- ✅ Uygulama tekrar açıldığında önceki marker’lar haritada gösterilir
- ✅ Arka planda uyandırılma senaryosu loglanır
- ✅ MVVM mimarisi
- ✅ UIKit tabanlı yapı
- ✅ SwiftData ile kalıcı veri saklama
- ✅ Info.plist arka plan yetkileri yapılandırılmıştır

## 🧠 Mimari

- UIKit kullanılarak programatik arayüz tasarımı
- MVVM mimarisi
- MapKit ile harita gösterimi
- CLLocationManager ile hassas konum takibi
- SwiftData ile VisitPoint veri modelinin kalıcı saklanması
- LocationManager sınıfı ile tüm konum yönetimi merkezi olarak ele alındı
- Delegate + Enum Output ile ViewModel’den ViewController’a iletişim

## 🗺️ Konum Takip Süreci

1. Kullanıcı butonla takibi başlatır
2. LocationManager, sistemden izin isteyerek startUpdatingLocation() ile konumu izlemeye başlar
3. Her konum güncellemesi totalDistance metoduyla hesaplanır
4. 100 metreden fazla mesafe kat edilirse:
   - Haritaya marker eklenir
   - VisitPoint olarak SwiftData ile kalıcı olarak saklanır
5. Marker’a tıklanırsa adres bilgisi çözümlenir (reverse geocoding)

## 📦 Bağımlılıklar

- Swift 5.9+
- iOS 16+
- SwiftData (built-in)

## 🛠️ Info.plist Ayarları

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Our app needs your location permission to perform accurately.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Our app needs your location permission to perform accurately.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

## 🔄 Arka Planda Uyandırılma

Uygulama, startMonitoringSignificantLocationChanges() kullanımıyla arka planda konumdan dolayı sistem tarafından uyandırıldığında:

AppDelegate içindeki `application(_:didFinishLaunchingWithOptions:)` içinde `.location` kontrol edilir ve LocationWakeUpHandler tetiklenir.

## 👨‍💻 Geliştirici

**Eyüp Mert**  
Senior iOS Developer  
📫 [LinkedIn](https://www.linkedin.com/in/eyupmert)

## 📝 Notlar

- Simülatörde konum test etmek için: Features > Location > Freeway Drive
- Arka plan takibi test etmek için uygulamayı home tuşuyla ya da yukarı kaydırarak arkaya alın (kapamayın)
- Force quit durumunda arka plandan uyanış gerçekleşmez

## 🚀 Başlamak İçin

```bash
git clone https://github.com/eyupmert/eyupMertCase.git
open eyupMertCase.xcodeproj
```
