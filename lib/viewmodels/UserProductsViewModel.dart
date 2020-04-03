import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/models/auth.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProductsViewModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  bool _isLoading = false;
  User _authenticatedUser;
}

class UserViewModel extends UserProductsViewModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();
  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

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
    final DateTime currDT = DateTime.now();
    final DateTime expireTime =
        currDT.add(Duration(seconds: int.parse(responseData['expiresIn'])));
    var message = 'Something Went Wrong.';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Success';
      final SharedPreferences sharedPrefs =
          await SharedPreferences.getInstance();
      sharedPrefs.setString('token', responseData['idToken']);
      sharedPrefs.setString('email', email);
      sharedPrefs.setString('userId', responseData['localId']);
      sharedPrefs.setString('expirationTime', expireTime.toIso8601String());

      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);

      _authenticatedUser = User(
          email: email,
          id: responseData['localId'],
          token: responseData['idToken']);
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

  void autoAuthenticate() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String token = sharedPreferences.getString('token');
    final String exprireTime = sharedPreferences.getString('expirationTime');
    if (token != null) {
      final DateTime currDT = DateTime.now();
      final DateTime parseExpirationTime = DateTime.parse(exprireTime);
      if (parseExpirationTime.isBefore(currDT)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      final String email = sharedPreferences.getString('email');
      final String id = sharedPreferences.getString('userId');
      final int tokenLifeSpan =
          parseExpirationTime.difference(currDT).inSeconds;

      _authenticatedUser = User(email: email, id: id, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);

      notifyListeners();
    }
  }

  void logOut() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove('token');
    sharedPreferences.remove('email');
    sharedPreferences.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logOut);
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
          "https://fluttertutorialds.firebaseio.com/products.json?auth=${_authenticatedUser.token}",
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
            "https://fluttertutorialds.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}")
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
            "https://fluttertutorialds.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}",
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

  void toggleIsFavorite() async {
    final bool isCurrentlyFavorited =
        _products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorited;
    if (newFavoriteStatus) {
      final http.Response response = await http.put(
          'https://fluttertutorialds.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: jsonEncode(true));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      await http.delete(
          'https://fluttertutorialds.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
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

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    print(_authenticatedUser.token);
    return http
        .get(
            "https://fluttertutorialds.firebaseio.com/products.json?auth=${_authenticatedUser.token}")
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
            userId: productData['userId'],
            isFavorite: productData['wishListUsers'] == null
                ? false
                : (productData['wishListUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        productList.add(product);
      });
      _products = onlyForUser
          ? productList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : productList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      print(error);
      return;
    });
  }
}

class UtilityModel extends UserProductsViewModel {
  bool get isLoading {
    return _isLoading;
  }
}
