import 'package:biochar_maps/modules/home/menu_page.dart';
import 'package:biochar_maps/modules/route/route_setup_page.dart';
import 'package:biochar_maps/modules/splash/splash_page.dart';
import 'package:flutter/material.dart';

import 'modules/route/maps_view_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biochar Rotas',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home' : (context) => const MenuPage(),
        '/setup' : (context) => const RouteSetupPage(),
        '/map': (context) => const MapsView(),
      },
    );
  }
}
