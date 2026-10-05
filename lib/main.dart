import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'servisler/zuzu_ses_servisi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const OnlineMentalAkademi());
}

class OnlineMentalAkademi extends StatelessWidget {
  const OnlineMentalAkademi({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Online Mental Akademi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF852BE8)),
        ),
        home: const AcilisEkrani(),
      );
}

// ---------------------------------------------------------------------------
// RENKLER
// ---------------------------------------------------------------------------
const kMor = Color(0xFF8139D5);
const kKahve = Color(0xFF6B3A12);
const kCerceve = Color(0xFFC98A3E);
const kMavi = Color(0xFF1646C7);

// ---------------------------------------------------------------------------
// OYUNCU VERİSİ (şimdilik bellekte tutulur)
// ---------------------------------------------------------------------------
class Oyuncu {
  Oyuncu._();
  static final Oyuncu instance = Oyuncu._();

  String ad = '';
  int yas = 0;
  String sinif = '';
  final ValueNotifier<int> puan = ValueNotifier<int>(250);
  final Set<String> alinanGorevler = {};
}

class Gorev {
  final String id, baslik, aciklama;
  final int hedef, ilerleme, odul;
  const Gorev(this.id, this.baslik, this.aciklama, this.hedef, this.ilerleme,
      this.odul);
}

const gorevListesi = [
  Gorev('g1', 'Günlük Başlangıç', 'Bugün 1 oyun oyna', 1, 1, 20),
  Gorev('g2', 'Matematik Kaşifi', 'Matematik Adası\'nda 3 soru çöz', 3, 2, 30),
  Gorev('g3', 'Dikkat Avcısı', 'Dikkat Adası\'nda 5 hedefi bul', 5, 5, 40),
  Gorev('g4', 'Hız Ustası', 'Hız Adası\'nda 2 oyun bitir', 2, 0, 50),
];

class Basari {
  final String baslik, aciklama;
  final IconData ikon;
  final int hedef, ilerleme;
  const Basari(this.baslik, this.aciklama, this.ikon, this.hedef, this.ilerleme);
}

const basariListesi = [
  Basari('İlk Adım', 'İlk oyununu tamamla', Icons.flag_rounded, 1, 1),
  Basari('Soru Avcısı', '50 soru çöz', Icons.quiz_rounded, 50, 18),
  Basari('Seri Oyuncu', '5 gün üst üste gir', Icons.local_fire_department_rounded,
      5, 2),
  Basari('Yıldız Toplayıcı', '500 puana ulaş', Icons.star_rounded, 500, 250),
];

class Rozet {
  final String ad;
  final IconData ikon;
  final Color renk;
  final int gerekenPuan;
  const Rozet(this.ad, this.ikon, this.renk, this.gerekenPuan);
}

const rozetListesi = [
  Rozet('Minik Kaşif', Icons.explore_rounded, Color(0xFF29B6F6), 0),
  Rozet('Dikkat Ustası', Icons.track_changes_rounded, Color(0xFFE53935), 100),
  Rozet('Matematik Dehası', Icons.calculate_rounded, Color(0xFF1E88E5), 200),
  Rozet('Mantık Kralı', Icons.extension_rounded, Color(0xFFFFB300), 400),
  Rozet('Hız Şampiyonu', Icons.bolt_rounded, Color(0xFF8E3FE0), 600),
  Rozet('Zuzu\'nun Dostu', Icons.favorite_rounded, Color(0xFFE040B8), 1000),
];

// ---------------------------------------------------------------------------
// SAHNE: görseli kendi gerçek oranında ekrana sığdırır (bozmadan), artan
// kenarları aynı görselin bulanık hâliyle doldurur. Yazı/buton konumları
// görselin kendisine göre oran olarak verilir.
//
// kGorselOrani   : acilis, hos_geldin, seni_taniyalim, profil görselleri (2000x900)
// kAnaMenuOrani  : ana_menu görseli (1670x942)
// Görsellerin boyutu farklıysa buradaki sayıları değiştir.
// ---------------------------------------------------------------------------
const double kGorselOrani = 2000 / 900;
const double kAnaMenuOrani = 1670 / 942;

class Sahne extends StatelessWidget {
  final String arkaPlan;
  final double gorselOrani;
  final List<Widget> Function(BuildContext context, double w, double h)
      katmanlar;

