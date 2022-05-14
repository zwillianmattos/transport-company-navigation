class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}

class LocModel {
  LocModel(this.country, this.latitude, this.longitude, {this.data});

  final String country;
  final double latitude;
  final double longitude;

  dynamic data;
}
