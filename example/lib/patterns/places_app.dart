import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../showcase/photos.dart';
import 'places_data.dart';

/// A small app made only of d3_ui parts, with fictional data, laid out the way
/// Material's canonical layouts ask for each window size (from the width it is
/// given, so it also adapts inside a frame):
///
/// - compact: a bottom [D3NavBar] and one pane; a place opens in a sheet.
/// - medium: a [D3NavRail] and one pane; a place opens in a sheet.
/// - expanded: a rail, and list and detail side by side.
///
/// It has its own Navigator and ScaffoldMessenger, so its search page, sheets,
/// dialogs and toasts stay inside the frame (they are opened with
/// `useRootNavigator: false`). It is deliberately not a MaterialApp: an app of
/// its own would report its own route to the browser and overwrite the page's
/// address.
class PlacesApp extends StatelessWidget {
  const PlacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _PlacesHome(),
        ),
      ),
    );
  }
}

class _PlacesHome extends StatefulWidget {
  const _PlacesHome();

  @override
  State<_PlacesHome> createState() => _PlacesHomeState();
}

class _PlacesHomeState extends State<_PlacesHome> {
  final List<Place> _places = [...seedPlaces];
  final Set<String> _saved = {'p1'};
  Set<String> _cuisineFilter = {};
  String? _selectedId = 'p1';
  bool _loading = true;
  int _tab = 0;
  bool _notify = true;
  String _units = 'km';

  static const _titles = ['Explore', 'Saved', 'Settings'];

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  List<Place> get _filtered => [
        for (final p in _places)
          if (_cuisineFilter.isEmpty || _cuisineFilter.contains(p.cuisine)) p,
      ];

  List<Place> get _savedPlaces => [
        for (final p in _places)
          if (_saved.contains(p.id)) p,
      ];

  Place? get _selected {
    for (final p in _places) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  String _distance(Place p) => _units == 'km'
      ? '${p.distanceKm.toStringAsFixed(1)} km'
      : '${(p.distanceKm * 0.621).toStringAsFixed(1)} mi';

  void _toggleSaved(Place p) {
    setState(
      () => _saved.contains(p.id) ? _saved.remove(p.id) : _saved.add(p.id),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Opens a place: in the detail pane when there is one, else in a sheet.
  Future<void> _open(Place p, D3WindowSizeClass size) async {
    if (size.isExpanded) {
      setState(() => _selectedId = p.id);
      return;
    }
    await D3BottomSheet.show<void>(
      context,
      useRootNavigator: false,
      title: p.name,
      subtitle: '${p.cuisine} · ${p.area}',
      snapPoints: const [D3SnapPoint(0.62)],
      child: StatefulBuilder(
        builder: (sheetContext, setSheet) => _PlaceDetail(
          place: p,
          distance: _distance(p),
          saved: _saved.contains(p.id),
          onToggleSaved: () {
            _toggleSaved(p);
            setSheet(() {});
          },
        ),
      ),
    );
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final canSave = ValueNotifier<bool>(false);
    final bodyKey = GlobalKey();
    String? cuisine;
    name.addListener(() => canSave.value = name.text.trim().isNotEmpty);

    final added = await D3FormSheet.show<Place>(
      context,
      useRootNavigator: false,
      title: 'Add a place',
      primaryAction: D3FormSheetAction(
        label: 'Add',
        listenable: canSave,
        enabledBuilder: () => canSave.value,
        onPressed: () => D3FormSheet.pop(
          bodyKey.currentContext!,
          Place(
            id: 'new-${_places.length}',
            name: name.text.trim(),
            cuisine: cuisine ?? 'Brunch',
            area: 'Near you',
            rating: 0,
            distanceKm: 0.3,
            photo: photoNames[_places.length % photoNames.length],
            about: 'Added by you.',
          ),
        ),
      ),
      child: Builder(
        key: bodyKey,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              D3TextField(label: 'Name', controller: name, isRequired: true),
              const SizedBox(height: 12),
              D3DropdownField<String, String>(
                label: 'Cuisine',
                items: cuisines,
                itemLabel: (c) => c,
                itemValue: (c) => c,
                hintText: 'Choose one',
                onChanged: (c) => cuisine = c,
              ),
            ],
          ),
        ),
      ),
    );
    name.dispose();
    canSave.dispose();
    if (added != null && mounted) {
      setState(() {
        _places.insert(0, added);
        _selectedId = added.id;
      });
      D3Toast.success(context, title: '${added.name} added');
    }
  }

