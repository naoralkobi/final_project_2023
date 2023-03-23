
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/show_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
 import 'package:provider/provider.dart';
 import 'package:final_project_2023/screen_size_config.dart';
 import 'dart:io';
 import 'package:final_project_2023/main.dart';
 import '../FireBase/auth_repository.dart';
import '../ProfileVars.dart';
import '../Widgets/age_drop_down.dart';
import '../Widgets/languageWidget.dart';
import '../Widgets/profile_date.dart';
import '../Widgets/profile_text_field.dart';
import 'home_page.dart';


///// **************************8

// class CreateProfilePage extends StatefulWidget {
//   Map? userInfo;
//
//   CreateProfilePage(this.userInfo);
//
//   @override
//   _CreateProfilePageState createState() => _CreateProfilePageState();
// }
//
// class _CreateProfilePageState extends State<CreateProfilePage> {
//   String imageUrl = "";
//   final _formKey = GlobalKey<FormState>();
//   DateTime currentDate = DateTime.now();
//   var user = FirebaseAuth.instance.currentUser;
//   final _storage = FirebaseStorage.instance;
//   StreamController<String> firebaseController = StreamController.broadcast();
//   bool isFinished = false;
//   bool isUserNameUnique = true;
//   final userNameController = TextEditingController();
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final countryController = TextEditingController();
//   final descController = TextEditingController();
//   String preferredGenderVal = 'c';
//   String userGender = 'c';
//   bool isUserNameValid = true;
//   bool loadFinish = false;
//
//   // Map userInfo = {};
//   bool firstClick = true;
//
//   @override
//   void initState() {
//     super.initState();
//     ProfileVars().init();
//     imageUrl = "";
//     _storage
//         .ref()
//         .child("userAvatars/" + user!.uid)
//         .getDownloadURL()
//         .then(found, onError: notFound);
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     if (widget.userInfo!.isNotEmpty && firstClick) {
//       userGender = widget.userInfo!["gender"];
//       preferredGenderVal = widget.userInfo!["preferred gender"];
//       firstClick = false;
//     }
//     return Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
//       Widget usernameTextField = ProfileTextField(
//           "username",
//           userNameController,
//           firebaseController,
//           isUserNameUnique,
//           widget.userInfo);
//       return GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           body: ListView(
//             shrinkWrap: true,
//             children: [
//               Container(
//                 padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
//                 alignment: Alignment.topLeft,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   iconSize: SizeConfig.blockSizeHorizontal * 8,
//                   onPressed: () {
//                     if (authRep.isNew()) {
//                       authRep.signOut();
//                       Navigator.of(context).popUntil((route) => route.isFirst);
//                     } else
//                       Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: SizeConfig.blockSizeVertical * 2,
//               ),
//               Align(
//                 child: Stack(
//                   children: [
//                     Hero(
//                       tag: "profileImage",
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => ShowImage(
//                                 imageUrl: imageUrl,
//                                 tag: "profileImage",
//                                 title: "Profile Image",
//                               )));
//                         },
//                         child: CircleAvatar(
//                           maxRadius: 85,
//                           backgroundImage: NetworkImage(imageUrl),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                         left: 112,
//                         right: 0,
//                         top: 120,
//                         child: RawMaterialButton(
//                           onPressed: () {
//                             uploadImage();
//                           },
//                           elevation: 1.0,
//                           constraints:
//                           BoxConstraints(maxHeight: 55, maxWidth: 55),
//                           fillColor: Color(0xAFA66CB7),
//                           child: Icon(
//                             Icons.camera_alt_outlined,
//                             color: Colors.white,
//                             size: 30.0,
//                           ),
//                           padding: EdgeInsets.all(15.0),
//                           shape: CircleBorder(),
//                         ))
//                   ],
//                   clipBehavior: Clip.none,
//                 ),
//               ),
//               SizedBox(
//                 height: authRep.isNew() ? 0 : SizeConfig.blockSizeVertical * 2,
//               ),
//               authRep.isNew()
//                   ? SizedBox()
//                   : Container(
//                 width: SizeConfig.screenWidth * 0.7,
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: SizedBox(
//                     child: widget.userInfo!["username"] == null
//                         ? SizedBox()
//                         : Text(
//                       widget.userInfo!["username"],
//                       style: TextStyle(
//                           fontSize: SizeConfig.screenWidth * 0.12,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: SizeConfig.blockSizeVertical * 7,
//               ),
//               Row(children: [
//                 Text(
//                   "             ABOUT",
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ]),
//               Divider(
//                 indent: 35,
//                 endIndent: 35,
//                 thickness: 0.6,
//               ),
//               SizedBox(
//                 height: SizeConfig.blockSizeVertical * 1.5,
//               ),
//               Form(
//                 key: _formKey,
//                 child: Column(children: [
//                   Container(
//                     margin: EdgeInsets.fromLTRB(
//                         SizeConfig.blockSizeHorizontal * 10,
//                         0,
//                         SizeConfig.blockSizeHorizontal * 20,
//                         0),
//                     child: Column(
//                       children: [
//                         // authRep.isNew()
//                         //     ? usernameTextField
//                         //     : SizedBox(),
//                         Visibility(
//                           visible: authRep.isNew(),
//                           child: usernameTextField,
//                         ),
//                         // usernameTextField,
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1.5,
//                         ),
//                         ProfileTextField(
//                             "first name",
//                             firstNameController,
//                             firebaseController,
//                             isUserNameUnique,
//                             widget.userInfo),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1.5,
//                         ),
//                         ProfileTextField(
//                             "last name",
//                             lastNameController,
//                             firebaseController,
//                             isUserNameUnique,
//                             widget.userInfo),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1.5,
//                         ),
//                         Row(children: [
//                           Text(
//                             "   Gender",
//                             style: TextStyle(
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ]),
//                         Row(
//                           children: <Widget>[
//                             // SizedBox(
//                             //   width: 30,
//                             // ),
//                             Radio<String>(
//                               value: 'Male',
//                               activeColor: Color(0xFFA66CB7),
//                               groupValue: userGender,
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   userGender = value!;
//                                 });
//                               },
//                             ),
//                             Text("Male    "),
//                             Radio<String>(
//                               value: 'Female',
//                               activeColor: Color(0xFFA66CB7),
//                               groupValue: userGender,
//                               onChanged: (String? value) {
//                                 setState(() {
//                                   userGender = value!;
//                                 });
//                               },
//                             ),
//                             Text("Female    "),
//                           ],
//                         ),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1,
//                         ),
//                         Container(
//                           // height: 20,
//                           padding: (isFinished && userGender == 'c')
//                               ? EdgeInsets.fromLTRB(
//                               0,
//                               0,
//                               SizeConfig.blockSizeHorizontal * 23,
//                               SizeConfig.blockSizeVertical * 3)
//                               : null,
//                           child: (isFinished && userGender == 'c')
//                               ? Text(
//                             "You must pick a gender",
//                             style: TextStyle(color: Colors.red[800]),
//                           )
//                               : null,
//                         ),
//                         ProfileDatePicker(firebaseController, widget.userInfo),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1.5,
//                         ),
//                         ProfileTextField(
//                             "country",
//                             countryController,
//                             firebaseController,
//                             isUserNameUnique,
//                             widget.userInfo),
//                         SizedBox(
//                           height: SizeConfig.blockSizeVertical * 1.5,
//                         ),
//                         ProfileTextField(
//                             "description",
//                             descController,
//                             firebaseController,
//                             isUserNameUnique,
//                             widget.userInfo),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: SizeConfig.blockSizeVertical * 6,
//                   ),
//                   Row(children: [
//                     Text(
//                       "             CHAT PREFERENCES",
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ]),
//                   Divider(
//                     indent: 35,
//                     endIndent: 35,
//                     thickness: 0.6,
//                   ),
//                   SizedBox(
//                     height: SizeConfig.blockSizeVertical * 1.5,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(
//                         SizeConfig.blockSizeHorizontal * 12, 0, 0, 0),
//                     child: SizedBox(
//                       height: SizeConfig.blockSizeVertical * 3.5,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(
//                                 0, 0, SizeConfig.blockSizeHorizontal * 2, 0),
//                             child: Text(
//                               "min age:",
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           AgeDropDown(
//                               "minAge", firebaseController, widget.userInfo),
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(
//                                 SizeConfig.blockSizeHorizontal * 2,
//                                 0,
//                                 SizeConfig.blockSizeHorizontal * 2,
//                                 0),
//                             child: Text(
//                               "max age:",
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           AgeDropDown(
//                               "maxAge", firebaseController, widget.userInfo),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     // height: 20,
//                     padding: (isFinished && preferredGenderVal == 'c')
//                         ? EdgeInsets.fromLTRB(
//                         0,
//                         0,
//                         SizeConfig.blockSizeHorizontal * 40,
//                         SizeConfig.blockSizeVertical * 2)
//                         : null,
//                     child: (isFinished &&
//                         (ProfileVars.minAge == 1 ||
//                             ProfileVars.maxAge == 1))
//                         ? Text(
//                       "You must pick age range",
//                       style: TextStyle(color: Colors.red[800]),
//                     )
//                         : null,
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(children: [
//                     Text(
//                       "             Preferred Gender",
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ]),
//                   Row(
//                     children: <Widget>[
//                       SizedBox(
//                         width: 30,
//                       ),
//                       Radio<String>(
//                         value: 'Male',
//                         activeColor: Color(0xFFA66CB7),
//                         groupValue: preferredGenderVal,
//                         onChanged: (String? value) {
//                           setState(() {
//                             preferredGenderVal = value!;
//                           });
//                         },
//                       ),
//                       Text("Male"),
//                       Radio<String>(
//                         value: 'Female',
//                         activeColor: Color(0xFFA66CB7),
//                         groupValue: preferredGenderVal,
//                         onChanged: (String? value) {
//                           setState(() {
//                             preferredGenderVal = value!;
//                           });
//                         },
//                       ),
//                       Text("Female"),
//                       Radio<String>(
//                         value: 'Dont Care',
//                         activeColor: Color(0xFFA66CB7),
//                         groupValue: preferredGenderVal,
//                         onChanged: (String? value) {
//                           setState(() {
//                             preferredGenderVal = value!;
//                           });
//                         },
//                       ),
//                       Text("Dont care"),
//                     ],
//                   ),
//                   SizedBox(
//                     height: SizeConfig.blockSizeVertical * 1,
//                   ),
//                   Container(
//                     // height: 20,
//                     padding: (isFinished && preferredGenderVal == 'c')
//                         ? EdgeInsets.fromLTRB(
//                         0,
//                         0,
//                         SizeConfig.blockSizeHorizontal * 27,
//                         SizeConfig.blockSizeVertical * 2)
//                         : null,
//                     child: (isFinished && preferredGenderVal == 'c')
//                         ? Text(
//                       "You must pick a preferred gender",
//                       style: TextStyle(color: Colors.red[800]),
//                     )
//                         : null,
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//                     Text(
//                       "             Languages",
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ]),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   LanguageWidget("Arabic", firebaseController, widget.userInfo),
//                   LanguageWidget("French", firebaseController, widget.userInfo),
//                   LanguageWidget("German", firebaseController, widget.userInfo),
//                   LanguageWidget("Hebrew", firebaseController, widget.userInfo),
//                   LanguageWidget(
//                       "Italian", firebaseController, widget.userInfo),
//                   LanguageWidget(
//                       "Portuguese", firebaseController, widget.userInfo),
//                   LanguageWidget(
//                       "Spanish", firebaseController, widget.userInfo),
//                   SizedBox(
//                     height: 5,
//                   ),
//                 ]),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                 // height: 20,
//                 padding: (isFinished &&
//                     (ProfileVars.languageNum == 0 ||
//                         ProfileVars.numOfLvls != ProfileVars.languageNum))
//                     ? EdgeInsets.fromLTRB(
//                     SizeConfig.blockSizeHorizontal * 9,
//                     0,
//                     SizeConfig.blockSizeHorizontal * 0,
//                     SizeConfig.blockSizeVertical * 2)
//                     : null,
//                 child: isFinished
//                     ? (ProfileVars.languageNum == 0
//                     ? Text(
//                   "You must pick at least one language",
//                   style: TextStyle(color: Colors.red[800]),
//                 )
//                     : (ProfileVars.numOfLvls != ProfileVars.languageNum
//                     ? Text(
//                   "You must pick the level",
//                   style: TextStyle(color: Colors.red[800]),
//                 )
//                     : null))
//                     : null,
//               ),
//               Divider(
//                 indent: 35,
//                 endIndent: 35,
//                 thickness: 0.6,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               loadFinish
//                   ? Center(child: CircularProgressIndicator())
//                   : Container(
//                 width: SizeConfig.screenWidth * 0.05,
//                 child: Align(
//                   child: ElevatedButton(
//                       onPressed: () async {
//                         changeLoadFinish();
//                         if (authRep.isNew()) {
//                           await checkUserNameUnique(
//                               userNameController.text);
//                         }
//                         pressedFinish();
//                         if (_formKey.currentState!.validate() &&
//                             isUserNameUnique &&
//                             userGender != 'c' &&
//                             ProfileVars().validate()) {
//                           finishedCreating(authRep);
//                         } else {
//                           await Future.delayed(
//                               Duration(milliseconds: 400));
//                           changeLoadFinish();
//                         }
//                       },
//                       child: Text(
//                         "Finish",
//                         style:
//                         TextStyle(color: Colors.green, fontSize: 16),
//                       ),
//                       style: ButtonStyle(
//                           minimumSize: MaterialStateProperty.all<Size>(
//                               Size(90, 35)),
//                           backgroundColor:
//                           MaterialStateProperty.all<Color>(
//                               Colors.white),
//                           shape: MaterialStateProperty.all<
//                               RoundedRectangleBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(13.0),
//                                 side: BorderSide(
//                                     color: Colors.black, width: 0.5),
//                               )))),
//                 ),
//               ),
//               SizedBox(
//                 height: 25,
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   pressedFinish() {
//     setState(() {
//       isFinished = true;
//     });
//   }
//
//   changeLoadFinish() {
//     setState(() {
//       loadFinish = !loadFinish;
//     });
//   }
//
//   found(String url) {
//     imageUrl = url;
//     setState(() {});
//   }
//
//   notFound(error) async {
//     final ref = _storage.ref().child("userAvatars/defaultAvatar.jpeg");
//     imageUrl = await ref.getDownloadURL();
//     setState(() {});
//   }
//
//   uploadImage() async {
//     final _picker = ImagePicker();
//     PickedFile? image;
//     await Permission.photos.request();
//     var permissionStatus = await Permission.photos.status;
//     if (permissionStatus.isGranted) {
//       image = await _picker.getImage(source: ImageSource.gallery);
//       if (image != null) {
//         var file = File(image.path);
//         TaskSnapshot uploadTask = await _storage
//             .ref()
//             .child("userAvatars/" + user!.uid)
//             .putFile(file);
//         String url = await uploadTask.ref.getDownloadURL();
//         setState(() {
//           imageUrl = url;
//         });
//       } else {
//         final snackBar = SnackBar(
//           content: Text('No image selected'),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     } else {
//       print("error");
//     }
//   }
//
//   Future<void> checkUserNameUnique(String userName) async {
//     setState(() {
//       isUserNameUnique = true;
//     });
//     await FirebaseFirestore.instance.collection("users").get().then((value) {
//       value.docs.forEach((element) {
//         if (element.data()["username"] == userName) {
//           setState(() {
//             isUserNameUnique = false;
//           });
//         }
//       });
//     });
//   }
//
//   Future<void> finishedCreating(AuthRepository authRep) async {
//     if (authRep.isNew()) {
//       await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
//         "email": user!.email,
//         "UID": user!.uid,
//         "URL": imageUrl,
//         "Languages": {},
//         "friends": [],
//         "gender": userGender,
//         "preferred gender": preferredGenderVal,
//         "score" : 0,
//       });
//       firebaseController.add("finish");
//       // Navigator.of(context).pushReplacement(
//       //     MaterialPageRoute<void>(builder: (BuildContext context) {
//       //   return MyHomePage();
//       // }));
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     } else {
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user!.uid)
//           .update({
//         "Languages": {},
//       });
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user!.uid)
//           .update({
//         "URL": imageUrl,
//       });
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user!.uid)
//           .update({
//         "gender": userGender,
//       });
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user!.uid)
//           .update({"preferred gender": preferredGenderVal});
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user!.uid)
//           .update({"username": widget.userInfo!["username"]});
//       firebaseController.add("finish");
//       Navigator.of(context).pop();
//     }
//     await Future.delayed(Duration(milliseconds: 500));
//     authRep.setNotNew();
//   }
// }
//
//



