  const Sahne({
    super.key,
    required this.arkaPlan,
    required this.katmanlar,
    this.gorselOrani = kGorselOrani,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final sw = c.maxWidth, sh = c.maxHeight;
          double bw = sw, bh = sw / gorselOrani;
          if (bh > sh) {
            bh = sh;
            bw = sh * gorselOrani;
          }
          final left = (sw - bw) / 2, top = (sh - bh) / 2;

          return ColoredBox(
            color: const Color(0xFF18BFF2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Image.asset(arkaPlan,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  ),
                ),
                Positioned(
                  left: left,
                  top: top,
                  width: bw,
                  height: bh,
                  child: Image.asset(
                    arkaPlan,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text('Görsel bulunamadı:\n$arkaPlan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                Positioned(
                  left: left,
                  top: top,
                  width: bw,
                  height: bh,
                  child: Stack(
                      clipBehavior: Clip.none, children: katmanlar(context, bw, bh)),
                ),
              ],
            ),
          );
        },
      );
}

/// Dokununca hafifçe küçülen sarmalayıcı (tıklama sesi de çalar).
class Basilabilir extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool ses;
  const Basilabilir({super.key, required this.child, this.onTap, this.ses = true});

  @override
  State<Basilabilir> createState() => _BasilabilirState();
}

class _BasilabilirState extends State<Basilabilir> {
  bool _basili = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _basili = true),
        onTapUp: (_) => setState(() => _basili = false),
        onTapCancel: () => setState(() => _basili = false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.ses) ZuzuSesServisi.instance.efekt(Ses.tikla);
                widget.onTap!();
              },
        child: AnimatedScale(
          scale: _basili ? .94 : 1,
          duration: const Duration(milliseconds: 90),
          child: widget.child,
        ),
      );
}

ButtonStyle morButon(double h) => ElevatedButton.styleFrom(
      backgroundColor: kMor,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(h * .05),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
    );

// ===========================================================================
// 1. AÇILIŞ
// ===========================================================================
class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});
  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _yukleme;
  bool _gecildi = false;

  @override
  void initState() {
    super.initState();
    _yukleme = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..addStatusListener((durum) {
        if (durum == AnimationStatus.completed && mounted && !_gecildi) {
          _gecildi = true;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HosGeldinEkrani(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 700),
            ),
          );
        }
      });
    _yukleme.forward();
  }

  @override
  void dispose() {
    _yukleme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/acilis.png',
          katmanlar: (context, w, h) => [
            Positioned(
              left: w * .185,
              top: h * .855,
              width: w * .42,
              height: h * .125,
              child: AnimatedBuilder(
                animation: _yukleme,
                builder: (_, __) => Container(
                  padding: EdgeInsets.symmetric(horizontal: w * .015, vertical: h * .01),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, .55),
                    borderRadius: BorderRadius.circular(h * .04),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: h * .04),
                          SizedBox(width: w * .008),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text('Zuzu dünyası hazırlanıyor...',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: h * .034)),
                            ),
                          ),
                          Text('%${(_yukleme.value * 100).round()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: h * .034)),
                        ],
                      ),
                      SizedBox(height: h * .01),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _yukleme.value,
                          minHeight: h * .022,
                          backgroundColor: Colors.white54,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

// ===========================================================================
// 2. HOŞ GELDİN  (hos_geldin.mp3 burada çalar)
// ===========================================================================
class HosGeldinEkrani extends StatefulWidget {
  const HosGeldinEkrani({super.key});
  @override
  State<HosGeldinEkrani> createState() => _HosGeldinEkraniState();
}

