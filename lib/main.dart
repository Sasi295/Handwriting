import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'download_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const HandwritingApp());
}

// ── Theme ────────────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

// ── Colors ───────────────────────────────────────────────────
const kBg = Color(0xFF0D0D0D);
const kSurface = Color(0xFF1A1A1A);
const kCard = Color(0xFF222222);
const kAccent = Color(0xFF00E5FF);
const kAccent2 = Color(0xFF7B2FFF);
const kText = Color(0xFFF0F0F0);
const kSubtext = Color(0xFF888888);
const kSuccess = Color(0xFF00E676);
const kError = Color(0xFFFF1744);
const kLightBg = Color(0xFFF5F5F5);
const kLightSurface = Color(0xFFFFFFFF);
const kLightCard = Color(0xFFEEEEEE);
const kLightText = Color(0xFF1A1A1A);
const kLightSubtext = Color(0xFF777777);

class AppColors {
  final bool isDark;
  AppColors(this.isDark);
  Color get bg => isDark ? kBg : kLightBg;
  Color get surface => isDark ? kSurface : kLightSurface;
  Color get card => isDark ? kCard : kLightCard;
  Color get text => isDark ? kText : kLightText;
  Color get subtext => isDark ? kSubtext : kLightSubtext;
}

// ── Custom Page Route ────────────────────────────────────────
Route<dynamic> _fadeSlideRoute(Widget page) {
  return PageRouteBuilder<dynamic>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

// ── App ──────────────────────────────────────────────────────
class HandwritingApp extends StatefulWidget {
  const HandwritingApp({super.key});
  @override
  State<HandwritingApp> createState() => _HandwritingAppState();
}

class _HandwritingAppState extends State<HandwritingApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandScript',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: kBg,
              colorScheme: const ColorScheme.dark(
                primary: kAccent,
                secondary: kAccent2,
                surface: kSurface,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: kLightBg,
              colorScheme: const ColorScheme.light(
                primary: kAccent,
                secondary: kAccent2,
                surface: kLightSurface,
              ),
            ),
      home: const SplashPage(),
    );
  }
}

