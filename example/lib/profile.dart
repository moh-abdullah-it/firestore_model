import 'package:firestore_model/firestore_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/post.dart';
import 'models/user.dart';

class Profile extends StatelessWidget {
  final User? user;
  const Profile({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user?.firstName}"),
        centerTitle: true,
      ),
      body: ModelStreamGetBuilder<Post>(
        parentModel: user,
        builder: (_, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (_, index) {
                Post? post = snapshot.data?[index];
                return ListTile(
                  onTap: () async {
                    post?.update(data: {'title': 'updated title'});
                    post?.description = 'new description';
                    post?.save();
                  },
                  title: Text("${post?.title}"),
                  subtitle: Text(post?.docId ?? ''),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.plus_app),
        onPressed: () {
          Post? post = user?.subCollection<Post>();
          post?.title = "new test Title For post ${DateTime.now()}";
          post?.description = "Description Title in post Sub collection";
          post?.create();
        },
      ),
    );
  }
}
