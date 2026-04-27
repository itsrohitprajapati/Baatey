import 'package:baatien/helpers/get_date.dart';
import 'package:baatien/models/chat_user.dart';
import 'package:baatien/screens/view_profile_screen.dart';
import 'package:baatien/widgets/input_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/apis.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  ChatScreen(this.user);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

bool me = false;

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messageList = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 243, 240),
        body: Column(
          children: [
            buildAppBar(context),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: StreamBuilder(
                          stream: APIs.getAllMessages(widget.user),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );

                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _messageList = data
                                        ?.map((e) => Message.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                if (_messageList.isNotEmpty) {
                                  return ListView.builder(
                                    reverse: true,
                                    itemCount: _messageList.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 80),
                                          child:
                                              MessageCard(_messageList[index]),
                                        );
                                      }
                                      return MessageCard(_messageList[index]);
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                      "Baatey Karo 💬",
                                      style: TextStyle(fontFamily: "Poppins"),
                                    ),
                                  );
                                }
                            }
                          }),
                    ),
                  ),
                  InputMessage(
                    heightForInputField: MediaQuery.of(context).size.height,
                    user: widget.user,
                    messageList: _messageList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .06, bottom: 10),
      color: Colors.amber,
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ViewProfileScreen(widget.user)));
              },
              child: Row(
                children: [
                  //back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  ),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.height * .05,
                      height: MediaQuery.of(context).size.height * .05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(Icons.person)),
                    ),
                  ),

                  //for adding some space
                  const SizedBox(width: 10),

                  //user name & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)),

                      //for adding some space
                      const SizedBox(height: 2),

                      //last seen time of user
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : GetDate.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : GetDate.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: list.isNotEmpty
                              ? list[0].isOnline
                                  ? const TextStyle(
                                      fontSize: 13,
                                      color: Colors.lightGreen,
                                      fontFamily: "Poppins")
                                  : const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontFamily: "Poppins")
                              : null)
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