class _HosGeldinEkraniState extends State<HosGeldinEkrani> {
  bool _konusuyor = false;
  String _sesDurumu = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _zuzuKonussun());
  }

  Future<void> _zuzuKonussun() async {
    if (_konusuyor || !mounted) return;
    setState(() => _konusuyor = true);
    final durum = await ZuzuSesServisi.instance.konus(
        dosya: Ses.hosGeldin, metin: ZuzuMetin.hosGeldin);
    debugPrint('SES DURUMU: $durum');
    if (mounted) {
      setState(() {
        _konusuyor = false;
        _sesDurumu = durum;
      });
    }
  }

  @override
  void dispose() {
    ZuzuSesServisi.instance.durdur();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/hos_geldin.png',
          katmanlar: (context, w, h) => [
            // GEÇİCİ TANI: ses durumunu gösterir ve Ses Testi'ne götürür
            Positioned(
              left: w * .01,
              top: h * .02,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SesTestSayfasi())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ses Testi ▶  ${_sesDurumu.isEmpty ? "..." : _sesDurumu}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            Positioned(
              left: w * .02,
              bottom: h * .03,
              width: h * .10,
              height: h * .10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(side: BorderSide(color: kMor, width: 3)),
                elevation: 5,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _konusuyor ? null : _zuzuKonussun,
                  child: Icon(Icons.volume_up_rounded,
                      size: h * .06, color: _konusuyor ? Colors.grey : kMor),
                ),
              ),
            ),
            Positioned(
              left: w * .64,
              top: h * .875,
              width: w * .25,
              height: h * .09,
              child: ElevatedButton.icon(
                onPressed: () {
                  ZuzuSesServisi.instance.durdur();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BilgiGirisiEkrani()));
                },
                icon: Icon(Icons.arrow_forward_rounded, size: h * .05),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Devam Edelim',
                      style: TextStyle(fontSize: h * .042, fontWeight: FontWeight.w900)),
                ),
                style: morButon(h),
              ),
            ),
          ],
        ),
      );
}

// ===========================================================================
// 3. SENİ TANIYALIM
// ===========================================================================
class BilgiGirisiEkrani extends StatefulWidget {
  const BilgiGirisiEkrani({super.key});
  @override
  State<BilgiGirisiEkrani> createState() => _BilgiGirisiEkraniState();
}

class _BilgiGirisiEkraniState extends State<BilgiGirisiEkrani> {
  final _adController = TextEditingController();
  int? _yas;
  String? _sinif;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ZuzuSesServisi.instance.konus(
            dosya: Ses.seniTaniyalim, metin: ZuzuMetin.seniTaniyalim));
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  void _devamEt() {
    FocusScope.of(context).unfocus();
    final ad = _adController.text.trim();
    if (ad.isEmpty || _yas == null || _sinif == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen adını, yaşını ve sınıfını seç.')),
      );
      return;
    }
    final o = Oyuncu.instance;
    o.ad = ad;
    o.yas = _yas!;
    o.sinif = _sinif!;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilEkrani()));
  }

  Widget _etiket(String yazi) => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(yazi,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kKahve)),
        ),
      );

  InputDecoration _alan({Widget? ikon, String? ipucu}) => InputDecoration(
        hintText: ipucu,
        hintStyle: const TextStyle(fontSize: 22, color: Colors.black38),
        prefixIcon: ikon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kCerceve, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kMor, width: 3),
        ),
      );

  static const _yaziStili =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kKahve);

  @override
  Widget build(BuildContext context) {
    final klavye = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: klavye * .55),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, kayma, child) =>
              Transform.translate(offset: Offset(0, -kayma), child: child),
          child: Sahne(
            arkaPlan: 'assets/images/seni_taniyalim.png',
            katmanlar: (context, w, h) => [
              Positioned(
                left: w * .142,
                top: h * .365,
                width: w * .500,
                height: h * .40,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 780,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _etiket('Adın ve soyadın'),
                        TextField(
                          controller: _adController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          style: _yaziStili,
                          cursorColor: kMor,
                          decoration: _alan(
                            ipucu: 'Adını yaz',
                            ikon: const Icon(Icons.person_rounded, size: 30, color: kMor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(children: [
                                _etiket('Yaşın'),
                                DropdownButtonFormField<int>(
                                  initialValue: _yas,
                                  isExpanded: true,
                                  style: _yaziStili,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  decoration: _alan(ipucu: 'Seç'),
                                  items: List.generate(13, (i) => i + 4)
                                      .map((v) => DropdownMenuItem(value: v, child: Text('$v yaş')))
                                      .toList(),
                                  onChanged: (v) => setState(() => _yas = v),
                                ),
                              ]),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(children: [
                                _etiket('Sınıfın'),
                                DropdownButtonFormField<String>(
                                  initialValue: _sinif,
                                  isExpanded: true,
                                  style: _yaziStili,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  decoration: _alan(ipucu: 'Seç'),
                                  items: const [
                                    'Okul öncesi',
                                    '1. sınıf',
                                    '2. sınıf',
                                    '3. sınıf',
                                    '4. sınıf',
                                  ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                  onChanged: (v) => setState(() => _sinif = v),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 380,
                          height: 62,
                          child: ElevatedButton.icon(
                            onPressed: _devamEt,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 30),
                            label: const Text('Profilimi Oluştur'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kMor,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              textStyle:
                                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(31),
                                side: const BorderSide(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 4. PROFİL OLUŞTURULDU  (profil.mp3 burada çalar)
// ===========================================================================
class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});
  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ZuzuSesServisi.instance
        .konus(
        dosya: Ses.profil, metin: ZuzuMetin.profil(Oyuncu.instance.ad)));
  }

  @override
  void dispose() {
    ZuzuSesServisi.instance.durdur();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/profil.png',
          katmanlar: (context, w, h) {
            final d = h * .35;
            return [
              Positioned(
                left: w * .4054 - d / 2,
                top: h * .5075 - d / 2,
                width: d,
                height: d,
                child: const ZuzuYuzu(),
              ),
              Positioned(
                left: w * .278,
                top: h * .697,
                width: w * .248,
                height: h * .075,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Oyuncu.instance.ad,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: h * .05,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF71330F))),
                  ),
                ),
              ),
              Positioned(
                left: w * .2804,
                top: h * .875,
                width: w * .25,
                height: h * .09,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ZuzuSesServisi.instance.durdur();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AnaMenuEkrani()));
                  },
                  icon: Icon(Icons.play_arrow_rounded, size: h * .06),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Başlayalım!',
                        style: TextStyle(fontSize: h * .045, fontWeight: FontWeight.w900)),
                  ),
                  style: morButon(h),
                ),
              ),
            ];
          },
        ),
      );
}

