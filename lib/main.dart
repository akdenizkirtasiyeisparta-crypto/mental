import 'dart:math' as math;
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
const double kAnaMenuOrani = 2000 / 900;

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
    ZuzuSesServisi.instance.durdur();
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

class _AdaBilgi {
  final double cx, ust, faz;
  final Color renk, yaziDolgu, yaziKontur;
  final String baslik, alt;
  final _Simge simge;
  const _AdaBilgi(this.cx, this.ust, this.faz, this.renk, this.baslik, this.alt,
      this.simge, this.yaziDolgu, this.yaziKontur);
}

const _adalar = [
  _AdaBilgi(.200, .320, 0.0, Color(0xFFE53935), 'DİKKAT', 'ADASI',
      _Simge.hedef, Colors.white, Color(0xFF7A2E12)),
  _AdaBilgi(.355, .345, .2, Color(0xFFE040B8), 'ZUZU', 'ADASI', _Simge.zuzu,
      Color(0xFFFF4FC3), Colors.white),
  _AdaBilgi(.510, .370, .4, Color(0xFF1E88E5), 'MATEMATİK', 'ADASI',
      _Simge.matematik, Color(0xFF1E5BE0), Colors.white),
  _AdaBilgi(.665, .345, .6, Color(0xFFFFB300), 'MANTIK', 'ADASI',
      _Simge.yapboz, Colors.white, Color(0xFF8A4A10)),
  _AdaBilgi(.820, .320, .8, Color(0xFF8E3FE0), 'HIZ', 'ADASI', _Simge.simsek,
      Color(0xFF3F4DE0), Colors.white),
];

