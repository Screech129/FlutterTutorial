import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/viewmodels/UserProductsViewModel.dart';

class ProductsViewModel extends ProductsUserViewModel {
  bool _showFavorites = false;

  List<Product> get productsList {
    return List.from(products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(products);
  }

  int get selectedProductIndex {
    return selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) return null;
    return products[selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void deleteProduct() {
    products.removeAt(selectedProductIndex);
  }

  void updateProduct(
      String title, String description, String image, double price) {
    final Product updatedProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void selectProduct(int index) {
    selProductIndex = index;
  }

  void toggleIsFavorite() {
    final bool isCurrentlyFavorited = products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorited;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        image: selectedProduct.image,
        price: selectedProduct.price,
        isFavorite: newFavoriteStatus,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);

    products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
