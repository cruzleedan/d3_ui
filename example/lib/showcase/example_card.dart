import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'code_highlighting.dart';

/// One live example with its code, as a card: a title, an optional sentence, the
/// widget itself, and a "Code" toggle that shows the example's source with a copy
/// button.
///
/// [source] is the text of the file the example lives in, taken from the
/// generated `exampleSources` map, so the code on screen is the code that runs.
class ExampleCard extends StatefulWidget {
  const ExampleCard({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.source,
    this.sourcePath,
  });

  final String title;
  final String? description;
  final Widget child;
  final String? source;

  /// The file the source comes from (`button/variants.dart`), shown above the
  /// code like an editor tab.
  final String? sourcePath;

  @override
  State<ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<ExampleCard> {
  @override
  void initState() {
    super.initState();
    if (widget.source != null && !CodeHighlighting.isReady) {
      CodeHighlighting.whenReady.then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  bool _showCode = false;

  /// Long code is collapsed to [_collapsedHeight] with a fade and a button.
  bool _expanded = false;
  static const double _collapsedHeight = 300;
  static const double _lineHeight = 12.5 * 1.55;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.source!));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  /// From this card width the code sits to the right of the example, so the two
  /// can be compared side by side; narrower, a "Code" button shows it below.
  static const double sideBySideWidth = 820;

  CodePanelColors get _codeColors =>
      CodeHighlighting.panel(Theme.of(context).brightness);

  /// The code, coloured like an editor, selectable.
  Widget _codeText(CodePanelColors code) {
    final base = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 12.5,
      height: 1.55,
      color: code.text,
    );
    final highlighted = CodeHighlighting.spans(
      widget.source!,
      Theme.of(context).brightness,
    );
    return SelectableText.rich(
      highlighted == null
          ? TextSpan(text: widget.source, style: base)
          : TextSpan(style: base, children: [highlighted]),
    );
  }

  /// The code as an inset, rounded editor panel: a file tab, the code, and for
  /// long code a fade and a "Show all" button instead of a hard cut-off.
  Widget _codePanel() {
    final code = _codeColors;
    final lines = '\n'.allMatches(widget.source!).length + 1;
    final collapsible = lines * _lineHeight + 26 > _collapsedHeight + 40;
    final collapsed = collapsible && !_expanded;

    Widget body = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: _codeText(code),
    );
    if (collapsed) {
      body = SizedBox(
        height: _collapsedHeight,
        child: Stack(
          children: [
            Positioned.fill(
                child: ClipRect(
                    child: OverflowBox(
              alignment: Alignment.topLeft,
              maxHeight: double.infinity,
              child: body,
            ))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 72,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        code.background.withValues(alpha: 0),
                        code.background,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: code.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: code.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _codeHeader(code),
          body,
          if (collapsible)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: code.border)),
              ),
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  foregroundColor: code.text,
                  minimumSize: const Size.fromHeight(40),
                  shape: const RoundedRectangleBorder(),
                ),
                icon: Icon(
                  _expanded
                      ? Icons.unfold_less_rounded
                      : Icons.unfold_more_rounded,
                  size: 18,
                ),
                label: Text(
                  _expanded ? 'Show less' : 'Show all $lines lines',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The file name and the copy button, above the code.
  Widget _codeHeader(CodePanelColors code) {
    final name = widget.sourcePath?.split('/').last ?? 'example.dart';
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: code.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 15, color: code.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: code.text,
              ),
            ),
          ),
          IconButton(
            tooltip: _copied ? 'Copied' : 'Copy code',
            onPressed: _copy,
            iconSize: 17,
            color: _copied ? code.accent : code.text,
            icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final shape = context.d3Shape;
    final hasCode = widget.source != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = hasCode && constraints.maxWidth >= sideBySideWidth;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: shape.circularLg,
            border: Border.all(
              color: shape.cardBorder ?? colors.outline.withValues(alpha: 0.4),
              width: shape.cardBorderWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (hasCode && !sideBySide)
                      TextButton.icon(
                        onPressed: () => setState(() => _showCode = !_showCode),
                        icon: Icon(
                          _showCode
                              ? Icons.visibility_off_outlined
                              : Icons.code,
                          size: 18,
                        ),
                        label: Text(_showCode ? 'Hide code' : 'Code'),
                      ),
                  ],
                ),
              ),
              if (widget.description != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    widget.description!,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (sideBySide)
                _sideBySide(colors)
              else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: widget.child,
                  ),
                ),
                if (_showCode && hasCode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _codePanel(),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// The example on the left and its code on the right (scrolling when long).
  Widget _sideBySide(D3ColorTokens colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(alignment: Alignment.centerLeft, child: widget.child),
          ),
        ),
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 12, 12),
            child: _codePanel(),
          ),
        ),
      ],
    );
  }
}

/// A page's heading block: title, the one-sentence summary and the import line.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.summary,
    this.importLine = "import 'package:d3_ui/d3_ui.dart';",
  });

  final String title;
  final String summary;
  final String importLine;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          summary,
          style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: context.d3Shape.circularMd,
          ),
          child: SelectableText(
            importLine,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12.5,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// A page body: a header, then the example cards, laid out in a centred column
/// that stays readable on a wide screen.
class ExamplePage extends StatelessWidget {
  const ExamplePage({
    super.key,
    required this.title,
    required this.summary,
    required this.examples,
    this.importLine = "import 'package:d3_ui/d3_ui.dart';",
  });

  final String title;
  final String summary;
  final String importLine;
  final List<Widget> examples;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Wide enough for an example and its code side by side.
        constraints: const BoxConstraints(maxWidth: 1280),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
          children: [
            // Text reads best in a column about this wide, however wide the page.
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: PageHeader(
                  title: title,
                  summary: summary,
                  importLine: importLine,
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (final example in examples) ...[
              example,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
