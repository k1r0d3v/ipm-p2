import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'gallery_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Simple class that generates images in base a level of detail
/// and cache it on disk.
class FSLODCache {
  FSLODCache(this.imagesDirectory, this.cacheDirectory);

  Directory imagesDirectory;
  Directory cacheDirectory;
  var _entries = <String, bool>{}; // A [Set] doesn't works ¿Why?

  /// Creates a new image in the cache or returns one existent
  /// given a [key] and a [lod].
  /// Note: [key] musn't be a path or contains invalid path characteres.
  Future<List<int>> getOrPut(String key, int lod) async {
    var tag = 'FSLODCache: [key: $key, lod: $lod]';
    print('$tag: Request');

    var cacheKey = _getCacheKey(key, lod);
    var cacheFile = File('${cacheDirectory.path}/${cacheKey}.jpg');

    // Check the memory cache.
    // If the entry has been recentry cached, return it.
    if (_entries.containsKey(cacheKey)) {      
      return cacheFile.readAsBytes();
    } else {
      // Try to read and return the cache file with the cached lod,
      // if fails, continue.
      try {
        print('$tag: Not cached in memory, trying to load from disk');
        var bytes = await cacheFile.readAsBytes();
        _entries[cacheKey] = true;
        return bytes;
      } on Exception {}
    }

    print('$tag: Not in disk, caching image');

    // Create the lod in memory
    var bytes = await FlutterImageCompress.compressWithFile(
      '${imagesDirectory.path}/${key}.jpg',
      quality: lod,
    );

    // Write the lod and register it in memory.
    // TODO: Asyncronous write
    await cacheFile.writeAsBytes(bytes);
    _entries[cacheKey] = true;

    // Returns the new created lod
    // TODO: Remove this conversion ¿can be done?
    return Uint8List.fromList(bytes);
  }

  String _getCacheKey(String key, int lod) => '${key}_$lod';
}

/// File system gallery storage entry.
class FSGalleryStorageEntry extends GalleryStorageEntry {
  const FSGalleryStorageEntry(String key, String root, FSLODCache cache)
      : _cache = cache,
        _root = root,
        super(key);

  final FSLODCache _cache;
  final String _root;

  @override
  Future<List<int>> photo(int lod) => _getImage('${key}_photo', lod);

  @override
  Future<List<int>> cartoon(int lod) => _getImage('${key}_cartoon', lod);

  Future<List<int>> _getImage(String key, int lod) => lod != 100
      ? _cache.getOrPut(key, lod)
      : File('${_root}/${key}.jpg').readAsBytes();
}

/// File system gallery storage.
class FSGalleryStorage implements GalleryStorage {
  Directory _root;
  FSLODCache _cache;

  @override
  Future<void> open() async {
    var root = await getApplicationDocumentsDirectory();

    _root = await Directory('${root.path}/images').create();
    _cache =
        FSLODCache(_root, await Directory('${root.path}/image_cache').create());
  }

  @override
  Future<void> close() => null;

  @override
  Future<GalleryStorageEntry> find(String key) {
    if (key == null) return null;

    return File('${_root.path}/${key}_photo.jpg')
        .exists()
        .then((value) => value ? _makeEntry(key) : null);
  }

  @override
  Stream<GalleryStorageEntry> list() => _root
      .list(recursive: false, followLinks: false)
      .where((entity) => entity.path.endsWith('_photo.jpg'))
      .map((entity) => _makeEntry(_pathToKey(entity.path)));

  @override
  Future<GalleryStorageEntry> store(List<int> photo, List<int> cartoon) async {
    var key = DateTime.now().toString();

    // Store the reals
    var futurePhotoFile = File('${_root.path}/${key}_photo.jpg')
        .create()
        .then((file) => file.writeAsBytes(photo));
    var futureCartoonFile = File('${_root.path}/${key}_cartoon.jpg')
        .create()
        .then((file) => file.writeAsBytes(cartoon));

    await Future.wait([futurePhotoFile, futureCartoonFile]);
    return _makeEntry(key);
  }

  String _pathToKey(String path) {
    var filename = path.substring(path.lastIndexOf('/') + 1);
    filename = filename.substring(0, filename.lastIndexOf(RegExp(r'_photo')));
    return filename;
  }

  FSGalleryStorageEntry _makeEntry(String key) =>
      FSGalleryStorageEntry(key, _root.path, _cache);
}