class CreateProfilePage extends StatefulWidget {
  Map? userInfo;

  CreateProfilePage(this.userInfo);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

 class _CreateProfilePageState extends State<CreateProfilePage> {
  String imageUrl = "";
  final _formKey = GlobalKey<FormState>();
  DateTime currentDate = DateTime.now();
  var user = FirebaseAuth.instance.currentUser;
  final _storage = FirebaseStorage.instance;
  StreamController<String> firebaseController = StreamController.broadcast();
  bool isFinished = false;
  bool isUserNameUnique = true;
  final userNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final countryController = TextEditingController();
  final descController = TextEditingController();
  String preferredGenderVal = 'c';
  String userGender = 'c';
  bool isUserNameValid = true;
  bool loadFinish = false;

  // Map userInfo = {};
  bool firstClick = true;

  @override
  void initState() {
    super.initState();
    ProfileVars().init();
    print("userAvatars/" + user!.uid);
    imageUrl = "";
    _storage
        .ref()
        .child("userAvatars/" + user!.uid)
        .getDownloadURL()
        .then(found, onError: notFound);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (widget.userInfo!.isNotEmpty && firstClick) {
      userGender = widget.userInfo!["gender"];
      preferredGenderVal = widget.userInfo!["preferred gender"];
      firstClick = false;
    }
    return (ChangeNotifierProvider(
        create: (context) => AuthRepository.instance(),
        builder: (context, snapshot) {
         return Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
           Widget usernameTextField = ProfileTextField(
               "username",
               userNameController,
               firebaseController,
               isUserNameUnique,
               widget.userInfo);
           return GestureDetector(
             onTap: () {
               FocusScope.of(context).unfocus();
             },
             child: Scaffold(
               resizeToAvoidBottomInset: false,
               body: ListView(
                 shrinkWrap: true,
                 children: [
                   Container(
                     padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                     alignment: Alignment.topLeft,
                     child: IconButton(
                       icon: Icon(Icons.arrow_back),
                       iconSize: SizeConfig.blockSizeHorizontal * 8,
                       onPressed: () {
                         if (authRep.isNew()) {
                           authRep.signOut();
                           Navigator.of(context).popUntil((route) => route.isFirst);
                         } else
                           Navigator.of(context).pop();
                       },
                     ),
                   ),
                   SizedBox(
                     height: SizeConfig.blockSizeVertical * 2,
                   ),
                   Align(
                     child: Stack(
                       children: [
                         Hero(
                           tag: "profileImage",
                           child: GestureDetector(
                             onTap: () {
                               Navigator.of(context).push(MaterialPageRoute(
                                   builder: (context) => ShowImage(
                                     imageUrl: imageUrl,
                                     tag: "profileImage",
                                     title: "Profile Image",
                                   )));
                             },
                             child: CircleAvatar(
                               maxRadius: 85,
                               backgroundImage: NetworkImage(imageUrl),
                             ),
                           ),
                         ),
                         Positioned(
                             left: 112,
                             right: 0,
                             top: 120,
                             child: RawMaterialButton(
                               onPressed: () {
                                 uploadImage();
                               },
                               elevation: 1.0,
                               constraints:
                               BoxConstraints(maxHeight: 55, maxWidth: 55),
                               fillColor: Color(0xAFA66CB7),
                               child: Icon(
                                 Icons.camera_alt_outlined,
                                 color: Colors.white,
                                 size: 30.0,
                               ),
                               padding: EdgeInsets.all(15.0),
                               shape: CircleBorder(),
                             ))
                       ],
                       clipBehavior: Clip.none,
                     ),
                   ),
                   SizedBox(
                     height: authRep.isNew() ? 0 : SizeConfig.blockSizeVertical * 2,
                   ),
                   authRep.isNew()
                       ? SizedBox()
                       : Container(
                     width: SizeConfig.screenWidth * 0.7,
                     child: FittedBox(
                       fit: BoxFit.scaleDown,
                       child: SizedBox(
                         child: widget.userInfo!["username"] == null
                             ? SizedBox()
                             : Text(
                           widget.userInfo!["username"],
                           style: TextStyle(
                               fontSize: SizeConfig.screenWidth * 0.12,
                               fontWeight: FontWeight.bold),
                         ),
                       ),
                     ),
                   ),
                   SizedBox(
                     height: SizeConfig.blockSizeVertical * 7,
                   ),
                   Row(children: [
                     Text(
                       "             ABOUT",
                       style: TextStyle(
                         color: Colors.grey,
                       ),
                     ),
                   ]),
                   Divider(
                     indent: 35,
                     endIndent: 35,
                     thickness: 0.6,
                   ),
                   SizedBox(
                     height: SizeConfig.blockSizeVertical * 1.5,
                   ),
                   Form(
                     key: _formKey,
                     child: Column(children: [
                       Container(
                         margin: EdgeInsets.fromLTRB(
                             SizeConfig.blockSizeHorizontal * 10,
                             0,
                             SizeConfig.blockSizeHorizontal * 20,
                             0),
                         child: Column(
                           children: [
                             authRep.isNew()
                                 ? usernameTextField
                                 : SizedBox(),
                             //todo - maybe need to remove 2 of the usernameTextField. check!
                             Visibility(
                               visible: authRep.isNew(),
                               child: usernameTextField,
                             ),
                             usernameTextField,
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "first name",
                                 firstNameController,
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "last name",
                                 lastNameController,
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             Row(children: [
                               Text(
                                 "   Gender",
                                 style: TextStyle(
                                   color: Colors.grey,
                                 ),
                               ),
                             ]),
                             Row(
                               children: <Widget>[
                                 // SizedBox(
                                 //   width: 30,
                                 // ),
                                 Radio<String>(
                                   value: 'Male',
                                   activeColor: Color(0xFFA66CB7),
                                   groupValue: userGender,
                                   onChanged: (String? value) {
                                     setState(() {
                                       userGender = value!;
                                     });
                                   },
                                 ),
                                 Text("Male    "),
                                 Radio<String>(
                                   value: 'Female',
                                   activeColor: Color(0xFFA66CB7),
                                   groupValue: userGender,
                                   onChanged: (String? value) {
                                     setState(() {
                                       userGender = value!;
                                     });
                                   },
                                 ),
                                 Text("Female    "),
                               ],
                             ),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1,
                             ),
                             Container(
                               // height: 20,
                               padding: (isFinished && userGender == 'c')
                                   ? EdgeInsets.fromLTRB(
                                   0,
                                   0,
                                   SizeConfig.blockSizeHorizontal * 23,
                                   SizeConfig.blockSizeVertical * 3)
                                   : null,
                               child: (isFinished && userGender == 'c')
                                   ? Text(
                                 "You must pick a gender",
                                 style: TextStyle(color: Colors.red[800]),
                               )
                                   : null,
                             ),
                             // ProfileDatePicker(firebaseController, widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "country",
                                 countryController,
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "description",
                                 descController,
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                           ],
                         ),
                       ),
                       SizedBox(
                         height: SizeConfig.blockSizeVertical * 6,
                       ),
                       Row(children: [
                         Text(
                           "             CHAT PREFERENCES",
                           style: TextStyle(
                             color: Colors.grey,
                           ),
                         ),
                       ]),
                       Divider(
                         indent: 35,
                         endIndent: 35,
                         thickness: 0.6,
                       ),
                       SizedBox(
                         height: SizeConfig.blockSizeVertical * 1.5,
                       ),
                       Padding(
                         padding: EdgeInsets.fromLTRB(
                             SizeConfig.blockSizeHorizontal * 12, 0, 0, 0),
                         child: SizedBox(
                           height: SizeConfig.blockSizeVertical * 3.5,
                           child: Row(
                             children: [
                               Padding(
                                 padding: EdgeInsets.fromLTRB(
                                     0, 0, SizeConfig.blockSizeHorizontal * 2, 0),
                                 child: Text(
                                   "min age:",
                                   style: TextStyle(color: Colors.grey),
                                 ),
                               ),
                               AgeDropDown(
                                   "minAge", firebaseController, widget.userInfo),
                               Padding(
                                 padding: EdgeInsets.fromLTRB(
                                     SizeConfig.blockSizeHorizontal * 2,
                                     0,
                                     SizeConfig.blockSizeHorizontal * 2,
                                     0),
                                 child: Text(
                                   "max age:",
                                   style: TextStyle(color: Colors.grey),
                                 ),
                               ),
                               AgeDropDown(
                                   "maxAge", firebaseController, widget.userInfo),
                             ],
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 20,
                       ),
                       Container(
                         // height: 20,
                         padding: (isFinished && preferredGenderVal == 'c')
                             ? EdgeInsets.fromLTRB(
                             0,
                             0,
                             SizeConfig.blockSizeHorizontal * 40,
                             SizeConfig.blockSizeVertical * 2)
                             : null,
                         child: (isFinished &&
                             (ProfileVars.minAge == 1 ||
                                 ProfileVars.maxAge == 1))
                             ? Text(
                           "You must pick age range",
                           style: TextStyle(color: Colors.red[800]),
                         )
                             : null,
                       ),
                       SizedBox(
                         height: 20,
                       ),
                       Row(children: [
                         Text(
                           "             Preferred Gender",
                           style: TextStyle(
                             color: Colors.grey,
                           ),
                         ),
                       ]),
                       Row(
                         children: <Widget>[
                           SizedBox(
                             width: 30,
                           ),
                           Radio<String>(
                             value: 'Male',
                             activeColor: Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           Text("Male"),
                           Radio<String>(
                             value: 'Female',
                             activeColor: Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           Text("Female"),
                           Radio<String>(
                             value: 'Dont Care',
                             activeColor: Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           Text("Dont care"),
                         ],
                       ),
                       SizedBox(
                         height: SizeConfig.blockSizeVertical * 1,
                       ),
                       Container(
                         // height: 20,
                         padding: (isFinished && preferredGenderVal == 'c')
                             ? EdgeInsets.fromLTRB(
                             0,
                             0,
                             SizeConfig.blockSizeHorizontal * 27,
                             SizeConfig.blockSizeVertical * 2)
                             : null,
                         child: (isFinished && preferredGenderVal == 'c')
                             ? Text(
                           "You must pick a preferred gender",
                           style: TextStyle(color: Colors.red[800]),
                         )
                             : null,
                       ),
                       SizedBox(
                         height: 10,
                       ),
                       Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                         Text(
                           "             Languages",
                           style: TextStyle(
                             color: Colors.grey,
                           ),
                         ),
                       ]),
                       SizedBox(
                         height: 10,
                       ),
                       LanguageWidget("Arabic", firebaseController, widget.userInfo),
                       LanguageWidget("French", firebaseController, widget.userInfo),
                       LanguageWidget("German", firebaseController, widget.userInfo),
                       LanguageWidget("Hebrew", firebaseController, widget.userInfo),
                       LanguageWidget(
                           "Italian", firebaseController, widget.userInfo),
                       LanguageWidget(
                           "Portuguese", firebaseController, widget.userInfo),
                       LanguageWidget(
                           "Spanish", firebaseController, widget.userInfo),
                       SizedBox(
                         height: 5,
                       ),
                     ]),
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Container(
                     // height: 20,
                     padding: (isFinished &&
                         (ProfileVars.languageNum == 0 ||
                             ProfileVars.numOfLvls != ProfileVars.languageNum))
                         ? EdgeInsets.fromLTRB(
                         SizeConfig.blockSizeHorizontal * 9,
                         0,
                         SizeConfig.blockSizeHorizontal * 0,
                         SizeConfig.blockSizeVertical * 2)
                         : null,
                     child: isFinished
                         ? (ProfileVars.languageNum == 0
                         ? Text(
                       "You must pick at least one language",
                       style: TextStyle(color: Colors.red[800]),
                     )
                         : (ProfileVars.numOfLvls != ProfileVars.languageNum
                         ? Text(
                       "You must pick the level",
                       style: TextStyle(color: Colors.red[800]),
                     )
                         : null))
                         : null,
                   ),
                   Divider(
                     indent: 35,
                     endIndent: 35,
                     thickness: 0.6,
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   loadFinish
                       ? Center(child: CircularProgressIndicator())
                       : Container(
                     width: SizeConfig.screenWidth * 0.05,
                     child: Align(
                       child: ElevatedButton(
                           onPressed: () async {
                             changeLoadFinish();
                             if (authRep.isNew()) {
                               await checkUserNameUnique(
                                   userNameController.text);
                             }
                             pressedFinish();
                             if (_formKey.currentState!.validate() &&
                                 isUserNameUnique &&
                                 userGender != 'c' &&
                                 ProfileVars().validate()) {
                               finishedCreating(authRep);
                             } else {
                               await Future.delayed(
                                   Duration(milliseconds: 400));
                               changeLoadFinish();
                             }
                           },
                           child: Text(
                             "Finish",
                             style:
                             TextStyle(color: Colors.green, fontSize: 16),
                           ),
                           style: ButtonStyle(
                               minimumSize: MaterialStateProperty.all<Size>(
                                   Size(90, 35)),
                               backgroundColor:
                               MaterialStateProperty.all<Color>(
                                   Colors.white),
                               shape: MaterialStateProperty.all<
                                   RoundedRectangleBorder>(
                                   RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(13.0),
                                     side: BorderSide(
                                         color: Colors.black, width: 0.5),
                                   )))),
                     ),
                   ),
                   SizedBox(
                     height: 25,
                   ),
                 ],
               ),
             ),
           );
         });
        }));

  }

  pressedFinish() {
    setState(() {
      isFinished = true;
    });
  }

  changeLoadFinish() {
    setState(() {
      loadFinish = !loadFinish;
    });
  }

  found(String url) {
    imageUrl = url;
    setState(() {});
  }

  notFound(error) async {
    final ref = _storage.ref().child("userAvatars/defaultAvatar.jpeg");
    imageUrl = await ref.getDownloadURL();
    setState(() {});
  }

  uploadImage() async {
    print("noooooooooooo");
    final _picker = ImagePicker();
    PickedFile? image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      image = await _picker.getImage(source: ImageSource.gallery);
      if (image != null) {
        var file = File(image.path);
        TaskSnapshot uploadTask = await _storage
            .ref()
            .child("userAvatars/" + user!.uid)
            .putFile(file);
        String url = await uploadTask.ref.getDownloadURL();
        setState(() {
          imageUrl = url;
        });
      } else {
        final snackBar = SnackBar(
          content: Text('No image selected'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print("error");
    }
  }

  Future<void> checkUserNameUnique(String userName) async {
    setState(() {
      isUserNameUnique = true;
    });
    await FirebaseFirestore.instance.collection("users").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()["username"] == userName) {
          setState(() {
            isUserNameUnique = false;
          });
        }
      });
    });
  }

  Future<void> finishedCreating(AuthRepository authRep) async {
    if (authRep.isNew()) {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "email": user!.email,
        "UID": user!.uid,
        "URL": imageUrl,
        "Languages": {},
        "friends": [],
        "gender": userGender,
        "preferred gender": preferredGenderVal,
        "score" : 0,
      });
      firebaseController.add("finish");
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute<void>(builder: (BuildContext context) {
      //   return MyHomePage();
      // }));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({
        "Languages": {},
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({
        "URL": imageUrl,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({
        "gender": userGender,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"preferred gender": preferredGenderVal});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"username": widget.userInfo!["username"]});
      firebaseController.add("finish");
      Navigator.of(context).pop();
    }
    await Future.delayed(Duration(milliseconds: 500));
    authRep.setNotNew();
  }
}
