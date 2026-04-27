import 'dart:io';
import 'package:baatien/models/apis.dart';
import 'package:baatien/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  ChatUser user;
  ProfileScreen(this.user);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

bool _isUpdating = false;

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // ignore: prefer_typing_uninitialized_variables
  var _image;

  void getImage(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        context: context,
        builder: (_) => ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              shrinkWrap: true,
              children: [
                const Text(
                  "Choose an option...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          await APIs.updateProfilePicture(File(_image!));
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.2,
                            MediaQuery.of(context).size.width * 0.2),
                      ),
                      child: Image.asset("assets/images/add_image.png"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          await APIs.updateProfilePicture(File(_image));
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: Size(MediaQuery.of(context).size.width * 0.2,
                            MediaQuery.of(context).size.width * 0.2),
                        elevation: 5,
                      ),
                      child: Image.asset("assets/images/camera.png"),
                    ),
                  ],
                ),
              ],
            ));
  }

  Future<void> _signOut() async {
    await APIs.updateActiveStatus(false);
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Container(
          padding: const EdgeInsets.only(bottom: 50),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const StadiumBorder(),
              elevation: 5,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    "Sign Out",
                    style: TextStyle(
                        fontFamily: "Poppins", fontSize: 30, color: Colors.red),
                  ),
                  content: const Text(
                    "Are you sure?",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _signOut()
                            .then((value) => Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                                    AuthScreen.routeName, (route) => false))
                            .then((value) => APIs.auth = FirebaseAuth.instance);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Sign Out",
                style: TextStyle(fontFamily: "Poppins", fontSize: 20),
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 243, 240),
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          centerTitle: true,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(200),
                                child: CachedNetworkImage(
                                  imageUrl: widget.user.image == ""
                                      ? "https://e7.pngegg.com/pngimages/103/590/png-clipart-computer-icons-user-profile-avatar-heroes-monochrome.png"
                                      : widget.user.image,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.fill,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person),
                                  placeholder: (context, url) =>
                                      const Icon(Icons.person),
                                ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(200),
                                child: Image.file(
                                  File(_image!),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                )),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.amber),
                          child: IconButton(
                            onPressed: () {
                              getImage(context);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(fontFamily: "Poppins"),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        style: const TextStyle(fontFamily: "Poppins"),
                        onSaved: (newValue) => APIs.me.name = newValue ?? "",
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : "Please Enter Your Name",
                        initialValue: widget.user.name,
                        decoration: InputDecoration(
                          prefix: const Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.amber,
                            ),
                          ),
                          hintText: "eg. Rohit Prajapati",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          label: const Text(
                            "Name",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        style: const TextStyle(fontFamily: "Poppins"),
                        onSaved: (newValue) => APIs.me.about = newValue ?? "",
                        validator: (value) =>
                            value != null && value.isNotEmpty ? null : null,
                        initialValue: widget.user.about,
                        decoration: InputDecoration(
                          prefix: const Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.amber,
                            ),
                          ),
                          hintText: "eg. Feeling Happy!!",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          label: const Text(
                            "About",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _isUpdating
                        ? const CircularProgressIndicator(
                            strokeWidth: 3,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 5, shape: const StadiumBorder()),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  _isUpdating = true;
                                });
                                await APIs.updateProfileName().then(
                                    (value) => Navigator.of(context).pop());
                                setState(() {
                                  _isUpdating = false;
                                });
                              }
                            },
                            child: const Text(
                              "Update",
                              style: TextStyle(fontFamily: "Poppins"),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
