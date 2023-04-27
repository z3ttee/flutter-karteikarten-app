
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModuleTitle extends StatefulWidget {
  final String moduleName;

  const ModuleTitle({
    super.key,
    required this.moduleName
  });

  @override
  State<StatefulWidget> createState() {
    return _ModuleStatsSectionState();
  }

}

class _ModuleStatsSectionState extends State<ModuleTitle> {

  int titleClicks = 0;

  /// Show credits
  _showTitle() {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text("DHGE Karteikarten App"),
        content: Text("Developed by Cedric & Robert"),
      )
    );
  }

  @override
  void initState() {
    super.initState();
    titleClicks = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(widget.moduleName),
      onTap: () {
        titleClicks++;
        if(titleClicks >= 8) {
          /// Show credits after 8 clicks on module name
          titleClicks = 0;
          _showTitle();
        }
      },
    );
  }

}