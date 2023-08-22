
import 'dart:convert';

ActionModel actionModelFromJson(String str) =>
    ActionModel.fromJson(json.decode(str));


class ActionModel {
  final String id;
  final ActionTypeTask typeTask;
  final String nextId;
  final List<AnswerModel> answerList;
  final String question;

  ActionModel({
    required this.id,
    required this.typeTask,
    required this.nextId,
    required this.answerList,
    required this.question,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) => ActionModel(
        id: json["id"],
        typeTask: getTypeTaskByString(json["type_task"]),
        // on fetch
        nextId: json["next_id"],
        answerList: List<AnswerModel>.from(
            json["answer_list"].  map((x) => AnswerModel.fromJson(x))),
        question: json["question"],
      );

}

class AnswerModel {
  final String text;
  final String goTo;

  AnswerModel({
    required this.text,
    required this.goTo,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
        text: json["text"],
        goTo: json["go_to"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "go_to": goTo,
      };
}

enum ActionTypeTask {
  select,
  freeText,
  appeal,
  speech,
}

ActionTypeTask getTypeTaskByString(String value) {
  switch (value) {
    case "select":
      return ActionTypeTask.select;
    case "freetext":
      return ActionTypeTask.freeText;
    case "appeal":
      return ActionTypeTask.appeal;
    case "speech":
      return ActionTypeTask.speech;
    default:
      return ActionTypeTask.select;
  }
}