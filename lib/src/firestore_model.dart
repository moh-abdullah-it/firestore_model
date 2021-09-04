import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

final Map<String, DocumentSnapshot<Object?>> pagination = {};
final Map<String, Object> injectsMap = {};

mixin MixinFirestoreModel<T> {
  String? docId;
  Map<String, dynamic> get toMap;
  ResponseBuilder<T> get responseBuilder;
  String get collectionName {
    return this.runtimeType.toString();
  }
}

abstract class FirestoreModel<T extends MixinFirestoreModel>
    with MixinFirestoreModel<T> {
  CollectionReference get _collectionReference => initReference();

  static T use<T extends Object>() {
    if (injectsMap.containsKey(T.toString())) {
      return injectsMap[T.toString()] as T;
    }
    throw Exception("FirestoreModel ${T.toString()} Not Found");
  }

  static void inject(Object t) {
    if (!injectsMap.containsKey(t.runtimeType.toString())) {
      injectsMap[t.runtimeType.toString()] = t;
    }
  }

  static void injectAll(List<Object> list) {
    list.forEach((t) {
      inject(t);
    });
  }

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

  Future<T> first({Query queryBuilder(Query query)?}) async {
    Query query = _collectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first.data() as T);
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

  Future<List<T?>> paginate(
      {int perPage = 1, Query queryBuilder(Query query)?}) async {
    Query query = _collectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    DocumentSnapshot? lastDocument = pagination[this.collectionName];
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(perPage);
    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.length > 0 &&
        snapshot.docs.last is QueryDocumentSnapshot<T>) {
      pagination[this.collectionName] = snapshot.docs.last;
    } else {
      print("End of documents in collection ${this.collectionName}");
    }
    return snapshot.docs.map<T?>((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    }).toList();
  }
}
