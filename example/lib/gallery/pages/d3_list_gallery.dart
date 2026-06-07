import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

class _Contact {
  const _Contact({required this.name, required this.email});
  final String name;
  final String email;
}

class D3ListGallery extends StatefulWidget {
  const D3ListGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<D3ListGallery> createState() => _D3ListGalleryState();
}

class _D3ListGalleryState extends State<D3ListGallery> {
  final _controller = D3ListController();

  static const _allContacts = [
    _Contact(name: 'Alice Brown', email: 'alice@example.com'),
    _Contact(name: 'Amy Chen', email: 'amy@example.com'),
    _Contact(name: 'Bob Carter', email: 'bob@example.com'),
    _Contact(name: 'Clara Davis', email: 'clara@example.com'),
    _Contact(name: 'Dan Lee', email: 'dan@example.com'),
    _Contact(name: 'Eva Morales', email: 'eva@example.com'),
    _Contact(name: 'Frank Nguyen', email: 'frank@example.com'),
    _Contact(name: 'Grace Park', email: 'grace@example.com'),
    _Contact(name: 'Henry Reyes', email: 'henry@example.com'),
    _Contact(name: 'Iris Santos', email: 'iris@example.com'),
    _Contact(name: 'James Tan', email: 'james@example.com'),
    _Contact(name: 'Karen Wu', email: 'karen@example.com'),
    _Contact(name: 'Leo Vasquez', email: 'leo@example.com'),
    _Contact(name: 'Mia Patel', email: 'mia@example.com'),
    _Contact(name: 'Noah Kim', email: 'noah@example.com'),
    _Contact(name: 'Olivia Scott', email: 'olivia@example.com'),
    _Contact(name: 'Pedro Alves', email: 'pedro@example.com'),
    _Contact(name: 'Quinn Foster', email: 'quinn@example.com'),
    _Contact(name: 'Rachel Gomez', email: 'rachel@example.com'),
    _Contact(name: 'Sam Turner', email: 'sam@example.com'),
    _Contact(name: 'Tara Okafor', email: 'tara@example.com'),
    _Contact(name: 'Uma Sato', email: 'uma@example.com'),
    _Contact(name: 'Victor Huang', email: 'victor@example.com'),
    _Contact(name: 'Wendy Johansson', email: 'wendy@example.com'),
    _Contact(name: 'Xander Bell', email: 'xander@example.com'),
    _Contact(name: 'Yara Mensah', email: 'yara@example.com'),
    _Contact(name: 'Zoe Nakamura', email: 'zoe@example.com'),
  ];

  static const _pageSize = 5;

  List<_Contact> _contacts = [];
  bool _hasMore = true;
  bool _isLoading = true;
  String _activeSection = 'Contacts'; // Contacts, Empty, Sections, Auto-fill

