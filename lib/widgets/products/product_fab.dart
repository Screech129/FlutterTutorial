import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFab extends StatefulWidget {
  final Product product;
  ProductFab(this.product);

  @override
  _ProductFabState createState() => _ProductFabState();
}

class _ProductFabState extends State<ProductFab> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainViewModel model) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 70,
            width: 56,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Interval(0, 1, curve: Curves.bounceIn),
              ),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                mini: true,
                heroTag: 'contact',
                onPressed: () async {
                  final url = 'mailto:${widget.product.userEmail}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch!';
                  }
                },
                child: Icon(Icons.mail, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          Container(
              height: 70,
              width: 56,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(0, .5, curve: Curves.easeIn),
                ),
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).cardColor,
                  heroTag: 'favorite',
                  mini: true,
                  onPressed: () {
                    model.toggleIsFavorite();
                  },
                  child: Icon(
                    model.selectedProduct.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
              )),
          FloatingActionButton(
              heroTag: 'options',
              onPressed: () {
                if (_animationController.isDismissed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.rotationZ(
                          _animationController.value * .5 * math.pi),
                      child: Icon(_animationController.isDismissed
                          ? Icons.more_vert
                          : Icons.close),
                    );
                  })),
        ]);
      },
    );
  }
}
