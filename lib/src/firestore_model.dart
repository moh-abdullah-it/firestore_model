import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'core/model.dart';

final Map<String, DocumentSnapshot<Object?>> _pagination = {};

final Map<String, Object> _injectsMap = {};

abstract class FirestoreModel<T extends Model> with Model<T> {
  /// init Firestore with collection name
  CollectionReference get _collectionReference => _initReference();

  bool isUpdating = false;

  Timestamp? _createdTime;
  Timestamp? _updatedTime;

  /// retrieve Your model FirestoreModel.use<Model>()
  static T use<T extends Object>() {
    if (_injectsMap.containsKey(T.toString())) {
      return _injectsMap[T.toString()] as T;
    }
    throw Exception("FirestoreModel ${T.toString()} Not Found");
  }

  /// Inject your model in [FirestoreModel] injectsMap
  /// FirestoreModel.inject(User())
  static void inject(Object t) {
    if (!_injectsMap.containsKey(t.runtimeType.toString())) {
      _injectsMap[t.runtimeType.toString()] = t;
    }
  }

  /// Inject All Your models
  static void injectAll(List<Object> list) {
    list.forEach((t) {
      inject(t);
    });
  }

  _responseBuilder(Map<String, dynamic>? map) {
    this._createdTime = map?['createdAt'];
    this._updatedTime = map?['updatedAt'];
    return this.responseBuilder(map);
  }

  _initReference() {
    return FirebaseFirestore.instance
        .collection(this.collectionName)
        .withConverter(
            fromFirestore: (snapshot, _) => _responseBuilder(snapshot.data()),
            toFirestore: (snapshot, _) => _dataMap());
  }

  T? _toModel(DocumentSnapshot doc) {
    if (!doc.exists) {
      return null;
    }
    T _model = doc.data() as T;
    _model.docId = doc.id;
    _model.path = doc.reference.path;
    _model.parentPath = doc.reference.parent.path;
    _model.createdAt = _createdTime?.toDate();
    _model.updatedAt = _updatedTime?.toDate();
    return _model;
  }

  Map<String, dynamic> _dataMap({Map<String, dynamic>? map}) {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data.addAll(map ?? this.toMap);
    if (this.withTimestamps) {
      _data.addAll({
        '${this.isUpdating ? 'updatedAt' : 'createdAt'}':
            FieldValue.serverTimestamp(),
      });
    }
    return _data;
  }

  /// To Write in firestore database
  /// call [create] method from your model like this:
  /// user.create();
  /// if you have [docId] for doc:
  /// user.create(docId: 'doc_id');
  /// return model after create
  Future<T?> create({String? docId}) async {
    if (docId != null) {
      return await _collectionReference
          .doc(docId)
          .set(this)
          .then((value) async => await find(docId));
    }
    return await _collectionReference
        .add(this)
        .then((doc) async => _toModel(await doc.get()));
  }

  /// To get document data by document id call [find] and pass [docId]
  /// User user = await [FirestoreModel].use<User>().find('doc_id')
  Future<T?> find(String docId) async {
    return await _collectionReference.doc(docId).get().then((doc) {
      return _toModel(doc);
    });
  }

  /// To stream document data by document id call [streamFind] as pass [docId]
  /// Stream<User> streamUser = [FirestoreModel].use<User>()
  /// .streamFind('doc_id')
  Stream<T?> streamFind(String docId) {
    return _collectionReference.doc(docId).snapshots().map((doc) {
      return _toModel(doc);
    });
  }

  /// To get first result from your collection call [first]
  /// you can build your query like where orderBy or any query buildr methods in [queryBuilder]
  /// User firstUser = await [FirestoreModel].use<User>().first(
  ///     queryBuilder: (query) => query.where('score', isGreaterThan: 100)
  ///     .orderBy('score', descending: true)
  ///     );
  Future<T?> first({Query queryBuilder(Query query)?}) async {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return await _query.limit(1).get().then((snapshot) {
      return _toModel(snapshot.docs.first);
    });
  }

