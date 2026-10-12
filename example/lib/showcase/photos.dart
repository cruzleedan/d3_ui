/// The generated pictures the examples use. They ship with the app (no third
/// party host) and are served from the same origin, so a full URL is built
/// from the page's own address.
const photoNames = ['sunset', 'forest', 'ocean', 'berry', 'citrus', 'slate'];

String photoUrl(String name) =>
    Uri.base.resolve('assets/assets/photos/$name.png').toString();

List<String> get allPhotoUrls => [for (final n in photoNames) photoUrl(n)];
