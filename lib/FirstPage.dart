import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreateBlogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services.dart';
import 'package:readmore/readmore.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class _FirstPageState extends State<FirstPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final fireStore = FirebaseFirestore.instance;
  String author_name = '';
  String title_name = '';
  String desc_name = '';
  String url_name = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                Service service = Service();
                await service.signOut();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.logout,
              ))
        ],
        centerTitle: true,
        title: const Text(
          'Blog',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('blogs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data?.docs;
                    for (var message in messages!) {
                      author_name = message['author'];
                      title_name = message['title'];
                      desc_name = message['description'];
                      url_name = message['url'];
                      print(url_name);
                      print('2222');
                      return Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              print(url_name);
                              print('1233');
                              return display(
                                  url_name: snapshot.data?.docs[index]['url'],
                                  author_name: snapshot.data?.docs[index]
                                      ['author'],
                                  title_name: snapshot.data?.docs[index]
                                      ['title'],
                                  desc_name: snapshot.data?.docs[index]
                                      ['description']);
                            }),
                      );
                    }
                  }
                  return Column();
                }),
            // const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                elevation: 15,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateBlog()));
                },
                child: const Icon(
                  Icons.add,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class display extends StatelessWidget {
  const display({
    Key? key,
    required this.url_name,
    required this.author_name,
    required this.title_name,
    required this.desc_name,
  }) : super(key: key);

  final String? url_name;
  final String? author_name;
  final String? title_name;
  final String? desc_name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 2),
          height: 250,
          child: Stack(
            // fit: StackFit.expand,
            children: [
              ClipRRect(
                child: Image.network(
                  '$url_name',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.black45.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6)),
              ),
              Container(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        author_name ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        title_name ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // Text(
                      //   desc_name ?? '',
                      //   textAlign: TextAlign.center,
                      //   style: const TextStyle(
                      //       fontSize: 25, fontWeight: FontWeight.w500),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ReadMoreText(
            '$desc_name',
            trimLines: 2,
            colorClickableText: Colors.red,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Show more',
            trimExpandedText: 'Show less',
            moreStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
            lessStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        )
      ],
    );
  }
}
