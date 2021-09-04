import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

final Map<String, DocumentSnapshot<Object?>> pagination = {};
final Map<String, Object> injectsMap = {};

mixin MixinFirestoreModel<T> {
  int get perPage => 20;
  String? docId;
  Map<String, dynamic> get toMap;
  ResponseBuilder<T> get responseBuilder;
  String get collectionName {
    return this.runtimeType.toString();
  }
}

abstract class FirestoreModel<T extends MixinFirestoreModel>
    with MixinFirestoreModel<T> {
  CollectionReference get _collectionReference => _initReference();

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

  _initReference() {
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

  Future<T> find(String? docId) async {
    return await _collectionReference
        .doc(docId)
        .get()
        .then((snapshot) => snapshot.data() as T);
  }

  Stream<T> streamFind(String? docId) {
    return _collectionReference
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.data() as T);
  }

  Future<T> first({Query queryBuilder(Query query)?}) async {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return await _query
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
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    QuerySnapshot snapshot = await _query.get();
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

  Stream<List<T?>>? streamGet({Query queryBuilder(Query query)?}) {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    Stream<QuerySnapshot> snapshot = _query.snapshots();
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

  Query _handlePaginateQuery({int? perPage, Query queryBuilder(Query query)?}) {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    DocumentSnapshot? lastDocument = pagination[this.collectionName];
    if (lastDocument != null) {
      _query = _query.startAfterDocument(lastDocument);
    }
    _query = _query.limit(perPage ?? this.perPage);
    return _query;
  }

  Future<List<T?>> paginate(
      {int? perPage, Query queryBuilder(Query query)?}) async {
    QuerySnapshot snapshot =
        await _handlePaginateQuery(perPage: perPage, queryBuilder: queryBuilder)
            .get();
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

  Stream<List<T?>> streamPaginate(
      {int? perPage, Query queryBuilder(Query query)?}) {
    Stream<QuerySnapshot> snapshot =
        _handlePaginateQuery(perPage: perPage, queryBuilder: queryBuilder)
            .snapshots();
    return snapshot.map((event) {
      if (event.docs.length > 0 &&
          event.docs.last is QueryDocumentSnapshot<T>) {
        pagination[this.collectionName] = event.docs.last;
      } else {
        print("End of documents in collection ${this.collectionName}");
      }
      return event.docs.map<T?>((doc) {
        T _model = doc.data() as T;
        _model.docId = doc.id;
        return _model;
      }).toList();
    });
  }

  Future<bool> exists(String docId) async {
    return await _collectionReference
        .doc(docId)
        .get()
        .then((value) => value.exists);
  }
}
