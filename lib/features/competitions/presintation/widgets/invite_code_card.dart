import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

class InviteCodeCard extends StatelessWidget {
  final String? inviteCode;

  const InviteCodeCard({this.inviteCode});

  @override
  Widget build(BuildContext context) {
    if (inviteCode == null || inviteCode!.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Invite Code",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              4.vs,
              Text(
                inviteCode!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invite code copied!")),
              );
            },
            icon: const Icon(Icons.copy, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}