  /// To stream document data by document id call [streamFind] as pass [docId]
  /// Stream<User> streamUser = [FirestoreModel].use<User>()
  /// .streamFind('doc_id')
  Stream<T?> streamFirst(
      {Query queryBuilder(Query query)?, VoidCallback? onChange}) {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return _collectionReference.limit(1).snapshots().map((snapshot) {
      if (snapshot.docChanges.isNotEmpty) {
        if (onChange != null) onChange();
      }
      return _toModel(snapshot.docs.first);
    });
  }

  /// To get all documents call [all]
  /// List<User> users = await [FirestoreModel].use<User>().all()
  Future<List<T?>> all() async {
    QuerySnapshot snapshot = await _collectionReference.get();
    return snapshot.docs.map<T?>((doc) {
      return _toModel(doc);
    }).toList();
  }

  /// To get results from your collection call [get]
  /// you can build your query like where orderBy or any query buildr methods in [queryBuilder]
  /// List<User> topUsers = await [FirestoreModel].use<User>().get(
  ///     queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
  ///     );
  Future<List<T?>?> get(
      {Query queryBuilder(Query query)?, Query? query}) async {
    Query _query = query ?? _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    QuerySnapshot snapshot = await _query.get();
    return snapshot.docs.map<T?>((doc) {
      return _toModel(doc);
    }).toList();
  }

  /// To stream all documents call [streamAll]
  /// Stream<List<User>> streamUsers = [FirestoreModel].use<User>()
  /// .streamAll()
  Stream<List<T?>>? streamAll() {
    Stream<QuerySnapshot> snapshot = _collectionReference.snapshots();
    return snapshot.map((event) => event.docs.map<T?>((doc) {
          return _toModel(doc);
        }).toList());
  }

  /// To stream results from your collection call [streamGet] with [queryBuilder]
  /// Stream<List<User>> topUsers = await [FirestoreModel].use<User>().streamGet(
  ///     queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
  ///     );
  Stream<List<T?>?> streamGet(
      {Query queryBuilder(Query query)?,
      Query? query,
      VoidCallback? onChange}) {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    Stream<QuerySnapshot> snapshot = _query.snapshots();
    return snapshot.map((event) {
      if (event.docChanges.isNotEmpty) {
        if (onChange != null) onChange();
      }
      return event.docs.map<T?>((doc) {
        return _toModel(doc);
      }).toList();
    });
  }

  /// make changes to your model and call [save]
  /// user.firstName = 'new firstname';
  /// user.save()
  Future<void> save({String? docId, SetOptions? setOptions}) async {
    if ((docId ?? this.docId) != null) {
      this.isUpdating = true;
    }
    return await _collectionReference
        .doc(docId ?? this.docId)
        .set(_dataMap(), setOptions)
        .then((value) => this.isUpdating = false);
  }

  /// update specific fields in your model call [update] by pass [data]
  /// user.update(data: {
  /// "first_name": "Mohamed",
  /// "last_name": "Abdullah"
  /// })
  /// update specific model use [update] by pass [docId] and [data]
  /// [FirestoreModel].use<User>().update(
  ///   docId: 'doc_id',
  ///   data: {
  ///     "first_name": "Mohamed",
  ///     "last_name": "Abdullah"
  ///   })
  Future<void> update(
      {String? docId, required Map<String, Object?> data}) async {
    this.isUpdating = true;
    return await _collectionReference
        .doc(docId ?? this.docId)
        .update(_dataMap(map: data))
        .then((value) => this.isUpdating = false);
  }

  /// delete current model call [delete]
  /// user.delete();
  /// delete specific model use delete by pass docId:
  /// [FirestoreModel].use<User>().delete(docId: 'doc_id')
  Future<void> delete({String? docId}) async {
    return await _collectionReference.doc(docId ?? this.docId).delete();
  }

  Query _handlePaginateQuery({int? perPage, Query queryBuilder(Query query)?}) {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    DocumentSnapshot? lastDocument = _pagination[this.collectionName];
    if (lastDocument != null) {
      _query = _query.startAfterDocument(lastDocument);
    }
    _query = _query.limit(perPage ?? this.perPage);
    return _query;
  }

