import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

mixin MixinFirestoreModel<T> {
  String? docId;
  Map<String, Object?> get toMap;
  ResponseBuilder<T> get responseBuilder;
  String get collectionName {
    return this.runtimeType.toString();
  }
}

abstract class FirestoreModel<T extends MixinFirestoreModel>
    with MixinFirestoreModel<T> {
  CollectionReference get _collectionReference => initReference();

  initReference() {
    return FirebaseFirestore.instance
        .collection(this.collectionName)
        .withConverter(
            fromFirestore: (snapshot, _) =>
                this.responseBuilder(snapshot.data()),
            toFirestore: (snapshot, _) => this.toMap);
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

  Future<List<T?>> all() async {
    QuerySnapshot snapshot = await _collectionReference.get();
    return snapshot.docs.map<T?>((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    }).toList();
  }

  Future<List<T?>> get({Query queryBuilder(Query query)?}) async {
    Query query = _collectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map<T?>((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    }).toList();
  }

  Stream<List<T?>>? streamAll() {
    Stream<QuerySnapshot> snapshot = _collectionReference.snapshots();
    return snapshot.map((event) => event.docs.map<T?>((doc) {
          T _model = doc.data() as T;
          _model.docId = doc.id;
          return _model;
        }).toList());
  }

  save() async {
    return await _collectionReference.doc(this.docId).update(this.toMap);
  }

  update({String? docId, required Map<String, Object?> data}) async {
    if (docId != null) {
      this.docId = docId;
    }
    return await _collectionReference.doc(this.docId).update(data);
  }

  delete({String? docId}) async {
    if (docId != null) {
      this.docId = docId;
    }
    return await _collectionReference.doc(this.docId).delete();
  }
}
