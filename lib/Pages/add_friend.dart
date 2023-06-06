import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/consts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_2023/firebase/FirebaseDB.dart';
import 'package:tuple/tuple.dart';
import '../screen_size_config.dart';
import 'view_user_profile.dart';

class AddFriend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddFriendState();
}

class AddFriendState extends State<AddFriend> {
  final TextEditingController searchUsername = TextEditingController();
  var user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  bool isNotEmpty = false;
  List users = []; // users we get from API
  List filteredUsers = []; // users filtered by search text
  bool isFriend = false;
  final Widget _appBarTitle = const Text(
    "Add a Friend",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(18.0),
            ),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 2,
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      iconSize: SizeConfig.blockSizeHorizontal * 8,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _appBarTitle,
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  controller: searchUsername,
                  cursorColor: PURPLE_COLOR,
                  decoration: InputDecoration(
                    hintText: USERNAME,
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: PURPLE_COLOR,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      setState(() {
                        isNotEmpty = false;
                      });
                      return EMPTY_TEXT;
                    }
                    return null;
                  },
                ),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF6D94BE)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _buildList();
                  setState(() {
                    isNotEmpty = true;
                  });
                }
              },
              child: const Text(
                SEARCH,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Visibility(
                visible: isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 0, 25),
                  child: Text("Results for \"${searchUsername.text}\":",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Visibility(
                  visible: isNotEmpty && filteredUsers.isEmpty,
                  child: Text("There is no such user",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Visibility(
                  visible: isNotEmpty,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                    itemCount: users.isEmpty ? 0 : filteredUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      isFriend = filteredUsers[index].item2;
                      return createUserListTile(filteredUsers[index]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUsers() async {
    final user = FirebaseAuth.instance.currentUser;
    List friendsList = (await FirebaseFirestore.instance
        .collection(USERS)
        .doc(user!.uid)
        .get())
        .data()![FRIENDS];
    List tempList = [];
    await FirebaseFirestore.instance
        .collection(USERS)
        .orderBy(USERNAME)
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.id != user.uid) {
          if (friendsList.contains(element.data()[USERNAME])) {
            tempList.add(Tuple2(element.data(),
                true)); // item2 here is if this user already friend
          } else {
            tempList.add(Tuple2(element.data(), false));
          }
        }
      }
      setState(() {
        users = tempList;
      });
    });
  }

  ListTile createUserListTile(Tuple2 userInfo) {
    isFriend = userInfo.item2;
    return ListTile(
      dense: true,
      tileColor: const Color(0xFFF8F5F5),
      title: Text(
        userInfo.item1[USERNAME],
        style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 5),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ViewUserProfile(userInfo.item1["UID"])));
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(userInfo.item1["URL"]),
          maxRadius: 20,
        ),
      ),
      trailing: isFriend
          ? const Icon(Icons.check, size: 35, color: Color(0xFF6D94BE))
          : IconButton(
        icon: const Icon(Icons.person_add_alt_1_outlined,
            size: 25, color: Color(0xFF6D94BE)),
        onPressed: () async {
          await FirebaseDB.Firebase_db.addFriend(
              userInfo.item1[USERNAME], context);
          _buildList();
        },
      ),
    );
  }

  void _buildList() async {
    await getUsers();
    filteredUsers = users;
    List tempList = [];
    for (int i = 0; i < filteredUsers.length; i++) {
      if (filteredUsers[i]
          .item1[USERNAME]
          .toLowerCase()
          .contains(searchUsername.text.toLowerCase())) {
        tempList.add(filteredUsers[i]);
      }
    }
    setState(() {
      filteredUsers = tempList;
    });
  }
}
