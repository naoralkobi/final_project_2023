// import 'package:flutter/cupertino.dart';
// import 'package:test/test.dart';
// import 'package:final_project_2023/Pages/questions_page.dart';
//
// void main() {
//   group('Questions Page Test', () {
//     test('shuffle should randomize list order', () {
//       var qp = QuestionsPageState(Map());
//       var items = [1, 2, 3, 4, 5];
//       var shuffled = qp.shuffle(items);
//       expect(shuffled, isNot(equals(items)));
//     });
//
//     test('getBodyWidget should return an image for "What\'s in the picture"', () {
//       var qp = QuestionsPageState(Map());
//       var widget = qp.getBodyWidget("What's in the picture", "someUrl");
//       expect(widget.runtimeType, equals(Container));
//       expect(widget.child.runtimeType, equals(ClipRRect));
//       expect(widget.child.child.runtimeType, equals(Image.network));
//     });
//   });
// }
