import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';

class Userinfo extends ConsumerWidget {
  const Userinfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final userInfo = ref.read(authProvider.notifier).userInfo;
    final d = AppLocalizations.of(context);

    if (userInfo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final spacing = screenHeight * 0.03;
    final buttonWidth = screenWidth * 0.5;
    final userType = userInfo['type'];
    final userTypeText = userType == 2
        ? 'Zoom Pro'
        : userType == 1
            ? 'Zoom Free (Basic)'
            : 'Unknown';

    return Scaffold(
      appBar: Utility.buildAppBar(context, disableSettings: true),
      backgroundColor: const Color(0xFFF7F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: isLoggedIn && userInfo['pic_url'] != null
                    ? NetworkImage(userInfo['pic_url'])
                    : const AssetImage('pictures/avatar.png') as ImageProvider,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                "${userInfo['first_name']} ${userInfo['last_name']}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                d!.email,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userInfo['email'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Divider(thickness: 1.2, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${d.accounttype}: ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: userTypeText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 2),
              if (isLoggedIn)
                SizedBox(
                  width: buttonWidth,
                  height: screenHeight * 0.07,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      context.go('/');
                    },
                    label: Text(
                      d.logout,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }
}
