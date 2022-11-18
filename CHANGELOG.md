## 0.9.10
- modify Firebase Options to initialize the Firebase app

## 0.9.9
- upgrade dependencies

## 0.9.8
- upgrade dependencies

## 0.9.7
- upgrade dependencies
- fix `pagination` load more: `not work`

## 0.9.5
- modify `bulkUpdate` && `bulkDelete`
- modify batch to `bulkUpdate` && `bulkDelete`
- modify `ModelGetRefreshBuilder` && `ModelSingleRefreshBuilder`

## 0.9.0
* modify `create` method return model after create.
* change beaver `save` method to create or update.
* add `initialData` to `builders`:
* add listeners to `builders`:
    * onLoading.
    * onChange.
    * onSuccess.
    * onError.
    * onEmpty.
* plural collection name by model name.

## 0.8.1
* fix `createdAt` && `updatedAt` return null.

## 0.8.0
* modify support `subCollections` by parent model 
* modify `builders` support `subCollections` by `parentModel`
* update documentation

## 0.7.0
* add `FieldValue` fields options:
  * `increment`: increment field value
  * `decrement`: decrement field value
  * `arrayUnion`: union elements to array
  * `arrayRemove`: remove elements from array
  * `remove`: remove field from document

## 0.6.0
* modify `path` document in firestore database
* modify `withTimestamps` this add `createdAt` & `updatedAt` to track document

## 0.5.0
* modify widgets builders:
  * `ModelSingleBuilder`: get `first` or `find` by docId.
  * `ModelGetBuilder`: get documents with any `query`
  * `ModelStreamGetBuilder`: stream `get` documents with any `query`
  * `ModelStreamSingleBuilder`: stream `first` or `find` by docId.
* fix read first document for `first` and `find`.

## 0.4.0
* modify `find` && `first` to add document id to current model.
* modify documents in code.

## 0.2.0
* update documentations.

## 0.1.0
* initial release.
