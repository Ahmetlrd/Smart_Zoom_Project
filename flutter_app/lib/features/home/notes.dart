import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: Utility.buildAppBar(context));
  }
}