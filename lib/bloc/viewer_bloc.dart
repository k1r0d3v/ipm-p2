import 'bloc.dart';
import '../model/gallery_storage.dart';

class ViewerBloc extends StatelessBloc {
  ViewerBloc(this.entry);

  final GalleryStorageEntry entry;
}