/// Yuvarlak içinde Zuzu'nun yüzü.
class ZuzuYuzu extends StatelessWidget {
  const ZuzuYuzu({super.key});

  @override
  Widget build(BuildContext context) => ClipOval(
        child: Image.asset(
          'assets/images/zuzu_yuz.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/zuzu.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -.85),
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFFFF1D6),
              child: const Icon(Icons.pets_rounded, size: 48, color: kMor),
            ),
          ),
        ),
      );
}

// ===========================================================================
// 5. ANA MENÜ
// Görsel (ana_menu.png) adalar, başlık, puan, zil, ayarlar, Zuzu ve alt
// butonların hepsini zaten içerir. Biz üstüne görünmez dokunma alanları
// koyuyoruz ve boş isim kutusuna çocuğun adını yazıyoruz.
// ===========================================================================
class AnaMenuEkrani extends StatefulWidget {
  const AnaMenuEkrani({super.key});
  @override
  State<AnaMenuEkrani> createState() => _AnaMenuEkraniState();
}

class _AnaMenuEkraniState extends State<AnaMenuEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ZuzuSesServisi.instance.konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu));
  }

  @override
  void dispose() {
    ZuzuSesServisi.instance.durdur();
    super.dispose();
  }

  // Görsel koordinatları (1670x942) -> oran
  static const double _gw = 1670, _gh = 942;

  Widget _alan(double w, double h, double x, double y, double ww, double hh,
      VoidCallback onTap,
      {Widget? child, String ipucu = ''}) {
    return Positioned(
      left: w * x / _gw,
      top: h * y / _gh,
      width: w * ww / _gw,
      height: h * hh / _gh,
      child: Basilabilir(
        onTap: onTap,
        child: Semantics(
          label: ipucu,
          button: true,
          child: child ?? const SizedBox.expand(),
        ),
      ),
    );
  }

  void _git(Widget sayfa) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => sayfa));

  void _ada(String ad) {
    showDialog(
      context: context,
      builder: (_) => ZuzuDiyalog(
        baslik: ad,
        mesaj: 'Bu ada çok yakında açılıyor! Zuzu seni burada bekliyor.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/ana_menu.png',
          gorselOrani: kAnaMenuOrani,
          katmanlar: (context, w, h) => [
            // Boş isim kutusuna çocuğun adı
            Positioned(
              left: w * 152 / _gw,
              top: h * 58 / _gh,
              width: w * 160 / _gw,
              height: h * 64 / _gh,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: w * .006),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Oyuncu.instance.ad,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: h * .04,
                            fontWeight: FontWeight.w900,
                            color: kMavi)),
                  ),
                ),
              ),
            ),
            // Puan: görseldeki sabit 250'yi örter ve gerçek puanı yazar
            Positioned(
              left: w * 1340 / _gw,
              top: h * 40 / _gh,
              width: w * 92 / _gw,
              height: h * 58 / _gh,
              child: ValueListenableBuilder<int>(
                valueListenable: Oyuncu.instance.puan,
                builder: (_, p, __) => Container(
                  alignment: Alignment.centerLeft,
                  color: const Color(0xFFF4F9FF),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('$p',
                        style: TextStyle(
                            fontSize: h * .05,
                            fontWeight: FontWeight.w900,
                            color: kMavi)),
                  ),
                ),
              ),
            ),

            // Profil
            _alan(w, h, 35, 30, 285, 120, () => _git(const ProfilSayfasi()),
                ipucu: 'Profil'),
            // Bildirim / Ayarlar
            _alan(w, h, 1458, 28, 84, 80, () => _git(const BildirimSayfasi()),
                ipucu: 'Bildirimler'),
            _alan(w, h, 1562, 28, 84, 80, () => _git(const AyarlarSayfasi()),
                ipucu: 'Ayarlar'),

            // Adalar
            _alan(w, h, 135, 330, 335, 255, () => _ada('Dikkat Adası'),
                ipucu: 'Dikkat Adası'),
            _alan(w, h, 475, 330, 290, 300, () => _ada('Zuzu Adası'),
                ipucu: 'Zuzu Adası'),
            _alan(w, h, 760, 372, 280, 293, () => _ada('Matematik Adası'),
                ipucu: 'Matematik Adası'),
            _alan(w, h, 1035, 330, 285, 310, () => _ada('Mantık Adası'),
                ipucu: 'Mantık Adası'),
            _alan(w, h, 1310, 330, 325, 270, () => _ada('Hız Adası'),
                ipucu: 'Hız Adası'),

            // Alt butonlar
            _alan(w, h, 472, 757, 283, 95, () => _git(const BasarilarimSayfasi()),
                ipucu: 'Başarılarım'),
            _alan(w, h, 772, 757, 283, 95, () => _git(const GorevlerSayfasi()),
                ipucu: 'Görevler'),
            _alan(w, h, 1073, 757, 292, 95, () => _git(const RozetlerSayfasi()),
                ipucu: 'Rozetler'),

            // Zuzu'ya dokununca konuşur
            _alan(w, h, 0, 470, 430, 470,
                () => ZuzuSesServisi.instance
                    .konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu),
                ipucu: 'Zuzu'),
          ],
        ),
      );
}

