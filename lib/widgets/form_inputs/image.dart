import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;

  ImageInput(this.setImage, this.product);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text(
                  "Choose an image",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                  child: Text("Use Camera"),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                  child: Text("Use Gallery"),
                ),
              ],
            ),
          );
        });
  }

  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400).then((File image) {
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Theme.of(context).primaryColor;
    Widget previewImage = Text('Please select an image');
    if (_imageFile != null) {
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: 300,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      previewImage = Image.network(
        widget.product.image,
        fit: BoxFit.cover,
        height: 300,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    }
    return Container(
      child: Column(
        children: <Widget>[
          OutlineButton(
            borderSide: BorderSide(
              color: buttonColor,
              width: 2,
            ),
            onPressed: () {
              _openImagePicker(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.camera_alt,
                  color: buttonColor,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  'Add Image',
                  style: TextStyle(
                    color: buttonColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
         previewImage
        ],
      ),
    );
  }
}
