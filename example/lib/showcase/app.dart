import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'brands.dart';
import 'page_model.dart';
import 'params.dart';
import 'registry.dart';
import 'scope.dart';
import 'shell.dart';

/// The d3_ui showcase: the shell, the brands, and the choices the address makes.
///
/// The address is the single source of truth. The page is its path
/// (`/button`), the brand, theme and `embed` are its query
/// (`?brand=green&theme=dark`). Every choice goes to a new address (a history
/// entry), so browser back undoes it; back, forward and reload come from the
/// router. Old `/?page=button` links are redirected.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({
    super.key,
    required this.brandThemes,
    this.initialUri,
  });

  final Map<String, BrandThemes> brandThemes;

  /// The address to open (on the web the browser's own address is used).
  final Uri? initialUri;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late final Uri _initial = widget.initialUri ?? Uri(path: '/');

  late final GoRouter _router = GoRouter(
    initialLocation: _initial.toString(),
    redirect: _redirect,
    routes: [
      // The overview and every other page are the same screen: one page key,
      // so switching pages updates the shell in place instead of replacing it
      // (no transition, the navigation stays put).
      for (final path in const ['/', '/:page'])
        GoRoute(
          path: path,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: const ValueKey('showcase'),
            child: ShowcaseShell(
              embed: ShowcaseParams.fromUri(state.uri).embed,
            ),
          ),
        ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onLocationChanged);
    _router.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    if (!mounted) return;
    // The router can announce its first location while the app is building.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  /// Old links and unknown pages.
  String? _redirect(BuildContext context, GoRouterState state) {
    final old = legacyLocation(state.uri);
    if (old != null) return old.toString();
    final page = ShowcaseParams.fromUri(state.uri).page;
    final known = page == null || showcasePages.any((p) => p.id == page);
    if (!known || page == showcasePages.first.id) {
      final query = state.uri.queryParameters;
      return Uri(path: '/', queryParameters: query.isEmpty ? null : query)
          .toString();
    }
    return null;
  }

  /// Where the router is, before its first parse the address it was given.
  Uri get _uri {
    final config = _router.routerDelegate.currentConfiguration;
    return config.isEmpty ? _initial : config.uri;
  }

  ShowcaseParams get _params => ShowcaseParams.fromUri(_uri);
  ShowcaseBrand get _brand => brandById(_params.brand);
  ThemeMode get _themeMode => _params.themeMode ?? ThemeMode.system;
  String get _pageId => pageForId(_params.page).id;

  double get _textScale => _params.textScale ?? 1.0;

  String _location({
    String? page,
    ShowcaseBrand? brand,
    ThemeMode? mode,
    double? textScale,
  }) =>
      showcaseLocation(
        page: page ?? _pageId,
        themeMode: mode ?? _themeMode,
        brand: (brand ?? _brand).id,
        textScale: textScale ?? _textScale,
        embed: _params.embed,
        defaultPage: showcasePages.first.id,
        defaultBrand: showcaseBrands.first.id,
      ).toString();

  @override
  Widget build(BuildContext context) {
    final brand = _brand;
    final themes = widget.brandThemes[brand.id]!;
    final pageId = _pageId;
    return MaterialApp.router(
      title: 'd3_ui: a Flutter design system',
      debugShowCheckedModeBanner: false,
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        // Everything the page shows, dialogs, sheets and toasts included (they
        // live in the navigator's overlay, under this builder), gets the mimicked
        // text size; the showcase's own controls opt back out to the device's.
        final system = MediaQuery.textScalerOf(context);
        final scale = _textScale;
        return MediaQuery(
          data: scale == 1.0
              ? MediaQuery.of(context)
              : MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
          child: _scope(child, system, brand, themes, pageId),
        );
      },
    );
  }

  Widget _scope(
    Widget? child,
    TextScaler system,
    ShowcaseBrand brand,
    BrandThemes themes,
    String pageId,
  ) {
    return ShowcaseScope(
      pageId: pageId,
      onPageChanged: (id) => _router.go(_location(page: id)),
      brand: brand,
      themeMode: _themeMode,
      brandThemes: widget.brandThemes,
      embed: _params.embed,
      onBrandChanged: (b) => _router.go(_location(brand: b)),
      onThemeModeChanged: (m) => _router.go(_location(mode: m)),
      textScale: _textScale,
      onTextScaleChanged: (s) => _router.go(_location(textScale: s)),
      systemTextScaler: system,
      // The tab title follows the page, so a bookmark has a useful name.
      child: Title(
        title: pageId == showcasePages.first.id
            ? 'd3_ui: a Flutter design system'
            : '${pageForId(pageId).title} · d3_ui',
        color: themes.light.colorScheme.primary,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// The page for a page id; unknown or missing is the overview.
ShowcasePage pageForId(String? id) => showcasePages.firstWhere(
      (p) => p.id == id,
      orElse: () => showcasePages.first,
    );
