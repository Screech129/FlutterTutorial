//CURRENT VIDEO 12_7
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/manage_products.dart';
import 'package:flutter_app/pages/product.dart';
import 'package:flutter_app/pages/products.dart';
import 'package:flutter_app/pages/auth.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/product.dart';

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
    final MainViewModel model = MainViewModel();
    return ScopedModel<MainViewModel>(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.blue,
            brightness: Brightness.dark,
            buttonColor: Colors.blue),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => ProductsPage(model),
          '/admin': (BuildContext context) => ManageProductsPage(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                model.productsList.firstWhere((Product product) {
              return product.id == productId;
            });
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => ProductPage(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => ProductsPage(model),
          );
        },
      ),
    );
  }
}
