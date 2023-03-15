import 'package:flutter/material.dart';

class SizeConfig {
  // Declare static variables to hold the device screen size information
  static late MediaQueryData _mediaQueryData; // Holds device screen size and orientation
  static late double screenWidth; // Holds the device screen width in logical pixels
  static late double screenHeight; // Holds the device screen height in logical pixels
  static late double blockSizeHorizontal; // Holds the width of one "block" of the screen in logical pixels
  static late double blockSizeVertical; // Holds the height of one "block" of the screen in logical pixels
  static late double blockSizeHorizontal_30; // Holds the width of 30% of the screen in logical pixels

  // A method to initialize the SizeConfig variables based on the current device screen size
  void init(BuildContext context) {
    // Get the MediaQueryData object from the current context
    _mediaQueryData = MediaQuery.of(context);
    // Set the screenWidth and screenHeight variables based on the size property of the MediaQueryData object
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    // Calculate the blockSizeHorizontal and blockSizeVertical variables as the screen width and height divided by 100
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    // Calculate the blockSizeHorizontal_30 variable as 30% of the screen width (i.e., 30 blocks)
    blockSizeHorizontal_30 = blockSizeHorizontal * 30;
  }
}
