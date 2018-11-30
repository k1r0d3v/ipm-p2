import 'bloc.dart';
import '../model/gallery_storage.dart';

class GalleryBloc extends StatelessBloc {
  GalleryBloc(this.entry, this.storage);

  final GalleryStorageEntry entry;
  final GalleryStorage storage;
}