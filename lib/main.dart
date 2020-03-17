//CURRENT VIDEO 11_5
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/manage_products.dart';
import 'package:flutter_app/pages/product.dart';
import 'package:flutter_app/pages/products.dart';
import 'package:flutter_app/pages/auth.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainViewModel>(
      model: MainViewModel(),
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.blue,
            brightness: Brightness.dark,
            buttonColor: Colors.blue),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => ProductsPage(),
          '/admin': (BuildContext context) => ManageProductsPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductPage(index));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => ProductsPage(),
          );
        },
      ),
    );
  }
}
