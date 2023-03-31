import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/screen_size_config.dart';
import 'package:final_project_2023/Widgets/friends_list_widget.dart';
import 'add_friend.dart';

class FriendsList extends StatefulWidget {
  bool isSelectFriendPage;
  String selectedLanguage;

  FriendsList(this.isSelectFriendPage, {this.selectedLanguage = ""});

  @override
  State<StatefulWidget> createState() => FriendsListState(isSelectFriendPage);
}

class FriendsListState extends State<FriendsList> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  bool isSelectFriendPage = true;
  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.white,
    size: 30,
  );
  Widget _appBarTitle = Text(
    "Friends List",
    style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  );

  FriendsListState(bool val) {
    isSelectFriendPage = val;
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
    if (isSelectFriendPage) {
      this._appBarTitle = Text(
        "Select a Friend",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      );
    } else {
      this._appBarTitle = Text(
        "Friends List",
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF8F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(18.0),
            ),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 2,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      iconSize: SizeConfig.blockSizeHorizontal * 8,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _appBarTitle,
                        SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                  widget.isSelectFriendPage || this._searchIcon.icon == Icons.close
                      ? SizedBox()
                      : IconButton(
                      icon: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      iconSize: SizeConfig.blockSizeHorizontal * 8,
                      onPressed: () {
                        navigateToAddFriend(context);
                      }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: IconButton(
                      icon: _searchIcon,
                      onPressed: () {
                        _searchPressed();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListViewFriends(widget.isSelectFriendPage, _searchText,
          selectedLanguage: widget.selectedLanguage),
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(
          Icons.close,
          size: 30,
          color: Colors.white,
        );
        this._appBarTitle = Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.white),
          child: new TextField(
            autofocus: true,
            controller: _filter,
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
            cursorColor: Colors.white,
          ),
        );
      } else {
        this._searchIcon = new Icon(
          Icons.search,
          color: Colors.white,
          size: 30,
        );
        if (widget.isSelectFriendPage) {
          this._appBarTitle = Text(
            "Select a Friend",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          );
        } else {
          this._appBarTitle = Text(
            "Friends List",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          );
        }

        _filter.clear();
      }
    });
  }
}

// implementing the list

// navigating to add a friend
void navigateToAddFriend(context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriend()));
}
