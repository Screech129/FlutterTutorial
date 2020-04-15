import 'package:flutter/material.dart';
import 'package:flutter_app/pages/product_edit.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListPage extends StatefulWidget {
  final MainViewModel model;
  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState() {
    widget.model.fetchProducts(onlyForUser: true,clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(
      BuildContext context, int index, MainViewModel model) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.productsList[index].id);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ProductEditPage();
          })).then((_){
            model.selectProduct(null);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainViewModel>(
        builder: (BuildContext context, Widget child, MainViewModel model) {
      return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.productsList[index].title),
              background:
                  Container(color: Colors.red, child: Icon(Icons.delete)),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.startToEnd) {
                  model.selectProduct(model.productsList[index].id);
                  model.deleteProduct();
                }
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.productsList[index].image),
                    ),
                    title: Text(model.productsList[index].title),
                    subtitle:
                        Text('\$${model.productsList[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                ],
              ),
            );
          },
          itemCount: model.productsList.length);
    });
  }
}
