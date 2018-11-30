import 'dart:convert';
import 'package:http/http.dart' as http;

import 'cartoonify_service.dart';
import 'cartoon.dart';

class RemoteCartoonifyService implements CartoonifyService {
  final String remote;

  RemoteCartoonifyService(this.remote);

  @override
  Future<Cartoon> cartoon(List<int> image) async {
    try {
      var mpr = http.MultipartRequest("POST", Uri.parse('$remote/cartoon'));
      mpr.files.add(
          http.MultipartFile.fromBytes('image', image, filename: 'image.jpg'));
      var response = await mpr.send();

      if (response.statusCode != 200) throw Exception('Unexpected result');

      var text = await response.stream.bytesToString();
      var cartoonJson = json.decode(text);
      var image64 = cartoonJson['cartoon'];

      if (image64 == null) throw Exception('Unexpected result');

      return Cartoon(image64);
    } on Exception catch (e) {
      print('$e');
      return Cartoon(null);
    }
  }
}
