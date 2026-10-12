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
cd example
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8090 --bind <private-address> --directory build/web
```

- Bind to a specific private address, not `0.0.0.0`, so the preview isn't
  exposed on every interface.
- The build is static: rebuild after each change you want to see. The server
  doesn't need restarting.
- The server is a plain background process and stops when the machine
  reboots.
- For hot reload instead, use
  `flutter run -d web-server --web-hostname <private-address> --web-port 8090`.
