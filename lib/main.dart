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
// kAnaMenuOrani  : ana_menu görseli (2000x900)
// Görsellerin boyutu farklıysa buradaki sayıları değiştir.
// ---------------------------------------------------------------------------
const double kGorselOrani = 2000 / 900;
const double kGorselGenislik = 2000;
const double kGorselYukseklik = 900;
const double kAnaMenuOrani = kGorselGenislik / kGorselYukseklik;

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
    if (mounted) setState(() => _konusuyor = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/hos_geldin.png',
          katmanlar: (context, w, h) => [
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
  static const _yaslar = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
  static const _siniflar = [
    'Okul öncesi',
    '1. sınıf',
    '2. sınıf',
    '3. sınıf',
    '4. sınıf',
    '5. sınıf',
    '6. sınıf',
    '7. sınıf',
    '8. sınıf',
  ];

  final _adController = TextEditingController();
  int? _yas;
  String? _sinif;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ZuzuSesServisi.instance
        .konus(dosya: Ses.seniTaniyalim, metin: ZuzuMetin.seniTaniyalim));
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
        const SnackBar(content: Text('Lütfen adını yaz, yaşını ve sınıfını seç.')),
      );
      return;
    }
    final o = Oyuncu.instance;
    o.ad = ad;
    o.yas = _yas!;
    o.sinif = _sinif!;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilEkrani()));
  }

  Widget _etiket(IconData ikon, Color renk, String yazi) => SizedBox(
        width: 190,
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: renk,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(ikon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Text(yazi,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, color: kKahve)),
        ]),
      );

  Widget _chip(String yazi, bool secili, VoidCallback onTap, {double genislik = 64}) =>
      Basilabilir(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: genislik,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: secili
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB36CF5), Color(0xFF7431B5)],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFFFEFD2)],
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: secili ? Colors.white : kCerceve, width: secili ? 3 : 2.5),
            boxShadow: [
              BoxShadow(
                  color: secili ? const Color(0x669C4DE0) : Colors.black12,
                  blurRadius: secili ? 10 : 4,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(yazi,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: secili ? Colors.white : kKahve)),
            ),
          ),
        ),
      );

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
              // Tahtanın krem iç alanı (görselde x:240-1320, y:320-705)
              Positioned(
                left: w * .142,
                top: h * .365,
                width: w * .50,
                height: h * .415,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 1040,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ad
                        Row(children: [
                          _etiket(Icons.person_rounded, const Color(0xFFE040B8), 'Adın'),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                                controller: _adController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: kKahve),
                                cursorColor: kMor,
                                decoration: InputDecoration(
                                  hintText: 'Adını ve soyadını yaz',
                                  hintStyle: const TextStyle(
                                      fontSize: 24, color: Colors.black38),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:
                                        const BorderSide(color: kCerceve, width: 3),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:
                                        const BorderSide(color: kMor, width: 3.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        // Yaş
                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          _etiket(Icons.cake_rounded, const Color(0xFFFF8A00), 'Yaşın'),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final y in _yaslar)
                                  _chip('$y', _yas == y, () => setState(() => _yas = y)),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        // Sınıf
                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          _etiket(Icons.school_rounded, const Color(0xFF1E88E5), 'Sınıfın'),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final k in _siniflar)
                                  _chip(
                                    k == 'Okul öncesi' ? k : k.substring(0, 1),
                                    _sinif == k,
                                    () => setState(() => _sinif = k),
                                    genislik: k == 'Okul öncesi' ? 170 : 64,
                                  ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 18),
                        Basilabilir(
                          onTap: _devamEt,
                          child: Container(
                            width: 420,
                            height: 66,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFA855F0), Color(0xFF7431B5)],
                              ),
                              borderRadius: BorderRadius.circular(33),
                              border: Border.all(color: Colors.white, width: 3.5),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 8,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Profilimi Oluştur',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 36, color: Colors.white),
                              ],
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
// Arka plan (assets/images/ana_menu.png) boş ada manzarasıdır. Başlık
// tabelası, adalar, puan, zil, ayarlar, Zuzu ve alt butonlar kodla çizilir.
// Tüm konumlar görselin kendisine göre orandır.
// ===========================================================================

/// Kenarlıklı (konturlu) yazı: çocuk oyunlarındaki kalın yazı görünümü.
class KonturluYazi extends StatelessWidget {
  final String yazi;
  final double boyut;
  final Color dolgu;
  final Color kontur;
  final double kalinlik;

