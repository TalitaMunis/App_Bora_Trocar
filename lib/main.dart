import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/food_listing.dart';
import 'models/user.dart';
import '/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FoodListingAdapter());
  // Register User adapter so UserService can open a Box<User> safely.
  // The generated `user.g.dart` contains `UserAdapter`.
  Hive.registerAdapter(UserAdapter());

  // Abrir o box antes de rodar o app
  await Hive.openBox<FoodListing>('adsBox');

  runApp(const MyApp());
}
