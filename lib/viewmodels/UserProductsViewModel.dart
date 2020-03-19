import 'dart:convert';

import 'package:flutter_app/models/auth.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class UserProductsViewModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  bool _isLoading = false;
  User _authenticatedUser;
}

class UserViewModel extends UserProductsViewModel {
  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode authmode = AuthMode.Login]) async {
    final Map<String, dynamic> authData = {
      'email': email.trim(),
      'password': password.trim(),
      'returnSecureToken': true
    };
    http.Response response;
    _isLoading = true;
    notifyListeners();
    authmode == AuthMode.Login
        ? response = await http.post(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDnAdTHdPfyjXBldc0UKf7fGrPPWS2Zt3M',
            body: json.encode(authData),
          )
        : response = await http.post(
            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDnAdTHdPfyjXBldc0UKf7fGrPPWS2Zt3M',
            body: json.encode(authData),
          );
    bool hasError = true;
    final Map<String, dynamic> responseData = json.decode(response.body);
    var message = 'Something Went Wrong.';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Sign up successful';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND' ||
        responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Login Failed';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }
}

class ProductsViewModel extends UserProductsViewModel {
  bool _showFavorites = false;

  List<Product> get productsList {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) return null;
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.airfrov.com/blog/wp-content/uploads/2016/05/snacks.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final http.Response response = await http.post(
          "https://fluttertutorialds.firebaseio.com/products.json",
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return http
        .delete(
            "https://fluttertutorialds.firebaseio.com/products/${deletedProductId}.json")
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://www.airfrov.com/blog/wp-content/uploads/2016/05/snacks.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
            "https://fluttertutorialds.firebaseio.com/products/${selectedProduct.id}.json",
            body: json.encode(updateData))
        .then((http.Response response) {
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);

      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
  }

  void toggleIsFavorite() {
    final bool isCurrentlyFavorited =
        _products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorited;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        image: selectedProduct.image,
        price: selectedProduct.price,
        isFavorite: newFavoriteStatus,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);

    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get("https://fluttertutorialds.firebaseio.com/products.json")
        .then<Null>((http.Response response) {
      final List<Product> productList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String prodId, dynamic productData) {
        final Product product = Product(
            id: prodId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            image: productData['image'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        productList.add(product);
      });
      _products = productList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }
}

class UtilityModel extends UserProductsViewModel {
  bool get isLoading {
    return _isLoading;
  }
}
