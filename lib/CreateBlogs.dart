import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({Key? key}) : super(key: key);

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String? author;
  String? title;
  String? description;
  File? selectedImage;
  Future getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final imageTemp = File(image.path);
      setState(() {
        selectedImage = imageTemp;
      });
    } catch (e) {
      print('Failed to load image');
    }
  }

  String? imageUrl;
  bool download = false;
  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    if (selectedImage != null) {
      setState(() {
        download = true;
      });
      final storage = FirebaseStorage.instance
          .ref()
          .child('blogimages')
          .child('${randomAlpha(9)}.jpg');
      final UploadTask task = storage.putFile(selectedImage!);
      var downloadURL = await (await task).ref.getDownloadURL();

      FirebaseFirestore.instance.collection('blogs').add({
        'author': author,
        'description': description,
        'title': title,
        'url': downloadURL,
      });
      Navigator.pop(context);
    } else {
      print('No Image Path Received');
    }
  }

  bool showbutton = false;
  final fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                uploadImage();
              },
              icon: const Icon(
                Icons.upload,
              ))
        ],
        centerTitle: true,
        title: const Text(
          'Blog',
        ),
      ),
      body: download
          ? Center(
              child: Container(
                child: const CircularProgressIndicator(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage();
                        showbutton = true;
                      },
                      child: showbutton
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                selectedImage!,
                                height: 300,
                                width: 400,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 300,
                              width: 450,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.black,
                              ),
                              //width: MediaQuery.of(context).size.width,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    TextField(
                      onChanged: (value) {
                        author = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Author Name',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        title = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        border: UnderlineInputBorder(),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
