import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/dialogs.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  // static const routename = "/developer-profile-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 240),
      appBar: AppBar(
        title: const Text(
          "Developer's Profile",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        centerTitle: true,
      ),
      floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shape: const StadiumBorder(),
          ),
          onPressed: () async {
            await Clipboard.setData(
              const ClipboardData(
                  text: "https://www.linkedin.com/in/rohitprajapati1113"),
            ).then((value) {
              Dialogs.showSnackBar(context, 'Link Copied!');
            });
          },
          child: const Text(
            "Copy LinkedIn Profile Link",
            style: TextStyle(fontFamily: "Popins"),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.asset(
                      "assets/images/Rohit's_Profile_Photo.jpg",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Email: rohitprajapati1113@gmail.com",
                style: TextStyle(fontFamily: "Poppins"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
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
                    "Rohit Prajapati",
                    style: TextStyle(
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
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "LinkedIn Profile: ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "https://www.linkedin.com/in/rohitprajapati1113",
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "About Me:",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "Hi!, I'm Rohit, currently a BCA Student at Guru Gobind Singh Indraprastha University and this is My First Application developed using Flutter Framework!!",
                      overflow: TextOverflow.fade,
                      softWrap: true,
                      style: TextStyle(
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
