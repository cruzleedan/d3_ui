import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A collage of live d3_ui widgets on rounded cards, for the Home page. They
/// are real, interactive components in the active brand and theme, not images.
///
/// The widgets are built after the first frame, so the page paints its heading
/// and button first and the collage follows (it is the heavier part).
class HomeCollage extends StatefulWidget {
  const HomeCollage({super.key, this.clipHeight, this.singleColumn = false});

  /// One column of cards (a phone), not two staggered ones.
  final bool singleColumn;

  /// A height to clip the two columns to (the cards run off the bottom, like a
  /// screenshot); null shows every card.
  final double? clipHeight;

  @override
  State<HomeCollage> createState() => _HomeCollageState();
}

class _HomeCollageState extends State<HomeCollage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return SizedBox(height: widget.clipHeight ?? 0);
    }
    final left = [
      const _RatingCard(),
      const _BannerCard(),
      const _ProgressCard(),
      const _MenuCard(),
    ];
    final right = [
      const _SliderCard(),
      const _StepperCard(),
      const _ChipsCard(),
      const _BadgeCard(),
    ];
    if (widget.singleColumn) {
      return Column(
        children: [
          for (final c in [
            const _RatingCard(),
            const _BannerCard(),
            const _SliderCard(),
            const _StepperCard(),
            const _ChipsCard(),
          ]) ...[c, const SizedBox(height: 14)],
        ],
      );
    }
    Widget column(List<Widget> cards, {double top = 0}) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: top),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in cards) ...[c, const SizedBox(height: 14)],
              ],
            ),
          ),
        );
    final cols = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column(left),
        const SizedBox(width: 14),
        column(right, top: 44)
      ],
    );
    if (widget.clipHeight == null) return cols;
    return SizedBox(
      height: widget.clipHeight,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: cols,
        ),
      ),
    );
  }
}

/// One rounded surface of the collage.
class _CollageCard extends StatelessWidget {
  const _CollageCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: context.d3Shape.circularXl,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _RatingCard extends StatefulWidget {
  const _RatingCard();

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  double _value = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return _CollageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate this dish',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          // Five 48 dp star slots are 240 wide: scale down in a narrow card.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: D3Rating(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
              showValue: true,
              label: 'Rating',
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) => const D3Banner(
        variant: D3BannerVariant.success,
        title: 'Order placed',
        message: 'Your food will be ready in 20 minutes.',
      );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return _CollageCard(
      child: Row(
        children: [
          const D3ProgressRing(value: 0.72, size: 64, showValue: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preparing',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                D3AvatarGroup(
                  size: D3AvatarSize.sm,
                  avatars: const [
                    D3Avatar(name: 'Ana Reyes'),
                    D3Avatar(name: 'Ben Cruz'),
                    D3Avatar(name: 'Cleo Park'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return _CollageCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bao House',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  'Asian, 0.4 km',
                  style:
                      TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          D3MenuButton(
            entries: [
              D3MenuItem(label: 'Save', icon: Icons.favorite_border_rounded),
              D3MenuItem(label: 'Share', icon: Icons.ios_share_rounded),
              const D3MenuDivider(),
              D3MenuItem(
                label: 'Report',
                icon: Icons.flag_outlined,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatefulWidget {
  const _SliderCard();

  @override
  State<_SliderCard> createState() => _SliderCardState();
}

class _SliderCardState extends State<_SliderCard> {
  double _volume = 0.6;
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return _CollageCard(
      child: Column(
        children: [
          D3Slider(
            value: _volume,
            onChanged: (v) => setState(() => _volume = v),
            label: 'Volume',
            showValue: true,
            valueFormatter: (v) => '${(v * 100).round()}%',
          ),
          D3Toggle(
            value: _on,
            label: 'Notifications',
            onChanged: (v) => setState(() => _on = v),
          ),
        ],
      ),
    );
  }
}

class _StepperCard extends StatefulWidget {
  const _StepperCard();

  @override
  State<_StepperCard> createState() => _StepperCardState();
}

class _StepperCardState extends State<_StepperCard> {
  int _qty = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return _CollageCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Margherita',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  '\$${(_qty * 9).toStringAsFixed(2)}',
                  style:
                      TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          D3QuantityStepper(
            value: _qty,
            min: 0,
            max: 9,
            label: 'Quantity',
            onChanged: (v) => setState(() => _qty = v),
          ),
        ],
      ),
    );
  }
}

class _ChipsCard extends StatefulWidget {
  const _ChipsCard();

  @override
  State<_ChipsCard> createState() => _ChipsCardState();
}

class _ChipsCardState extends State<_ChipsCard> {
  final _on = <String>{'Vegan'};

  @override
  Widget build(BuildContext context) {
    return _CollageCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in ['Vegan', 'Halal', 'Gluten free', 'Nut free'])
            D3Chip(
              label: c,
              selected: _on.contains(c),
              onTap: () => setState(
                () => _on.contains(c) ? _on.remove(c) : _on.add(c),
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard();

  @override
  Widget build(BuildContext context) {
    return _CollageCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const D3Badge.label('New', variant: D3BadgeVariant.primary),
          const D3Badge.label('Open now', variant: D3BadgeVariant.success),
          const D3Badge.label('Closing soon', variant: D3BadgeVariant.warning),
          D3BadgeAnchor(
            badge: const D3Badge.count(3, semanticsLabel: '3 new'),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: context.d3Colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
