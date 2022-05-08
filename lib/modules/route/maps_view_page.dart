import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class MapsView extends StatefulWidget {
  const MapsView({Key? key}) : super(key: key);

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  late SnackBar _snackBar;
  late MapLatLng initialPosition;
  late MapZoomPanBehavior _zoomPanBehavior;
  late MapTileLayerController _controller;

  late MapLatLng oldPosition;
  late MapLatLng newPosition;

  List<MapLatLng> _coordinates = <MapLatLng>[];

  bool isLoading = false;
  @override
  void initState() {
    _checkService();
    _zoomPanBehavior = MapZoomPanBehavior();
    super.initState();
  }

  _checkService() async {
    setState(() {
      isLoading = true;
    });
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
    Position pos = await Geolocator.getCurrentPosition();
    initialPosition = MapLatLng(pos.latitude, pos.longitude);

    _controller = MapTileLayerController();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: StreamBuilder<Object>(
                stream: Geolocator.getPositionStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  Position position = snapshot.data as Position;
                  _controller.updateMarkers([0]);
                  _zoomPanBehavior.focalLatLng =
                      MapLatLng(position.latitude, position.longitude);
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
                          initialMarkersCount: 1,
                          markerBuilder: (ctx, index) {
                            if (index == 0) {
                              //current position
                              return MapMarker(
                                latitude: position.latitude,
                                longitude: position.longitude,
                                iconType: MapIconType.circle,
                                iconColor: Colors.blue,
                              );
                            }

                            return MapMarker(
                              latitude: _coordinates[index].latitude,
                              longitude: _coordinates[index].longitude,
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B2835),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 20),
                            Text(
                              '${(position.speed * 3.600000).roundToDouble()} km/h',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 1)),
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
                      ),
                    ),
                  ]);
                }),
          );
  }
}
