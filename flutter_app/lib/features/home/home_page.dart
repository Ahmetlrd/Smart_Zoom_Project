import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCard(
                icon: Icons.calendar_today,
                label: "Meeting List",
                onTap: () => context.push('/meetinglist'),
              ),
              _buildCard(
                icon: Icons.connect_without_contact,
                label: "Meeting Details",
                onTap: () => context.push('/meetingdetailpage'),
              ),
              _buildCard(
                icon: Icons.auto_awesome,
                label: "NLP Summary",
                onTap: () => context.push('/nlp'),
              ),
              _buildCard(
                icon: Icons.note,
                label: "Saved Summaries",
                onTap: () => context.push('/saved'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
