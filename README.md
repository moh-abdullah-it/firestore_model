# firestore_model

Easy way to use firestore collection with data model

## Adding Firestore Model to your project

In your project's `pubspec.yaml` file,

* Add *firestore_model* latest version to your *dependencies*.

```yaml
# pubspec.yaml

dependencies:
  firestore_model: ^<latest version>

```

## Config

```dart
void main() async {
  await FirebaseApp.initializeApp(
      settings: FirestoreModelSettings(
          //persistenceEnabled: true,
          ));
  runApp(MyApp());
}
```
## Data Model
* define your model `User`
* extend model with `FirestoreModel` with your model Type
```dart
class User extends FirestoreModel<User> {
}
```
* override `toMap` && `responseBuilder`
```dart
class User extends FirestoreModel<User> {
  String? firstName;
  String? lastName;

  User({this.firstName, this.lastName});

  // use to read
  User.fromMap(Map<String, dynamic> map) {
    this.firstName = map['first_name'];
    this.lastName = map['last_name'];
  }

  // use to write
  @override
  Map<String, dynamic> get toMap => {
    'first_name': this.firstName,
    'last_name': this.lastName,
  };

  @override
  ResponseBuilder<User> get responseBuilder => (map) => User.fromMap(map);
  
}
```
* we use model name as collection name in this example `User`
* if you wont to change collection name override `collectionName` in your model
```dart
@override
String get collectionName => 'users';
```

## Inject Model
* Inject your Model
```dart
FirestoreModel.inject(User());
```
* Inject All your Models
```dart
FirestoreModel.injectAll([User()]);
```
* retrieve your model
```dart
FirestoreModel.use<User>();
```

## Create
To Write in data base:
* prepare your data model like this:
```dart
User user = User(firstName: "Mohamed", lastName: "Abdullah 3");
```
* call `create` method from your model like this:
```dart
user.create();
```
* if you have id for doc:
```dart
user.create(docId: 'hdoihvnoirejiu9345j');
```

## Save
* make changes to your model and call `save`:
```dart
user.firstName = 'new firstname';
user.save()
```

## Update
* update specific fields in your model call `update`:
```dart
user.update(data: {
"first_name": "Mohamed",
"last_name": "Abdullah"
})
```
* update specific model use `update` by pass docId:
```dart
FirestoreModel.use<User>().update(
  docId: 'hdoihvnoirejiu9345j',
  data: {
    "first_name": "Mohamed",
    "last_name": "Abdullah"
  })
```
## delete
* delete current model call `delete`:
```dart
user.delete();
```
* delete specific model use `delete` by pass docId:
```dart
FirestoreModel.use<User>().delete(docId: 'hdoihvnoirejiu9345j')
```

## Exists
* check if document is exists call `exists` by docId:
```dart
bool isExists = await FirestoreModel.use<User>().exists('hdoihvnoirejiu9345j')
```

## Find
* To get document data by document id call `find`:
```dart
User user = await FirestoreModel.use<User>().find('hdoihvnoirejiu9345j')
```
* To stream document data by document id call `streamFind`:
```dart
Stream<User> streamUser = FirestoreModel.use<User>().streamFind('hdoihvnoirejiu9345j')
```

## All
* To get all documents call `all`:
```dart
List<User> users = await FirestoreModel.use<User>().all()
```
* To stream all documents call `streamAll`:
```dart
Stream<List<User>> streamUsers = FirestoreModel.use<User>().streamAll()
```

## First
* To get first result from your collection call `first`:
* you can build your query like `where` `orderBy` or any query buildr methods:
```dart
User firstUser = await FirestoreModel.use<User>().first(
    queryBuilder: (query) => query.where('score', isGreaterThan: 100)
    .orderBy('score', descending: true)
    );
```

## Get
* To get results from your collection call `get`:
* you can build your query like `where` `orderBy` or any query buildr methods:
```dart
List<User> topUsers = await FirestoreModel.use<User>().get(
    queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
    );
```
* To stream results from your collection call `streamGet`:
```dart
Stream<List<User>> topUsers = await FirestoreModel.use<User>().streamGet(
    queryBuilder: (query) => query.orderBy('score', descending: true).limit(10)
    );
```

