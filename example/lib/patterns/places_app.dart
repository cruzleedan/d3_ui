import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../showcase/photos.dart';
import 'places_data.dart';

/// A small app made only of d3_ui parts, with fictional data: find places,
/// filter them, open one, add one, save and unsave, and change settings.
///
/// It runs in its own MaterialApp, so it has its own Navigator and
/// ScaffoldMessenger: its toasts appear inside the phone frame.
class PlacesApp extends StatelessWidget {
  const PlacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      home: const _PlacesHome(),
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
  String _query = '';
  bool _loading = true;
  int _tab = 0;
  bool _notify = true;
  String _units = 'km';

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  List<Place> get _visible => [
        for (final p in _places)
          if ((_cuisineFilter.isEmpty || _cuisineFilter.contains(p.cuisine)) &&
              p.name.toLowerCase().contains(_query.toLowerCase()))
            p,
      ];

  String _distance(Place p) => _units == 'km'
      ? '${p.distanceKm.toStringAsFixed(1)} km'
      : '${(p.distanceKm * 0.621).toStringAsFixed(1)} mi';

  void _toggleSaved(Place p) {
    setState(
        () => _saved.contains(p.id) ? _saved.remove(p.id) : _saved.add(p.id));
  }

  Future<void> _open(Place p) async {
    await D3BottomSheet.show<void>(
      context,
      title: p.name,
      subtitle: '${p.cuisine} · ${p.area}',
      snapPoints: const [D3SnapPoint(0.62)],
      child: StatefulBuilder(
        builder: (sheetContext, setSheet) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            D3Image(url: photoUrl(p.photo), aspectRatio: 16 / 9),
            const SizedBox(height: 12),
            Text(p.about),
            const SizedBox(height: 12),
            D3InfoCard(
              children: [
                D3InfoRow.text(
                    icon: Icons.star_rounded, text: '${p.rating} rating'),
                D3InfoRow.text(
                    icon: Icons.place_outlined,
                    text: '${p.area}, ${_distance(p)} away'),
                D3InfoRow.text(
                  icon: Icons.schedule_outlined,
                  text: p.openNow ? 'Open now' : 'Closed, opens at 17:00',
                ),
              ],
            ),
            const SizedBox(height: 16),
            D3Button(
              label: _saved.contains(p.id) ? 'Saved' : 'Save place',
              leadingIcon: _saved.contains(p.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              variant: _saved.contains(p.id)
                  ? D3ButtonVariant.tonal
                  : D3ButtonVariant.filled,
              isFullWidth: true,
              onPressed: () {
                _toggleSaved(p);
                setSheet(() {});
              },
            ),
          ],
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
      setState(() => _places.insert(0, added));
      D3Toast.success(context, title: '${added.name} added');
    }
  }

  Future<void> _remove(Place p) async {
    final ok = await D3Dialog.show<bool>(
      context,
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
          label: 'Undo', onPressed: () => setState(() => _saved.add(p.id))),
    );
  }

  Widget _tile(Place p, {bool swipe = false}) {
    final tile = D3ListTile(
      leading: D3Avatar(name: p.name, imageUrl: photoUrl(p.photo)),
      title: p.name,
      subtitle: '${p.cuisine} · ${_distance(p)}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.rating > 0) ...[
            const Icon(Icons.star_rounded, size: 16),
            const SizedBox(width: 2),
            Text('${p.rating}'),
          ],
        ],
      ),
      onTap: () => _open(p),
    );
    if (!swipe) return tile;
    return D3SlidableRow(
      groupTag: 'saved',
      actions: [
        D3SwipeAction(
            icon: Icons.delete_outline,
            label: 'Remove',
            onPressed: () => _remove(p))
      ],
      child: tile,
    );
  }

  Widget _explore() {
    final results = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: D3SearchBar(
            hint: 'Search places',
            padding: EdgeInsets.zero,
            onChanged: (q) => setState(() => _query = q),
          ),
        ),
        const SizedBox(height: 8),
        D3FilterChipRow<String>(
          multiSelect: true,
          options: [
            for (final c in cuisines) D3FilterOption(value: c, label: c)
          ],
          selected: _cuisineFilter,
          onChanged: (v) => setState(() => _cuisineFilter = v),
        ),
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
                      message: 'Try another search or clear the filters.',
                      action: D3Button(
                        label: 'Clear filters',
                        variant: D3ButtonVariant.outlined,
                        onPressed: () => setState(() {
                          _cuisineFilter = {};
                          _query = '';
                        }),
                      ),
                    )
                  : ListView(children: [for (final p in results) _tile(p)]),
        ),
      ],
    );
  }

  Widget _savedTab() {
    final saved = [
      for (final p in _places)
        if (_saved.contains(p.id)) p
    ];
    if (saved.isEmpty) {
      return const D3EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Nothing saved yet',
        message: 'Open a place and tap Save.',
      );
    }
    return ListView(
      children: [
        const D3SectionHeader.label(label: 'Swipe a row to remove it').padded(),
        for (final p in saved) _tile(p, swipe: true),
      ],
    );
  }

  Widget _settingsTab() {
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

  @override
  Widget build(BuildContext context) {
    final titles = ['Explore', 'Saved', 'Settings'];
    return D3Screen(
      title: titles[_tab],
      actions: [
        if (_tab == 0)
          D3ScreenAction.icon(
            Icons.add_rounded,
            onPressed: _add,
            semanticsLabel: 'Add a place',
          ),
      ],
      body: switch (_tab) {
        0 => _explore(),
        1 => _savedTab(),
        _ => _settingsTab(),
      },
      bottomNavigationBar: D3NavBar(
        selectedIndex: _tab,
        onTabSelected: (i) => setState(() => _tab = i),
        items: [
          const D3NavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
              label: 'Explore'),
          D3NavItem(
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
            label: 'Saved',
            badgeCount: _saved.length,
          ),
          const D3NavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'Settings'),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget padded() =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: this);
}
