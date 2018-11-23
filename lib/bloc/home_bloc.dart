import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';

import '../model/cartoonify_service.dart';
import '../model/cartonify_mock_service.dart';
import '../model/gallery_storage.dart';


class HomeBloc extends StatefulBloc {
  SharedPreferences _preferences;

  var _gotoGalleryEvent = PublishSubject();
  var _takePhotoEvent = PublishSubject();

  var _photoEvent = PublishSubject<List<int>>();
  var _photoEventSubscription;

  var _cartoonProcessor = PublishSubject<Future<GalleryStorageEntry>>();
  var _cartoonReady = PublishSubject<GalleryStorageEntry>();

  CartoonifyService _service = CartoonifyMockService();

  final GalleryStorage storage;
  GalleryStorageEntry _lastEntry;

  GalleryStorageEntry get lastEntry => _lastEntry;

  /// Take a photo event
  Sink get takePhotoEventSink => _takePhotoEvent.sink;
  Stream get takePhotoEventStream => _takePhotoEvent.stream.asBroadcastStream();

  /// Got to the gallery event
  Sink get gotoGalleryEventSink => _gotoGalleryEvent.sink;
  Stream get gotoGalleryEventStream =>
      _gotoGalleryEvent.stream.asBroadcastStream();

  /// Send a photo to be converted to a cartoon
  /// This sink generates the next events: photoStream -> cartoonProcessorStream -> cartoonReadyStream
  Sink<List<int>> get photoSink => _photoEvent.sink;
  Stream<List<int>> get photoStream => _photoEvent.stream.asBroadcastStream();

  /// Stream processor transformator of photos in cartoons
  Stream<Future<GalleryStorageEntry>> get cartoonProcessorStream =>
      _cartoonProcessor.stream.asBroadcastStream();

  /// Notify when a new cartoon is available
  Stream<GalleryStorageEntry> get cartoonReadyStream =>
      _cartoonReady.stream.asBroadcastStream();

  HomeBloc(this.storage);

  @override
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await storage.open();

    _lastEntry = await storage.find(_getLastEntryKey());

    _photoEventSubscription = _photoEvent.stream.listen((photoBytes) =>
        _cartoonProcessor.sink.add(_service
            .cartoon(photoBytes)
            .then((cartoon) => storage.store(photoBytes, cartoon.bytes)
              ..then((entry) {
                _lastEntry = entry;
                _saveLastEntryKey();
                _cartoonReady.sink.add(entry);
              }))));
  }

  @override
  Future<void> dispose() async {
    _photoEventSubscription.cancel();
    _cartoonReady.close();
    _gotoGalleryEvent.close();
    _takePhotoEvent.close();
    _photoEvent.close();
    _cartoonProcessor.close();

    await storage.close();
  }

  String _getLastEntryKey() {
    return _preferences
        .getString(this.runtimeType.toString() + '_last_entry_key');
  }

  Future<bool> _saveLastEntryKey() async {
    return await _preferences.setString(
        this.runtimeType.toString() + '_last_entry_key', _lastEntry.key);
  }
}
