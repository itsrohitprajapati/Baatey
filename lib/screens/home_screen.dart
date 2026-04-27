import 'package:baatien/screens/developer_profile_screen.dart';
import 'package:baatien/screens/profile_screen.dart';
import 'package:baatien/screens/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../models/apis.dart';
import '../models/chat_user.dart';
import '../widgets/chat_card.dart';
import '../widgets/dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = "/home-screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BuildContext ctx;
  double _animatedContainerBorderRadius = 0;
  double _animatedContainerHeight = 1, _animatedContainerWidth = 1;
  double _stackContinerHeight = 0.91, _stackContinerWidth = 1;
  double _animatedContainerMargin = 0;
  List<ChatUser> _list = [];
  // bool _isSearching = false;
  String yourName = "Your Name", yourEmail = "Your Email";
  String yourProfilePhoto = "";
  List<ChatUser> searchList = [];
  String _aboutMe = "";

  void shrinkMainScreen() {
    setState(() {
      _animatedContainerBorderRadius = 30;
      _animatedContainerHeight = 0.8;
      _animatedContainerWidth = 0.8;
      _stackContinerHeight = 0.7;
      _animatedContainerMargin = 0.6;
      yourName = APIs.me.name;
      yourEmail = APIs.me.email;
      yourProfilePhoto = APIs.me.image;
      _aboutMe = APIs.me.about;
    });
  }

  void expandMainScreen() {
    setState(() {
      _animatedContainerBorderRadius = 0;
      _animatedContainerHeight = 1;
      _animatedContainerWidth = 1;
      _stackContinerHeight = 0.91;
      _animatedContainerMargin = 0;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getToken();
    APIs.getYourProfile();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Listener(
      onPointerMove: (move) {
        if (move.delta.dx > 10) {
          // Right Swipe
          shrinkMainScreen();
        }
        if (move.delta.dx < 10) {
          //Left Swipe
          expandMainScreen();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 243, 240),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 121, 189, 193),
                  Color.fromARGB(255, 160, 77, 110),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(fontFamily: "Poppins", fontSize: 50, fontWeight: FontWeight.w700, color: Colors.white54),
                        ),
                        const Expanded(
                          child: Text(""),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                APIs.me,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: CachedNetworkImage(
                                imageUrl: yourProfilePhoto == "" ? "https://e7.pngegg.com/pngimages/103/590/png-clipart-computer-icons-user-profile-avatar-heroes-monochrome.png" : yourProfilePhoto,
                                fit: BoxFit.fill,
                                width: 150,
                                height: 150,
                                errorWidget: (context, url, error) => const CircleAvatar(
                                    child: Icon(
                                  Icons.person,
                                  size: 100,
                                )),
                                placeholder: (context, url) => const CircleAvatar(
                                    child: Icon(
                                  Icons.person,
                                  size: 100,
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text(
                        yourName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Poppins"),
                      ),
                      minLeadingWidth: 0,
                      subtitle: Text(
                        yourEmail,
                        style: const TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: 10),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 15),
                      child: Text(
                        "About You:",
                        style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "Poppins", fontSize: 25, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          _aboutMe == "" ? "Aao Baatien Karein!!" : _aboutMe,
                          style: const TextStyle(fontFamily: "Poppins", fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Developed by Rohit with",
                            style: TextStyle(fontFamily: "Poppins", color: Colors.amber),
                          ),
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeveloperProfileScreen(),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              "assets/images/Rohit's_Profile_Photo.jpg",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        title: const Text(
                          "Rohit Prajapati",
                          style: TextStyle(fontFamily: "Poppins", color: Colors.amber),
                        ),
                        subtitle: const Text(
                          "LinkedIn Profile",
                          style: TextStyle(color: Colors.blue, fontFamily: "Poppins"),
                        ),
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(bottom: 50),
                    //   child: ListTile(
                    //     onTap: () {
                    //       showDialog(
                    //         context: context,
                    //         builder: (BuildContext context) => AlertDialog(
                    //           title: const Text(
                    //             "Sign Out",
                    //             style: TextStyle(
                    //                 fontFamily: "Poppins",
                    //                 fontSize: 30,
                    //                 color: Colors.red),
                    //           ),
                    //           content: const Text(
                    //             "Are you sure?",
                    //             style: TextStyle(
                    //                 fontFamily: "Poppins", fontSize: 15),
                    //           ),
                    //           actions: [
                    //             TextButton(
                    //               onPressed: () => Navigator.of(context).pop(),
                    //               child: const Text(
                    //                 'Cancel',
                    //                 style: TextStyle(
                    //                   fontFamily: "Poppins",
                    //                 ),
                    //               ),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {
                    //                 _signOut()
                    //                     .then((value) => Navigator.of(context)
                    //                         .pushNamedAndRemoveUntil(
                    //                             AuthScreen.routeName,
                    //                             (route) => false))
                    //                     .then((value) =>
                    //                         APIs.auth = FirebaseAuth.instance);
                    //               },
                    //               child: const Text(
                    //                 'OK',
                    //                 style: TextStyle(
                    //                   fontFamily: "Poppins",
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //     splashColor: Colors.blueGrey,
                    //     leading: const Icon(Icons.power_settings_new_rounded),
                    //     trailing: const Text(
                    //       "Sign Out",
                    //       style: TextStyle(
                    //           fontFamily: "Poppins",
                    //           color: Colors.red,
                    //           fontSize: 20),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AnimatedContainer(
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * _animatedContainerMargin),
                      height: MediaQuery.of(context).size.height * _animatedContainerHeight,
                      width: MediaQuery.of(context).size.width * _animatedContainerWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_animatedContainerBorderRadius),
                        color: const Color.fromARGB(255, 244, 243, 240),
                      ),
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(_animatedContainerBorderRadius), topRight: Radius.circular(_animatedContainerBorderRadius)),
                              boxShadow: const [BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 10)],
                              color: Colors.amber,
                            ),
                            child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.only(top: 30),
                                height: MediaQuery.of(context).size.height * .1,
                                child: const Center(
                                  child: Text(
                                    "Baatey",
                                    style: TextStyle(fontFamily: "Poppins", fontSize: 40, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: MediaQuery.of(context).size.height * _stackContinerHeight,
                              width: MediaQuery.of(context).size.width * _stackContinerWidth,
                              child: Stack(
                                alignment: const Alignment(0, 1.01),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                    child: StreamBuilder(
                                        stream: APIs.getMyUsersId(),
                                        builder: (context, snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                            case ConnectionState.waiting:
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );

                                            case ConnectionState.active:
                                            case ConnectionState.done:
                                              return StreamBuilder(
                                                  stream: APIs.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                                                  builder: (context, snapshot) {
                                                    switch (snapshot.connectionState) {
                                                      case ConnectionState.none:
                                                      case ConnectionState.waiting:
                                                        return const Center(
                                                          child: CircularProgressIndicator(),
                                                        );

                                                      case ConnectionState.active:
                                                      case ConnectionState.done:
                                                        if (snapshot.hasData) {
                                                          final data = snapshot.data!.docs;
                                                          _list = data.map((e) => ChatUser.fromJson(e.data())).toList();
                                                        }
                                                        if (_list.isNotEmpty) {
                                                          return ListView.builder(
                                                            itemCount: _list.length,
                                                            physics: const BouncingScrollPhysics(),
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return ChatCard(_list[index]);
                                                            },
                                                          );
                                                        } else {
                                                          return const Center(
                                                            child: Text(
                                                              "Add Some Friends!!",
                                                              style: TextStyle(fontFamily: "Poppins"),
                                                            ),
                                                          );
                                                        }
                                                    }
                                                  });
                                          }
                                        }),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.amber, boxShadow: const [BoxShadow(color: Colors.grey, offset: Offset(0, 10), blurRadius: 10)]),
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    child: GNav(
                                      haptic: true,
                                      tabs: [
                                        GButton(
                                          gap: 10,
                                          icon: Icons.chat_outlined,
                                          text: "Chats",
                                          textStyle: const TextStyle(fontFamily: "Poppins"),
                                          onPressed: () {
                                            expandMainScreen();
                                          },
                                        ),
                                        GButton(
                                          gap: 10,
                                          icon: Icons.search,
                                          text: "Search",
                                          textStyle: const TextStyle(fontFamily: "Poppins"),
                                          onPressed: () {
                                            expandMainScreen();
                                            Future.delayed(const Duration(milliseconds: 400), () {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(_list)));
                                            });
                                          },
                                        ),
                                        GButton(
                                          gap: 10,
                                          icon: Icons.person_add_alt_1,
                                          text: "Add Friend",
                                          textStyle: const TextStyle(fontFamily: "Poppins"),
                                          onPressed: () {
                                            Future.delayed(const Duration(milliseconds: 400), () {
                                              _addChatUserDialog();
                                            });
                                          },
                                        ),
                                      ],
                                      tabBackgroundColor: const Color.fromARGB(255, 255, 227, 141),
                                      padding: const EdgeInsets.all(10),
                                      tabMargin: const EdgeInsets.all(10),
                                      activeColor: Colors.black,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
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

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.amber,
                    size: 28,
                  ),
                  Text(
                    '  Add User',
                    style: TextStyle(fontFamily: "Poppins"),
                  )
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(hintText: 'Email Id', prefixIcon: const Icon(Icons.email, color: Colors.amber), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.amber, fontSize: 16, fontFamily: "Poppins"))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackBar(context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.amber, fontSize: 16, fontFamily: "Poppins"),
                    ))
              ],
            ));
  }
}
