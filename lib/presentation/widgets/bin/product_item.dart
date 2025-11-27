import 'package:flutter/material.dart';
import 'package:coo_list/data/models/product_model.dart';

class ProductItem {
  final String id;
  ProductModel product;
  final Key stableKey;

  ProductItem(this.id, this.product) : stableKey = ValueKey('product_$id');

  void updateProduct(ProductModel newProduct) {
    product = newProduct;
  }
}
