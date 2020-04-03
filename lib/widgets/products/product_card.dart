import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:flutter_app/widgets/form_inputs/location_inputFlutterMap.dart';
import 'package:flutter_app/widgets/products/address_tag.dart';
import 'package:flutter_app/widgets/products/price_tag.dart';
import 'package:flutter_app/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;
  ProductCard(this.product, this.productIndex);

  Widget _buildButtonBar(BuildContext context) {
    return ScopedModelDescendant<MainViewModel>(
      builder: (BuildContext context, Widget child, MainViewModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).primaryColor,
                onPressed: () => Navigator.pushNamed<bool>(
                    context, '/product/' + model.productsList[productIndex].id),
              ),
              IconButton(
                icon: Icon(model.productsList[productIndex].isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
                  model.selectProduct(model.productsList[productIndex].id);
                  model.toggleIsFavorite();
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          FadeInImage(
            placeholder: AssetImage('assets/food.jpg'),
            image: NetworkImage(product.image),
            height: 300,
            fit: BoxFit.cover,
          ),
          Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TitleDefault(product.title),
                  SizedBox(
                    width: 8.0,
                  ),
                  PriceTag(product.price.toString())
                ],
              )),
          AddressTag('Augusta, GA'),
          Container(
            alignment: Alignment.center,
            height: 200,
            child: LocationInputFlutterMap(),
          ),
          Text(product.userEmail),
          _buildButtonBar(context)
        ],
      ),
    );
  }
}
