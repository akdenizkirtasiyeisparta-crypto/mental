import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../servisler/zuzu_ses_servisi.dart';

// ===========================================================================
// FARK BULMA OYUNU (test)
// 5 seviye: kolaydan zora. Seviye arttıkça nesne sayısı, fark sayısı artar,
// nesneler küçülür ve farklar inceleşir. Sahne kodla çizilir, görsel gerekmez.
// ===========================================================================

const _seviyeAd = ['Çok kolay', 'Kolay', 'Orta', 'Zor', 'Çok zor'];
const _ogeSayisi = [8, 11, 14, 17, 20];
const _farkSayisi = [3, 4, 5, 6, 7];
const _boyutOran = [.20, .17, .15, .13, .115];
const _panelOrani = 1.34; // panel genişliği / yüksekliği

const _emojiler = [
  '🌴', '🌺', '🐠', '🐚', '⭐', '🦀', '🐙', '⛵', '🐬', '🦋',
  '🍉', '🍍', '🥥', '🐢', '🐟', '🎈', '🦜', '🌼', '🐳', '🍓',
];

/// Sağ-sol çevrilince farkı görünen nesneler.
const _asimetrik = {'🐠', '🐟', '🐬', '🐢', '🦜', '⛵', '🐳'};

/// Zor seviyelerde birbirine benzeyen nesne çiftleri.
const _benzer = {
  '🐠': '🐟',
  '🐟': '🐠',
  '🐬': '🐳',
  '🐳': '🐬',
  '🌺': '🌼',
  '🌼': '🌺',
  '🍉': '🍓',
  '🍓': '🍉',
};

enum _Tur { eksik, degis, buyukKucuk, ayna, don }

class _Oge {
  final String emoji;
  final double x, y; // panele göre oran (0..1)
  final double boyut; // panel yüksekliğine oran
  final double olcek, aci;
  final bool ayna;
  const _Oge(this.emoji, this.x, this.y, this.boyut,
      {this.olcek = 1, this.aci = 0, this.ayna = false});

  _Oge degistir({String? emoji, double? olcek, double? aci, bool? ayna}) =>
      _Oge(emoji ?? this.emoji, x, y, boyut,
          olcek: olcek ?? this.olcek,
          aci: aci ?? this.aci,
          ayna: ayna ?? this.ayna);
}

class _Sahne {
  final List<_Oge> sol;
  final List<_Oge?> sag;
  final List<int> farklar;
  _Sahne(this.sol, this.sag, this.farklar);
}

_Sahne _sahneUret(int seviye, int deneme) {
  final r = math.Random(seviye * 1000 + deneme * 7 + 13);
  final n = _ogeSayisi[seviye];
  final cols = math.sqrt(n * _panelOrani).ceil();
  final rows = (n / cols).ceil();

  final hucreler = <List<int>>[
    for (var c = 0; c < cols; c++)
      for (var s = 0; s < rows; s++) [c, s]
  ]..shuffle(r);

  final hucreY = .83 / rows;
  final hucreX = 1 / cols;
  final boyut = math.min(
      _boyutOran[seviye], math.min(hucreY * .85, hucreX * _panelOrani * .85));

  final emojiHavuzu = [..._emojiler]..shuffle(r);
  final sol = <_Oge>[];
  for (var i = 0; i < n; i++) {
    final h = hucreler[i];
    final jx = (r.nextDouble() - .5) * hucreX * .22;
    final jy = (r.nextDouble() - .5) * hucreY * .22;
    sol.add(_Oge(
      emojiHavuzu[i % emojiHavuzu.length],
      (h[0] + .5) / cols + jx,
      .12 + (h[1] + .5) * hucreY + jy,
      boyut,
    ));
  }

  final tipler = switch (seviye) {
    0 => [_Tur.eksik, _Tur.degis],
    1 => [_Tur.eksik, _Tur.degis, _Tur.buyukKucuk],
    2 => [_Tur.eksik, _Tur.degis, _Tur.buyukKucuk, _Tur.ayna],
    _ => [_Tur.eksik, _Tur.degis, _Tur.buyukKucuk, _Tur.ayna, _Tur.don],
  };

  final sira = List<int>.generate(n, (i) => i)..shuffle(r);
  final farklar = sira.take(_farkSayisi[seviye]).toList()..sort();
  final sag = <_Oge?>[...sol];

  for (final i in farklar) {
    final o = sol[i];
    var tur = tipler[r.nextInt(tipler.length)];
    if (tur == _Tur.ayna && !_asimetrik.contains(o.emoji)) tur = _Tur.buyukKucuk;
    switch (tur) {
      case _Tur.eksik:
        sag[i] = null;
      case _Tur.degis:
        String yeni;
        if (seviye >= 3 && _benzer.containsKey(o.emoji)) {
          yeni = _benzer[o.emoji]!;
        } else {
          final adaylar = _emojiler.where((e) => e != o.emoji).toList();
          yeni = adaylar[r.nextInt(adaylar.length)];
        }
        sag[i] = o.degistir(emoji: yeni);
      case _Tur.buyukKucuk:
        final buyuk = r.nextBool();
        final oran = switch (seviye) {
          0 || 1 => buyuk ? 1.6 : .55,
          2 => buyuk ? 1.45 : .65,
          _ => buyuk ? 1.32 : .72,
        };
        sag[i] = o.degistir(olcek: oran);
      case _Tur.ayna:
        sag[i] = o.degistir(ayna: true);
      case _Tur.don:
        final yon = r.nextBool() ? 1 : -1;
        sag[i] = o.degistir(aci: yon * (seviye == 3 ? .9 : .6));
    }
  }
  return _Sahne(sol, sag, farklar);
}

