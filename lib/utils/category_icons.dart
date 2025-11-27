import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIconForCategory(String categoryName) {
    switch (categoryName) {
      case 'Zöldség':
        return Icons.eco;
      case 'Gyümölcs':
        return Icons.apple;
      case 'Pékárú':
        return Icons.bakery_dining;
      case 'Hús':
        return Icons.restaurant;
      case 'Italok':
        return Icons.local_drink;
      case 'Alkohol':
        return Icons.wine_bar;
      case 'Háztartás':
        return Icons.cleaning_services;
      case 'Alapvető élelmiszerek':
        return Icons.shopping_basket;
      case 'Tejtermékek':
        return Icons.egg;
      case 'Szépségápolás':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }
}
