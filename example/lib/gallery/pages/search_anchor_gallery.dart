import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared data model
// ─────────────────────────────────────────────────────────────────────────────

class _Contact {
  const _Contact({required this.name, required this.email, this.role});
  final String name;
  final String email;
  final String? role;
}

const _contacts = [
  _Contact(name: 'Alice Brown', email: 'alice@example.com', role: 'Designer'),
  _Contact(name: 'Amanda Chen', email: 'amanda@example.com', role: 'Engineer'),
  _Contact(name: 'Bob Carter', email: 'bob@example.com', role: 'Manager'),
  _Contact(name: 'Clara Davis', email: 'clara@example.com', role: 'Designer'),
  _Contact(name: 'Dan Lee', email: 'dan@example.com', role: 'Engineer'),
  _Contact(name: 'Eva Morales', email: 'eva@example.com', role: 'Product'),
  _Contact(name: 'Frank Nguyen', email: 'frank@example.com', role: 'Engineer'),
  _Contact(name: 'Grace Park', email: 'grace@example.com', role: 'Designer'),
  _Contact(name: 'Henry Reyes', email: 'henry@example.com', role: 'Manager'),
  _Contact(name: 'Iris Santos', email: 'iris@example.com', role: 'Product'),
  _Contact(name: 'James Tan', email: 'james@example.com', role: 'Engineer'),
  _Contact(name: 'Karen Wu', email: 'karen@example.com', role: 'Designer'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Gallery
// ─────────────────────────────────────────────────────────────────────────────

class SearchAnchorGallery extends StatefulWidget {
  const SearchAnchorGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<SearchAnchorGallery> createState() => _SearchAnchorGalleryState();
}

class _SearchAnchorGalleryState extends State<SearchAnchorGallery> {
  String _mode = 'Local'; // Local, Remote

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: D3SegmentedControl<String>(
                expand: true,
                segments: const [
                  D3Segment(value: 'Local', label: 'Local'),
                  D3Segment(value: 'Remote', label: 'Remote'),
                ],
                selected: _mode,
                onChanged: (v) => setState(() => _mode = v),
              ),
            ),
            Expanded(
              child: _mode == 'Local'
                  ? const _LocalModeDemo()
                  : const _RemoteModeDemo(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local mode demo
// ─────────────────────────────────────────────────────────────────────────────

class _LocalModeDemo extends StatefulWidget {
  const _LocalModeDemo();

  @override
  State<_LocalModeDemo> createState() => _LocalModeDemoState();
}

class _LocalModeDemoState extends State<_LocalModeDemo> {
  final _controller = D3SearchController();

  List<_Contact> _filter(List<_Contact> items, String query) {
    final q = query.toLowerCase();
    return items
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            (c.role?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Column(
      children: [
        // Search anchor — opens with full list immediately
        D3SearchAnchor<_Contact>.local(
          controller: _controller,
          hint: 'Search contacts…',
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          items: _contacts,
          filterItems: _filter,
          emptyState: D3EmptyState(
            icon: Icons.search_off_rounded,
            iconColor: colors.onSurfaceVariant,
            title: 'No contacts found',
            message: 'Try a different name, email, or role.',
            compact: true,
          ),
          resultBuilder: (context, results, query) => D3List<_Contact>(
            items: results,
            itemBuilder: (context, contact, _) => D3ListTile(
              leading: D3Avatar(name: contact.name, size: D3AvatarSize.sm),
              titleWidget: RichText(
                text: D3SearchAnchor.highlight(
                  text: contact.name,
                  query: query,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                    height: 1.3,
                  ),
                  highlightColor: colors.primary,
                ),
              ),
              subtitle: contact.role ?? contact.email,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _controller.close(),
            ),
          ),
        ),

        // Originating list — same data, no search applied
        Expanded(
          child: D3List<_Contact>(
            items: _contacts,
            itemBuilder: (context, contact, _) => D3ListTile(
              leading: D3Avatar(name: contact.name, size: D3AvatarSize.sm),
              title: contact.name,
              subtitle: contact.role ?? contact.email,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Remote mode demo
// ─────────────────────────────────────────────────────────────────────────────

class _RemoteModeDemo extends StatefulWidget {
  const _RemoteModeDemo();

  @override
  State<_RemoteModeDemo> createState() => _RemoteModeDemoState();
}

class _RemoteModeDemoState extends State<_RemoteModeDemo> {
  final _controller = D3SearchController();

  // Simulates a paginated remote API: returns 5 contacts per page.
  static const _pageSize = 5;
  List<_Contact> _results = _contacts.take(_pageSize).toList();
  bool _hasMore = _contacts.length > _pageSize;
  bool _isLoading = false;

  Future<List<_Contact>?> _onSearch(String query) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return null;
    final q = query.toLowerCase();
    return _contacts
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            (c.role?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _results = _contacts.take(_pageSize).toList();
      _hasMore = _contacts.length > _pageSize;
    });
  }

  Future<void> _onLoadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final next = _results.length + _pageSize;
    setState(() {
      _results = _contacts.take(next).toList();
      _hasMore = next < _contacts.length;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Column(
      children: [
        // Search anchor — shows initialItems on open, fetches on type
        D3SearchAnchor<_Contact>.remote(
          controller: _controller,
          hint: 'Search contacts…',
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          initialItems: _results,
          onSearch: _onSearch,
          emptyState: D3EmptyState(
            icon: Icons.search_off_rounded,
            iconColor: colors.onSurfaceVariant,
            title: 'No contacts found',
            message: 'Try a different name, email, or role.',
            compact: true,
          ),
          resultBuilder: (context, results, query) => D3List<_Contact>(
            items: results,
            itemBuilder: (context, contact, _) => D3ListTile(
              leading: D3Avatar(name: contact.name, size: D3AvatarSize.sm),
              titleWidget: RichText(
                text: D3SearchAnchor.highlight(
                  text: contact.name,
                  query: query,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                    height: 1.3,
                  ),
                  highlightColor: colors.primary,
                ),
              ),
              subtitle: contact.role ?? contact.email,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _controller.close(),
            ),
          ),
        ),

        // Originating paginated list
        Expanded(
          child: D3List<_Contact>(
            items: _results,
            hasMore: _hasMore,
            onRefresh: _onRefresh,
            onLoadMore: _onLoadMore,
            itemBuilder: (context, contact, _) => D3ListTile(
              leading: D3Avatar(name: contact.name, size: D3AvatarSize.sm),
              title: contact.name,
              subtitle: contact.role ?? contact.email,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}
