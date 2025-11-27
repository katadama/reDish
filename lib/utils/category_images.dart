class CategoryImages {
  static String getImageForCategory(String categoryName) {
    switch (categoryName) {
      case 'Zöldség':
        return 'assets/images/zoldseg.png';
      case 'Gyümölcs':
        return 'assets/images/gyumolcs.png';
      case 'Pékárú':
        return 'assets/images/pekaru.png';
      case 'Hús':
        return 'assets/images/hus.png';
      case 'Italok':
        return 'assets/images/italok.png';
      case 'Alkohol':
        return 'assets/images/alkohol.png';
      case 'Háztartás':
        return 'assets/images/haztartas.png';
      case 'Higénia':
        return 'assets/images/higenia.png';
      case 'Alapvető élelmiszerek':
        return 'assets/images/alapvetoelelmiszerek.png';
      case 'Tejtermékek':
        return 'assets/images/tejtermek.png';
      default:
        return 'assets/images/zoldseg.png';
    }
  }
}
