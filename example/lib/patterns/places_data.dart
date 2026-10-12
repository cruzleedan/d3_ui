/// Fictional data for the Patterns page. Nothing here is a real place.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.area,
    required this.rating,
    required this.distanceKm,
    required this.photo,
    required this.about,
    this.openNow = true,
  });

  final String id;
  final String name;
  final String cuisine;
  final String area;
  final double rating;
  final double distanceKm;

  /// One of the generated photo names (see showcase/photos.dart).
  final String photo;
  final String about;
  final bool openNow;
}

const cuisines = ['Asian', 'Mexican', 'Pizza', 'Seafood', 'Brunch', 'Vegan'];

const seedPlaces = [
  Place(
    id: 'p1',
    name: 'Bao House',
    cuisine: 'Asian',
    area: 'Old Town',
    rating: 4.6,
    distanceKm: 0.4,
    photo: 'sunset',
    about: 'Steamed buns and noodles from an open kitchen.',
  ),
  Place(
    id: 'p2',
    name: 'Casa Verde',
    cuisine: 'Mexican',
    area: 'Riverside',
    rating: 4.3,
    distanceKm: 1.1,
    photo: 'forest',
    about: 'Tacos on hand-pressed tortillas and a long mezcal list.',
  ),
  Place(
    id: 'p3',
    name: 'Dough Brothers',
    cuisine: 'Pizza',
    area: 'Market Street',
    rating: 4.8,
    distanceKm: 0.8,
    photo: 'citrus',
    about: 'Wood-fired pizza with a two-day dough.',
    openNow: false,
  ),
  Place(
    id: 'p4',
    name: 'Harbour Fish',
    cuisine: 'Seafood',
    area: 'The Docks',
    rating: 4.5,
    distanceKm: 2.3,
    photo: 'ocean',
    about: 'Whatever the boats brought in this morning.',
  ),
  Place(
    id: 'p5',
    name: 'Ivy Cafe',
    cuisine: 'Brunch',
    area: 'Old Town',
    rating: 4.2,
    distanceKm: 0.6,
    photo: 'berry',
    about: 'All-day brunch, strong coffee and a quiet back garden.',
  ),
  Place(
    id: 'p6',
    name: 'Green Bowl',
    cuisine: 'Vegan',
    area: 'Riverside',
    rating: 4.4,
    distanceKm: 1.6,
    photo: 'slate',
    about: 'Grain bowls and seasonal salads, all plant-based.',
  ),
];