class _Yanlis {
  final double x, y;
  final bool sag;
  _Yanlis(this.x, this.y, this.sag);
}

class FarkBulmaOyunu extends StatefulWidget {
  /// 0-4 arası; başlamak istediğin seviye (varsayılan: ilk seviye).
  final int baslangicSeviye;
  const FarkBulmaOyunu({super.key, this.baslangicSeviye = 0});
  @override
  State<FarkBulmaOyunu> createState() => _FarkBulmaOyunuState();
}

class _FarkBulmaOyunuState extends State<FarkBulmaOyunu> {
  int _seviye = 0;
  int _deneme = 0;
  late _Sahne _sahne;
  final Set<int> _bulunan = {};
  int _can = 3;
  int _ipucuHakki = 1;
  int? _ipucuIdx;
  bool _bitti = false;
  final List<_Yanlis> _yanlislar = [];

  @override
  void initState() {
    super.initState();
    _seviye = widget.baslangicSeviye.clamp(0, _seviyeAd.length - 1);
    _yeniSahne();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ZuzuSesServisi.instance.konus(metin: 'Resimler arasındaki farkları bul!'));
  }

  /// Test için: farkların panel üzerindeki konumları (oran olarak).
  List<Offset> get debugFarkKonumlari =>
      [for (final i in _sahne.farklar) Offset(_sahne.sol[i].x, _sahne.sol[i].y)];

  void _yeniSahne() {
    _sahne = _sahneUret(_seviye, _deneme);
    _bulunan.clear();
    _yanlislar.clear();
    _can = 3;
    _ipucuHakki = 1;
    _ipucuIdx = null;
    _bitti = false;
  }

  void _vurus(double nx, double ny, double pw, double ph, bool sag) {
    if (_bitti) return;
    for (final i in _sahne.farklar) {
      if (_bulunan.contains(i)) continue;
      final o = _sahne.sol[i];
      final dx = (nx - o.x) * pw;
      final dy = (ny - o.y) * ph;
      final yaricap = math.max(o.boyut * ph * .85, 30.0);
      if (dx * dx + dy * dy <= yaricap * yaricap) {
        setState(() {
          _bulunan.add(i);
          if (_ipucuIdx == i) _ipucuIdx = null;
        });
        HapticFeedback.lightImpact();
        ZuzuSesServisi.instance.efekt(Ses.odul);
        if (_bulunan.length == _sahne.farklar.length) _seviyeBitti();
        return;
      }
    }
    // yanlış dokunuş
    final y = _Yanlis(nx, ny, sag);
    setState(() {
      _can--;
      _yanlislar.add(y);
    });
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _yanlislar.remove(y));
    });
    if (_can <= 0) _kaybet();
  }

  void _ipucu() {
    if (_bitti || _ipucuHakki <= 0) return;
    final kalan = _sahne.farklar.where((i) => !_bulunan.contains(i)).toList();
    if (kalan.isEmpty) return;
    final secilen = kalan.first;
    setState(() {
      _ipucuHakki--;
      _ipucuIdx = secilen;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _ipucuIdx == secilen) setState(() => _ipucuIdx = null);
    });
  }

  Future<void> _seviyeBitti() async {
    _bitti = true;
    final kazanilan = 10 + 5 * (_seviye + 1);
    Oyuncu.instance.puan.value += kazanilan;
    ZuzuSesServisi.instance.konus(metin: 'Aferin! Harika iş çıkardın!');
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final son = _seviye == _seviyeAd.length - 1;
    final secim = await _diyalog(
      baslik: son ? 'Tebrikler! Hepsini bitirdin!' : 'Harika!',
      yildiz: _can,
      mesaj: '+$kazanilan puan kazandın!',
      dugmeler: [
        _DiyalogDugme('Tekrar', 'tekrar', false),
        _DiyalogDugme(son ? 'Bitir' : 'Sonraki seviye', 'devam', true),
      ],
    );
    if (!mounted) return;
    if (secim == 'devam') {
      if (son) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _seviye++;
          _deneme = 0;
          _yeniSahne();
        });
      }
    } else {
      setState(() {
        _deneme++;
        _yeniSahne();
      });
    }
  }

  Future<void> _kaybet() async {
    _bitti = true;
    ZuzuSesServisi.instance.konus(metin: 'Üzülme! Tekrar deneyelim.');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final secim = await _diyalog(
      baslik: 'Olmadı, tekrar dene!',
      yildiz: 0,
      mesaj: 'Hakların bitti. Bir daha deneyelim mi?',
      dugmeler: [
        _DiyalogDugme('Çık', 'cik', false),
        _DiyalogDugme('Tekrar dene', 'tekrar', true),
      ],
    );
    if (!mounted) return;
    if (secim == 'cik') {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _deneme++;
        _yeniSahne();
      });
    }
  }

  Future<String?> _diyalog({
    required String baslik,
    required int yildiz,
    required String mesaj,
    required List<_DiyalogDugme> dugmeler,
  }) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
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
                      if (yildiz > 0)
                        Row(children: [
                          for (var i = 0; i < 3; i++)
                            Icon(Icons.star_rounded,
                                size: 38,
                                color: i < yildiz
                                    ? const Color(0xFFFFB300)
                                    : Colors.black26),
                        ]),
                      Text(mesaj,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700, color: kKahve)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          for (final d in dugmeler)
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(d.deger),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: d.vurgulu ? kMor : Colors.white,
                                foregroundColor: d.vurgulu ? Colors.white : kMor,
                              ),
                              child: Text(d.yazi,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w900)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ------------------------------------------------------------------
  Widget _ogeCiz(_Oge o, double pw, double ph) {
    final s = o.boyut * ph * o.olcek;
    return Positioned(
      left: o.x * pw - s / 2,
      top: o.y * ph - s / 2,
      width: s,
      height: s,
      child: Transform.rotate(
        angle: o.aci,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(o.ayna ? -1 : 1, 1, 1),
          child: FittedBox(
            child: Text(o.emoji, style: TextStyle(fontSize: s * .8, height: 1)),
          ),
        ),
      ),
    );
  }

  Widget _halka(_Oge o, double pw, double ph, Color renk, {bool tik = false}) {
    final d = math.max(o.boyut * ph * 1.5, 46.0);
    return Positioned(
      left: o.x * pw - d / 2,
      top: o.y * ph - d / 2,
      width: d,
      height: d,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: renk, width: 4.5),
            color: renk.withValues(alpha: .15),
          ),
          child: tik ? Icon(Icons.check_rounded, color: renk, size: d * .5) : null,
        ),
      ),
    );
  }

  Widget _panel(bool sag, double pw, double ph) => Container(
        width: pw,
        height: ph,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kCerceve, width: 5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              // çerçeve kalınlığı kadar içeride
              final iw = pw - 10, ih = ph - 10;
              _vurus(d.localPosition.dx / iw, d.localPosition.dy / ih, iw, ih, sag);
            },
            child: LayoutBuilder(
              builder: (_, c) {
                final w = c.maxWidth, h = c.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _ArkaPlanPainter())),
                    for (var i = 0; i < _sahne.sol.length; i++)
                      if (!sag)
                        _ogeCiz(_sahne.sol[i], w, h)
                      else if (_sahne.sag[i] != null)
                        _ogeCiz(_sahne.sag[i]!, w, h),
                    for (final i in _bulunan)
                      _halka(_sahne.sol[i], w, h, const Color(0xFF43A047), tik: true),
                    if (sag && _ipucuIdx != null)
                      _halka(_sahne.sol[_ipucuIdx!], w, h, const Color(0xFFFFB300)),
                    for (final y in _yanlislar)
                      if (y.sag == sag)
                        Positioned(
                          left: y.x * w - 22,
                          top: y.y * h - 22,
                          width: 44,
                          height: 44,
                          child: const IgnorePointer(
                            child: Icon(Icons.close_rounded,
                                color: Color(0xFFE53935), size: 44),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Sahne(
          arkaPlan: 'assets/images/ana_menu.png',
          gorselOrani: kAnaMenuOrani,
          katmanlar: (context, w, h) {
            final pw = w * .47, ph = h * .78;
            return [
              Positioned.fill(
                child: Container(color: const Color.fromRGBO(10, 70, 140, .62)),
              ),
              // geri
              Positioned(
                left: w * .012,
                top: h * .018,
                width: h * .10,
                height: h * .10,
                child: Basilabilir(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kMor, width: 3),
                    ),
                    child: Icon(Icons.arrow_back_rounded, size: h * .06, color: kMor),
                  ),
                ),
              ),
              // başlık
              Positioned(
                left: w * .09,
                top: h * .012,
                width: w * .36,
                height: h * .11,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: KonturluYazi(
                      'Seviye ${_seviye + 1}/5 · ${_seviyeAd[_seviye]}',
                      boyut: h * .065,
                      dolgu: Colors.white,
                      kontur: kMavi,
                      kalinlik: h * .014,
                    ),
                  ),
                ),
              ),
              // sağ üst: sayaç, canlar, ipucu
              Positioned(
                right: w * .014,
                top: h * .018,
                height: h * .10,
                width: w * .50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: h * .03),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(h * .05),
                        border: Border.all(color: const Color(0xFFB8D9FF), width: 3),
                      ),
                      child: Text(
                        'Bulunan ${_bulunan.length}/${_sahne.farklar.length}',
                        style: TextStyle(
                            fontSize: h * .05,
                            fontWeight: FontWeight.w900,
                            color: kMavi),
                      ),
                    ),
                    SizedBox(width: w * .012),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: h * .02),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(h * .05),
                        border: Border.all(color: const Color(0xFFB8D9FF), width: 3),
                      ),
                      child: Row(children: [
                        for (var i = 0; i < 3; i++)
                          Icon(
                            Icons.favorite_rounded,
                            size: h * .065,
                            color: i < _can ? const Color(0xFFE53935) : Colors.black26,
                          ),
                      ]),
                    ),
                    SizedBox(width: w * .012),
                    Basilabilir(
                      onTap: _ipucuHakki > 0 ? _ipucu : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: h * .03),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _ipucuHakki > 0 ? const Color(0xFFFFB300) : Colors.grey,
                          borderRadius: BorderRadius.circular(h * .05),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Row(children: [
                          Icon(Icons.lightbulb_rounded,
                              size: h * .06, color: Colors.white),
                          SizedBox(width: h * .01),
                          Text('İpucu',
                              style: TextStyle(
                                  fontSize: h * .045,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              // paneller
              Positioned(left: w * .02, top: h * .15, child: _panel(false, pw, ph)),
              Positioned(right: w * .02, top: h * .15, child: _panel(true, pw, ph)),
            ];
          },
        ),
      );
}

class _DiyalogDugme {
  final String yazi, deger;
  final bool vurgulu;
  _DiyalogDugme(this.yazi, this.deger, this.vurgulu);
}

class _ArkaPlanPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final gok = Rect.fromLTWH(0, 0, s.width, s.height * .5);
    c.drawRect(
        gok,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6CCBFF), Color(0xFFCDF0FF)],
          ).createShader(gok));
    final deniz = Rect.fromLTWH(0, s.height * .5, s.width, s.height * .5);
    c.drawRect(
        deniz,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF35BFF5), Color(0xFF0E8ED8)],
          ).createShader(deniz));
    // kum
    c.drawOval(
        Rect.fromLTWH(-s.width * .1, s.height * .93, s.width * 1.2, s.height * .2),
        Paint()..color = const Color(0xFFF3DCA0));
    // güneş (süs)
    c.drawCircle(Offset(s.width * .9, s.height * .1), s.height * .07,
        Paint()..color = const Color(0xFFFFE14D));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
