import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  /*
    'Rotas',
    'Relatorios',
    'Pedidos',
    'Catalogo de Produtos',
    'Dados Bancarios',
    'Contato'
  */
  List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Rotas',
      icon: Icons.map,
      route: '/setup',
    ),
    MenuItem(
      title: 'Relatórios',
      icon: Icons.insert_chart,
    ),
    MenuItem(
      title: 'Pedidos',
      icon: Icons.shopping_cart,
    ),
    MenuItem(
      title: 'Catalogo Produtos',
      icon: Icons.store,
    ),
    MenuItem(
      title: 'Dados Bancários',
      icon: Icons.account_balance_wallet,
    ),
    MenuItem(
      title: 'Contato',
      icon: Icons.phone,
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView.builder(
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_menuItems[index].title),
              onTap: () {},
            );
          },
        ),
      ),
      backgroundColor: Color(0xFF205B4E),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFFF1EEA0),
          foregroundColor: Color(0xFF205B4E),
          centerTitle: true,
          title: ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: Image.asset(
                'assets/logo_green.png',
                scale: 2.6,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => {
              scaffoldKey.currentState?.openDrawer(),
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: () => {},
            ),
          ],
        ),
        SliverGrid.count(
          crossAxisCount: MediaQuery.of(context).size.width > 550 ? 4 : 2,
          children: [
            ..._menuItems.map((e) => menuCardItem(
                  context,
                  menuItem: e,
                  onTap: e.route != null ? () {
                    Navigator.pushNamed(context, e.route!);
                  } : null,
                )),
          ],
        ),
      ]),
    );
  }
}

Widget menuCardItem(BuildContext context,
    {required MenuItem menuItem, Function()? onTap}) {
  return Container(
    padding: const EdgeInsets.all(15),
    height: MediaQuery.of(context).size.height * 0.25,
    child: InkWell(
      onTap: onTap,
      
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: menuItem.route != null ? Color(0xFF0B7937) : Color(0xFF8D8D8D),
        elevation: 4,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                menuItem.icon,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                menuItem.title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MenuItem {
  final String title;
  final IconData? icon;
  final String? route;

  const MenuItem({
    required this.title,
    this.route,
    this.icon,
  });
}
