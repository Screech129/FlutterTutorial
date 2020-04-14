import 'package:flutter/material.dart';
import 'package:flutter_app/models/locationData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:flutter_app/widgets/form_inputs/image.dart';
import 'package:flutter_app/widgets/form_inputs/location_inputFlutterMap.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'imageUrl': null,
    'location': null
  };

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Widget _buildTitleTextFiled(Product selectedProduct) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Title'),
      initialValue: selectedProduct == null ? '' : selectedProduct.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ chars long.';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product selectedProduct) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Description'),
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      initialValue: selectedProduct == null ? '' : selectedProduct.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ chars long.';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Product selectedProduct) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.number,
      initialValue:
          selectedProduct == null ? '' : selectedProduct.price.toString(),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['imageUrl'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(_formData['title'], _formData['description'],
              _formData['imageUrl'], _formData['price'], _formData['location'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Something went wrong!'),
                content: Text('Please try the request again.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            },
          );
        }
      });
    } else {
      updateProduct(
        _formData['title'],
        _formData['description'],
        _formData['imageUrl'],
        _formData['price'],
        _formData['location'],
      ).then((_) => Navigator.pushReplacementNamed(context, '/products')
          .then((_) => setSelectedProduct(null)));
    }
  }

  void _setLocation(LocationData locationData) {
    _formData['location'] = locationData;
  }

  void _setImage(File image) {
    _formData['imageUrl'] = image;
  }

  Widget _buldSubmitButton() {
    return ScopedModelDescendant<MainViewModel>(
      builder: (BuildContext context, Widget child, MainViewModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product selectedProduct) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
              children: <Widget>[
                _buildTitleTextFiled(selectedProduct),
                _buildDescriptionTextField(selectedProduct),
                _buildPriceTextField(selectedProduct),
                SizedBox(
                  height: 10.0,
                ),

                SizedBox(
                  height: 10.0,
                ),

                LocationInputFlutterMap(_setLocation, selectedProduct),
                SizedBox(
                  height: 10.0,
                ),
                ImageInput(_setImage, selectedProduct),
                // GestureDetector(
                //   child: Container(
                //     color: Colors.green,
                //     padding: EdgeInsets.all(5.0),
                //     child: Text("button"),
                //   ),
                //   onTap: _submitForm,
                // )
                _buldSubmitButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainViewModel>(
        builder: (BuildContext context, Widget child, MainViewModel model) {
      var pageContent = _buildPageContent(context, model.selectedProduct);
      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(title: Text('Edit Product')),
              body: pageContent,
            );
    });
  }
}
