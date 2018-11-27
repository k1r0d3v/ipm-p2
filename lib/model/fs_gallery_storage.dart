import 'dart:async';
import 'dart:io';
import 'gallery_storage.dart';
import 'package:path_provider/path_provider.dart';


/// File system gallery storage entry.
class FSGalleryStorageEntry extends GalleryStorageEntry {
  const FSGalleryStorageEntry(String key, String root)
      : _root = root,
        super(key);

  final String _root;

  @override
  Future<List<int>> photo(int lod) => _getImage('${key}_photo', lod);

  @override
  Future<List<int>> cartoon(int lod) => _getImage('${key}_cartoon', lod);

  Future<List<int>> _getImage(String key, int lod) => File('${_root}/${key}.jpg').readAsBytes();
}

/// File system gallery storage.
class FSGalleryStorage implements GalleryStorage {
  Directory _root;

  @override
  Future<void> open() async {
    var root = await getApplicationDocumentsDirectory();

    _root = await Directory('${root.path}/images').create();
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
      FSGalleryStorageEntry(key, _root.path);
}
