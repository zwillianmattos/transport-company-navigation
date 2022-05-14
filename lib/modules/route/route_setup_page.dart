import 'package:biochar_maps/models/model.dart';
import 'package:biochar_maps/network_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:calendar_view/calendar_view.dart';

class RouteSetupPage extends StatefulWidget {
  const RouteSetupPage({Key? key}) : super(key: key);

  @override
  State<RouteSetupPage> createState() => _RouteSetupPageState();
}

class _RouteSetupPageState extends State<RouteSetupPage> {
  List<LocModel> api = <LocModel>[
    // LocModel("Biochar Brasil", -22.456102989309546, -48.98985072759156),
    LocModel("Uniao Agrofort", -22.301575706408986, -49.037770702652324),
    LocModel("Coopercitrus Cooperativa De Produtores Rurais",
        -22.31876990824477, -49.05439488555774),
    LocModel("NovAgroserv", -22.314787331731353, -49.05583011093955),
    LocModel("Casa Agrícola", -22.314393144127333, -49.06855549567126),
    LocModel(
        "VANDO PETSHOP -AGROPECUARIA", -22.320980774574608, -49.07311684883046),
    LocModel(
        "Toledo Guedes Agropecuária", -22.322568754620068, -49.06951196005103),
    LocModel("Sementes Falcão, Rua Campos Salles", -22.327928053856205,
        -49.08603436695669),
    LocModel(
        "Agro Pet Falcão - Vila Falcao", -22.32749137791823, -49.0868068431237),
    LocModel(
        "Agrofera, Av. Castelo Branco", -22.32951595483557, -49.09114129272753),
    LocModel("Pet Shop e Agropecuária São José", -22.337737345949716,
        -49.068378540136294),
  ];

  List<LocModel> locations = <LocModel>[];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkService();
  }

  _checkService() async {
    setState(() {
      // isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return _checkService();
    } else {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();
      if (!servicestatus) {
        return _checkService();
      }

      // await _loadLocations();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future _loadLocations() async {
    setState(() {
      isLoading = true;
    });
    Position pos = await Geolocator.getCurrentPosition();
    print(pos);
    locations.clear();
    locations.addAll(api);
    for (int i = 0; i < api.length; i++) {
      NetworkHelper routeHelper = NetworkHelper(
        startLat: pos.latitude,
        startLng: pos.longitude,
        endLat: api[i].latitude,
        endLng: api[i].longitude,
      );
      var data = await routeHelper.getData();

      locations[i].data = data;
    }

    setState(() {
      locations.sort((a, b) => a.data['features'][0]['properties']['segments']
              [0]['distance']
          .compareTo(
              b.data['features'][0]['properties']['segments'][0]['distance']));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotas diarias'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkService();
        },
        child: StreamBuilder<Object>(
            stream: Geolocator.getPositionStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              Position pos = snapshot.data as Position;
              List<CalendarEventData> events = <CalendarEventData>[
                CalendarEventData(
                  date: DateTime(2022, 5, 13),
                  startTime: DateTime(2022, 5, 13, 10),
                  endTime: DateTime.now(),
                  title: 'Você está aqui',
                  description: 'Você está aqui',
                  color: Colors.green,
                ),
              ];
              return DayView(
                controller: EventController()..addAll(events),
                eventTileBuilder: (date, events, boundry, start, end) {
                  // Return your widget to display as event tile.
                  return Container();
                },
                showVerticalLine:
                    false, // To display live time line in day view.
                showLiveTimeLineInAllDays:
                    false, // To display live time line in all pages in day view.
                heightPerMinute: 1, // height occupied by 1 minute time span.
                eventArranger:
                    SideEventArranger(), // To define how simultaneous events will be arranged.
                onEventTap: (events, date) => print(events),
                onDateLongPress: (date) => print(date),
              );
              // return ListView(
              //   children: [
              //     Text("${pos.latitude} - ${pos.longitude}"),
              //     ...locations.map(
              //       (e) => ListTile(
              //         title: Text(e.country),
              //         subtitle: Text(e.latitude.toString() +
              //             ", " +
              //             e.longitude.toString()),
              //         onTap: () {
              //           Navigator.pushNamed(context, '/map', arguments: {
              //             'data': e
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // );
            }),
      ),
    );
  }
}
