import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Nlp extends StatelessWidget {
  const Nlp({super.key});

  @override
  Widget build(BuildContext context) {
            var d = AppLocalizations.of(context);

    return Scaffold(appBar: Utility.buildAppBar(context));
  }
}