  Future<void> _remove(Place p) async {
    final ok = await D3Dialog.show<bool>(
      context,
      useRootNavigator: false,
      icon: Icons.delete_outline_rounded,
      iconColor: context.d3Colors.error,
      title: 'Remove ${p.name}?',
      message: 'It will leave your saved places.',
      actions: [
        D3DialogAction(
          label: 'Cancel',
          onPressedWithContext: (c) => D3Dialog.pop(c, false),
        ),
        D3DialogAction(
          label: 'Remove',
          isDestructive: true,
          onPressedWithContext: (c) => D3Dialog.pop(c, true),
        ),
      ],
    );
    if (ok != true || !mounted) return;
    setState(() => _saved.remove(p.id));
    D3Toast.show(
      context,
      title: 'Removed ${p.name}',
      action: D3ToastAction(
        label: 'Undo',
        onPressed: () => setState(() => _saved.add(p.id)),
      ),
    );
  }

  // ── Pieces ─────────────────────────────────────────────────────────────────

  Widget _tile(Place p, D3WindowSizeClass size, {bool swipe = false}) {
    final selected = size.isExpanded && p.id == _selectedId;
    final tile = D3ListTile(
      leading: D3Avatar(name: p.name, imageUrl: photoUrl(p.photo)),
      title: p.name,
      subtitle: '${p.cuisine} · ${_distance(p)}',
      trailing: p.rating > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 16),
                const SizedBox(width: 2),
                Text('${p.rating}'),
              ],
            )
          : null,
      onTap: () => _open(p, size),
    );
    final row = swipe
        ? D3SlidableRow(
            groupTag: 'saved',
            actions: [
              D3SwipeAction(
                icon: Icons.delete_outline,
                label: 'Remove',
                onPressed: () => _remove(p),
              ),
            ],
            child: tile,
          )
        : tile;
    // A Material under the tile, so the selected tint sits below the ripple.
    return Material(
      color: selected
          ? context.d3Colors.primaryContainer.withValues(alpha: 0.6)
          : Colors.transparent,
      child: row,
    );
  }

  /// Search: an anchor that opens a search page with the cuisine filters; a
  /// result opens the place.
  Widget _search(D3WindowSizeClass size) {
    final colors = context.d3Colors;
    return D3SearchAnchor<Place, String>.local(
      hint: 'Search places',
      useRootNavigator: false,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      items: _places,
      filterOptions: [
        for (final c in cuisines) D3FilterOption(value: c, label: c),
      ],
      multiSelectFilters: true,
      activeFilters: _cuisineFilter,
      defaultFilters: const {},
      onFiltersChanged: (f) => setState(() => _cuisineFilter = f),
      filterItems: (items, query, filters) => [
        for (final p in items)
          if ((filters.isEmpty || filters.contains(p.cuisine)) &&
              p.name.toLowerCase().contains(query.toLowerCase()))
            p,
      ],
      emptyState: D3EmptyState(
        icon: Icons.search_off_rounded,
        iconColor: colors.onSurfaceVariant,
        title: 'No places match',
        message: 'Try another name or clear the filters.',
        compact: true,
      ),
      resultBuilder: (context, results, query) => ListView(
        children: [
          for (final p in results)
            D3ListTile(
              leading: D3Avatar(name: p.name, imageUrl: photoUrl(p.photo)),
              titleWidget: RichText(
                text: D3SearchAnchor.highlight(
                  text: p.name,
                  query: query,
                  style: TextStyle(fontSize: 14, color: colors.onSurface),
                  highlightColor: colors.primary,
                ),
              ),
              subtitle: '${p.cuisine} · ${_distance(p)}',
              onTap: () {
                Navigator.of(context).pop();
                _open(p, size);
              },
            ),
        ],
      ),
    );
  }

  Widget _exploreList(D3WindowSizeClass size) {
    final results = _filtered;
    return Column(
      children: [
        _search(size),
        Expanded(
          child: _loading
              ? const D3Shimmer(
                  child: Column(
                    children: [
                      D3ListTileSkeleton(),
                      D3ListTileSkeleton(),
                      D3ListTileSkeleton(),
                      D3ListTileSkeleton(),
                    ],
                  ),
                )
              : results.isEmpty
                  ? D3EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No places match',
                      message: 'Clear the filters to see everything.',
                      action: D3Button(
                        label: 'Clear filters',
                        variant: D3ButtonVariant.outlined,
                        onPressed: () => setState(() => _cuisineFilter = {}),
                      ),
                    )
                  : ListView(
                      children: [for (final p in results) _tile(p, size)]),
        ),
      ],
    );
  }

  Widget _savedList(D3WindowSizeClass size) {
    final saved = _savedPlaces;
    if (saved.isEmpty) {
      return const D3EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Nothing saved yet',
        message: 'Open a place and tap Save.',
      );
    }
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: D3SectionHeader.label(label: 'Swipe a row to remove it'),
        ),
        for (final p in saved) _tile(p, size, swipe: true),
      ],
    );
  }

  Widget _settings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        D3Toggle(
          value: _notify,
          label: 'Tell me about new places',
          onChanged: (v) => setState(() => _notify = v),
        ),
        const SizedBox(height: 20),
        const D3SectionHeader.label(label: 'Distance'),
        D3SegmentedControl<String>(
          expand: true,
          segments: const [
            D3Segment(value: 'km', label: 'Kilometres'),
            D3Segment(value: 'mi', label: 'Miles'),
          ],
          selected: _units,
          onChanged: (v) => setState(() => _units = v),
        ),
        const SizedBox(height: 20),
        const D3ExpandableSection(
          title: 'About this demo',
          child: Text(
            'Every part of this app is a d3_ui component. The places are made up.',
          ),
        ),
      ],
    );
  }

  /// The detail pane of the list-detail layout.
  Widget _detailPane() {
    final place =
        _tab == 1 && _selected != null && !_saved.contains(_selectedId)
            ? null
            : _selected;
    if (place == null) {
      return const D3EmptyState(
        icon: Icons.touch_app_outlined,
        title: 'Select a place',
        message: 'Its details show here.',
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: _PlaceDetail(
          key: ValueKey(place.id),
          place: place,
          distance: _distance(place),
          saved: _saved.contains(place.id),
          onToggleSaved: () => _toggleSaved(place),
          title: place.name,
          subtitle: '${place.cuisine} · ${place.area}',
        ),
      ),
    );
  }

  Widget _content(D3WindowSizeClass size) {
    if (_tab == 2) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _settings(),
        ),
      );
    }
    final list = _tab == 0 ? _exploreList(size) : _savedList(size);
    if (size.isExpanded) {
      return Row(
        children: [
          SizedBox(width: 380, child: list),
          VerticalDivider(width: 1, color: context.d3Colors.outlineVariant),
          Expanded(child: _detailPane()),
        ],
      );
    }
    if (size.isMedium) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: list,
        ),
      );
    }
    return list;
  }

  List<D3NavItem> get _navItems => [
        const D3NavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore_rounded,
          label: 'Explore',
        ),
        D3NavItem(
          icon: Icons.favorite_border_rounded,
          activeIcon: Icons.favorite_rounded,
          label: 'Saved',
          badgeCount: _saved.isEmpty ? null : _saved.length,
        ),
        const D3NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
          label: 'Settings',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return D3WindowSizeBuilder(
      builder: (context, size) {
        final screen = D3Screen(
          title: _titles[_tab],
          actions: [
            if (_tab == 0)
              D3ScreenAction.icon(
                Icons.add_rounded,
                onPressed: _add,
                semanticsLabel: 'Add a place',
              ),
          ],
          body: _content(size),
          bottomNavigationBar: size.isCompact
              ? D3NavBar(
                  selectedIndex: _tab,
                  onTabSelected: (i) => setState(() => _tab = i),
                  items: _navItems,
                )
              : null,
        );
        if (size.isCompact) return screen;
        return Scaffold(
          body: Row(
            children: [
              D3NavRail(
                selectedIndex: _tab,
                onDestinationSelected: (i) => setState(() => _tab = i),
                items: _navItems,
              ),
              Expanded(child: screen),
            ],
          ),
        );
      },
    );
  }
}

