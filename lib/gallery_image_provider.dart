import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui' as ui show Codec;
import 'model/gallery_storage.dart';


/// Image provider for GalleryStorageEntry, this implementation is like MemoryImage
/// but includes the bytes future processing inside it.
class GalleryImageProvider extends ImageProvider<GalleryImageProvider> {
  GalleryImageProvider(
      {@required GalleryStorageEntry entry,
      this.cartoon = false,
      this.lod = 100,
      this.scale = 1.0})
      : assert(scale != null),
        assert(entry != null),
        key = entry.key {
    if (cartoon)
      image = entry.cartoon(lod);
    else
      image = entry.photo(lod);
  }

  final String key;
  final int lod;
  final bool cartoon;
  final double scale;
  Future<List<int>> image;

  @override
  Future<GalleryImageProvider> obtainKey(ImageConfiguration configuration) =>
    SynchronousFuture<GalleryImageProvider>(this);
  

  @override
  ImageStreamCompleter load(GalleryImageProvider key) =>
    /// We do not need multiple frames so we use [OneFrameImageStreamCompleter] 
    /// instead [MultiFrameImageStreamCompleter].
    OneFrameImageStreamCompleter(_loadAsync(key)
        .then((codec) => codec.getNextFrame())
        .catchError(() => null)
        .then((info) => ImageInfo(image: info?.image, scale: key.scale)));
  

  Future<ui.Codec> _loadAsync(GalleryImageProvider key) {
    assert(key == this);
    return image.then((bytes) => PaintingBinding.instance.instantiateImageCodec(bytes));
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final GalleryImageProvider typedOther = other;
    return key == typedOther.key &&
        lod == typedOther.lod &&
        cartoon == typedOther.cartoon &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(key, lod, cartoon, scale);

  @override
  String toString() =>
      '$runtimeType(key: $key, lod: $lod, cartoon: $cartoon, scale: $scale)';
}
