import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:flutter_app/widgets/products/address_tag.dart';
import 'package:flutter_app/widgets/products/price_tag.dart';
import 'package:flutter_app/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductPage extends StatelessWidget {
  final int productIndex;

  ProductPage(this.productIndex);

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This is permanent'),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () {
      print('Back Pressed');
      Navigator.pop(context, false);
      return Future.value(false);
    }, child: ScopedModelDescendant<MainViewModel>(
        builder: (BuildContext context, Widget child, MainViewModel model) {
      final Product product = model.productsList[productIndex];

      return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Image.asset(product.image),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TitleDefault(product.title),
                PriceTag(product.price.toString())
              ],
            ),
            SizedBox(
              width: 8.0,
              height: 8.0,
            ),
            Text(product.description),
            SizedBox(
              width: 8.0,
              height: 8.0,
            ),
            AddressTag('Augusta, GA'),
            Container(
              padding: EdgeInsets.all(10.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text('DELETE'),
                onPressed: () => _showWarningDialog(context),
              ),
            ),
          ]),
        ),
      );
    }));
  }
}
