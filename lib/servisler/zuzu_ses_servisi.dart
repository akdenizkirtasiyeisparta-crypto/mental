import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Hazır ses dosyası adları (assets/audio/ içinde).
/// Dosya varsa o çalınır; yoksa aynı metin telefonun Türkçe sesiyle okunur.
class Ses {
  static const hosGeldin = 'audio/hos_geldin.mp3';
  static const seniTaniyalim = 'audio/seni_taniyalim.mp3';
  static const profil = 'audio/profil.mp3';
  static const anaMenu = 'audio/ana_menu.mp3';
  static const tikla = 'audio/tikla.mp3';
  static const odul = 'audio/odul.mp3';
}

/// Zuzu'nun okuduğu metinler.
class ZuzuMetin {
  static const hosGeldin =
      'Merhaba! Online Mental Akademi\'ye hoş geldin! '
      'Zuzu ile birlikte öğrenmek çok eğlenceli!';
  static const seniTaniyalim =
      'Seni tanıyalım! Adını yaz, yaşını ve sınıfını seç.';
  static String profil(String ad) =>
      'Profilin oluşturuldu $ad! Hadi birlikte başlayalım!';
  static const anaMenu =
      'Hangi adaya gitmek istersin? Bir adaya dokun ve oyuna başla!';
}

class ZuzuSesServisi {
  ZuzuSesServisi._();
  static final ZuzuSesServisi instance = ZuzuSesServisi._();

  final AudioPlayer _konusma = AudioPlayer();
  final AudioPlayer _efekt = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsHazir = false;
  bool sesAcik = true;

  Future<void> _ttsHazirla() async {
    if (_ttsHazir) return;
    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.25); // biraz tiz, tavşan sesi gibi
      await _tts.awaitSpeakCompletion(true);
      _ttsHazir = true;
    } catch (e) {
      debugPrint('Sesli okuma hazırlanamadı: $e');
    }
  }

  Future<bool> _dosyaVar(String dosya) async {
    try {
      await rootBundle.load('assets/$dosya');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Zuzu konuşur. [dosya] varsa onu çalar, yoksa [metin]'i sesli okur.
  Future<void> konus({String? dosya, required String metin}) async {
    if (!sesAcik) return;
    try {
      await durdur();
      if (dosya != null && await _dosyaVar(dosya)) {
        await _konusma.play(AssetSource(dosya));
        await _konusma.onPlayerComplete.first
            .timeout(const Duration(seconds: 60));
        return;
      }
      await _ttsHazirla();
      await _tts.speak(metin);
    } catch (e) {
      debugPrint('Zuzu konuşamadı: $e');
    }
  }

  /// Kısa efekt (tıklama, ödül). Dosya yoksa sessiz kalır.
  Future<void> efekt(String dosya) async {
    if (!sesAcik) return;
    try {
      if (!await _dosyaVar(dosya)) return;
      await _efekt.stop();
      await _efekt.play(AssetSource(dosya));
    } catch (e) {
      debugPrint('Efekt çalınamadı: $e');
    }
  }

  Future<void> durdur() async {
    try {
      await _konusma.stop();
      await _efekt.stop();
      await _tts.stop();
    } catch (_) {}
  }
}
