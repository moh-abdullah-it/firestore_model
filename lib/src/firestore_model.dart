import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

abstract class FirestoreModel<T extends Object> {
  Map<String, dynamic> get toMap;
  ResponseBuilder<T> get responseBuilder;

  String get collectionName {
    return this.runtimeType.toString();
  }

  CollectionReference get _collectionReference => initReference();

  initReference() {
    return FirebaseFirestore.instance
        .collection(this.collectionName)
        .withConverter(
            fromFirestore: (snapshot, _) => responseBuilder(snapshot.data()),
            toFirestore: (snapshot, _) => toMap);
  }

  create({String? docId}) async {
    await _collectionReference.doc(docId).set(this).catchError((error) {
      print("Failed to add user: $error");
    });
  }

  Future<T> find({String? id}) async {
    return await _collectionReference
        .doc(id)
        .get()
        .then((snapshot) => snapshot.data() as T);
  }

  Future<List<T>> all() async {
    QuerySnapshot snapshot = await _collectionReference.get();
    return snapshot.docs.map((doc) => doc.data() as T).toList();
  }

  Future<List<T>> get({Query queryBuilder(Query query)?}) async {
    Query query = _collectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as T).toList();
  }

  Stream<List<T>> streamAll() {
    Stream<QuerySnapshot> snapshot = _collectionReference.snapshots();
    return snapshot.map((event) => event.docs.map((e) => e as T).toList());
  }

  update() {}
}
