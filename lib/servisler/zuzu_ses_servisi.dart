import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Zuzu'nun hazır ses dosyalarını çalar.
/// Ses dosyalarını assets/sesler/ klasörüne koy. Adları farklıysa
/// aşağıdaki [Ses] listesindeki dosya adlarını değiştirmen yeterli.
class Ses {
  static const hosGeldin = 'sesler/hos_geldin.mp3';
  static const profil = 'sesler/profil.mp3';
  static const tikla = 'sesler/tikla.mp3';
  static const odul = 'sesler/odul.mp3';
}

class ZuzuSesServisi {
  ZuzuSesServisi._();
  static final ZuzuSesServisi instance = ZuzuSesServisi._();

  final AudioPlayer _konusma = AudioPlayer();
  final AudioPlayer _efekt = AudioPlayer();
  bool sesAcik = true;

  /// Zuzu'nun konuşması: bitene kadar bekler. Dosya yoksa sessizce geçer.
  Future<void> konus(String dosya) async {
    if (!sesAcik) return;
    try {
      await _konusma.stop();
      await _konusma.play(AssetSource(dosya));
      await _konusma.onPlayerComplete.first
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint('Zuzu sesi çalınamadı ($dosya): $e');
    }
  }

  /// Kısa efekt (tıklama, ödül). Beklemez.
  Future<void> efekt(String dosya) async {
    if (!sesAcik) return;
    try {
      await _efekt.stop();
      await _efekt.play(AssetSource(dosya));
    } catch (e) {
      debugPrint('Efekt çalınamadı ($dosya): $e');
    }
  }

  Future<void> durdur() async {
    await _konusma.stop();
    await _efekt.stop();
  }
}