/// A place's details: the same content in a sheet and in the detail pane.
class _PlaceDetail extends StatelessWidget {
  const _PlaceDetail({
    super.key,
    required this.place,
    required this.distance,
    required this.saved,
    required this.onToggleSaved,
    this.title,
    this.subtitle,
  });

  final Place place;
  final String distance;
  final bool saved;
  final VoidCallback onToggleSaved;

  /// A heading shown above the content (the sheet has its own header).
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 12),
        ],
        D3Image(url: photoUrl(place.photo), aspectRatio: 16 / 9),
        const SizedBox(height: 12),
        Text(place.about),
        const SizedBox(height: 12),
        D3InfoCard(
          children: [
            D3InfoRow.text(
              icon: Icons.star_rounded,
              text: place.rating > 0
                  ? '${place.rating} rating'
                  : 'No ratings yet',
            ),
            D3InfoRow.text(
              icon: Icons.place_outlined,
              text: '${place.area}, $distance away',
            ),
            D3InfoRow.text(
              icon: Icons.schedule_outlined,
              text: place.openNow ? 'Open now' : 'Closed, opens at 17:00',
            ),
          ],
        ),
        const SizedBox(height: 16),
        D3Button(
          label: saved ? 'Saved' : 'Save place',
          leadingIcon:
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          variant: saved ? D3ButtonVariant.tonal : D3ButtonVariant.filled,
          isFullWidth: true,
          onPressed: onToggleSaved,
        ),
      ],
    );
  }
}
