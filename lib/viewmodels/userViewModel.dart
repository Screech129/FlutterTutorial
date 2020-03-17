import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/viewmodels/UserProductsViewModel.dart';

class UserViewModel extends ProductsUserViewModel {

  void login(String email, String password) {
    authenticatedUser = User(id: "123", email: email, password: password);
  }
}
