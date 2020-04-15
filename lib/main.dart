//CURRENT VIDEO 14_12
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/manage_products.dart';
import 'package:flutter_app/pages/product.dart';
import 'package:flutter_app/pages/products.dart';
import 'package:flutter_app/pages/auth.dart';
import 'package:flutter_app/shared/adaptiveTheme.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:flutter_app/widgets/custom_route.dart';
import 'package:scoped_model/scoped_model.dart';
import 'models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainViewModel _model = MainViewModel();
  bool _isAuthenticated = false;
  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainViewModel>(
      model: _model,
      child: MaterialApp(
        theme: getAdaptiveThemeData(context),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ManageProductsPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.productsList.firstWhere((Product product) {
              return product.id == productId;
            });
            return CustomRoute<bool>(
                builder: (BuildContext context) =>
                    !_isAuthenticated ? AuthPage() : ProductPage(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) =>
                !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          );
        },
      ),
    );
  }
}