// ===========================================================================
// ORTAK: TEMALI SAYFA ÇERÇEVESİ (bulanık ada manzarası + ahşap başlık + Zuzu)
// ===========================================================================
class TemaSayfa extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final Widget Function(double w, double h) icerik;

  const TemaSayfa({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.icerik,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/ana_menu.png',
          gorselOrani: kAnaMenuOrani,
          katmanlar: (context, w, h) => [
            // Görseldeki menüyü örten yarı saydam kum rengi tahta panel
            Positioned.fill(
              child: Container(
                color: const Color.fromRGBO(10, 90, 160, .55),
              ),
            ),
            // Panel
            Positioned(
              left: w * .08,
              top: h * .17,
              width: w * .84,
              height: h * .76,
              child: Container(
                padding: EdgeInsets.all(h * .03),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DC),
                  borderRadius: BorderRadius.circular(h * .05),
                  border: Border.all(color: kCerceve, width: h * .012),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: h * .05),
                  child: icerik(w, h),
                ),
              ),
            ),
            // Başlık tahtası
            Positioned(
              left: w * .30,
              top: h * .06,
              width: w * .40,
              height: h * .15,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF2AE5A), Color(0xFFD4822F)],
                  ),
                  borderRadius: BorderRadius.circular(h * .05),
                  border: Border.all(color: const Color(0xFFFFF1D0), width: h * .008),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(ikon, color: Colors.white, size: h * .08),
                        SizedBox(width: w * .01),
                        Text(baslik,
                            style: TextStyle(
                                fontSize: h * .075,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Color(0xFF8F4A14), blurRadius: 0, offset: Offset(2, 3)),
                                ])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Geri butonu
            Positioned(
              left: w * .02,
              top: h * .04,
              width: h * .12,
              height: h * .12,
              child: Basilabilir(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: kMor, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: h * .075, color: kMor),
                ),
              ),
            ),
            // Puan rozeti (sağ üst)
            Positioned(
              right: w * .02,
              top: h * .05,
              child: const PuanRozeti(),
            ),
          ],
        ),
      );
}

