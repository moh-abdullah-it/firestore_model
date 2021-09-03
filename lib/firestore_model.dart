library firestore_model;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

export 'src/firestore_model.dart';

class FirebaseApp {
  // Wait for Firebase to initialize
  static initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
}
