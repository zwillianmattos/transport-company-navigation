import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';

import 'models/model.dart';

class NetworkHelper {
  NetworkHelper(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf6248075e5a2869e54177a20262a7b5c1a37d';
  final String pathParam = 'driving-car'; // Change it if you want
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async {
    http.Response response = await http.get(new Uri(
        scheme: 'https',
        host: 'api.openrouteservice.org',
        path: 'v2/directions/$pathParam',
        queryParameters: {
          'api_key': apiKey,
          'start': '$startLng,$startLat',
          'end': '$endLng,$endLat',
        }));

    print(
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat');

    if (response.statusCode == 200) {
      String data = response.body;
      print(data);
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future<List<MapLatLng>> recalculateRoutes() async {
    var data = await this.getData();

    LineString ls = LineString(data['features'][0]['geometry']['coordinates']);

    List<MapLatLng> _polyline = <MapLatLng>[];
    ls.lineString.map((e) => _polyline.add(MapLatLng(e[1], e[0])));

    return _polyline;
  }
}