class PuanRozeti extends StatelessWidget {
  const PuanRozeti({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: Oyuncu.instance.puan,
        builder: (_, p, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFB8D9FF), width: 3),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 30),
            const SizedBox(width: 6),
            Text('$p',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, color: kMavi)),
          ]),
        ),
      );
}

/// Sayfa içinde kullanılan beyaz kart.
class Kart extends StatelessWidget {
  final Widget child;
  final Color? renk;
  const Kart({super.key, required this.child, this.renk});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: renk ?? Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4C48A), width: 2.5),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      );
}

class ZuzuDiyalog extends StatelessWidget {
  final String baslik, mesaj;
  const ZuzuDiyalog({super.key, required this.baslik, required this.mesaj});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DC),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: kCerceve, width: 5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 80, height: 80, child: ZuzuYuzu()),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900, color: kMor)),
                    const SizedBox(height: 6),
                    Text(mesaj,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: kKahve)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kMor, foregroundColor: Colors.white),
                        child: const Text('Tamam',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ===========================================================================
// PROFİL SAYFASI
// ===========================================================================
class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  Widget _bilgi(IconData ikon, String etiket, String deger, Color renk) => Kart(
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: renk,
            child: Icon(ikon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiket,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black54)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(deger,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900, color: kKahve)),
                ),
              ],
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final o = Oyuncu.instance;
    return TemaSayfa(
      baslik: 'Profilim',
      ikon: Icons.person_rounded,
      icerik: (w, h) {
        final acilan =
            rozetListesi.where((r) => o.puan.value >= r.gerekenPuan).length;
        return Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: h * .30,
                    height: h * .30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kMor, width: 6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: const ZuzuYuzu(),
                  ),
                  SizedBox(height: h * .02),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(o.ad.isEmpty ? 'Misafir' : o.ad,
                        style: TextStyle(
                            fontSize: h * .07, fontWeight: FontWeight.w900, color: kMor)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _bilgi(Icons.cake_rounded, 'Yaşım',
                      o.yas == 0 ? '-' : '${o.yas}', const Color(0xFFE040B8)),
                  _bilgi(Icons.school_rounded, 'Sınıfım',
                      o.sinif.isEmpty ? '-' : o.sinif, const Color(0xFF1E88E5)),
                  _bilgi(Icons.star_rounded, 'Puanım', '${o.puan.value}',
                      const Color(0xFFFFB300)),
                  _bilgi(Icons.workspace_premium_rounded, 'Rozetlerim',
                      '$acilan / ${rozetListesi.length}', const Color(0xFF8E3FE0)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// BAŞARILARIM
// ===========================================================================
class BasarilarimSayfasi extends StatelessWidget {
  const BasarilarimSayfasi({super.key});

  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Başarılarım',
        ikon: Icons.emoji_events_rounded,
        icerik: (w, h) => ListView.separated(
          itemCount: basariListesi.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final b = basariListesi[i];
            final tamam = b.ilerleme >= b.hedef;
            final oran = (b.ilerleme / b.hedef).clamp(0.0, 1.0);
            return Kart(
              renk: tamam ? const Color(0xFFFFF8D6) : Colors.white,
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      tamam ? const Color(0xFFFFB300) : Colors.grey.shade400,
                  child: Icon(b.ikon, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.baslik,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w900, color: kKahve)),
                      Text(b.aciklama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: oran,
                          minHeight: 14,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(
                              tamam ? const Color(0xFF43A047) : const Color(0xFFFFA500)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                tamam
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF43A047), size: 44)
                    : Text('${b.ilerleme}/${b.hedef}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: kMavi)),
              ]),
            );
          },
        ),
      );
}

