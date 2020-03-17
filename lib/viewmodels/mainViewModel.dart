import 'package:flutter_app/viewmodels/UserProductsViewModel.dart';
import 'package:flutter_app/viewmodels/productsViewModel.dart';
import 'package:flutter_app/viewmodels/userViewModel.dart';
import 'package:scoped_model/scoped_model.dart';

class MainViewModel extends Model with ProductsViewModel, UserViewModel, ProductsUserViewModel {

}