import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/Pages/show_image.dart';
import 'package:final_project_2023/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
 import 'package:provider/provider.dart';
 import 'package:final_project_2023/screen_size_config.dart';
 import 'dart:io';
 import '../FireBase/auth_repository.dart';
import '../profile_vars.dart';
import '../Widgets/age_drop_down.dart';
import '../Widgets/languageWidget.dart';
import '../Widgets/profile_date.dart';
import '../Widgets/profile_text_field.dart';
import 'home_page.dart';
import 'package:final_project_2023/consts.dart';
import 'package:file_picker/file_picker.dart';
/// This code file is responsible for the Create Profile Page,
/// where users can create their profile and set preferences.

// Class representing the Create Profile Page
class CreateProfilePage extends StatefulWidget {
  Map? userInfo;

  CreateProfilePage(this.userInfo);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

// State class for the Create Profile Page
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
  String preferredGenderVal = 'c'; // Default preferred gender value
  String userGender = 'c'; // Default user gender value
  bool isUserNameValid = true;
  bool loadFinish = false;
  bool firstClick = true; // Flag to check if it's the first time clicking

  @override
  void initState() {
    super.initState();
    ProfileVars().init();
    imageUrl = "";
    // Get the download URL of the user's profile image
    _storage
        .ref()
        .child("userAvatars/${user!.uid}")
        .getDownloadURL()
        .then(found, onError: notFound);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // If user info is provided and it's the first time clicking, update gender values
    if (widget.userInfo!.isNotEmpty && firstClick) {
      userGender = widget.userInfo!["gender"];
      preferredGenderVal = widget.userInfo!["preferred gender"];
      firstClick = false;
    }
    return (ChangeNotifierProvider(
        create: (context) => AuthRepository.instance(),
        builder: (context, snapshot) {
         return Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
           // Widget for the username text field
           Widget usernameTextField = ProfileTextField(
             "username", // Placeholder text for the text field
             userNameController, // Controller to manage the text field value
             firebaseController, // Stream controller for real-time validation
             isUserNameUnique, // Flag to indicate if the username is unique
             widget.userInfo, // User information (if available) for pre-filling the field
           );
           return GestureDetector(
             onTap: () {
               // When the user taps on the screen, unfocus any text field that has focus.
               FocusScope.of(context).unfocus();
             },
             child: Scaffold(
               resizeToAvoidBottomInset: false,
               body: ListView(
                 shrinkWrap: true,
                 children: [
                   // Container for the back button
                   Container(
                     padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                     alignment: Alignment.topLeft,
                     child: IconButton(
                       icon: const Icon(Icons.arrow_back),
                       iconSize: SizeConfig.blockSizeHorizontal * 8,
                       onPressed: () {
                         // If the user is new (creating a new account),
                         // sign out and navigate to the home screen.
                         // Otherwise, go back to the previous screen.
                         if (authRep.isNew()) {
                           authRep.signOut();
                           Navigator.of(context).popUntil((route) => route.isFirst);
                         } else {
                           Navigator.of(context).pop();
                         }
                       },
                     ),
                   ),
                   SizedBox(
                     height: SizeConfig.blockSizeVertical * 2,
                   ),
                   // Profile Image
                   Align(
                     child: Stack(
                       clipBehavior: Clip.none,
                       children: [
                         Hero(
                           tag: "profileImage",
                           child: GestureDetector(
                             onTap: () {
                               // When the user taps on the profile image, navigate to a screen to view the image.
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
                                 // When the user taps on the camera button,
                                 // upload a new profile image.
                                 uploadImage();
                               },
                               elevation: 1.0,
                               constraints:
                               const BoxConstraints(maxHeight: 55, maxWidth: 55),
                               fillColor: const Color(0xAFA66CB7),
                               padding: const EdgeInsets.all(15.0),
                               shape: const CircleBorder(),
                               child: const Icon(
                                 Icons.camera_alt_outlined,
                                 color: Colors.white,
                                 size: 30.0,
                               ),
                             ))
                       ],
                     ),
                   ),
                   SizedBox(
                     height: authRep.isNew() ? 0 : SizeConfig.blockSizeVertical * 2,
                   ),
                   authRep.isNew()
                       ? const SizedBox()
                       : SizedBox(
                     width: SizeConfig.screenWidth * 0.7,
                       child: FittedBox(
                         fit: BoxFit.scaleDown,
                         child: SizedBox(
                           child: widget.userInfo!["username"] == null
                               ? Container()
                               : Text(
                             widget.userInfo!["username"],
                             style: TextStyle(
                                 fontSize: SizeConfig.screenWidth * 0.12,
                                 fontWeight: FontWeight.bold),
                           ),
                         ),
                       ),
                   ),
                   // About section
                   SizedBox(
                     height: SizeConfig.blockSizeVertical * 7,
                   ),
                   Row(children: [
                     Text(
                       "             ABOUT",
                       style:TextStyle(
                         color: Colors.grey[700],
                         fontSize: 16,
                       ),
                     ),
                   ]),
                   const Divider(
                     indent: 35,
                     endIndent: 35,
                     thickness: 0.8,
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
                             // Username Text Field (for new users)
                             // authRep.isNew()
                             //     ? usernameTextField
                             //     : SizedBox(), // Display the username text field only for new users
                             // //todo - maybe need to remove 2 of the usernameTextField. check!
                             // Visibility(
                             //   visible: authRep.isNew(), // Set the visibility of the widget based on whether the user is new or not
                             //   child: usernameTextField, // Display the username text field if the user is new
                             // ),
                             usernameTextField, // Display the username text field
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "first name",  // Label for the text field
                                 firstNameController, // Controller for the text field
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "last name", // Label for the text field
                                 lastNameController, // Controller for the text field
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             Row(children: [
                               Text(
                                 "   Gender", // Label for the gender selection
                                 style: TextStyle(
                                   color: Colors.grey[700],
                                   fontSize: 16,
                                 ),
                               ),
                             ]),
                             Row(
                               children: <Widget>[
                                 // SizedBox(
                                 //   width: 30,
                                 // ),
                                 Radio<String>(
                                   value: 'Male', // Value for the male gender
                                   activeColor: const Color(0xFFA66CB7),
                                   groupValue: userGender, // Currently selected gender
                                   onChanged: (String? value) {
                                     setState(() {
                                       userGender = value!; // Update the selected gender
                                     });
                                   },
                                 ),
                                 const Text("Male    "),
                                 Radio<String>(
                                   value: 'Female', // Value for the female gender
                                   activeColor: const Color(0xFFA66CB7),
                                   groupValue: userGender, // Currently selected gender
                                   onChanged: (String? value) {
                                     setState(() {
                                       userGender = value!; // Update the selected gender
                                     });
                                   },
                                 ),
                                 const Text("Female    "),
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
                                 "You must pick a gender",  // Error message if gender is not selected
                                 style: TextStyle(color: Colors.red[800]),
                               )
                                   : null,
                             ),
                              ProfileDatePicker(firebaseController, widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "country", // Label for the text field
                                 countryController, // Controller for the text field
                                 firebaseController,
                                 isUserNameUnique,
                                 widget.userInfo),
                             SizedBox(
                               height: SizeConfig.blockSizeVertical * 1.5,
                             ),
                             ProfileTextField(
                                 "description", // Label for the text field
                                 descController, // Controller for the text field
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
                           "             CHAT PREFERENCES", // Label for the chat preferences section
                           style: TextStyle(
                             color: Colors.grey[700],
                             fontSize: 16,
                           ),
                         ),
                       ]),
                       const Divider(
                         indent: 35,
                         endIndent: 35,
                         thickness: 0.8,
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
                                   style: TextStyle(
                                     color: Colors.grey[700],
                                     fontSize: 16,
                                   ),
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
                                   style:TextStyle(
                                     color: Colors.grey[700],
                                     fontSize: 16,
                                   ),
                                 ),
                               ),
                               AgeDropDown(
                                   "maxAge", firebaseController, widget.userInfo),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(
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
                       const SizedBox(
                         height: 20,
                       ),
                       Row(children: [
                         Text(
                           "             Preferred Gender",
                           style: TextStyle(
                             color: Colors.grey[700],
                             fontSize: 16,
                           ),
                         ),
                       ]),
                       Row(
                         children: <Widget>[
                           const SizedBox(
                             width: 30,
                           ),
                           Radio<String>(
                             value: 'Male',
                             activeColor: const Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           const Text("Male"),
                           Radio<String>(
                             value: 'Female',
                             activeColor: const Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           const Text("Female"),
                           Radio<String>(
                             value: "Don't Care",
                             activeColor: const Color(0xFFA66CB7),
                             groupValue: preferredGenderVal,
                             onChanged: (String? value) {
                               setState(() {
                                 preferredGenderVal = value!;
                               });
                             },
                           ),
                           const Text("Don't care"),
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
                       const SizedBox(
                         height: 10,
                       ),
                       Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                         Text(
                           "             Languages", // Label for the languages section
                           style: TextStyle(
                             color: Colors.grey[700],
                             fontSize: 16,
                           ),
                         ),
                       ]),
                       const SizedBox(
                         height: 10,
                       ),
                       LanguageWidget("Arabic", firebaseController, widget.userInfo), // Language widget for Arabic
                       LanguageWidget("French", firebaseController, widget.userInfo), // Language widget for French
                       LanguageWidget("German", firebaseController, widget.userInfo), // Language widget for German
                       LanguageWidget("Hebrew", firebaseController, widget.userInfo), // Language widget for Hebrew
                       LanguageWidget("Italian", firebaseController, widget.userInfo), // Language widget for Italian
                       LanguageWidget("Portuguese", firebaseController, widget.userInfo), // Language widget for Portuguese
                       LanguageWidget("Spanish", firebaseController, widget.userInfo), // Language widget for Spanish
                       const SizedBox(
                         height: 5,
                       ),
                     ]),
                   ),
                   const SizedBox(
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
                       "You must pick at least one language", // Error message if no language is selected
                       style: TextStyle(color: Colors.red[800]),
                     )
                         : (ProfileVars.numOfLvls != ProfileVars.languageNum
                         ? Text(
                       "You must pick the level", // Error message if the level is not selected for all languages
                       style: TextStyle(color: Colors.red[800]),
                     )
                         : null))
                         : null,
                   ),
                   const Divider(
                     indent: 35,
                     endIndent: 35,
                     thickness: 0.8,
                   ),
                   const SizedBox(
                     height: 10,
                   ),
                   loadFinish
                       ? const Center(child: CircularProgressIndicator()) // Display a loading indicator if the 'loadFinish' variable is true
                       : SizedBox(
                     width: SizeConfig.screenWidth * 0.05,
                     child: Align(
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           primary: MAIN_BLUE_COLOR,
                           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(30), // if you need to add a border radius
                           ),
                         ),
                         onPressed: () async {
                           changeLoadFinish();
                           if (authRep.isNew()) {
                             await checkUserNameUnique(userNameController.text);
                           }
                           pressedFinish();
                           if (_formKey.currentState!.validate() &&
                               isUserNameUnique &&
                               userGender != 'c' &&
                               ProfileVars().validate()) {
                             finishedCreating(authRep);
                           } else {
                             await Future.delayed(const Duration(milliseconds: 400));
                             changeLoadFinish();
                           }
                         },
                         child: const Text(
                           "Finish",
                           style: TextStyle(color: Colors.white),
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(
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
    // Function to handle the finish button press

    setState(() {
      isFinished = true;
    });
  }


  changeLoadFinish() {
    // Function to toggle the value of the loadFinish state variable

    setState(() {
      loadFinish = !loadFinish;
    });
  }


  found(String url) {
    // Callback function executed when an image URL is found

    imageUrl = url;
    setState(() {});
  }

  notFound(error) async {
    // Callback function executed when an image URL is not found

    final ref = _storage.ref().child("userAvatars/defaultAvatar.jpeg");
    imageUrl = await ref.getDownloadURL();
    setState(() {});
  }

  uploadImage() async {
    // Function to upload an image selected from the device's gallery
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      // If an image is selected, create a File object from the selected image's path
      var file = File(result.files.single.path!);

      // Upload the file to Firebase Storage using a reference path based on the user's UID
      TaskSnapshot uploadTask = await _storage
          .ref()
          .child("userAvatars/" + user!.uid)
          .putFile(file);

      // Retrieve the download URL of the uploaded image
      String url = await uploadTask.ref.getDownloadURL();

      // Update the state variable with the image URL
      setState(() {
        imageUrl = url;
      });
    } else {
      // If no image is selected, display a snackbar with a message
      final snackBar = SnackBar(
        content: Text('No image selected'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  Future<void> checkUserNameUnique(String userName) async {
    // Function to check if the provided username is unique in the Firestore collection

    setState(() {
      // Update the state variable to indicate that the username is initially assumed to be unique
      isUserNameUnique = true;
    });

    // Query the Firestore collection "users" to retrieve all documents
    await FirebaseFirestore.instance.collection("users").get().then((value) {
      // Iterate over each document in the query result
      value.docs.forEach((element) {
        // Check if the "username" field in the document matches the provided username
        if (element.data()["username"] == userName) {
          setState(() {
            // Update the state variable to indicate that the username is not unique
            isUserNameUnique = false;
          });
        }
      });
    });
  }


  Future<void> finishedCreating(AuthRepository authRep) async {
    // Function to handle the completion of profile creation

    if (authRep.isNew()) {
      // If the user is new and creating a profile for the first time
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        // Set the user data in the "users" collection in Firestore
        "email": user!.email,
        "UID": user!.uid,
        "URL": imageUrl,
        "Languages": {},
        "friends": [],
        "gender": userGender,
        "preferred gender": preferredGenderVal,
        "score": 0,
      });

      firebaseController.add("finish");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) {
          return MyHomePage();
        }),
            (route) => false,
      );

    } else {
      // If the user is updating an existing profile
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        // Update the user data in the "users" collection in Firestore
        "Languages": {},
      });

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "URL": imageUrl,
      });

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "gender": userGender,
      });

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "preferred gender": preferredGenderVal,
      });

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "username": widget.userInfo!["username"],
      });

      firebaseController.add("finish");

      // Navigate back to the previous screen
      Navigator.of(context).pop();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Set the user as not new
    authRep.setNotNew();
  }

}