// ===========================================================================
// GÖREVLER
// ===========================================================================
class GorevlerSayfasi extends StatefulWidget {
  const GorevlerSayfasi({super.key});
  @override
  State<GorevlerSayfasi> createState() => _GorevlerSayfasiState();
}

class _GorevlerSayfasiState extends State<GorevlerSayfasi> {
  void _oduluAl(Gorev g) {
    final o = Oyuncu.instance;
    o.alinanGorevler.add(g.id);
    o.puan.value += g.odul;
    ZuzuSesServisi.instance.efekt(Ses.odul);
    setState(() {});
    showDialog(
      context: context,
      builder: (_) => ZuzuDiyalog(
        baslik: 'Harika!',
        mesaj: '${g.odul} puan kazandın!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Görevler',
        ikon: Icons.assignment_rounded,
        icerik: (w, h) => ListView.separated(
          itemCount: gorevListesi.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final g = gorevListesi[i];
            final bitti = g.ilerleme >= g.hedef;
            final alindi = Oyuncu.instance.alinanGorevler.contains(g.id);
            return Kart(
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: bitti ? const Color(0xFFFF8A00) : Colors.grey.shade400,
                  child: const Icon(Icons.assignment_turned_in_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.baslik,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w900, color: kKahve)),
                      Text(g.aciklama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (g.ilerleme / g.hedef).clamp(0.0, 1.0),
                          minHeight: 14,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA500)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  height: 56,
                  child: alindi
                      ? const Center(
                          child: Icon(Icons.check_circle_rounded,
                              color: Color(0xFF43A047), size: 44))
                      : ElevatedButton.icon(
                          onPressed: bitti ? () => _oduluAl(g) : null,
                          icon: const Icon(Icons.star_rounded),
                          label: Text('+${g.odul}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                        ),
                ),
              ]),
            );
          },
        ),
      );
}

// ===========================================================================
// ROZETLER
// ===========================================================================
class RozetlerSayfasi extends StatelessWidget {
  const RozetlerSayfasi({super.key});

  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Rozetler',
        ikon: Icons.workspace_premium_rounded,
        icerik: (w, h) => ValueListenableBuilder<int>(
          valueListenable: Oyuncu.instance.puan,
          builder: (_, puan, __) => GridView.builder(
            itemCount: rozetListesi.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (_, i) {
              final r = rozetListesi[i];
              final acik = puan >= r.gerekenPuan;
              return Kart(
                renk: acik ? Colors.white : const Color(0xFFEDEDED),
                child: Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: acik ? r.renk : Colors.grey.shade500,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Icon(acik ? r.ikon : Icons.lock_rounded,
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(r.ad,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: acik ? kKahve : Colors.black45)),
                        ),
                        Text(acik ? 'Kazandın!' : '${r.gerekenPuan} puan',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: acik ? const Color(0xFF43A047) : Colors.black45)),
                      ],
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      );
}

// ===========================================================================
// BİLDİRİMLER ve AYARLAR
// ===========================================================================
class BildirimSayfasi extends StatelessWidget {
  const BildirimSayfasi({super.key});

  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Bildirimler',
        ikon: Icons.notifications_rounded,
        icerik: (w, h) => Center(
          child: Kart(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 80, height: 80, child: ZuzuYuzu()),
              const SizedBox(width: 16),
              Text('Henüz yeni bildirimin yok!',
                  style: TextStyle(
                      fontSize: h * .055, fontWeight: FontWeight.w900, color: kKahve)),
            ]),
          ),
        ),
      );
}

class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({super.key});
  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Ayarlar',
        ikon: Icons.settings_rounded,
        icerik: (w, h) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Kart(
                child: SwitchListTile(
                  value: ZuzuSesServisi.instance.sesAcik,
                  activeThumbColor: kMor,
                  secondary:
                      const Icon(Icons.volume_up_rounded, size: 40, color: kMor),
                  title: const Text('Zuzu\'nun sesi',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900, color: kKahve)),
                  onChanged: (v) {
                    setState(() => ZuzuSesServisi.instance.sesAcik = v);
                    if (!v) ZuzuSesServisi.instance.durdur();
                  },
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SesTestSayfasi())),
                icon: const Icon(Icons.bug_report_rounded),
                label: const Text('Ses Testi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMor,
                  foregroundColor: Colors.white,
                  textStyle:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      );
}

