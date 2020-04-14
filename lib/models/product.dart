import 'package:flutter/material.dart';
import 'package:flutter_app/models/locationData.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final LocationData location;
  final String imagePath;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      this.isFavorite = false,
      @required this.userEmail,
      @required this.userId,
      @required this.location,
      @required this.imagePath});
}
