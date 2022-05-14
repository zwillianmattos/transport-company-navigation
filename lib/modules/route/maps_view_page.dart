import 'package:biochar_maps/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../network_helper.dart';

class MapsView extends StatefulWidget {
  const MapsView({Key? key}) : super(key: key);

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView>
    with SingleTickerProviderStateMixin {
  late SnackBar _snackBar;
  late MapLatLng initialPosition;
  late MapLatLng destinationPosition;
  late MapZoomPanBehavior _zoomPanBehavior;
  late MapTileLayerController _controller;

  late List<MapLatLng> polyline;
  late List<List<MapLatLng>> polylines;

  late Position lastKnownPosition;

  bool focus = false;
  bool isLoading = false;
  bool fullScreen = false;

  late final AnimationController _carAnim =
      AnimationController(vsync: this, duration: Duration(seconds: 1));
  double lastAngle = 0;

  @override
  void initState() {
    _checkService();
    _zoomPanBehavior = MapZoomPanBehavior(
      minZoomLevel: 1,
      maxZoomLevel: 20,
      // enableDoubleTapZooming: true,
      // enablePinching: true,
      // enablePanning: true,
    );
// to hide only bottom bar:
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  _checkService() async {
    setState(() {
      isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return _checkService();
    } else {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();
      if (!servicestatus) {
        _snackBar = SnackBar(
          content: const Text('Por favor, ative o serviço de localização'),
          action: SnackBarAction(
            label: 'Ativar',
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(_snackBar);
      }

      _controller = MapTileLayerController();

      // Get argument from previous page
      _drawPolyLines();
    }

    setState(() {
      isLoading = false;
    });
  }

  _drawPolyLines() async {
    setState(() {
      isLoading = true;
    });
    var routes =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    LocModel locModel = routes['data'];

    Position pos = await Geolocator.getCurrentPosition();
    initialPosition = MapLatLng(pos.latitude, pos.longitude);
    destinationPosition = MapLatLng(locModel.latitude, locModel.longitude);

    _controller.insertMarker(0);
    _controller.insertMarker(1);
    _controller.insertMarker(2);

    LineString ls =
        LineString(locModel.data['features'][0]['geometry']['coordinates']);

    polyline = <MapLatLng>[];

    ls.lineString.forEach((element) {
      polyline.add(MapLatLng(element[1], element[0]));
    });

    // ls.lineString.map((e) =>);

    polylines = <List<MapLatLng>>[polyline];
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> recalculateRoute() async {
  //   isLoading = true;

  //   _polyline = <MapLatLng>[];

  //   Position pos = await Geolocator.getCurrentPosition();
  //   for (int i = 0; i < _data.length; i++) {
  //     NetworkHelper network = NetworkHelper(
  //       startLat: pos.latitude,
  //       startLng: pos.longitude,
  //       endLat: _data[i].latitude,
  //       endLng: _data[i].longitude,
  //     );

  //     var data = await network.getData();

  //     LineString ls =
  //         LineString(data['features'][0]['geometry']['coordinates']);

  //     ls.lineString.map((e) => _polyline.add(MapLatLng(e[1], e[0])));
  //     _data[i].data = data;
  //   }

  //   _data.sort((a, b) => a.data['features'][0]['properties']['segments'][0]
  //           ['distance']
  //       .compareTo(
  //           b.data['features'][0]['properties']['segments'][0]['distance']));

  //   polylines = <List<MapLatLng>>[_polyline];
  //   isLoading = false;
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: StreamBuilder<Position>(
                stream: Geolocator.getPositionStream(
                    locationSettings: LocationSettings(
                  accuracy: LocationAccuracy.bestForNavigation,
                )),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  Position position = snapshot.data as Position;
                  lastKnownPosition = position;

                  _controller.updateMarkers([2]);

                  if (focus) {
                    _zoomPanBehavior.focalLatLng =
                        MapLatLng(position.latitude, position.longitude);
                    _zoomPanBehavior.zoomLevel = 18;
                  }

                  return Stack(children: [
                    SfMaps(
                      layers: [
                        MapTileLayer(
                          controller: _controller,
                          zoomPanBehavior: _zoomPanBehavior,
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          initialFocalLatLng: initialPosition,
                          initialZoomLevel: 15,
                          initialMarkersCount: 3,
                          sublayers: [
                            MapPolylineLayer(
                              color: Colors.green,
                              width: 5,
                              polylines: List<MapPolyline>.generate(
                                polylines.length,
                                (int index) {
                                  return MapPolyline(
                                    points: polylines[index],
                                  );
                                },
                              ).toSet(),
                            ),
                          ],
                          markerBuilder: (ctx, index) {
                            if (index == 0) {
                              return MapMarker(
                                latitude: initialPosition.latitude,
                                longitude: initialPosition.longitude,
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              );
                            } else if (index == 1) {
                              return MapMarker(
                                latitude: destinationPosition.latitude,
                                longitude: destinationPosition.longitude,
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              );
                            } else if (index == 2) {
                              //current position

                              double angle = -math.pi * -position.heading / 180;
                              return MapMarker(
                                latitude: position.latitude,
                                longitude: position.longitude,
                                // iconType: MapIconType.circle,
                                // iconColor: Colors.blue,
                                child: AnimatedBuilder(
                                  animation: _carAnim,
                                  builder: (ctx, widget) {
                                    return Transform.rotate(
                                      alignment: Alignment.center,
                                      angle: _carAnim.value * angle,
                                      child: Image.asset(
                                        position.heading >= 0.0 &&
                                                position.heading <= 180
                                            ? "assets/gps/navigation-2.png"
                                            : "assets/gps/navigation.png",
                                        width: _zoomPanBehavior.zoomLevel *
                                            MediaQuery.of(context).size.width *
                                            0.5 /
                                            100,
                                        height: _zoomPanBehavior.zoomLevel *
                                            MediaQuery.of(context).size.height *
                                            0.5 /
                                            100,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return MapMarker(
                                // latitude: _data[index].latitude,
                                // longitude: _data[index].longitude,
                                latitude: 0,
                                longitude: 0,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.1,
                      minChildSize: 0.1,
                      maxChildSize: 0.3,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Card(
                            color: Color(0xFF1B2835),
                            elevation: 12.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            margin: const EdgeInsets.all(0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (fullScreen) {
                                                SystemChrome
                                                    .setEnabledSystemUIMode(
                                                        SystemUiMode
                                                            .immersiveSticky);
                                              } else {
                                                SystemChrome
                                                    .setEnabledSystemUIMode(
                                                        SystemUiMode
                                                            .edgeToEdge);
                                              }

                                              fullScreen = !fullScreen;
                                            });
                                          },
                                          icon: Icon(
                                            fullScreen
                                                ? Icons.fullscreen
                                                : Icons.fullscreen_exit,
                                            color: Colors.white,
                                          )),
                                      IconButton(
                                        icon: Icon(
                                          focus
                                              ? Icons.gps_fixed
                                              : Icons.gps_not_fixed,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            focus = !focus;

                                            if (focus == false) {
                                              _zoomPanBehavior.zoomLevel = 15;
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        '${((position.speed * 3600) / 1000).roundToDouble()} km/h',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      StreamBuilder(
                                        stream: Stream.periodic(
                                            const Duration(seconds: 1)),
                                        builder: (context, snapshot) {
                                          return Center(
                                            child: Text(
                                              DateFormat('hh:mm ar')
                                                  .format(DateTime.now()),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      "Rotas restantes",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  // ..._data.map((data) {
                                  //   return ListTile(
                                  //               leading: Icon(Icons.drag_handle, color: Colors.white,),
                                  //               title: Text(
                                  //                 "${data.country}",
                                  //                 style: const TextStyle(
                                  //                     color: Colors.white,
                                  //                     fontSize: 18,
                                  //                     overflow:
                                  //                         TextOverflow.fade),
                                  //               ),
                                  //             );
                                  // })
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ]);
                }),
          );
  }
}