  /// To get results limit and load more as pagination from your collection call [paginate]
  /// you can build your query like where orderBy or any query buildr methods in [queryBuilder]
  /// you can set [perPage] in your call or set in your model
  /// List<User> topUsers = await FirestoreModel.use<User>().paginate(
  ///     perPage: 15,
  ///     queryBuilder: (query) => query.orderBy('score', descending: true),
  ///     );
  Future<List<T?>> paginate(
      {int? perPage, Query queryBuilder(Query query)?}) async {
    QuerySnapshot snapshot =
        await _handlePaginateQuery(perPage: perPage, queryBuilder: queryBuilder)
            .get();
    if (snapshot.docs.length > 0 &&
        snapshot.docs.last is QueryDocumentSnapshot<T>) {
      _pagination[this.collectionName] = snapshot.docs.last;
    } else {
      print("End of documents in collection ${this.collectionName}");
    }
    return snapshot.docs.map<T?>((doc) {
      return _toModel(doc);
    }).toList();
  }

  /// To stream results from your collection call [streamPaginate]
  /// Stream<List<User>> topUsers = await [FirestoreModel].use<User>().streamPaginate(
  ///     perPage: 15,
  ///     queryBuilder: (query) => query.orderBy('score', descending: true),
  ///     );
  Stream<List<T?>> streamPaginate(
      {int? perPage, Query queryBuilder(Query query)?}) {
    Stream<QuerySnapshot> snapshot =
        _handlePaginateQuery(perPage: perPage, queryBuilder: queryBuilder)
            .snapshots();
    return snapshot.map((event) {
      if (event.docs.length > 0 &&
          event.docs.last is QueryDocumentSnapshot<T>) {
        _pagination[this.collectionName] = event.docs.last;
      } else {
        print("End of documents in collection ${this.collectionName}");
      }
      return event.docs.map<T?>((doc) {
        return _toModel(doc);
      }).toList();
    });
  }

  /// check if document is exists call [exists] by [docId]
  /// bool isExists = await [FirestoreModel].use<User>()
  /// .exists('doc_id')
  Future<bool> exists(String docId) async {
    return await _collectionReference
        .doc(docId)
        .get()
        .then((value) => value.exists);
  }

  /// update [field] realtime value
  /// that tells the server to [increment] the [field]’s current [value] by the given [value].
  Future<void> increment({
    required String field,
    String? docId,
    num value = 1,
  }) async {
    return await this
        .update(docId: docId, data: {field: FieldValue.increment(value)});
  }

  /// update [field] realtime value
  /// that tells the server to [decrement] the [field]’s current [value] by the given [value].
  Future<void> decrement({
    required String field,
    String? docId,
    num value = 1,
  }) async {
    return await this
        .update(docId: docId, data: {field: FieldValue.increment(-value)});
  }

  /// update [field] realtime value
  /// tells the server to [union] the given [elements]
  /// with any array value that already exists on the server.
  Future<void> arrayUnion({
    required String field,
    required List<dynamic> elements,
    String? docId,
  }) async {
    return await this
        .update(docId: docId, data: {field: FieldValue.arrayUnion(elements)});
  }

  /// update [field] realtime value
  /// tells the server to [remove] the given
  /// [elements] from any array value that already exists on the server.
  Future<void> arrayRemove({
    required String field,
    required List<dynamic> elements,
    String? docId,
  }) async {
    return await this
        .update(docId: docId, data: {field: FieldValue.arrayRemove(elements)});
  }

  /// remove [field] from document
  Future<void> remove({
    required String field,
    String? docId,
  }) async {
    return await this.update(docId: docId, data: {field: FieldValue.delete()});
  }

  Future<List<T?>?> getSubCollection(
    String subCollection, {
    String? docId,
    Query queryBuilder(Query query)?,
  }) async {
    Query? _query =
        _collectionReference.doc(docId ?? this.docId).collection(subCollection);
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return await this.get(query: _query);
  }

  Stream<List<T?>?> streamSubCollection(
    String subCollection, {
    String? docId,
    Query queryBuilder(Query query)?,
  }) {
    Query? _query =
        _collectionReference.doc(docId ?? this.docId).collection(subCollection);
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return this.streamGet(query: _query);
  }

  S subCollection<S extends Model>({String? path}) {
    if (_injectsMap.containsKey(S.toString())) {
      S _model = _injectsMap[S.toString()] as S;
      _model.parentPath = path ?? this.path;
      return _model;
    }
    throw Exception("SubCollectionModel ${S.toString()} Not Found");
  }
}
