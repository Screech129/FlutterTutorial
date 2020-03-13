import 'package:flutter/material.dart';
import 'package:flutter_app/pages/product_create.dart';
import 'package:flutter_app/pages/product_list.dart';

class ManageProductsPage extends StatelessWidget {
  final Function addProduct;
  final Function deleteProduct;

  ManageProductsPage(this.addProduct, this.deleteProduct);

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Navigation'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Products List'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Manage Products'),
      bottom: TabBar(
        tabs: <Widget>[
          Tab(
            text: 'Create product',
            icon: Icon(Icons.create),
          ),
          Tab(text: 'Products', icon: Icon(Icons.list))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: _buildAppBar(),
        body: TabBarView(
          children: <Widget>[ProductCreatePage(addProduct), ProductListPage()],
        ),
      ),
    );
  }
}