class _AnaMenuEkraniState extends State<AnaMenuEkrani>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dalga;

  @override
  void initState() {
    super.initState();
    _dalga = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => ZuzuSesServisi.instance
        .konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu));
  }

  @override
  void dispose() {
    _dalga.dispose();
    ZuzuSesServisi.instance.durdur();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/ana_menu.png',
          gorselOrani: kAnaMenuOrani,
          katmanlar: (context, w, h) => [
            for (final a in _adalar) _adaKonum(w, h, a),

            // --- Zuzu (sol alt) ---
            Positioned(
              left: -w * .012,
              bottom: -h * .03,
              height: h * .62,
              child: Basilabilir(
                ses: false,
                onTap: () => ZuzuSesServisi.instance
                    .konus(dosya: Ses.anaMenu, metin: ZuzuMetin.anaMenu),
                child: Image.asset(
                  'assets/images/zuzu.png',
                  height: h * .62,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

            // --- Üst çubuk ---
            _isimKutusu(w, h),
            _baslikTabelasi(w, h),
            _puanKutusu(w, h),
            _yuvarlakDugme(w, h, .903, Icons.notifications_rounded,
                () => _git(const BildirimSayfasi())),
            _yuvarlakDugme(w, h, .955, Icons.settings_rounded,
                () => _git(const AyarlarSayfasi())),

            // --- Alt butonlar (iskele üzerinde) ---
            _altDugme(w, h, .335, 'Başarılarım', Icons.emoji_events_rounded,
                const Color(0xFFFFB300), () => _git(const BasarilarimSayfasi())),
            _altDugme(w, h, .495, 'Görevler', Icons.assignment_rounded,
                const Color(0xFFFF8A00), () => _git(const GorevlerSayfasi())),
            _altDugme(w, h, .655, 'Rozetler', Icons.shield_rounded,
                const Color(0xFFFF9800), () => _git(const RozetlerSayfasi()),
                yildiz: true),
          ],
        ),
      );

  // ------------------------------------------------------------------
  // ADA
  // ------------------------------------------------------------------
  Widget _adaKonum(double w, double h, _AdaBilgi a) {
    final bw = w * .165;
    final bh = h * .47;
    return Positioned(
      left: w * a.cx - bw / 2,
      top: h * a.ust,
      width: bw,
      height: bh,
      child: AnimatedBuilder(
        animation: _dalga,
        builder: (_, child) => Transform.translate(
          offset: Offset(
              0, math.sin((_dalga.value + a.faz) * 2 * math.pi) * h * .007),
          child: child,
        ),
        child: Basilabilir(
          onTap: () => _ada('${a.baslik[0]}${a.baslik.substring(1).toLowerCase()} ${a.alt}'),
          child: _adaGovde(bw, bh, a),
        ),
      ),
    );
  }

  Widget _simgeCiz(_Simge simge, double dd) {
    switch (simge) {
      case _Simge.hedef:
        return Stack(alignment: Alignment.center, children: [
          for (final k in [1.0, .74, .48, .22])
            Container(
              width: dd * .66 * k,
              height: dd * .66 * k,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: k == 1.0 || k == .48
                    ? Colors.white
                    : const Color(0xFFD32F2F),
              ),
            ),
          Positioned(
            right: dd * .0,
            top: dd * .0,
            child: Icon(Icons.north_east_rounded,
                size: dd * .32, color: const Color(0xFF8D4B14)),
          ),
        ]);
      case _Simge.zuzu:
        return Container(
          width: dd * .88,
          height: dd * .88,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const ZuzuYuzu(),
        );
      case _Simge.matematik:
        Widget kare(String t, Color c) => Container(
              width: dd * .31,
              height: dd * .31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(dd * .08),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(t,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: dd * .26,
                      fontWeight: FontWeight.w900,
                      height: 1)),
            );
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            kare('+', const Color(0xFF43A047)),
            SizedBox(width: dd * .05),
            kare('−', const Color(0xFF1565C0)),
          ]),
          SizedBox(height: dd * .05),
          Row(mainAxisSize: MainAxisSize.min, children: [
            kare('×', const Color(0xFFFFB300)),
            SizedBox(width: dd * .05),
            kare('÷', const Color(0xFFE53935)),
          ]),
        ]);
      case _Simge.yapboz:
        return Icon(Icons.extension_rounded,
            size: dd * .72,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ]);
      case _Simge.simsek:
        return Icon(Icons.bolt_rounded,
            size: dd * .78,
            color: const Color(0xFFFFEB3B),
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
            ]);
    }
  }

  Widget _adaGovde(double bw, double bh, _AdaBilgi a) {
    final dd = bw * .74; // kubbe çapı
    final renk = a.renk;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Su halkası, kayalar, kum, çimen
        Positioned.fill(
          child: CustomPaint(painter: _AdaZeminPainter()),
        ),
        // Renkli kubbe
        Positioned(
          top: 0,
          left: (bw - dd) / 2,
          width: dd,
          height: dd,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-.35, -.45),
                radius: 1.0,
                colors: [
                  Color.lerp(renk, Colors.white, .40)!,
                  renk,
                  Color.lerp(renk, Colors.black, .30)!,
                ],
                stops: const [0, .55, 1],
              ),
              border: Border.all(
                  color: Color.lerp(renk, Colors.white, .55)!, width: 3.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: dd * .12),
              child: _simgeCiz(a.simge, dd),
            ),
          ),
        ),
        // Parlama
        Positioned(
          top: dd * .08,
          left: (bw - dd) / 2 + dd * .16,
          width: dd * .30,
          height: dd * .14,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, .32),
              borderRadius:
                  BorderRadius.all(Radius.elliptical(dd * .15, dd * .07)),
            ),
          ),
        ),
        // Ahşap tabela
        Positioned(
          left: bw * .07,
          right: bw * .07,
          top: bh * .50,
          height: bh * .27,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3B060), Color(0xFFCB7A2E)],
              ),
              borderRadius: BorderRadius.circular(bh * .045),
              border: Border.all(color: const Color(0xFF7A3E10), width: 3),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 6, offset: Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                // tahta çizgileri
                Positioned.fill(
                  child: CustomPaint(painter: _TahtaPainter()),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: bw * .04),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KonturluYazi(a.baslik,
                              boyut: bh * .095,
                              dolgu: a.yaziDolgu,
                              kontur: a.yaziKontur,
                              kalinlik: bh * .022),
                          KonturluYazi(a.alt,
                              boyut: bh * .075,
                              dolgu: a.yaziDolgu,
                              kontur: a.yaziKontur,
                              kalinlik: bh * .018),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Yapraklar ve çiçekler (tabelanın iki yanında)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _YaprakPainter(renk)),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // ÜST ÇUBUK
  // ------------------------------------------------------------------
  BoxDecoration _beyazKutu(double h) => BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, .97),
        borderRadius: BorderRadius.circular(h * .06),
        border: Border.all(color: const Color(0xFFB8D9FF), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      );

  Widget _isimKutusu(double w, double h) => Positioned(
        left: w * .012,
        top: h * .03,
        width: w * .165,
        height: h * .14,
        child: Basilabilir(
          onTap: () => _git(const ProfilSayfasi()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: h * .05,
                right: 0,
                top: h * .025,
                bottom: h * .025,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: h * .10, right: h * .02),
                  decoration: _beyazKutu(h),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Oyuncu.instance.ad.isEmpty ? 'Misafir' : Oyuncu.instance.ad,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: h * .05,
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
                width: h * .14,
                height: h * .14,
                child: Container(
                  padding: EdgeInsets.all(h * .008),
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

  Widget _baslikTabelasi(double w, double h) => Positioned(
        left: w * .315,
        top: h * .045,
        width: w * .37,
        height: h * .26,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5B563), Color(0xFFD27D2C)],
                  ),
                  borderRadius: BorderRadius.circular(h * .07),
                  border: Border.all(
                      color: const Color(0xFFFFF1D0), width: h * .009),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black45,
                        blurRadius: 14,
                        offset: Offset(0, 7)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _TahtaPainter())),
                    Center(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              KonturluYazi('Online',
                                  boyut: 74,
                                  dolgu: Color(0xFF1E6BFF),
                                  kontur: Colors.white,
                                  kalinlik: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  KonturluYazi('Mental',
                                      boyut: 60,
                                      dolgu: Color(0xFFFF7A1A),
                                      kontur: Colors.white,
                                      kalinlik: 11),
                                  SizedBox(width: 14),
                                  KonturluYazi('Akademi',
                                      boyut: 60,
                                      dolgu: Color(0xFF8A2BE2),
                                      kontur: Colors.white,
                                      kalinlik: 11),
                                ],
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
            // sol ve sağ üst köşelerde yaprak + çiçek
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _BaslikSusPainter()),
              ),
            ),
          ],
        ),
      );

  Widget _puanKutusu(double w, double h) => Positioned(
        left: w * .735,
        top: h * .03,
        width: w * .12,
        height: h * .14,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: h * .05,
              right: 0,
              top: h * .025,
              bottom: h * .025,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: h * .09, right: h * .02),
                decoration: _beyazKutu(h),
                child: ValueListenableBuilder<int>(
                  valueListenable: Oyuncu.instance.puan,
                  builder: (_, p, __) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontSize: h * .058,
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
              width: h * .14,
              height: h * .14,
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
                    size: h * .09,
                    color: const Color(0xFFFFF3B0),
                    shadows: const [
                      Shadow(color: Color(0xFFB35F00), blurRadius: 0, offset: Offset(1.5, 2)),
                    ]),
              ),
            ),
          ],
        ),
      );

  Widget _yuvarlakDugme(
          double w, double h, double sol, IconData ikon, VoidCallback onTap) =>
      Positioned(
        left: w * sol - h * .06,
        top: h * .03,
        width: h * .12,
        height: h * .12,
        child: Basilabilir(
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
            child: Icon(ikon, size: h * .07, color: const Color(0xFF0876E8)),
          ),
        ),
      );

  // ------------------------------------------------------------------
  // ALT BUTONLAR
  // ------------------------------------------------------------------
  Widget _altDugme(double w, double h, double sol, String ad, IconData ikon,
          Color ikonRenk, VoidCallback onTap,
          {bool yildiz = false}) =>
      Positioned(
        left: w * sol,
        top: h * .845,
        width: w * .15,
        height: h * .115,
        child: Basilabilir(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * .008),
            decoration: _beyazKutu(h),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(ikon,
                            size: h * .08,
                            color: ikonRenk,
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ]),
                        if (yildiz)
                          Icon(Icons.star_rounded,
                              size: h * .035, color: const Color(0xFFFFF3B0)),
                      ],
                    ),
                    SizedBox(width: w * .008),
                    Text(
                      ad,
                      style: TextStyle(
                        fontSize: h * .045,
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

enum _Simge { hedef, zuzu, matematik, yapboz, simsek }

// ---------------------------------------------------------------------------
// ÇİZİM YARDIMCILARI
// ---------------------------------------------------------------------------
void _yaprakCiz(Canvas c, Offset o, double len, double aci, Color renk) {
  c.save();
  c.translate(o.dx, o.dy);
  c.rotate(aci);
  final yol = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(len * .35, -len * .30, len, 0)
    ..quadraticBezierTo(len * .35, len * .30, 0, 0);
  c.drawPath(yol, Paint()..color = renk);
  c.drawPath(
      yol,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x33000000));
  c.drawLine(Offset.zero, Offset(len * .88, 0),
      Paint()..color = const Color(0x40FFFFFF)..strokeWidth = 1.4);
  c.restore();
}

void _cicekCiz(Canvas c, Offset o, double r, Color petal) {
  final p = Paint()..color = petal;
  for (var i = 0; i < 5; i++) {
    final t = i * 2 * math.pi / 5;
    c.drawCircle(o + Offset(math.cos(t), math.sin(t)) * r * .75, r * .62, p);
  }
  c.drawCircle(o, r * .5, Paint()..color = const Color(0xFFFFD54F));
}

class _AdaZeminPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    // su halkası
    final halka = Rect.fromLTWH(-w * .02, h * .72, w * 1.04, h * .28);
    c.drawOval(halka, Paint()..color = const Color(0x2EFFFFFF));
    c.drawOval(
        halka,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x88FFFFFF));
    // kum
    final kum = Rect.fromLTWH(w * .04, h * .74, w * .92, h * .23);
    c.drawOval(kum.shift(const Offset(0, 5)), Paint()..color = const Color(0x33000000));
    c.drawOval(
        kum,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAE9BA), Color(0xFFD9B26C)],
          ).createShader(kum));
    c.drawOval(
        kum,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFB88F4E));
    // çimen
    final cimen = Rect.fromLTWH(w * .14, h * .735, w * .72, h * .13);
    c.drawOval(
        cimen,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6BD65F), Color(0xFF2E9A3E)],
          ).createShader(cimen));
    // kayalar
    final kaya = [
      [.10, .90, .09],
      [.22, .95, .07],
      [.50, .975, .08],
      [.78, .95, .07],
      [.90, .90, .09],
    ];
    for (final k in kaya) {
      final o = Offset(w * k[0], h * k[1]);
      final r = w * k[2];
      final rect = Rect.fromCenter(center: o, width: r * 2, height: r * 1.3);
      c.drawOval(
          rect,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-.4, -.5),
              colors: [Color(0xFFD7D2C8), Color(0xFF9C9488)],
            ).createShader(rect));
      c.drawOval(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0x55000000));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _YaprakPainter extends CustomPainter {
  final Color renk;
  _YaprakPainter(this.renk);

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    const yesil1 = Color(0xFF2E8B3A);
    const yesil2 = Color(0xFF4CB848);
    const yesil3 = Color(0xFF7BD25A);
    final y = h * .64;
    // sol yaprak demeti
    _yaprakCiz(c, Offset(w * .10, y), w * .22, -2.6, yesil1);
    _yaprakCiz(c, Offset(w * .10, y), w * .20, -1.9, yesil2);
    _yaprakCiz(c, Offset(w * .10, y), w * .18, -3.3, yesil3);
    _yaprakCiz(c, Offset(w * .08, y + h * .05), w * .18, 3.5, yesil2);
    // sağ yaprak demeti
    _yaprakCiz(c, Offset(w * .90, y), w * .22, -.55, yesil1);
    _yaprakCiz(c, Offset(w * .90, y), w * .20, -1.25, yesil2);
    _yaprakCiz(c, Offset(w * .90, y), w * .18, .2, yesil3);
    _yaprakCiz(c, Offset(w * .92, y + h * .05), w * .18, -.35, yesil2);
    // çiçekler
    _cicekCiz(c, Offset(w * .07, y - h * .02), w * .045, const Color(0xFFFF6FA5));
    _cicekCiz(c, Offset(w * .13, y + h * .07), w * .035, Colors.white);
    _cicekCiz(c, Offset(w * .93, y - h * .01), w * .045, const Color(0xFFFFB3D1));
    _cicekCiz(c, Offset(w * .87, y + h * .075), w * .035, const Color(0xFFFFE066));
  }

  @override
  bool shouldRepaint(covariant _YaprakPainter old) => old.renk != renk;
}

