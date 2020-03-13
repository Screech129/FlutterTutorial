import 'package:flutter/material.dart';
import 'package:flutter_app/pages/product_edit.dart';

class ProductListPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function updateProduct;
  final Function deleteProduct;
  ProductListPage(this.products, this.updateProduct, this.deleteProduct);

  Widget _buildEditButton(BuildContext context, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ProductEditPage(
            product: products[index],
            updateProduct: updateProduct,
            productIndex: index,
          );
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(products[index]['title']),
            background: Container(color: Colors.red, child: Icon(Icons.delete)),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.startToEnd) {
                deleteProduct(index);
              }
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(products[index]['imageUrl']),
                  ),
                  title: Text(products[index]['title']),
                  subtitle: Text('\$${products[index]['price'].toString()}'),
                  trailing: _buildEditButton(context, index),
                ),
                Divider(
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
        itemCount: products.length);
  }
}
