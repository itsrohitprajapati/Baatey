import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:baatien/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;
  static late ChatUser me;

  static Future<bool> userExists() async {
    // ProfileProvider().setProfile(user as ChatUser);
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> getYourProfile() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getYourProfile());
      }
    });
  }

  static Future<void> createUser() async {
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Aao Baatein Karein!!",
        name: user.displayName.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
        isOnline: false,
        id: user.uid,
        email: user.email.toString(),
        pushToken: "");
    // ProfileProvider().setProfile(chatUser);
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateProfileName() async {
    await firestore.collection("users").doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final extension = file.path.split(".").last;
    final ref = storage.ref().child("profile_picture/${user.uid}.$extension");
    await ref.putFile(file, SettableMetadata(contentType: "image/$extension"));
    me.image = await ref.getDownloadURL();
    await firestore.collection("users").doc(user.uid).update({
      "image": me.image,
    });
  }

  static String getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode ? "${user.uid}-$id" : "$id-${user.uid}";

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser _user) {
    return APIs.firestore
        .collection("chats/${getConversationId(_user.id)}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return APIs.firestore
        .collection("users")
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  // chats (collection) --> conversation id (doc) --> messages (collection) --> message (doc)

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //msg to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection("chats/${getConversationId(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "Image"));
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chats/${getConversationId(message.fromId)}/messages/")
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection("chats/${getConversationId(chatUser.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final extension = file.path.split(".").last;
    final ref = storage.ref().child(
        "images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$extension");
    await ref.putFile(file, SettableMetadata(contentType: "image/$extension"));
    final imageURL = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageURL, Type.image);
  }

  static Future<void> sendScribble(
      ChatUser chatUser, Uint8List imageBytes) async {
    final ref = storage.ref().child(
        "images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.jpg");
    await ref.putData(imageBytes, SettableMetadata(contentType: "image/.jpg"));
    final imageURl = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageURl, Type.image);
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    final pt = await FirebaseMessaging.instance.getToken();
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': pt,
    });
  }

  //for firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await FirebaseMessaging.instance.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=your_key'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
