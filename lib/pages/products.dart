//Video 8_9 is current tutorial
import 'package:flutter/material.dart';

import '../widgets/products/products.dart';

class ProductsPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductsPage(this.products);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Navigation'),
            ),
            ListTile(
                leading: Icon(Icons.edit),
                title: Text('Manage Products'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/admin');
                })
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Easy List'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.favorite), onPressed: () {})
        ],
      ),
      body: Products(products),
    );
  }
}
