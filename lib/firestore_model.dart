library firestore_model;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_model/src/core/settings.dart';
import 'package:flutter/widgets.dart';

export 'src/core/model.dart';
export 'src/core/settings.dart';
export 'src/firestore_model.dart';
export 'src/sub_collection_model.dart';
export 'src/widgets/model_get_builder.dart';
export 'src/widgets/model_get_refresh_builder.dart';
export 'src/widgets/model_single_builder.dart';
export 'src/widgets/model_single_refresh_builder.dart';
export 'src/widgets/model_stream_get_builder.dart';
export 'src/widgets/model_stream_single_builder.dart';

class FirebaseApp {
  // Wait for Firebase to initialize
  static initializeApp(
      {FirestoreModelSettings? settings, FirebaseOptions? options}) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: options);
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: settings?.persistenceEnabled,
      cacheSizeBytes: settings?.cacheSizeBytes,
      sslEnabled: settings?.sslEnabled,
      host: settings?.host,
    );
  }
}
