class Card{

  String question = "";
  String answer = "";
  bool lastCorrect = false;

  //Card([this.question = "", this.answer = ""]);
  Card(this.question , this.answer);

  toJson(){
    return {
      "question": question,
      "answer": answer,
      "lastCorrect" : lastCorrect
    };
  }
}