  // ── Auto-fill demo state ───────────────────────────────────────────────────
  // Simulates a paginated API with exactly 10 items. Each page returns 3 items.
  // When the list is exhausted the next fetch returns empty → hasMore = false.
  static const _autoFillPageSize = 3;
  static List<_Contact> get _autoDataset => _allContacts.take(10).toList();
  List<_Contact> _autoContacts = [];
  bool _autoHasMore = true;
  bool _autoIsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _loadAutoInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _contacts = _allContacts.take(_pageSize).toList();
      _hasMore = _allContacts.length > _pageSize;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _contacts = _allContacts.take(_pageSize).toList();
      _hasMore = _allContacts.length > _pageSize;
    });
  }

  Future<void> _onLoadMore() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final next = _contacts.length + _pageSize;
    setState(() {
      _contacts = _allContacts.take(next).toList();
      _hasMore = next < _allContacts.length;
    });
  }

  // ── Auto-fill demo ─────────────────────────────────────────────────────────

  Future<void> _loadAutoInitial() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final page = _autoDataset.take(_autoFillPageSize).toList();
    setState(() {
      _autoContacts = page;
      _autoHasMore = true; // don't know if there's more until we ask
      _autoIsLoading = false;
    });
  }

  Future<void> _onAutoRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final page = _autoDataset.take(_autoFillPageSize).toList();
    setState(() {
      _autoContacts = page;
      _autoHasMore = true;
    });
  }

  Future<void> _onAutoLoadMore() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // Simulate API: fetch the next page. If it comes back empty, we're done.
    final nextPage = _autoDataset
        .skip(_autoContacts.length)
        .take(_autoFillPageSize)
        .toList();
    setState(() {
      _autoContacts = [..._autoContacts, ...nextPage];
      _autoHasMore = nextPage.isNotEmpty; // empty response → no more pages
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Section picker ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: D3SegmentedControl<String>(
                expand: true,
                segments: const [
                  D3Segment(value: 'Contacts', label: 'Contacts'),
                  D3Segment(value: 'Empty', label: 'Empty'),
                  D3Segment(value: 'Sections', label: 'Sections'),
                  D3Segment(value: 'Auto-fill', label: 'Auto-fill'),
                ],
                selected: _activeSection,
                onChanged: (v) => setState(() => _activeSection = v),
              ),
            ),

            // ── Programmatic controls ─────────────────────────────────────
            if (_activeSection == 'Contacts')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    D3Button(
                      label: 'Refresh',
                      size: D3ButtonSize.sm,
                      variant: D3ButtonVariant.outlined,
                      onPressed: _controller.refresh,
                    ),
                    const SizedBox(width: 8),
                    D3Button(
                      label: 'Top',
                      size: D3ButtonSize.sm,
                      variant: D3ButtonVariant.outlined,
                      onPressed: _controller.scrollToTop,
                    ),
                    const SizedBox(width: 8),
                    D3Button(
                      label: 'Bottom',
                      size: D3ButtonSize.sm,
                      variant: D3ButtonVariant.outlined,
                      onPressed: _controller.scrollToBottom,
                    ),
                    const SizedBox(width: 8),
                    D3Button(
                      label: 'Item 8',
                      size: D3ButtonSize.sm,
                      variant: D3ButtonVariant.outlined,
                      onPressed: () => _controller.scrollToIndex(7),
                    ),
                  ],
                ),
              ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: switch (_activeSection) {
                'Contacts' => D3List<_Contact>(
                    controller: _controller,
                    items: _contacts,
                    isLoading: _isLoading,
                    hasMore: _hasMore,
                    onRefresh: _onRefresh,
                    onLoadMore: _onLoadMore,
                    emptyState: D3EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No contacts',
                      message: 'Add your first contact to get started.',
                      action: D3Button(
                        label: 'Add contact',
                        onPressed: () {},
                      ),
                    ),
                    itemBuilder: (context, contact, index, {isSelected = false, inSelectionMode = false, onAvatarTap}) => D3ListTile(
                      leading: D3ListTileIcon(
                        icon: Icons.person_outline_rounded,
                        color: colors.primary,
                      ),
                      title: contact.name,
                      subtitle: contact.email,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ),
                'Empty' => D3List<_Contact>(
                    items: const [],
                    isLoading: false,
                    hasMore: false,
                    onRefresh: _onRefresh,
                    emptyState: D3EmptyState(
                      icon: Icons.people_outline_rounded,
                      iconColor: colors.primary,
                      title: 'No contacts yet',
                      message:
                          'Pull down to refresh or add your first contact.',
                      action: D3Button(
                        label: 'Add contact',
                        onPressed: () {},
                      ),
                    ),
                    itemBuilder: (_, c, __, {isSelected = false, inSelectionMode = false, onAvatarTap}) => D3ListTile(title: c.name),
                  ),
                'Auto-fill' => _AutoFillDemo(
                    contacts: _autoContacts,
                    isLoading: _autoIsLoading,
                    hasMore: _autoHasMore,
                    onRefresh: _onAutoRefresh,
                    onLoadMore: _onAutoLoadMore,
                  ),
                _ => D3List<_Contact>(
                    items: _contacts,
                    isLoading: _isLoading,
                    hasMore: false,
                    onRefresh: _onRefresh,
                    sectionBuilder: (_, contact, __) =>
                        contact.name[0].toUpperCase(),
                    itemBuilder: (context, contact, index, {isSelected = false, inSelectionMode = false, onAvatarTap}) => D3ListTile(
                      leading: D3Avatar(
                        name: contact.name,
                        size: D3AvatarSize.sm,
                      ),
                      title: contact.name,
                      subtitle: contact.email,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auto-fill demo widget
// ─────────────────────────────────────────────────────────────────────────────

class _AutoFillDemo extends StatelessWidget {
  const _AutoFillDemo({
    required this.contacts,
    required this.isLoading,
    required this.hasMore,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final List<_Contact> contacts;
  final bool isLoading;
  final bool hasMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Column(
      children: [
        // Status banner showing current state
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: colors.primaryContainer.withValues(alpha: 0.5),
          child: Row(
            children: [
              Icon(
                hasMore
                    ? Icons.downloading_rounded
                    : Icons.check_circle_outline_rounded,
                size: 16,
                color: hasMore ? colors.primary : colors.success,
              ),
              const SizedBox(width: 8),
              Text(
                hasMore
                    ? 'Loaded ${contacts.length} — fetching next page…'
                    : 'All ${contacts.length} contacts loaded ✓',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: D3List<_Contact>(
            items: contacts,
            isLoading: isLoading,
            hasMore: hasMore,
            onRefresh: onRefresh,
            onLoadMore: onLoadMore,
            itemBuilder: (context, contact, index, {isSelected = false, inSelectionMode = false, onAvatarTap}) => D3ListTile(
              leading: D3Avatar(name: contact.name, size: D3AvatarSize.sm),
              title: contact.name,
              subtitle: contact.email,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}
