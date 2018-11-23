import 'dart:async';
import 'cartoon.dart';

abstract class CartoonifyService {
  Future<Cartoon> cartoon(List<int> image);
}