  const KonturluYazi(
    this.yazi, {
    super.key,
    required this.boyut,
    this.dolgu = Colors.white,
    this.kontur = kMavi,
    this.kalinlik = 4,
  });

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Text(
            yazi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: boyut,
              fontWeight: FontWeight.w900,
              height: 1.05,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = kalinlik
                ..strokeJoin = StrokeJoin.round
                ..color = kontur,
            ),
          ),
          Text(
            yazi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: boyut,
              fontWeight: FontWeight.w900,
              height: 1.05,
              color: dolgu,
            ),
          ),
        ],
      );
}

class AnaMenuEkrani extends StatefulWidget {
  const AnaMenuEkrani({super.key});
  @override
  State<AnaMenuEkrani> createState() => _AnaMenuEkraniState();
}

/// Görseldeki ada tabelaları ve dokunma alanları (1670x942 piksel koordinatı).
class _AdaBilgi {
  final String baslik, alt;
  final Color yaziDolgu, yaziKontur;
  final Rect tabela; // yazının yazılacağı boş ahşap tabela
  final Rect alan; // dokunma alanı (tüm ada)
  const _AdaBilgi(this.baslik, this.alt, this.yaziDolgu, this.yaziKontur,
      this.tabela, this.alan);
}

const _adalar = [
  _AdaBilgi('DİKKAT', 'ADASI', Colors.white, Color(0xFF7A2E12),
      Rect.fromLTWH(305, 542, 210, 72), Rect.fromLTWH(222, 388, 343, 262)),
  _AdaBilgi('ZUZU', 'ADASI', Color(0xFFFF4FC3), Colors.white,
      Rect.fromLTWH(625, 554, 202, 74), Rect.fromLTWH(565, 380, 305, 295)),
  _AdaBilgi('MATEMATİK', 'ADASI', Color(0xFF1E5BE0), Colors.white,
      Rect.fromLTWH(935, 570, 196, 80), Rect.fromLTWH(870, 405, 315, 285)),
  _AdaBilgi('MANTIK', 'ADASI', Colors.white, Color(0xFF8A4A10),
      Rect.fromLTWH(1250, 568, 196, 68), Rect.fromLTWH(1180, 405, 320, 270)),
  _AdaBilgi('HIZ', 'ADASI', Color(0xFF3F4DE0), Colors.white,
      Rect.fromLTWH(1585, 550, 196, 72), Rect.fromLTWH(1500, 388, 350, 272)),
];

