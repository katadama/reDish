import 'package:flutter/material.dart';

class ProductDateUtils {
  static DateTime calculateSpoilDate(DateTime lastMovedDate, int spoilageDays) {
    return lastMovedDate.add(Duration(days: spoilageDays));
  }

  static int calculateDaysUntilSpoiled(
      DateTime lastMovedDate, int spoilageDays) {
    final spoilDate = calculateSpoilDate(lastMovedDate, spoilageDays);
    final today = DateTime.now();

    final todayStripped = DateTime(today.year, today.month, today.day);
    final spoilDateStripped =
        DateTime(spoilDate.year, spoilDate.month, spoilDate.day);

    return spoilDateStripped.difference(todayStripped).inDays;
  }

  static int calculateDaysInList(DateTime lastMovedDate) {
    final today = DateTime.now();

    final todayStripped = DateTime(today.year, today.month, today.day);
    final lastMovedStripped =
        DateTime(lastMovedDate.year, lastMovedDate.month, lastMovedDate.day);

    return todayStripped.difference(lastMovedStripped).inDays;
  }

  static String getTimeInListMessage(DateTime lastMovedDate) {
    final daysInList = calculateDaysInList(lastMovedDate);

    if (daysInList == 0) {
      return 'Ma került a listába';
    } else if (daysInList == 1) {
      return 'Tegnap került a listába';
    } else {
      return '$daysInList napja listában';
    }
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String getSpoilageStatusMessage(int daysUntilSpoiled) {
    if (daysUntilSpoiled < 0) {
      return '${daysUntilSpoiled.abs()} napja lejárt';
    } else if (daysUntilSpoiled == 0) {
      return 'Ma fog lejárni';
    } else if (daysUntilSpoiled == 1) {
      return 'Holnap fog lejárni';
    } else if (daysUntilSpoiled == 3) {
      return '3 nap múlva fog járni';
    } else {
      return '$daysUntilSpoiled nap múlva fog járni';
    }
  }

  static Color getSpoilageStatusColor(int daysUntilSpoiled) {
    if (daysUntilSpoiled < 0) {
      return Colors.red;
    } else if (daysUntilSpoiled <= 2) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  static Color getTimeInListColor(int daysInList) {
    if (daysInList > 14) {
      return Colors.orange;
    } else if (daysInList > 7) {
      return Colors.amber;
    } else {
      return Colors.blue;
    }
  }
}
