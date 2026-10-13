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
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _codeColors.background,
                      border:
                          Border(top: BorderSide(color: _codeColors.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _codeHeader(_codeColors),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _codeText(_codeColors),
                          ),
                        ),
                      ],
                    ),
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _codeColors.background,
              border: Border(
                left: BorderSide(color: _codeColors.border),
                top: BorderSide(color: _codeColors.border),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _codeHeader(_codeColors),
                  Flexible(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _codeText(_codeColors),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