class _AnaMenuEkraniState extends State<AnaMenuEkrani> {
  static const double _gw = kGorselGenislik, _gh = kGorselYukseklik;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ZuzuSesServisi.instance
        .konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu));
  }

  @override
  void dispose() {
    super.dispose();
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

  /// Görsel pikseline göre konumlandırma.
  Widget _px(double w, double h, Rect r, Widget child) => Positioned(
        left: w * r.left / _gw,
        top: h * r.top / _gh,
        width: w * r.width / _gw,
        height: h * r.height / _gh,
        child: child,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/ana_menu.png',
          gorselOrani: kAnaMenuOrani,
          katmanlar: (context, w, h) {
            final u = h / _gh; // 1 görsel pikselinin ekrandaki boyu
            return [
              // --- Başlık tabelasının yazısı ---
              _px(
                w,
                h,
                const Rect.fromLTWH(790, 118, 430, 148),
                IgnorePointer(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        KonturluYazi('Online',
                            boyut: 70,
                            dolgu: Color(0xFF1E6BFF),
                            kontur: Colors.white,
                            kalinlik: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KonturluYazi('Mental',
                                boyut: 56,
                                dolgu: Color(0xFFFF7A1A),
                                kontur: Colors.white,
                                kalinlik: 10),
                            SizedBox(width: 12),
                            KonturluYazi('Akademi',
                                boyut: 56,
                                dolgu: Color(0xFF8A2BE2),
                                kontur: Colors.white,
                                kalinlik: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Adalar: dokunma alanı + tabela yazısı ---
              for (final a in _adalar) ...[
                _px(
                  w,
                  h,
                  a.alan,
                  Basilabilir(
                    onTap: () => _ada(
                        '${a.baslik[0]}${a.baslik.substring(1).toLowerCase()} ${a.alt}'),
                    child: const SizedBox.expand(),
                  ),
                ),
                _px(
                  w,
                  h,
                  a.tabela,
                  IgnorePointer(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KonturluYazi(a.baslik,
                                boyut: 40,
                                dolgu: a.yaziDolgu,
                                kontur: a.yaziKontur,
                                kalinlik: 8),
                            KonturluYazi(a.alt,
                                boyut: 31,
                                dolgu: a.yaziDolgu,
                                kontur: a.yaziKontur,
                                kalinlik: 6.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // --- Zuzu (sol alt) ---
              Positioned(
                left: -w * .02,
                bottom: -h * .02,
                height: h * .42,
                child: Basilabilir(
                  ses: false,
                  onTap: () => ZuzuSesServisi.instance
                      .konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu),
                  child: Image.asset(
                    'assets/images/zuzu.png',
                    height: h * .42,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // --- Üst çubuk ---
              _isimKutusu(w, h, u),
              _puanKutusu(w, h, u),
              _yuvarlakDugme(w, h, u, 1768, Icons.notifications_rounded,
                  () => _git(const BildirimSayfasi())),
              _yuvarlakDugme(w, h, u, 1868, Icons.settings_rounded,
                  () => _git(const AyarlarSayfasi())),

              // --- Alt butonlar (iskele üzerinde) ---
              _altDugme(w, h, u, 558, 'Başarılarım', Icons.emoji_events_rounded,
                  const Color(0xFFFFB300), () => _git(const BasarilarimSayfasi())),
              _altDugme(w, h, u, 868, 'Görevler', Icons.assignment_rounded,
                  const Color(0xFFFF8A00), () => _git(const GorevlerSayfasi())),
              _altDugme(w, h, u, 1178, 'Rozetler', Icons.shield_rounded,
                  const Color(0xFFFF9800), () => _git(const RozetlerSayfasi()),
                  yildiz: true),
            ];
          },
        ),
      );

  // ------------------------------------------------------------------
  // ÜST ÇUBUK
  // ------------------------------------------------------------------
  BoxDecoration _beyazKutu(double u, {double yaricap = 40}) => BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, .97),
        borderRadius: BorderRadius.circular(yaricap * u),
        border: Border.all(color: const Color(0xFFB8D9FF), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      );

  Widget _isimKutusu(double w, double h, double u) => _px(
        w,
        h,
        const Rect.fromLTWH(30, 26, 300, 130),
        Basilabilir(
          onTap: () => _git(const ProfilSayfasi()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 70 * u,
                right: 0,
                top: 26 * u,
                bottom: 26 * u,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 70 * u, right: 12 * u),
                  decoration: _beyazKutu(u),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Oyuncu.instance.ad.isEmpty ? 'Misafir' : Oyuncu.instance.ad,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 40 * u,
                        fontWeight: FontWeight.w900,
                        color: kMavi,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: 124 * u,
                height: 124 * u,
                child: Container(
                  padding: EdgeInsets.all(6 * u),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFB8D9FF), width: 4),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const ZuzuYuzu(),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _puanKutusu(double w, double h, double u) => _px(
        w,
        h,
        const Rect.fromLTWH(1535, 24, 205, 86),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 40 * u,
              right: 0,
              top: 12 * u,
              bottom: 12 * u,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 50 * u, right: 10 * u),
                decoration: _beyazKutu(u),
                child: ValueListenableBuilder<int>(
                  valueListenable: Oyuncu.instance.puan,
                  builder: (_, p, __) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontSize: 44 * u,
                        fontWeight: FontWeight.w900,
                        color: kMavi,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 86 * u,
              height: 86 * u,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-.3, -.4),
                    colors: [Color(0xFFFFE680), Color(0xFFFFB300), Color(0xFFE08600)],
                  ),
                  border: Border.all(color: const Color(0xFFFFE9A8), width: 4),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Icon(Icons.star_rounded,
                    size: 52 * u,
                    color: const Color(0xFFFFF3B0),
                    shadows: const [
                      Shadow(color: Color(0xFFB35F00), offset: Offset(1.5, 2)),
                    ]),
              ),
            ),
          ],
        ),
      );

  Widget _yuvarlakDugme(double w, double h, double u, double x, IconData ikon,
          VoidCallback onTap) =>
      _px(
        w,
        h,
        Rect.fromLTWH(x, 24, 82, 82),
        Basilabilir(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB8D9FF), width: 3.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Icon(ikon, size: 48 * u, color: const Color(0xFF0876E8)),
          ),
        ),
      );

  // ------------------------------------------------------------------
  // ALT BUTONLAR
  // ------------------------------------------------------------------
  Widget _altDugme(double w, double h, double u, double x, String ad,
          IconData ikon, Color ikonRenk, VoidCallback onTap,
          {bool yildiz = false}) =>
      _px(
        w,
        h,
        Rect.fromLTWH(x, 795, 290, 88),
        Basilabilir(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * u),
            decoration: _beyazKutu(u, yaricap: 46),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(ikon, size: 60 * u, color: ikonRenk, shadows: const [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ]),
                        if (yildiz)
                          Icon(Icons.star_rounded,
                              size: 26 * u, color: const Color(0xFFFFF3B0)),
                      ],
                    ),
                    SizedBox(width: 12 * u),
                    Text(
                      ad,
                      style: TextStyle(
                        fontSize: 36 * u,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1247D7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
