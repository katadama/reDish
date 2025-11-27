class CategoryMessages {
  CategoryMessages._();

  static const String movedToShopping = 'Termék bevásárló listába helyezve';
  static const String movedToHome = 'Termék otthoni listába helyezve';
  static const String movedToBin = 'Termék kukába helyezve';

  static const String duplicateInProgress = 'Duplikálás folyamatban...';
  static const String duplicateSuccess = 'Termék duplikálva';
  static String duplicateError(String error) => 'Sikertelen duplikálás: $error';

  static const String sliceInProgress = 'Kettévágás folyamatban...';
  static const String sliceSuccess = 'Termék kettévágva';
  static String sliceError(String error) => 'Sikertelen kettévágás: $error';

  static const String takeOneInProgress =
      'Egy darab termék kivétele folyamatban...';
  static const String takeOneSuccess = 'Egy darab termék kivéve';
  static String takeOneError(String error) =>
      'Sikertelen egy darab termék kivétele: $error';

  static const String createMultipleQuantityError =
      'Nem lehet több darabot létrehozni, ha a mennyiség 25 vagy több. Kérlek használd a kettévágást.';
  static const String createMultipleInProgress = 'Darabolás folyamatban...';
  static const String createMultipleSuccess = 'Több darab létrehozva';
  static String createMultipleError(String error) =>
      'Sikertelen több darab létrehozás: $error';

  static const String invalidProductId = 'Hiba: Érvénytelen termék ID';
  static const String noProfileSelected = 'Error: Nincs profil kiválasztva';
  static const String invalidProfileId = 'Error: Hibás profile ID';
}
