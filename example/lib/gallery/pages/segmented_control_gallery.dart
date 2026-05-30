import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class SegmentedControlGallery extends StatefulWidget {
  const SegmentedControlGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<SegmentedControlGallery> createState() =>
      _SegmentedControlGalleryState();
}

class _SegmentedControlGalleryState extends State<SegmentedControlGallery> {
  String _filter = 'All';
  String _view = 'List';
  String _iconOnly = 'list';
  String _period = 'Day';
  String _twoSeg = 'Light';

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GallerySection(
                title: 'Text only',
                child: D3SegmentedControl<String>(
                  segments: const [
                    D3Segment(value: 'All', label: 'All'),
                    D3Segment(value: 'Active', label: 'Active'),
                    D3Segment(value: 'Archived', label: 'Archived'),
                  ],
                  selected: _filter,
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
              GallerySection(
                title: 'Icon + text',
                child: D3SegmentedControl<String>(
                  segments: const [
                    D3Segment(
                        value: 'List', label: 'List', icon: Icons.list_rounded),
                    D3Segment(
                        value: 'Grid',
                        label: 'Grid',
                        icon: Icons.grid_view_rounded),
                    D3Segment(
                        value: 'Map', label: 'Map', icon: Icons.map_outlined),
                  ],
                  selected: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ),
              GallerySection(
                title: 'Icon only',
                child: D3SegmentedControl<String>(
                  segments: const [
                    D3Segment(
                      value: 'list',
                      icon: Icons.list_rounded,
                      semanticsLabel: 'List',
                    ),
                    D3Segment(
                      value: 'grid',
                      icon: Icons.grid_view_rounded,
                      semanticsLabel: 'Grid',
                    ),
                    D3Segment(
                      value: 'map',
                      icon: Icons.map_outlined,
                      semanticsLabel: 'Map',
                    ),
                  ],
                  selected: _iconOnly,
                  onChanged: (v) => setState(() => _iconOnly = v),
                ),
              ),
              GallerySection(
                title: 'Full width — 4 segments',
                child: D3SegmentedControl<String>(
                  segments: const [
                    D3Segment(value: 'Day', label: 'Day'),
                    D3Segment(value: 'Week', label: 'Week'),
                    D3Segment(value: 'Month', label: 'Month'),
                    D3Segment(value: 'Year', label: 'Year'),
                  ],
                  selected: _period,
                  onChanged: (v) => setState(() => _period = v),
                  expand: true,
                ),
              ),
              GallerySection(
                title: '2 segments',
                child: D3SegmentedControl<String>(
                  segments: const [
                    D3Segment(
                        value: 'Light',
                        label: 'Light',
                        icon: Icons.light_mode_outlined),
                    D3Segment(
                        value: 'Dark',
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined),
                  ],
                  selected: _twoSeg,
                  onChanged: (v) => setState(() => _twoSeg = v),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
