class Module{

  String name = "";
  String description = "";
  int id = 0;

  Module(this.name, this.description, this.id);

  toJson(){
    return {
      "name" : name,
      "description" : description,
      "id" : id
    };
  }

}