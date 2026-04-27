import 'dart:developer';
import 'package:baatien/helpers/get_date.dart';
import 'package:baatien/models/apis.dart';
import 'package:baatien/models/message.dart';
import 'package:baatien/widgets/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  bool isMe = true;
  final Message message;
  MessageCard(this.message);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        child: isMe ? messageSent(context) : messageRecieved(context),
        onLongPress: () {
          _show(isMe);
        });
  }

  void _show(bool isMe) {
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
          widget.message.type == Type.text
              ?
              //copy option
              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                            ClipboardData(text: widget.message.msg))
                        .then((value) {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      Dialogs.showSnackBar(context, 'Text Copied!');
                    });
                  })
              :
              //save option
              _OptionItem(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Save Image',
                  onTap: () async {
                    try {
                      log('Image Url: ${widget.message.msg}');
                      await GallerySaver.saveImage(widget.message.msg,
                              albumName: 'Baatey')
                          .then((success) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                        if (success != null && success) {
                          Dialogs.showSnackBar(
                              context, 'Image Successfully Saved!');
                        }
                      });
                    } catch (e) {
                      log('ErrorWhileSavingImg: $e');
                    }
                  }),

          //separator or divider
          if (isMe)
            const Divider(
              color: Colors.black54,
            ),

          //edit option
          if (widget.message.type == Type.text && isMe)
            _OptionItem(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                name: 'Edit Message',
                onTap: () {
                  // for hiding bottom sheet
                  Navigator.pop(context);

                  _showMessageUpdateDialog();
                }),

          //delete option
          if (isMe)
            _OptionItem(
                icon: const Icon(Icons.delete_forever,
                    color: Colors.red, size: 26),
                name: 'Delete Message',
                onTap: () async {
                  await APIs.deleteMessage(widget.message)
                      .then((value) => Navigator.of(context).pop());
                }),

          //separator or divider
          const Divider(
            color: Colors.black54,
          ),

          //sent time
          _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              name:
                  'Sent At: ${GetDate.getFormattedTime(context: context, time: widget.message.sent)}',
              onTap: () {}),

          //read time
          _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              name: widget.message.read.isEmpty
                  ? 'Read At: Not seen yet'
                  : 'Read At: ${GetDate.getFormattedTime(context: context, time: widget.message.read)}',
              onTap: () {}),
        ],
      ),
    );
  }

  Widget messageSent(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          widget.message.read.isNotEmpty
              ? const Icon(
                  Icons.done_all_rounded,
                  color: Colors.blue,
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(GetDate.getFormattedTime(
                context: context, time: widget.message.sent)),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, offset: Offset(0, 5), blurRadius: 5)
                ],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                border: Border.all(color: Colors.amber),
                color: const Color.fromARGB(255, 255, 241, 191),
              ),
              child: widget.message.type == Type.text
                  ? Text(widget.message.msg)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 80,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageRecieved(BuildContext context) {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Colors.grey, offset: Offset(0, 5), blurRadius: 5)
              ],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              border: Border.all(color: Colors.black),
              color: const Color.fromARGB(255, 223, 223, 223),
            ),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 80,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(GetDate.getFormattedTime(
              context: context, time: widget.message.sent)),
        ),
      ],
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Colors.amber,
                    size: 28,
                  ),
                  Text(
                    ' Update Message',
                    style: TextStyle(fontFamily: "Poppins"),
                  )
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //update button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      await APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontFamily: "Poppins"),
                    ))
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .05,
              top: MediaQuery.of(context).size.height * .015,
              bottom: MediaQuery.of(context).size.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
