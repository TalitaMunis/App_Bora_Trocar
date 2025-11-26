import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/food_listing.dart';
import 'models/user.dart';
import '/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FoodListingAdapter());
  // Registra o adapter de `User` para o `UserService` abrir um Box<User>.
  // O arquivo gerado `user.g.dart` contém `UserAdapter`.
  Hive.registerAdapter(UserAdapter());

  // Abrir o box antes de rodar o app
  await Hive.openBox<FoodListing>('adsBox');

  runApp(const MyApp());
}
