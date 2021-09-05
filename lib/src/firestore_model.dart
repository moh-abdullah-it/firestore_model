import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

final Map<String, DocumentSnapshot<Object?>> _pagination = {};

final Map<String, Object> _injectsMap = {};

mixin Model<T> {
  /// default items in page
  int get perPage => 20;

  /// document id [FirestoreModel] will get it for your model
  String? docId;

  /// model mapping to write in collection
  Map<String, dynamic> get toMap;

  /// model mapping to write in collection
  ResponseBuilder<T> get responseBuilder;

  /// collection name [FirestoreModel] use your [Model] name
  String get collectionName {
    return this.runtimeType.toString();
  }
}

abstract class FirestoreModel<T extends Model> with Model<T> {
  /// init Firestore with collection name
  CollectionReference get _collectionReference => _initReference();

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

  _initReference() {
    return FirebaseFirestore.instance
        .collection(this.collectionName)
        .withConverter(
            fromFirestore: (snapshot, _) =>
                this.responseBuilder(snapshot.data()),
            toFirestore: (snapshot, _) => this.toMap);
  }

  /// To Write in firestore database
  /// call [create] method from your model like this:
  /// user.create();
  /// if you have [docId] for doc:
  /// user.create(docId: 'doc_id');
  create({String? docId}) async {
    await _collectionReference.doc(docId).set(this).catchError((error) {
      print("Failed to add user: $error");
    });
  }

  /// To get document data by document id call [find] and pass [docId]
  /// User user = await [FirestoreModel].use<User>().find('doc_id')
  Future<T> find(String? docId) async {
    return await _collectionReference.doc(docId).get().then((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    });
  }

  /// To stream document data by document id call [streamFind] as pass [docId]
  /// Stream<User> streamUser = [FirestoreModel].use<User>()
  /// .streamFind('doc_id')
  Stream<T> streamFind(String? docId) {
    return _collectionReference.doc(docId).snapshots().map((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    });
  }

  /// To get first result from your collection call [first]
  /// you can build your query like where orderBy or any query buildr methods in [queryBuilder]
  /// User firstUser = await [FirestoreModel].use<User>().first(
  ///     queryBuilder: (query) => query.where('score', isGreaterThan: 100)
  ///     .orderBy('score', descending: true)
  ///     );
  Future<T> first({Query queryBuilder(Query query)?}) async {
    Query _query = _collectionReference;
    if (queryBuilder != null) {
      _query = queryBuilder(_query);
    }
    return await _query.limit(1).get().then((snapshot) {
      T _model = snapshot.docs.last.data() as T;
      _model.docId = snapshot.docs.last.id;
      return _model;
    });
  }

  /// To get all documents call [all]
  /// List<User> users = await [FirestoreModel].use<User>().all()
  Future<List<T?>> all() async {
    QuerySnapshot snapshot = await _collectionReference.get();
    return snapshot.docs.map<T?>((doc) {
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
    }).toList();
  }

  /// To get results from your collection call [get]
  /// you can build your query like where orderBy or any query buildr methods in [queryBuilder]
  /// List<User> topUsers = await [FirestoreModel].use<User>().get(
  ///     queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
  ///     );
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

  /// To stream all documents call [streamAll]
  /// Stream<List<User>> streamUsers = [FirestoreModel].use<User>()
  /// .streamAll()
  Stream<List<T?>>? streamAll() {
    Stream<QuerySnapshot> snapshot = _collectionReference.snapshots();
    return snapshot.map((event) => event.docs.map<T?>((doc) {
          T _model = doc.data() as T;
          _model.docId = doc.id;
          return _model;
        }).toList());
  }

  /// To stream results from your collection call [streamGet] with [queryBuilder]
  /// Stream<List<User>> topUsers = await [FirestoreModel].use<User>().streamGet(
  ///     queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
  ///     );
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

  /// make changes to your model and call [save]
  /// user.firstName = 'new firstname';
  /// user.save()
  save() async {
    return await _collectionReference.doc(this.docId).update(this.toMap);
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
  update({String? docId, required Map<String, Object?> data}) async {
    if (docId != null) {
      this.docId = docId;
    }
    return await _collectionReference.doc(this.docId).update(data);
  }

  /// delete current model call [delete]
  /// user.delete();
  /// delete specific model use delete by pass docId:
  /// [FirestoreModel].use<User>().delete(docId: 'doc_id')
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
      T _model = doc.data() as T;
      _model.docId = doc.id;
      return _model;
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
        T _model = doc.data() as T;
        _model.docId = doc.id;
        return _model;
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
}
