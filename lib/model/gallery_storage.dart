abstract class GalleryStorageEntry {
  const GalleryStorageEntry(this.key);

  /// String key describing identifying the entry.
  final String key;

  /// Returns a future with the image bytes with the
  /// required level of detail [lod].
  /// [lod] ranges between 0 - 100 with 0 the worst quality
  /// and 100 the original quality.
  Future<List<int>> photo(int lod);

  /// Returns a future with the image bytes with the
  /// required level of detail [lod].
  /// /// [lod] ranges between 0 - 100 with 0 the worst quality
  /// and 100 the original quality.
  Future<List<int>> cartoon(int lod);
}

abstract class GalleryStorage
{
  /// Open this storage and allocate resources.
  Future<void> open();

  /// Closes this storage and free resources.
  Future<void> close();

  /// Find a entry by key, if not found or null returns null.
  Future<GalleryStorageEntry> find(String key);

  /// Stores an image with his cartoon equivalent in this storage.
  Future<GalleryStorageEntry> store(List<int> photo, List<int> cartoon);

  /// List this storage entries in any order.
  Stream<GalleryStorageEntry> list();

  Future<void> delete(String key);
}