class _TahtaPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 4; i++) {
      final y = s.height * i / 4;
      c.drawLine(Offset(s.width * .04, y), Offset(s.width * .96, y), p);
    }
    final civi = Paint()..color = const Color(0xFF8F5A24);
    for (final x in [.05, .95]) {
      for (final y in [.14, .86]) {
        c.drawCircle(Offset(s.width * x, s.height * y), s.height * .035, civi);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BaslikSusPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    const g1 = Color(0xFF2E8B3A), g2 = Color(0xFF4CB848), g3 = Color(0xFF7BD25A);
    // sol üst
    _yaprakCiz(c, Offset(w * .03, h * .10), h * .34, -.6, g1);
    _yaprakCiz(c, Offset(w * .03, h * .10), h * .30, -1.4, g2);
    _yaprakCiz(c, Offset(w * .03, h * .10), h * .28, .35, g3);
    _cicekCiz(c, Offset(w * .04, h * .06), h * .09, const Color(0xFFFF4D7D));
    _cicekCiz(c, Offset(w * .10, h * .10), h * .06, const Color(0xFFFFD54F));
    // sağ üst
    _yaprakCiz(c, Offset(w * .97, h * .10), h * .34, -2.5, g1);
    _yaprakCiz(c, Offset(w * .97, h * .10), h * .30, -1.7, g2);
    _yaprakCiz(c, Offset(w * .97, h * .10), h * .28, 3.0, g3);
    _cicekCiz(c, Offset(w * .96, h * .06), h * .09, const Color(0xFFFFB300));
    _cicekCiz(c, Offset(w * .90, h * .10), h * .06, const Color(0xFFFF6FA5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
