import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class Userinfo extends ConsumerWidget {
  const Userinfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.read(authProvider.notifier).userInfo;
    final isLoggedIn = ref.watch(authProvider);
    final d = AppLocalizations.of(context)!;

    if (!isLoggedIn || userInfo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final spacing = screenHeight * 0.03;

    final userType = userInfo['type'];
    final userTypeText = userType == 2
        ? 'Zoom Pro'
        : userType == 1
            ? 'Zoom Free (Basic)'
            : 'Unknown';

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            width: double.infinity,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("pictures/Blue Gradient Background Poster.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // İçerik kutusu
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: screenWidth < 600 ? screenWidth * 0.95 : 550,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            color: Colors.grey.shade800,
            onPressed: () => context.go('/settings'),
          ),
        ),
        Center(
          child: Text(
            d.userinfo, 
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    Image.asset('pictures/appicon_1.png', height: 60),
    const SizedBox(height: 16),
    const SizedBox(height: 24),

                      CircleAvatar(
                        radius: 48,
                        backgroundImage: userInfo['pic_url'] != null
                            ? NetworkImage(userInfo['pic_url'])
                            : const AssetImage('pictures/avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${userInfo['first_name']} ${userInfo['last_name']}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userInfo['email'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_user, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            "${d.accounttype} ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userTypeText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 1.5),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                            context.go('/');
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(d.logout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
