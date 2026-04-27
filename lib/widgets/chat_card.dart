import 'package:baatien/helpers/get_date.dart';
import 'package:baatien/models/apis.dart';
import 'package:baatien/models/chat_user.dart';
import 'package:baatien/models/message.dart';
import 'package:baatien/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  final ChatUser user;
  ChatCard(this.user);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Center(
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshots) {
              final data = snapshots.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }
              return ListTile(
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(widget.user),
                        ),
                      ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          const CircleAvatar(child: Icon(Icons.person)),
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(Icons.person)),
                    ),
                  ),
                  title: Text(
                    widget.user.name,
                    style: const TextStyle(fontFamily: "Poppins"),
                  ),
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "Image"
                            : _message!.msg
                        : "Aao Baatey Kare!!",
                    style: const TextStyle(fontFamily: "Poppins"),
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.lightGreenAccent),
                            )
                          : Text(GetDate.getLastMessageTime(
                              context: context, time: _message!.sent)));
            }),
      ),
    );
  }
}
