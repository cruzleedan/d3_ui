import 'dart:ui' as ui;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart'
    show ValueListenable, visibleForTesting;
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// How strongly the aurora tints the surface (0 to 1). Capped so text on top
/// keeps 4.5:1: `test/aurora_contrast_test.dart` checks the worst case.
const double auroraStrength = 0.34;

/// The three colours of the aurora, from the theme's own tokens: the brand's
/// primary, its container, and the primary turned 40 degrees round the hue wheel
/// for depth. A brand change recolours the shader live.
List<Color> auroraColors(D3ColorTokens colors) {
  final hsl = HSLColor.fromColor(colors.primary);
  return [
    colors.primary,
    colors.primaryContainer,
    hsl.withHue((hsl.hue + 40) % 360).toColor(),
  ];
}

/// A slow, GPU-shaded aurora behind [child], coloured from the brand.
///
/// Calm by design: it drifts slowly, stands still when the user prefers reduced
/// motion, stops while the browser tab is hidden or the widget is out of the
/// tree, and falls back to a plain brand gradient if the shader cannot load. It
/// is decorative and hidden from assistive technology.
class AuroraHero extends StatefulWidget {
  const AuroraHero({
    super.key,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
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
    final colors = context.d3Colors;
    final palette = auroraColors(colors);
    Widget background;
    if (_shader == null) {
      background = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                palette[0].withValues(alpha: auroraStrength * 0.6),
                colors.surfaceContainerLow,
              ),
              colors.surfaceContainerLow,
              Color.alphaBlend(
                palette[2].withValues(alpha: auroraStrength * 0.6),
                colors.surfaceContainerLow,
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
            base: colors.surfaceContainerLow,
            palette: palette,
          ),
          child: const SizedBox.expand(),
        ),
      );
    }

    final content = Stack(
      children: [
        Positioned.fill(child: ExcludeSemantics(child: background)),
        widget.child,
      ],
    );
    return widget.height == null
        ? content
        : SizedBox(height: widget.height, child: content);
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.shader,
    required this.time,
    required this.base,
    required this.palette,
  }) : super(repaint: time);

  final ui.FragmentShader shader;
  final ValueListenable<double> time;
  final Color base;
  final List<Color> palette;

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
      ..setFloat(3, auroraStrength);
    _color(4, base);
    _color(7, palette[0]);
    _color(10, palette[1]);
    _color(13, palette[2]);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.base != base || old.palette != palette;
}
