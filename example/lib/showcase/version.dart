/// What build of the showcase this is. `scripts/build_showcase.sh` passes the
/// values with `--dart-define`; a plain `flutter run` shows `dev`.
class ShowcaseVersion {
  const ShowcaseVersion._();

  /// The release (`1.8.0` from the tag `showcase-v1.8.0`), or `dev`.
  static const String showcase = String.fromEnvironment(
    'SHOWCASE_VERSION',
    defaultValue: 'dev',
  );

  /// The d3_ui library version this was built against.
  static const String library = String.fromEnvironment(
    'D3_UI_VERSION',
    defaultValue: '',
  );

  /// The short commit hash, when known.
  static const String commit = String.fromEnvironment(
    'SHOWCASE_COMMIT',
    defaultValue: '',
  );

  static String get _showcasePart =>
      showcase == 'dev' ? 'showcase dev' : 'showcase v$showcase';

  /// `showcase v1.8.0 · d3_ui 0.2.0 · abc1234`.
  static String get label => [
        _showcasePart,
        if (library.isNotEmpty) 'd3_ui $library',
        if (commit.isNotEmpty) commit,
      ].join(' · ');

  /// `v1.8.0` or `dev`: short enough for a rail.
  static String get short => showcase == 'dev' ? 'dev' : 'v$showcase';
}