// ── Splash ───────────────────────────────────────────────────
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _slide;
  late AnimationController _particleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(themeNotifier.isDark);
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: themeNotifier.isDark
                    ? [const Color(0xFF1A0A2E), kBg]
                    : [const Color(0xFFE8F4FD), kLightBg],
              ),
            ),
          ),
          // Floating particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _SplashParticlesPainter(
                progress: _particleCtrl.value,
                isDark: themeNotifier.isDark,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          // Main content
          FadeTransition(
            opacity: _fade,
            child: AnimatedBuilder(
              animation: _slide,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, _slide.value),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing logo
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [kAccent, kAccent2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kAccent.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: kAccent2.withValues(alpha: 0.2),
                              blurRadius: 60,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.draw_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'HandScript',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Turn your handwriting into a font',
                      style: TextStyle(
                        fontSize: 16,
                        color: c.subtext,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: kAccent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: kAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'v1.0',
                        style: TextStyle(
                          color: kAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _GlowButton(
                      label: 'Start Drawing',
                      icon: Icons.edit_rounded,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        _fadeSlideRoute(const CharacterCollectionPage()),
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
}

// ── Splash Particles Painter ─────────────────────────────────
class _SplashParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _SplashParticlesPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // Fixed seed for consistent positions
    for (int i = 0; i < 25; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * math.pi * 2;
      final radius = rng.nextDouble() * 3.5 + 1;
      final speed = rng.nextDouble() * 0.5 + 0.3;

      final t = progress * 2 * math.pi * speed + phase;
      final x = baseX + math.sin(t) * 25;
      final y = baseY + math.cos(t * 0.7) * 20;
      final opacity = (math.sin(t * 2) + 1) / 2 * 0.35 + 0.05;

      final color = i.isEven ? kAccent : kAccent2;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withValues(alpha: isDark ? opacity : opacity * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_SplashParticlesPainter o) => o.progress != progress;
}

// ── Glow Button ──────────────────────────────────────────────
class _GlowButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = kAccent;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, kAccent2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Characters ───────────────────────────────────────────────
const List<String> allCharacters = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '.',
  ',',
  ':',
  ';',
  '"',
  "'",
  '/',
  '\\',
  '!',
  '@',
  '#',
  r'$',
  '%',
  '^',
  '&',
  '*',
  '(',
  ')',
  '{',
  '}',
  '[',
  ']',
  '-',
  '=',
  '_',
  '+',
  '?',
  '<',
  '>',
  '~',
  '`',
  '|',
];

String safeKey(String char) {
  if (char == char.toUpperCase() && char != char.toLowerCase()) {
    return 'upper_$char';
  }
  if (RegExp(r'[0-9]').hasMatch(char)) return 'num_$char';
  if (char == char.toLowerCase() && char != char.toUpperCase()) {
    return 'lower_$char';
  }
  const symMap = {
    '.': 'sym_dot',
    ',': 'sym_comma',
    ':': 'sym_colon',
    ';': 'sym_semicolon',
    '"': 'sym_dquote',
    "'": "sym_squote",
    '/': 'sym_slash',
    '\\': 'sym_backslash',
    '!': 'sym_exclaim',
    '@': 'sym_at',
    '#': 'sym_hash',
    r'$': 'sym_dollar',
    '%': 'sym_percent',
    '^': 'sym_caret',
    '&': 'sym_ampersand',
    '*': 'sym_asterisk',
    '(': 'sym_lparen',
    ')': 'sym_rparen',
    '{': 'sym_lbrace',
    '}': 'sym_rbrace',
    '[': 'sym_lbracket',
    ']': 'sym_rbracket',
    '-': 'sym_minus',
    '=': 'sym_equals',
    '_': 'sym_underscore',
    '+': 'sym_plus',
    '?': 'sym_question',
    '<': 'sym_lt',
    '>': 'sym_gt',
    '~': 'sym_tilde',
    '`': 'sym_backtick',
    '|': 'sym_pipe',
  };
  return symMap[char] ?? 'char_${char.codeUnitAt(0)}';
}

// ── Category Helpers ─────────────────────────────────────────
const _catNames = ['A-Z', 'a-z', '0-9', '!@#'];
const _catStarts = [0, 26, 52, 62];

int _getCategoryForIndex(int index) {
  if (index < 26) return 0;
  if (index < 52) return 1;
  if (index < 62) return 2;
  return 3;
}

// ── Character Collection Page ────────────────────────────────
class CharacterCollectionPage extends StatefulWidget {
  const CharacterCollectionPage({super.key});
  @override
  State<CharacterCollectionPage> createState() =>
      _CharacterCollectionPageState();
}

class _CharacterCollectionPageState extends State<CharacterCollectionPage> {
  int currentIndex = 0;
  Map<String, List<List<Offset>>> savedCharacters = {};
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToCurrentIndex(),
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCurrentIndex() {
    if (!_scrollCtrl.hasClients) return;
    final target = currentIndex * 34.0 - 120;
    _scrollCtrl.animateTo(
      target.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpToCategory(int cat) {
    setState(() => currentIndex = _catStarts[cat]);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToCurrentIndex(),
    );
  }

  void onCharacterSaved(String character, List<List<Offset>> strokes) {
    setState(() {
      savedCharacters[safeKey(character)] = strokes;
      if (currentIndex < allCharacters.length - 1) {
        currentIndex++;
      } else {
        _showDoneDialog();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToCurrentIndex(),
    );
  }

  void _skipCharacter() {
    if (currentIndex < allCharacters.length - 1) {
      setState(() => currentIndex++);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentIndex(),
      );
    }
  }

  void _showDoneDialog() {
    final c = AppColors(themeNotifier.isDark);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [kAccent, kAccent2]),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'All Characters Done!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Open notepad to write in your handwriting!',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.subtext, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _GlowButton(
                label: 'Open Notepad',
                icon: Icons.edit_note_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    _fadeSlideRoute(
                      NotepadPage(savedCharacters: savedCharacters),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors(themeNotifier.isDark).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final c = AppColors(themeNotifier.isDark);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.subtext,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 24),

                // Theme toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kAccent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          themeNotifier.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: kAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: TextStyle(
                                color: c.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              themeNotifier.isDark ? 'Dark Mode' : 'Light Mode',
                              style: TextStyle(color: c.subtext, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: themeNotifier.isDark,
                        onChanged: (v) {
                          themeNotifier.toggle();
                          setModalState(() {});
                          setState(() {});
                        },
                        activeColor: kAccent,
                        activeTrackColor: kAccent.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kSuccess.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kSuccess.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: kSuccess,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                color: c.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${savedCharacters.length} / '
                              '${allCharacters.length} '
                              'characters drawn',
                              style: TextStyle(color: c.subtext, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${((savedCharacters.length / allCharacters.length) * 100).toInt()}%',
                        style: const TextStyle(
                          color: kSuccess,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(themeNotifier.isDark);
    final character = allCharacters[currentIndex];
    final progress = savedCharacters.length / allCharacters.length;
    final remaining = allCharacters.length - savedCharacters.length;
    final activeCat = _getCategoryForIndex(currentIndex);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [kAccent, kAccent2]),
              ),
              child: const Icon(
                Icons.draw_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'HandScript',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: c.text,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              _fadeSlideRoute(NotepadPage(savedCharacters: savedCharacters)),
            ),
            icon: const Icon(Icons.edit_note_rounded, color: kAccent),
            tooltip: 'Open Notepad',
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_rounded, color: kAccent),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress + Category Tabs + Character Strip ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              color: c.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${savedCharacters.length} / ${allCharacters.length}',
                      style: TextStyle(
                        color: c.subtext,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        if (remaining > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: kAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$remaining left',
                              style: const TextStyle(
                                color: kAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: kAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Gradient progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 6,
                    child: LayoutBuilder(
                      builder: (context, constraints) => Stack(
                        children: [
                          Container(color: c.card),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * progress,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kAccent, kAccent2],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int cat = 0; cat < _catNames.length; cat++) ...[
                      if (cat > 0) const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _jumpToCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: activeCat == cat
                                ? kAccent.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: activeCat == cat
                                  ? kAccent
                                  : c.subtext.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _catNames[cat],
                            style: TextStyle(
                              color: activeCat == cat ? kAccent : c.subtext,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Character strip (scrollable + tappable)
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    scrollDirection: Axis.horizontal,
                    itemCount: allCharacters.length,
                    itemBuilder: (context, index) {
                      final key = safeKey(allCharacters[index]);
                      final isDone = savedCharacters.containsKey(key);
                      final isCurrent = index == currentIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() => currentIndex = index);
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToCurrentIndex(),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isCurrent ? 36 : 30,
                          height: isCurrent ? 36 : 30,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isDone
                                ? kSuccess.withValues(alpha: 0.2)
                                : isCurrent
                                ? kAccent.withValues(alpha: 0.2)
                                : c.card,
                            border: Border.all(
                              color: isDone
                                  ? kSuccess
                                  : isCurrent
                                  ? kAccent
                                  : Colors.transparent,
                              width: isCurrent ? 2 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(
                              isCurrent ? 8 : 6,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              allCharacters[index],
                              style: TextStyle(
                                color: isDone
                                    ? kSuccess
                                    : isCurrent
                                    ? kAccent
                                    : c.subtext,
                                fontWeight: isCurrent
                                    ? FontWeight.w900
                                    : FontWeight.bold,
                                fontSize: isCurrent ? 13 : 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DrawingCanvas(
              character: character,
              onSaved: (strokes) => onCharacterSaved(character, strokes),
              onSkip: _skipCharacter,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawing Canvas ───────────────────────────────────────────
class DrawingCanvas extends StatefulWidget {
  final String character;
  final Function(List<List<Offset>>) onSaved;
  final VoidCallback? onSkip;
  const DrawingCanvas({
    super.key,
    required this.character,
    required this.onSaved,
    this.onSkip,
  });
  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas>
    with SingleTickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];
  late AnimationController _charAnim;
  late Animation<double> _charScale;

  @override
  void initState() {
    super.initState();
    _charAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _charScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _charAnim, curve: Curves.elasticOut));
    _charAnim.forward();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(DrawingCanvas old) {
    super.didUpdateWidget(old);
    if (old.character != widget.character) {
      setState(() {
        strokes = [];
        currentStroke = [];
      });
      _charAnim.reset();
      _charAnim.forward();
    }
  }

  @override
  void dispose() {
    _charAnim.dispose();
    super.dispose();
  }

  void onPanStart(DragStartDetails d) =>
      setState(() => currentStroke = [d.localPosition]);
  void onPanUpdate(DragUpdateDetails d) =>
      setState(() => currentStroke.add(d.localPosition));
  void onPanEnd(DragEndDetails d) => setState(() {
    strokes.add(List.from(currentStroke));
    currentStroke = [];
  });
  void clearCanvas() => setState(() {
    strokes = [];
    currentStroke = [];
  });

  void _saveLocally() {
    final c = AppColors(themeNotifier.isDark);
    widget.onSaved(strokes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: kSuccess),
            const SizedBox(width: 8),
            Text(
              '"${widget.character}" saved!',
              style: TextStyle(color: c.text),
            ),
          ],
        ),
        backgroundColor: c.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(themeNotifier.isDark);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _charScale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kAccent.withValues(alpha: 0.3),
                  width: 1,
                ),
                color: kAccent.withValues(alpha: 0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Draw  ',
                    style: TextStyle(color: c.subtext, fontSize: 16),
                  ),
                  Text(
                    widget.character,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: kAccent,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 360,
                  maxHeight: 360,
                ),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: strokes.isNotEmpty
                        ? kAccent.withValues(alpha: 0.5)
                        : c.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withValues(
                        alpha: strokes.isNotEmpty ? 0.15 : 0.05,
                      ),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: GestureDetector(
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background + strokes
                        RepaintBoundary(
                          key: _canvasKey,
                          child: CustomPaint(
                            painter: CanvasBgPainter(
                              isDark: themeNotifier.isDark,
                              ghostChar: widget.character,
                            ),
                            foregroundPainter: DrawingPainter(
                              strokes: strokes,
                              currentStroke: currentStroke,
                              isDark: themeNotifier.isDark,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        // Stroke count badge
                        if (strokes.isNotEmpty)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: c.card.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '${strokes.length} stroke${strokes.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    color: kAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IconBtn(
                icon: Icons.undo_rounded,
                color: kSubtext,
                onTap: strokes.isEmpty
                    ? null
                    : () => setState(() => strokes.removeLast()),
              ),
              const SizedBox(width: 12),
              _IconBtn(
                icon: Icons.delete_outline_rounded,
                color: kError,
                onTap: strokes.isEmpty ? null : clearCanvas,
              ),
              const SizedBox(width: 16),
              // Skip button
              if (widget.onSkip != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: widget.onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: c.subtext.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.skip_next_rounded,
                            color: c.subtext,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Skip',
                            style: TextStyle(
                              color: c.subtext,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Save & Next button (dimmed when empty)
              AnimatedOpacity(
                opacity: strokes.isEmpty ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: _GlowButton(
                  label: 'Save & Next',
                  icon: Icons.arrow_forward_rounded,
                  onTap: strokes.isEmpty ? () {} : _saveLocally,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Icon Button (theme-aware) ────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _IconBtn({required this.icon, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = AppColors(themeNotifier.isDark);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? color.withValues(alpha: 0.1) : c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onTap != null
                ? color.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Icon(icon, color: onTap != null ? color : c.subtext, size: 22),
      ),
    );
  }
}

// ── Notepad Page ─────────────────────────────────────────────
class NotepadPage extends StatefulWidget {
  final Map<String, List<List<Offset>>> savedCharacters;
  const NotepadPage({super.key, required this.savedCharacters});
  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  final TextEditingController _ctrl = TextEditingController();
  final GlobalKey _pageKey = GlobalKey();
  String typedText = '';
  double fontSize = 48;
  bool _showKeyboard = true;

  double get charW => fontSize * 0.65;
  double get charH => fontSize * 1.1;
  double get spaceW => fontSize * 0.35;
  double get lineH => fontSize * 1.6;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? getCharKey(String char) {
    if (char == char.toUpperCase() && char != char.toLowerCase()) {
      return 'upper_$char';
    }
    if (RegExp(r'[0-9]').hasMatch(char)) return 'num_$char';
    if (char == char.toLowerCase() && char != char.toUpperCase()) {
      return 'lower_$char';
    }
    const symMap = {
      '.': 'sym_dot',
      ',': 'sym_comma',
      ':': 'sym_colon',
      ';': 'sym_semicolon',
      '"': 'sym_dquote',
      "'": "sym_squote",
      '/': 'sym_slash',
      '\\': 'sym_backslash',
      '!': 'sym_exclaim',
      '@': 'sym_at',
      '#': 'sym_hash',
      r'$': 'sym_dollar',
      '%': 'sym_percent',
      '^': 'sym_caret',
      '&': 'sym_ampersand',
      '*': 'sym_asterisk',
      '(': 'sym_lparen',
      ')': 'sym_rparen',
      '{': 'sym_lbrace',
      '}': 'sym_rbrace',
      '[': 'sym_lbracket',
      ']': 'sym_rbracket',
      '-': 'sym_minus',
      '=': 'sym_equals',
      '_': 'sym_underscore',
      '+': 'sym_plus',
      '?': 'sym_question',
      '<': 'sym_lt',
      '>': 'sym_gt',
      '~': 'sym_tilde',
      '`': 'sym_backtick',
      '|': 'sym_pipe',
    };
    return symMap[char];
  }

  void _showDownloadDialog() {
    final c = AppColors(themeNotifier.isDark);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [kAccent, kAccent2]),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Download As',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred format',
                style: TextStyle(color: c.subtext, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // PNG
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _downloadAsPng();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: kAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PNG Image',
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'High quality image file',
                            style: TextStyle(color: c.subtext, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kAccent,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // PDF
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _downloadAsPdf();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kAccent2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kAccent2.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent2.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: kAccent2,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Document',
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Printable A4 document',
                            style: TextStyle(color: c.subtext, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kAccent2,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadAsPng() async {
    final c = AppColors(themeNotifier.isDark);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kAccent,
                ),
              ),
              const SizedBox(width: 12),
              Text('Preparing PNG...', style: TextStyle(color: c.text)),
            ],
          ),
          backgroundColor: c.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      RenderRepaintBoundary boundary =
          _pageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      await DownloadHandler.downloadBytes(
        fileName: 'my_handwriting.png',
        mimeType: 'image/png',
        bytes: pngBytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kSuccess),
                const SizedBox(width: 8),
                Text('PNG downloaded!', style: TextStyle(color: c.text)),
              ],
            ),
            backgroundColor: c.card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e', style: TextStyle(color: c.text)),
            backgroundColor: kError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadAsPdf() async {
    final c = AppColors(themeNotifier.isDark);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kAccent2,
                ),
              ),
              const SizedBox(width: 12),
              Text('Preparing PDF...', style: TextStyle(color: c.text)),
            ],
          ),
          backgroundColor: c.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      RenderRepaintBoundary boundary =
          _pageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final pdfDoc = pw.Document();
      final pageImage = pw.MemoryImage(pngBytes);
      pdfDoc.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context ctx) =>
              pw.Center(child: pw.Image(pageImage, fit: pw.BoxFit.contain)),
        ),
      );
      final pdfBytes = await pdfDoc.save();
      await DownloadHandler.downloadBytes(
        fileName: 'my_handwriting.pdf',
        mimeType: 'application/pdf',
        bytes: pdfBytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kSuccess),
                const SizedBox(width: 8),
                Text('PDF downloaded!', style: TextStyle(color: c.text)),
              ],
            ),
            backgroundColor: c.card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e', style: TextStyle(color: c.text)),
            backgroundColor: kError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: lineH * 2),
        Center(
          child: Column(
            children: [
              Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Start typing below...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your handwriting will appear here',
                // FIX: Colors.grey only has swatches at 50,100,...,900 —
                // grey[350] doesn't exist and silently resolves to null,
                // which falls back to default (black) text. Using grey[400].
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(themeNotifier.isDark);
    final screenW = MediaQuery.of(context).size.width;
    final a4W = math.min(screenW * 0.92, 794.0);
    final a4H = a4W * 1.4142;

    return Scaffold(
      backgroundColor: themeNotifier.isDark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFD0D0D0),
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Handwriting Notepad',
          style: TextStyle(
            color: c.text,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          // Font size slider
          PopupMenuButton(
            icon: const Icon(Icons.format_size_rounded, color: kAccent),
            color: c.card,
            tooltip: 'Font Size',
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) => Column(
                    children: [
                      Text(
                        'Font Size: ${fontSize.toInt()}pt',
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: fontSize,
                        min: 24,
                        max: 80,
                        divisions: 14,
                        activeColor: kAccent,
                        inactiveColor: c.surface,
                        onChanged: (v) {
                          setMenuState(() => fontSize = v);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _showKeyboard ? Icons.keyboard_hide : Icons.keyboard,
              color: kAccent,
            ),
            tooltip: _showKeyboard ? 'Hide Keyboard' : 'Show Keyboard',
            onPressed: () => setState(() => _showKeyboard = !_showKeyboard),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: kAccent),
            onPressed: _showDownloadDialog,
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: kError),
            onPressed: () => setState(() {
              typedText = '';
              _ctrl.clear();
            }),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: RepaintBoundary(
                  key: _pageKey,
                  child: Container(
                    width: a4W,
                    constraints: BoxConstraints(minHeight: a4H),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Ruled paper lines
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CustomPaint(
                              painter: RuledPaperPainter(
                                lineHeight: lineH,
                                marginLeft: a4W * 0.09,
                                topPadding: 40,
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            a4W * 0.1,
                            40,
                            a4W * 0.05,
                            40,
                          ),
                          child: typedText.isEmpty
                              ? _buildEmptyState()
                              : _buildHandwritingText(a4W),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Keyboard
          if (_showKeyboard)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: TextStyle(color: c.text, fontSize: 16),
                cursorColor: kAccent,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Type here to see your handwriting...',
                  hintStyle: TextStyle(color: c.subtext, fontSize: 14),
                  filled: true,
                  fillColor: c.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kAccent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (v) => setState(() => typedText = v),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHandwritingText(double a4W) {
    final pageW = a4W * 0.85;
    List<Widget> lines = [];
    List<Widget> currentLine = [];
    double currentLineW = 0;

    for (int i = 0; i < typedText.length; i++) {
      final char = typedText[i];
      if (char == '\n') {
        lines.add(_buildLine(currentLine));
        currentLine = [];
        currentLineW = 0;
        continue;
      }
      if (char == ' ') {
        if (currentLineW + spaceW > pageW) {
          lines.add(_buildLine(currentLine));
          currentLine = [];
          currentLineW = 0;
        }
        currentLine.add(SizedBox(width: spaceW));
        currentLineW += spaceW;
        continue;
      }
      if (currentLineW + charW > pageW) {
        lines.add(_buildLine(currentLine));
        currentLine = [];
        currentLineW = 0;
      }
      final key = getCharKey(char);
      final strokes = key != null ? widget.savedCharacters[key] : null;

      if (strokes != null && strokes.isNotEmpty) {
        currentLine.add(
          SizedBox(
            width: charW,
            height: charH,
            child: CustomPaint(
              painter: MiniCharPainter(
                strokes: strokes,
                inkColor: Colors.black87,
              ),
            ),
          ),
        );
        currentLineW += charW;
      } else {
        final textW = fontSize * 0.6;
        currentLine.add(
          SizedBox(
            width: textW,
            height: charH,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                char,
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  color: Colors.black87,
                  height: 1,
                ),
              ),
            ),
          ),
        );
        currentLineW += textW;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(_buildLine(currentLine));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }

  Widget _buildLine(List<Widget> chars) {
    return SizedBox(
      height: lineH,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: chars),
    );
  }
}

// ── Canvas Background Painter ────────────────────────────────
class CanvasBgPainter extends CustomPainter {
  final bool isDark;
  final String? ghostChar;
  CanvasBgPainter({required this.isDark, this.ghostChar});

  @override
  void paint(Canvas canvas, Size size) {
    // Background fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = isDark ? kCard : kLightCard,
    );

    // Dot grid pattern
    final dp = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04);
    for (double x = 20; x < size.width; x += 30) {
      for (double y = 20; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1.5, dp);
      }
    }

    // Ghost guide character (very faint watermark)
    if (ghostChar != null && ghostChar!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: ghostChar,
          style: TextStyle(
            fontSize: 180,
            fontWeight: FontWeight.w900,
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.04,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CanvasBgPainter o) =>
      o.isDark != isDark || o.ghostChar != ghostChar;
}

// ── Drawing Painter (adaptive colors) ────────────────────────
class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final bool isDark;
  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    this.isDark = true,
  });

  void _drawPath(Canvas canvas, List<Offset> s, Paint p) {
    if (s.length < 2) return;
    final path = Path();
    path.moveTo(s[0].dx, s[0].dy);
    for (int i = 1; i < s.length - 1; i++) {
      final mx = (s[i].dx + s[i + 1].dx) / 2;
      final my = (s[i].dy + s[i + 1].dy) / 2;
      path.quadraticBezierTo(s[i].dx, s[i].dy, mx, my);
    }
    path.lineTo(s.last.dx, s.last.dy);
    canvas.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Adaptive ink color — visible in both light and dark modes
    final inkColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final glowColor = isDark
        ? kAccent.withValues(alpha: 0.3)
        : kAccent2.withValues(alpha: 0.15);

    final main = Paint()
      ..color = inkColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final glow = Paint()
      ..color = glowColor
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final s in strokes) {
      _drawPath(canvas, s, glow);
      _drawPath(canvas, s, main);
    }
    if (currentStroke.isNotEmpty) {
      _drawPath(canvas, currentStroke, glow);
      _drawPath(canvas, currentStroke, main);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter o) => true;
}

// ── Mini Char Painter ────────────────────────────────────────
class MiniCharPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color inkColor;
  MiniCharPainter({required this.strokes, this.inkColor = Colors.black87});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;
    double minX = double.infinity, minY = double.infinity;
    double maxX = 0, maxY = 0;
    for (final s in strokes) {
      for (final p in s) {
        minX = math.min(minX, p.dx);
        minY = math.min(minY, p.dy);
        maxX = math.max(maxX, p.dx);
        maxY = math.max(maxY, p.dy);
      }
    }
    if (maxX <= minX || maxY <= minY) return;
    double sx = size.width / (maxX - minX + 1);
    double sy = size.height / (maxY - minY + 1);
    double scale = math.min(sx, sy) * 0.82;
    double offX = (size.width - (maxX - minX) * scale) / 2;
    double offY = (size.height - (maxY - minY) * scale) / 2;
    final paint = Paint()
      ..color = inkColor
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(
        (stroke[0].dx - minX) * scale + offX,
        (stroke[0].dy - minY) * scale + offY,
      );
      for (int i = 1; i < stroke.length - 1; i++) {
        final mx =
            ((stroke[i].dx + stroke[i + 1].dx) / 2 - minX) * scale + offX;
        final my =
            ((stroke[i].dy + stroke[i + 1].dy) / 2 - minY) * scale + offY;
        path.quadraticBezierTo(
          (stroke[i].dx - minX) * scale + offX,
          (stroke[i].dy - minY) * scale + offY,
          mx,
          my,
        );
      }
      path.lineTo(
        (stroke.last.dx - minX) * scale + offX,
        (stroke.last.dy - minY) * scale + offY,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(MiniCharPainter o) => false;
}

// ── Ruled Paper Painter ──────────────────────────────────────
class RuledPaperPainter extends CustomPainter {
  final double lineHeight;
  final double marginLeft;
  final double topPadding;

  RuledPaperPainter({
    required this.lineHeight,
    required this.marginLeft,
    this.topPadding = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Blue ruled lines
    final linePaint = Paint()
      ..color = const Color(0xFFBDD6E6)
      ..strokeWidth = 0.8;

    // Red margin line
    final marginPaint = Paint()
      ..color = const Color(0xFFE88E8E)
      ..strokeWidth = 1.2;

    // Draw horizontal ruled lines
    double y = topPadding + lineHeight;
    while (y < size.height - 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += lineHeight;
    }

    // Draw red margin line
    canvas.drawLine(
      Offset(marginLeft, 0),
      Offset(marginLeft, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(RuledPaperPainter o) =>
      o.lineHeight != lineHeight || o.marginLeft != marginLeft;
}
