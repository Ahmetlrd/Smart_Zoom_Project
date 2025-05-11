import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_app/providers/auth_provider.dart'; // Authentication state management

class Userinfo extends ConsumerWidget {
  const Userinfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final userInfo = ref.read(authProvider.notifier).userInfo;
    // If userInfo is null (e.g. token expired), redirect to login page
    if (userInfo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }
    // Update dropdown selection based on current locale

    // Responsive ölçüler hesaplanıyor
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final d = AppLocalizations.of(context); // Localized strings

    final iconSize = screenWidth * 0.12;
    final fontSize = screenWidth * 0.045;
    final horizontalPadding = screenWidth * 0.1;
    final dropdownWidth = screenWidth * 0.3;
    final buttonWidth = screenWidth * 0.5;
    final spacing = screenHeight * 0.02;
    final userType = userInfo!['type'];
    final userTypeText = userType == 2
        ? 'Zoom Pro'
        : userType == 1
            ? 'Zoom Free (Basic)'
            : 'Unknown';
    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 170.0, bottom: 10),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: isLoggedIn && userInfo?['pic_url'] != null
                    ? NetworkImage(userInfo!['pic_url'])
                    : const AssetImage('pictures/avatar.png') as ImageProvider,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(userInfo!['first_name'], style: TextStyle(fontSize: 30)),
            Text(
              userInfo!['last_name'],
              style: TextStyle(fontSize: 30),
            ),
            Divider(),
            Text(
              d!.email,
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              userInfo['email'],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Divider(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: d!.accounttype,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  TextSpan(
                    text: userTypeText,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            // Logout button if user is logged in
            if (isLoggedIn)
              SizedBox(
                width: buttonWidth,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  child: Text(d!.logout,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }
}
