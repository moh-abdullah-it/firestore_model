import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreModelSettings {
  const FirestoreModelSettings(
      {this.persistenceEnabled,
      this.host,
      this.sslEnabled,
      this.cacheSizeBytes});

  /// Constant used to indicate the LRU garbage collection should be disabled.
  ///
  /// Set this value as the cacheSizeBytes on the settings passed to the Firestore instance.
  static const int CACHE_SIZE_UNLIMITED = -1;

  /// Attempts to enable persistent storage, if possible.
  /// This setting has no effect on Web, for Web use [FirebaseFirestore.enablePersistence] instead.
  final bool? persistenceEnabled;

  /// The hostname to connect to.
  final String? host;

  /// Whether to use SSL when connecting.
  final bool? sslEnabled;

  final int? cacheSizeBytes;
}
