import 'package:baatien/helpers/get_date.dart';
import 'package:baatien/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatelessWidget {
  ChatUser user;
  ViewProfileScreen(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 240),
      appBar: AppBar(
        title: Text(
          "${user.name}'s Profile",
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              "Created At: ",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            GetDate.getLastMessageTime(context: context, time: user.createdAt),
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 15,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: CachedNetworkImage(
                    imageUrl: user.image == ""
                        ? "https://e7.pngegg.com/pngimages/103/590/png-clipart-computer-icons-user-profile-avatar-heroes-monochrome.png"
                        : user.image,
                    height: 250,
                    width: 250,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                    placeholder: (context, url) => const Icon(
                      Icons.person,
                      size: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Email: ${user.email}",
                style: const TextStyle(fontFamily: "Poppins"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Name: ",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "About: ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      user.about,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
