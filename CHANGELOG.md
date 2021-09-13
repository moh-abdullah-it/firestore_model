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
