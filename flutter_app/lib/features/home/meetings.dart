import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';

class Meetings extends StatelessWidget {
  const Meetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: Utility.buildAppBar(context));
  }
}