// ===========================================================================
// SES TESTİ: uygulamanın bulduğu ses dosyalarını listeler ve çalmayı dener
// ===========================================================================
class SesTestSayfasi extends StatefulWidget {
  const SesTestSayfasi({super.key});
  @override
  State<SesTestSayfasi> createState() => _SesTestSayfasiState();
}

class _SesTestSayfasiState extends State<SesTestSayfasi> {
  final AudioPlayer _oynatici = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  List<String>? _dosyalar;
  final Map<String, String> _sonuc = {};
  String _ttsSonuc = 'Henüz denenmedi';
  String _hata = '';

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _oynatici.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    try {
      final m = await AssetManifest.loadFromAssetBundle(rootBundle);
      final liste = m
          .listAssets()
          .where((a) => RegExp(r'\.(mp3|wav|ogg|m4a|aac)$', caseSensitive: false)
              .hasMatch(a))
          .toList();
      setState(() => _dosyalar = liste);
    } catch (e) {
      setState(() {
        _dosyalar = [];
        _hata = 'Dosya listesi okunamadı: $e';
      });
    }
  }

  Future<void> _cal(String yol) async {
    setState(() => _sonuc[yol] = 'Deneniyor...');
    try {
      await rootBundle.load(yol);
    } catch (e) {
      setState(() => _sonuc[yol] = 'HATA: dosya pakette yok ($e)');
      return;
    }
    try {
      await _oynatici.stop();
      await _oynatici.setVolume(1.0);
      await _oynatici.play(AssetSource(yol.replaceFirst('assets/', '')));
      setState(() => _sonuc[yol] = 'Çalmaya başladı. Ses duydun mu?');
    } catch (e) {
      setState(() => _sonuc[yol] = 'HATA: çalınamadı ($e)');
    }
  }

  Future<void> _ttsDene() async {
    setState(() => _ttsSonuc = 'Deneniyor...');
    try {
      final diller = await _tts.getLanguages;
      final tr = await _tts.isLanguageAvailable('tr-TR');
      await _tts.setLanguage('tr-TR');
      await _tts.setVolume(1.0);
      await _tts.speak('Merhaba, ben Zuzu. Beni duyuyor musun?');
      setState(() => _ttsSonuc =
          'Türkçe var mı: $tr\nDil sayısı: ${(diller as List).length}\n'
          'Konuşma başlatıldı. Ses duydun mu?');
    } catch (e) {
      setState(() => _ttsSonuc = 'HATA: $e');
    }
  }

  @override
  Widget build(BuildContext context) => TemaSayfa(
        baslik: 'Ses Testi',
        ikon: Icons.bug_report_rounded,
        icerik: (w, h) => ListView(
          children: [
            const Text(
              'Önce telefonun/emülatörün MEDYA SESİNİ aç. Sonra aşağıdaki '
              'düğmelere sırayla bas ve ne yazdığını bana bildir.',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: kKahve),
            ),
            const SizedBox(height: 10),
            Kart(
              child: Row(children: [
                Expanded(
                  child: Text('Sesli okuma (TTS)\n$_ttsSonuc',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                    onPressed: _ttsDene, child: const Text('Okut')),
              ]),
            ),
            const SizedBox(height: 10),
            Text(
              _dosyalar == null
                  ? 'Dosyalar aranıyor...'
                  : 'Pakette bulunan ses dosyaları: ${_dosyalar!.length}'
                      '${_dosyalar!.isEmpty ? "  (HİÇ YOK! pubspec.yaml assets bölümünü kontrol et)" : ""}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: kMavi),
            ),
            if (_hata.isNotEmpty) Text(_hata),
            for (final d in _dosyalar ?? <String>[])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Kart(
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900)),
                          Text(_sonuc[d] ?? 'Denenmedi',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () => _cal(d), child: const Text('Çal')),
                  ]),
                ),
              ),
          ],
        ),
      );
}
