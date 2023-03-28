import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project_2023/Pages/chat_page.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/Widgets/chat_list.dart';
import 'package:final_project_2023/Widgets/start_chat.dart';

import 'package:final_project_2023/firebase/auth_repository.dart';

import '../consts.dart';
import 'friends_list.dart';
import 'show_image.dart';
import 'createProfilePage.dart';

class ViewUserProfile extends StatefulWidget {
  String userID;
  var user = AuthRepository.instance().user;

  ViewUserProfile(this.userID);

  @override
  _ViewUserProfileState createState() => _ViewUserProfileState();
}

class _ViewUserProfileState extends State<ViewUserProfile> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userID)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> userInfo) {
          if (userInfo.hasError) return Text("There has been an error");
          //if connecting show progressIndicator
          if (userInfo.connectionState == ConnectionState.waiting &&
              userInfo.data == null)
            return Center(child: CircularProgressIndicator());
          else {
            Map<String, dynamic> userData = userInfo.data!.data() as Map<String, dynamic>;
            Map<String, dynamic> languagesData = userData["Languages"] as Map<String, dynamic>;
            List<String> languagesList = languagesData.keys.toList();
            return Scaffold(
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
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
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                ),
                                iconSize: SizeConfig.blockSizeHorizontal * 8,
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            widget.user!.uid == (userInfo.data!.data() as Map<String, dynamic>)["UID"]
                                ? IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Color(0xFFA66CB7),
                                ),
                                iconSize:
                                SizeConfig.blockSizeHorizontal *
                                    6,
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext
                                          context) {
                                            return CreateProfilePage(
                                                userInfo.data!.data()! as Map<String, dynamic>);
                                          }));
                                })
                                : SizedBox(),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: SizeConfig.blockSizeVertical * 1,
                      // ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ShowImage(
                                imageUrl: (userInfo.data!.data() as Map<String, dynamic>)["UID"]
                                ,
                                tag: "profileImage",
                                title: "Profile Image",
                              )));
                        },
                        child: CircleAvatar(
                          maxRadius: 85,
                          backgroundImage:
                          NetworkImage((userInfo.data!.data() as Map<String, dynamic>)["URL"]
                          ),
                        ),
                      ),
                      Container(
                        width: SizeConfig.screenWidth * 0.7,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            child: Text(
                            (userInfo.data!.data() as Map<String, dynamic>)["username"]
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
                        visible: (userInfo.data!.data() as Map<String, dynamic>).containsKey('score'),
                        child: Container(
                          width: SizeConfig.screenWidth * 0.7,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              child: Row(
                                children: [
                                  ImageIcon(AssetImage("assets/images/trophy.png"),
                                      color: Colors.black,
                                      size: SizeConfig.blockSizeHorizontal * 8),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 1,
                                  ),


                                  (userInfo.data!.data() as Map<String, dynamic>).containsKey('score')
                                      ?
                                  (userInfo.data!.data() as Map<String, dynamic>)["score"].toString() != "null" ?
                                  Text(
                                    (userInfo.data!.data() as Map<String, dynamic>)["score"].toString(),
                                    style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.05),
                                  ) : Text("0", style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.05))
                                      : Text("")
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
                      Divider(
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
                          Text(
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
                            "Gender",
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
                            (userInfo.data!.data() as Map<String, dynamic>)["gender"],
                            style: TextStyle(
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(40, 0, 0, 6),
                      //   child: Row(children: [
                      //     Text(
                      //       "Date Of Birth",
                      //       style: TextStyle(
                      //           color: Colors.grey,
                      //           fontSize: SizeConfig.screenWidth * 0.035),
                      //     ),
                      //   ]),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(children: [
                          Text(
                            (userInfo.data!.data() as Map<String, dynamic>)["birthdate"],
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
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                  (userInfo.data!.data() as Map<String, dynamic>)["description"],
                                style: TextStyle(
                                    fontSize: SizeConfig.screenWidth * 0.035),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                style: BorderStyle.solid,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.all(
                                const Radius.circular(12.0),
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
                            "Languages",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: SizeConfig.screenWidth * 0.035),
                          ),
                        ]),
                      ),
                      Flexible(
                        // fit: FlexFit.loose,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: (userInfo.data!.data() as Map<String, dynamic>)["Languages"].length,
                          itemBuilder: (context, index) {
                            return LangRow(
                                languagesList[index],
                                (userInfo.data!.data() as Map<String, dynamic>)["Languages"]
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
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 10),
      child: Row(children: [
        Container(
          width: SizeConfig.screenWidth * 0.28,
          child: Text(
            lang,
            style: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
          ),
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.1,
        ),
        Container(
          width: SizeConfig.screenWidth * 0.3,
          constraints:
          BoxConstraints(minHeight: SizeConfig.blockSizeVertical * 1.2),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              lvl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: SizeConfig.screenWidth * 0.035),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              style: BorderStyle.solid,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(
              const Radius.circular(16.0),
            ),
          ),
        ),
      ]),
    );
  }
}
