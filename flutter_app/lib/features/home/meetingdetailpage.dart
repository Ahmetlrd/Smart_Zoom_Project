import 'package:flutter/material.dart'; // Core Flutter UI library
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization helper (auto-generated from .arb files)

// A stateless widget to display meeting details
class MeetingDetailPage extends StatelessWidget {
  MeetingDetailPage({super.key});
  
  // Example static number, used for demonstration in button labels
  var number = 10;

  @override
  Widget build(BuildContext context) {
    // Access the localization instance for the current context
    var d = AppLocalizations.of(context);

    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Calculate responsive padding, font size, button height, and spacing
    final padding = screenWidth * 0.06;
    final fontSize = screenWidth * 0.045;
    final buttonHeight = screenHeight * 0.07;
    final verticalSpacing = screenHeight * 0.025;

    return Scaffold(
      appBar: Utility.buildAppBar(context), // Top app bar with title
      body: Padding(
        padding: EdgeInsets.all(padding), // Responsive padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the children
          children: [
            Divider(),
            SizedBox(height: 50,),
            Text(d!.meetingdetails,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)  ,
            SizedBox(height: 50,),
            Divider(),
            // Four buttons with localized labels and emoji
            _buildOption(context, "👥 ${d!.participants}$number", buttonHeight, fontSize, verticalSpacing),
            _buildOption(context, "📄 ${d.transcription}", buttonHeight, fontSize, verticalSpacing),
            _buildOption(context, "🧠 ${d.summary}", buttonHeight, fontSize, verticalSpacing),
            _buildOption(context, "📝 ${d.notes}", buttonHeight, fontSize, verticalSpacing),
          ],
        ),
      ),
    );
  }

  // A reusable function that creates an elevated button with given label
  Widget _buildOption(BuildContext context, String label, double height, double fontSize, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing), // Responsive vertical spacing
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(height)), // Responsive button height
        onPressed: () {
          // Shows a small notification at the bottom when button is clicked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Clicked: $label")),
          );
        },
        child: Text(label, style: TextStyle(fontSize: fontSize)), // Responsive font size
      ),
    );
  }
}
