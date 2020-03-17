import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:flutter_app/widgets/products/product_card.dart';
import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
    Widget productCard = Center(
      child: Text('No Products Found. Please add some.'),
    );

    if (products.length > 0) {
      productCard = ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              ProductCard(products[index], index),
          itemCount: products.length);
    }

    return productCard;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainViewModel>(
      builder: (BuildContext context, Widget child, MainViewModel model) {
        return _buildProductList(model.displayedProducts);
      },
    );
  }
}
