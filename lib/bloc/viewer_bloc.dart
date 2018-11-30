import 'bloc.dart';
import '../model/gallery_storage.dart';

class ViewerBloc extends StatelessBloc {
  ViewerBloc(this.entries, this.index);

  final List<GalleryStorageEntry> entries;
  final int index;
}