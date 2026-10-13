# ds_example

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Previewing the web showcase

Build the showcase as a static web app and serve it from any machine you can
reach, for example over a VPN or private network:

```bash
scripts/build_showcase.sh                                  # builds example/build/web
python3 scripts/preview_showcase.py --bind <private-address> --port 8090
```

Run both from the repository root (the paths are relative to it). The preview
script serves `index.html` for any path that is not a file, as the real host
does, so a deep link such as `/button` works on reload; `python3 -m http.server`
answers 404 for those.

- Bind to a specific private address, not `0.0.0.0`, so the preview isn't
  exposed on every interface.
- The build is static: rebuild after each change you want to see. The server
  doesn't need restarting.
- The server is a plain background process and stops when the machine
  reboots.
- For hot reload instead, use
  `flutter run -d web-server --web-hostname <private-address> --web-port 8090`.

## Adding or changing an example

Each example on a showcase page is one small widget in its own file under
`lib/examples/<component>/`. The "Code" button on its card shows that file's
text, which comes from `lib/showcase/generated/example_sources.g.dart`: a
generated map of every example file's source. After you add, rename or edit an
example, regenerate it (from `example/`):

```bash
dart run tool/gen_example_sources.dart
```

- Don't edit the generated file by hand, and don't run `dart format` on it.
- It is committed, because a clean checkout needs it to build.
- `scripts/build_showcase.sh` regenerates it before every web build, and
  `flutter test` (in `example/`) fails if the committed copy is out of date.
- A new example also needs a page entry: add it to a page in
  `lib/showcase/pages/` with `exampleCard('Title', 'component/file.dart', const MyExample())`
  and, for a new page, to `lib/showcase/registry.dart`. A test fails if an
  exported widget has no example, or an example file is on no page.

## Checking the showcase in a browser

```bash
scripts/build_showcase.sh                  # build first
python3 scripts/check_showcase.py          # quick check; --full for every width, theme and brand
```

It needs `pip install playwright && playwright install chromium`.
