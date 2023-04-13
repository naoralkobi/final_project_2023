class Question{
  List<String> answers =[];
  String? correctAnswer;
  String? questionBody;
  String? type;


  Map<String, dynamic> toJson() =>{
    'answers' : answers,
    'correctAnswer' : correctAnswer,
    'questionBody' : questionBody,
    'type' : type,
  };

}