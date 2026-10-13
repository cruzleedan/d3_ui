import 'dart:ui' as ui;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart'
    show ValueListenable, visibleForTesting;
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// The brightest any pixel of the aurora may be, as relative luminance (0 to
/// 1). Light text on top keeps 4.5:1 against it:
/// `test/aurora_hero_test.dart` checks this against every brand's text colour.
const double auroraMaxLuminance = 0.13;

/// The night sky and the three curtains, from a brand's *dark* theme tokens:
/// the sky is the dark surface with a breath of the brand, the curtains are the
/// brand's primary, a lighter container tone and the primary turned round the
/// hue wheel for depth. A brand change recolours the shader live.
({Color sky, List<Color> curtains}) auroraPalette(D3ColorTokens night) {
  final hsl = HSLColor.fromColor(night.primary);
  return (
    sky: Color.lerp(night.surface, night.primary, 0.10)!,
    curtains: [
      night.primary,
      hsl.withHue((hsl.hue + 38) % 360).toColor(),
      hsl.withHue((hsl.hue - 32) % 360).toColor(),
    ],
  );
}

/// Northern lights, drawn on the GPU, behind [child]: dark sky, three shimmering
/// curtains in the brand's colours, a few stars. Give it the brand's *dark*
/// tokens ([night]) and put light text on top.
///
/// Calm by design: it drifts slowly, stands still when the user prefers reduced
/// motion, stops while the browser tab is hidden or the widget is out of the
/// tree, and falls back to a plain brand gradient if the shader cannot load. It
/// is decorative and hidden from assistive technology.
class AuroraHero extends StatefulWidget {
  const AuroraHero({
    super.key,
    required this.night,
    required this.child,
    this.height,
    this.shaded = true,
  });

  /// False shows only the plain brand gradient: no shader is loaded or run (the
  /// embedded view, which should stay as light as possible).
  final bool shaded;

  /// Forgets the loaded shader (tests only: a load started in one test's fake
  /// clock cannot finish in the next).
  @visibleForTesting
  static void resetForTest() => _AuroraHeroState._program = null;

  /// The brand's dark-theme colour tokens.
  final D3ColorTokens night;

  final Widget child;

  /// A fixed height; null takes the child's.
  final double? height;

  @override
  State<AuroraHero> createState() => _AuroraHeroState();
}

class _AuroraHeroState extends State<AuroraHero>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static Future<ui.FragmentProgram>? _program;

  ui.FragmentShader? _shader;
  late final Ticker _ticker;
  final _time = ValueNotifier<double>(0);

  /// Where the pointer is (in the shader's units) and how strongly it is felt,
  /// eased towards its target every frame so it glides.
  final _pointer = _PointerState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
      _pointer.ease();
      _time.value = elapsed.inMicroseconds / 1e6;
    });
    if (widget.shaded) _load();
  }

  Future<void> _load() async {
    try {
      final program = await (_program ??= ui.FragmentProgram.fromAsset(
        'shaders/aurora.frag',
      ));
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
      _syncTicker();
    } catch (_) {
      // Unsupported or failed: show the gradient instead.
      _program = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A hidden tab (on the web, visibilitychange) stops the animation.
    _syncTicker();
  }

  bool _reduceMotion = false;

  void _syncTicker() {
    final visible =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.hidden &&
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused;
    final shouldRun = _shader != null && visible && !_reduceMotion;
    if (shouldRun && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _time.value = 4; // a pleasant still frame
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant AuroraHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _time.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = auroraPalette(widget.night);
    Widget background;
    if (_shader == null) {
      // No shader (embedded, loading, or unsupported): a calm night gradient.
      background = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.sky,
              Color.alphaBlend(
                palette.curtains[0].withValues(alpha: 0.28),
                palette.sky,
              ),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      );
    } else {
      background = RepaintBoundary(
        child: CustomPaint(
          painter: _AuroraPainter(
            shader: _shader!,
            time: _time,
            pointer: _pointer,
            sky: palette.sky,
            curtains: palette.curtains,
          ),
          child: const SizedBox.expand(),
        ),
      );
    }

    final content = _reduceMotion || _shader == null
        ? Stack(
            children: [
              Positioned.fill(child: ExcludeSemantics(child: background)),
              widget.child,
            ],
          )
        : _withPointer(background);
    return widget.height == null
        ? content
        : SizedBox(height: widget.height, child: content);
  }

  /// The aurora follows a mouse over it, or a finger on it, and leans towards it.
  Widget _withPointer(Widget background) {
    void aim(Offset p, Size size) =>
        _pointer.aim(Offset(p.dx / size.height, p.dy / size.height));
    final content = Stack(
      children: [
        Positioned.fill(child: ExcludeSemantics(child: background)),
        widget.child,
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (e) => aim(e.localPosition, size),
          onExit: (_) => _pointer.release(),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (e) => aim(e.localPosition, size),
            onPointerMove: (e) => aim(e.localPosition, size),
            onPointerUp: (_) => _pointer.release(),
            onPointerCancel: (_) => _pointer.release(),
            child: content,
          ),
        );
      },
    );
  }
}

/// The pointer's eased position and strength, shared with the painter.
class _PointerState {
  Offset position = const Offset(0.8, 0.4);
  double strength = 0;
  Offset _targetPosition = const Offset(0.8, 0.4);
  double _targetStrength = 0;

  void aim(Offset p) {
    _targetPosition = p;
    _targetStrength = 1;
  }

  void release() => _targetStrength = 0;

  /// One frame of easing.
  void ease() {
    position = Offset.lerp(position, _targetPosition, 0.12)!;
    strength += (_targetStrength - strength) * 0.07;
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.shader,
    required this.time,
    required this.pointer,
    required this.sky,
    required this.curtains,
  }) : super(repaint: time);

  final ui.FragmentShader shader;
  final ValueListenable<double> time;
  final _PointerState pointer;
  final Color sky;
  final List<Color> curtains;

  void _color(int index, Color c) {
    shader
      ..setFloat(index, c.r)
      ..setFloat(index + 1, c.g)
      ..setFloat(index + 2, c.b);
  }

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time.value)
      ..setFloat(3, auroraMaxLuminance);
    _color(4, sky);
    _color(7, curtains[0]);
    _color(10, curtains[1]);
    _color(13, curtains[2]);
    shader
      ..setFloat(16, pointer.position.dx)
      ..setFloat(17, pointer.position.dy)
      ..setFloat(18, pointer.strength);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.sky != sky || old.curtains != curtains;
}
