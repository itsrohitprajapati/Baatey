import 'package:baatien/models/chat_user.dart';
import 'package:flutter/material.dart';
import '../models/apis.dart';
import '../widgets/chat_card.dart';

class SearchScreen extends StatefulWidget {
  List<ChatUser> mainList;
  List<ChatUser> searchList = [];
  SearchScreen(this.mainList);

  static const routeName = "/search-screen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 243, 240),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Form(
                  child: ListView(
                    children: [
                      TextFormField(
                        style: const TextStyle(fontFamily: "Poppins"),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          label: const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Icon(Icons.search),
                          ),
                        ),
                        onChanged: (value) {
                          widget.searchList.clear();
                          for (var user in widget.mainList) {
                            if (user.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                user.email
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                              widget.searchList.add(user);
                            }
                            setState(() {
                              widget.searchList;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
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
                            stream: APIs.getAllUsers(
                                snapshot.data?.docs.map((e) => e.id).toList() ??
                                    []),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );

                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (widget.searchList.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "No Matches...",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: widget.searchList.length,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ChatCard(
                                            widget.searchList[index]);
                                      },
                                    );
                                  }
                              }
                            },
                          );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