## Pagination
* To get results limit and load more as pagination from your collection call `paginate`.
* you can build your query like `where` `orderBy` or any query buildr methods.
* you can set `perPage` in your call or set in your model
```dart
List<User> topUsers = await FirestoreModel.use<User>().paginate(
    perPage: 15,
    queryBuilder: (query) => query.orderBy('score', descending: true),
    );
```
* To stream results from your collection call `streamPaginate`:
```dart
Stream<List<User>> topUsers = await FirestoreModel.use<User>().streamPaginate(
    perPage: 15,
    queryBuilder: (query) => query.orderBy('score', descending: true),
    );
```

## Builders
* `ModelSingleBuilder`: get `first` or `find` by docId.
```dart
ModelSingleBuilder<User>(
// your query to get first result
query: (q) => q.orderBy('createdAt'),
// pass document id if you need to get only this document
docId: 'iuiouurpoeuriqwe',
builder: (_, snapshot) {
// your widget
});
```
* `ModelGetBuilder`: get documents with any `query`.
```dart
ModelGetBuilder<User>(
// your query to get results
query: (q) => q.orderBy('createdAt'),
builder: (_, snapshot) {
// your list builder
});
```
* `ModelStreamGetBuilder`: stream `get` documents with any `query`.
```dart
ModelStreamGetBuilder<User>(
// your query to stream results
query: (q) => q.orderBy('createdAt'),
builder: (_, snapshot) {
// your list builder
});
```
* `ModelStreamSingleBuilder`: stream `first` or `find` by docId.
```dart
ModelStreamSingleBuilder<User>(
// your query to stream first result
query: (q) => q.orderBy('createdAt'),
// pass document id if you need to stream only this document
docId: 'iuiouurpoeuriqwe',
builder: (_, snapshot) {
// your widget
});
```

## FieldValue

* `increment`: increment field value
```dart
// this increase user score by 1;
user.increment(field: 'score');

// this increase user score by 2;
user.increment(field: 'score', value: 2);
```

* `decrement`: decrement field value
```dart
// this decrease user score by 1;
user.decrement(field: 'score');

// this decrease user score by 2;
user.decrement(field: 'score', value: 2);
```

* `arrayUnion`: union elements to array
```dart
// append 'kotlin' to user languages
user.arrayUnion(field: 'languages', elements: ['kotlin']);
```

* `arrayRemove`: remove elements from array
```dart
// remove 'kotlin' from user languages
user.arrayRemove(field: 'languages', elements: ['kotlin']);
```

* `remove`: remove field from document
```dart
// remove 'languages' field from user document
user.remove(field: 'languages');
```

## SubCollection
`SubCollection` is a collection associated with a specific document.
### Prepare SubCollection Model
* create `Model` for `SubCollection` and extends model with `SubCollectionModel` with your model Type:
```dart
class Post extends SubCollectionModel<Post> {
}
```
* override `toMap` && `responseBuilder`
* we use model name as subCollection name in this example `Post`
* if you wont to change subCollection name override `subCollectionName` in your model
```dart
@override
String get subCollectionName => 'posts';
```
### Create in SubCollection
* use parent to work with subCollection
```dart
Post post = user.subCollection<Post>();
post.title = "new test Title For post ${DateTime.now()}";
post.description = "Description Title in post Sub collection";
post.create();
```

### Update document in SubCollection
```dart
// use `update` to update document in subCollection
post.update(data: {'title': 'updated title'});

// or you can use `save`
post.description = 'new description';
post.save();
```
#### if you have `SubCollectionModel` you can work as any `FirestoreModel`

### Builder With SubCollection
* to use builders to retrieve subCollection Documents you must be have `parentModel`
```dart
ModelStreamGetBuilder<Post>(
// parent model for Post SubCollectionModel
parentModel: user,
builder: (_, snapshot) {
// your list builder
}
);
```