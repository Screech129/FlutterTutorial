import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/widgets/products/address_tag.dart';
import 'package:flutter_app/widgets/products/price_tag.dart';
import 'package:flutter_app/widgets/products/product_fab.dart';
import 'package:flutter_app/widgets/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  _openMap() {}

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
    return WillPopScope(
      onWillPop: () {
        print('Back Pressed');
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(product.title),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(product.title),
                background: Hero(
                  tag: product.id,
                  child: FadeInImage(
                    placeholder: AssetImage('assets/food.jpg'),
                    image: NetworkImage(product.image),
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
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
                GestureDetector(
                  child: AddressTag(product.location.address),
                  onTap: _openMap,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text('DELETE'),
                    onPressed: () => _showWarningDialog(context),
                  ),
                ),
              ]),
            )
          ],
        ),
        floatingActionButton: ProductFab(product),
      ),
    );
  }
}
