import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class Pin {
  int? id;
  LatLng coord;
  String title;
  List<XFile>? images;

  Pin({this.id, required this.coord, required this.title, this.images});

//  https://stackoverflow.com/questions/57823787/does-dart-have-an-equivalent-to-pythons-pickle-to-serialize-collections-of-obje

  /// Database --> Pin class
  Pin.fromMap(Map<String, dynamic> pin)
      : id = pin['id'],
        coord = LatLng(pin['lat'], pin['long']),
        title = pin['title'],
        images = (pin['images'] != null)
            ? List<XFile>.from(
                jsonDecode(pin['images']).map((path) => XFile(path)))
            : null;

  /// Pin class --> Database
  Map<String, dynamic> toMap() {
    final record = {
      'lat': coord.latitude,
      'long': coord.longitude,
      'title': title
    };

    if (images != null) {
      record.addAll(
          {'images': jsonEncode(images!.map((xfile) => xfile.path).toList())});
    }

    return record;
  }
}
