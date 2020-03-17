import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductsUserViewModel extends Model {
  List<Product> products = [];
  int selProductIndex;

  User authenticatedUser;

  void addProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: authenticatedUser.email,
        userId: authenticatedUser.id);
    products.add(newProduct);
    notifyListeners();
  }
}
