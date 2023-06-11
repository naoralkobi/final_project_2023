import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/firebase/auth_repository.dart';
import '../consts.dart';
import 'show_image.dart';
import 'createProfilePage.dart';

/// This file contains the implementation of the ViewUserProfile widget,
/// which is responsible for displaying the profile of a user.

class ViewUserProfile extends StatefulWidget {
  String userID; // User ID for the profile being viewed
  var user = AuthRepository.instance().user; // Current authenticated user


  ViewUserProfile(this.userID);

  @override
  _ViewUserProfileState createState() => _ViewUserProfileState();
}

class _ViewUserProfileState extends State<ViewUserProfile> {
  @override
  Widget build(BuildContext context) {
    // Initialize the screen size configuration
    SizeConfig().init(context);
    return StreamBuilder(
      // Stream data from Firestore collection USERS with the specified user ID
        stream: FirebaseFirestore.instance
            .collection(USERS)
            .doc(widget.userID)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> userInfo) {
          // Show error message if there is an error in the snapshot
          if (userInfo.hasError) return Text(ERROR_MESSAGE);
          // Show a progress indicator while connecting to Firestore and waiting for data
          if (userInfo.connectionState == ConnectionState.waiting &&
              userInfo.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Extract user data from the snapshot
            Map<String, dynamic> userData = userInfo.data!.data() as Map<String, dynamic>;
            // Extract language data from user data
            Map<String, dynamic> languagesData = userData[LANGUAGES] as Map<String, dynamic>;
            List<String> languagesList = languagesData.keys.toList();  // Convert language data to a list
            return Scaffold(
                resizeToAvoidBottomInset: false, // Avoid resizing the layout when the keyboard appears
                body: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                ),
                                iconSize: SizeConfig.blockSizeHorizontal * 8,
                                onPressed: () {
                                  // Navigate back to the previous screen
                                  Navigator.pop(context);
                                }),
                            // Show the edit button only if the current user is the owner of the profile
                            widget.user!.uid == (userInfo.data!.data() as Map<String, dynamic>)[UID]
                                ? IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: PURPLE_COLOR,
                                ),
                                iconSize:
                                SizeConfig.blockSizeHorizontal *
                                    6,
                                onPressed: () {
                                  // Navigate to the edit profile page
                                  Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext
                                          context) {
                                            return CreateProfilePage(
                                                userInfo.data!.data()! as Map<String, dynamic>);
                                          }));
                                })
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Open a page to show the profile image in full screen
                          String imageUrl = (userInfo.data!.data() as Map<String, dynamic>)["URL"];
                          if (imageUrl.isNotEmpty){
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ShowImage(
                                  imageUrl: imageUrl,
                                  tag: "profileImage",
                                  title: "Profile Image",
                            )));
                          }
                          // TODO add else
                        },
                        child: CircleAvatar(
                          maxRadius: 85,
                          backgroundImage:
                          NetworkImage((userInfo.data!.data() as Map<String, dynamic>)["URL"]
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.screenWidth * 0.7,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            child: Text(
                              // Display the username
                            (userInfo.data!.data() as Map<String, dynamic>)[USERNAME]
                          ,
                              style: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 1,
                      ),
                      Visibility(
                        visible: (userInfo.data!.data() as Map<String, dynamic>).containsKey(SCORE),
                        child: SizedBox(
                          width: SizeConfig.screenWidth * 0.7,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              child: Row(
                                children: [
                                  ImageIcon(const AssetImage("assets/images/trophy.png"),
                                      color: Colors.black,
                                      size: SizeConfig.blockSizeHorizontal * 8),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 1,
                                  ),

                                  // Check if the user has a score
                                  (userInfo.data!.data() as Map<String, dynamic>).containsKey(SCORE)
                                      ?
                                  (userInfo.data!.data() as Map<String, dynamic>)[SCORE].toString() != "null" ?
                                  Text( // Display the user's score
                                    (userInfo.data!.data() as Map<String, dynamic>)[SCORE].toString(),
                                    style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.05),
                                  )
                                  // Display a default score of 0
                                      : Text("0", style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.05))
                                  // Display an empty text if there is no score
                                      : const Text("")
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 7,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(
                            "ABOUT",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: SizeConfig.screenWidth * 0.04),
                          ),
                        ]),
                      ),
                      const Divider(
                        indent: 35,
                        endIndent: 35,
                        thickness: 0.6,
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 1.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 6),
                        child: Row(children: [
                          Text(
                            "Name",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(// Display full name of the user by combining the "first name" and "last name" fields from the data,
                            (userInfo.data!.data() as Map<String, dynamic>)["first name"] +
                                " " +
                                (userInfo.data!.data() as Map<String, dynamic>)["last name"],
                            style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 6),
                        child: Row(children: [
                          Text(
                            GENDER,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(
                            // Display the gender of the user
                            (userInfo.data!.data() as Map<String, dynamic>)[GENDER],
                            style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(
                            // Display the birthdate of the user
                            (userInfo.data!.data() as Map<String, dynamic>)["birthDate"],
                            style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 6),
                        child: Row(children: [
                          Text(
                            "Country",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(
                            // Display the country of the user
                            (userInfo.data!.data() as Map<String, dynamic>)["country"],
                            style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 6),
                        child: Row(children: [
                          Text(
                            "Description",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Container(
                            width: SizeConfig.screenWidth * 0.7,
                            // height: 50,
                            constraints: BoxConstraints(
                                minHeight: SizeConfig.blockSizeVertical * 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                style: BorderStyle.solid,
                                color: Colors.grey,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                // Display the user's description
                                  (userInfo.data!.data() as Map<String, dynamic>)["description"],
                                style: TextStyle(
                                    fontSize: SizeConfig.screenWidth * 0.035),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                        child: Row(children: [
                          Text(
                            LANGUAGES,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Flexible(
                        // fit: FlexFit.loose,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: (userInfo.data!.data() as Map<String, dynamic>)[LANGUAGES].length,
                          itemBuilder: (context, index) {
                            return LangRow(
                              // Display each language and its proficiency level
                                languagesList[index],
                                (userInfo.data!.data() as Map<String, dynamic>)[LANGUAGES]
                                [languagesList[index]]);
                          },
                        ),
                      ),
                    ],
                  ),
                ));
          }
        });
  }

  Widget LangRow(String lang, String lvl) {
    return Padding(
      // Add left padding of 40 and top padding of 10
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 10),
      child: Row(children: [
        Container(
          // Set the width of the container based on a fraction of the screen width
          width: SizeConfig.screenWidth * 0.28,
          child: Text(
            lang, // Display the language parameter
            // Set the font size based on the screen width
            style: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
          ),
        ),
        SizedBox(
          // Add a fixed width-sized box for spacing between the language and level containers
          width: SizeConfig.screenWidth * 0.1,
        ),
        Container(
          // Set the width of the container based on a fraction of the screen width
          width: SizeConfig.screenWidth * 0.3,
          // Set the minimum height of the container based on the vertical block size
          constraints: BoxConstraints(minHeight: SizeConfig.blockSizeVertical * 1.2),
          decoration: BoxDecoration(
            // Set a white background color for the container
            color: Colors.white,
            border: Border.all(
              style: BorderStyle.solid,
              color: Colors.grey, // Set a grey color for the border
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          child: Padding(
            // Add padding inside the container
            padding: const EdgeInsets.all(4.0),
            child: Text(
              lvl, // Display the level parameter
              textAlign: TextAlign.center, // Center align the level text
              // Set the font size based on the screen width
              style: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
            ),
          ),
        ),
      ]),
    );
  }

}
