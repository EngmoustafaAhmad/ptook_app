// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
// import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

// class EditableMemberRow extends StatelessWidget {
//   final String competitionId;
//   final String teamId;
//   final ParticipantEntity member;
//   final String rank;
//   final bool isFinished;
//   final VoidCallback onDelete;

//   const EditableMemberRow({
//     super.key,
//     required this.competitionId,
//     required this.teamId,
//     required this.member,
//     required this.rank,
//     required this.isFinished,
//     required this.onDelete,
//   });

//   void _updatePoints(BuildContext context, int delta) {
//     if (member.points + delta < 0) return;

//     context.read<TeamManagementCubit>().updateMemberPoints(
//           competitionId: competitionId,
//           teamId: teamId,
//           memberId: member.id,
//           deltaPoints: delta,
//         );
//   }

//   void _showEditPointsDialog(BuildContext context) {
//     final controller = TextEditingController(text: member.points.toString());
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: const Color(0xFF161925),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Edit Points for ${member.name}',
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         ),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           autofocus: true,
//           style: const TextStyle(color: Colors.white),
//           decoration: const InputDecoration(
//             labelText: 'Points',
//             labelStyle: TextStyle(color: Colors.white70),
//             enabledBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Color(0xFFFFC107)),
//             ),
//             focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Color(0xFFFFC107)),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFFC107),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             onPressed: () {
//               final newPoints = int.tryParse(controller.text.trim());
//               if (newPoints != null && newPoints >= 0) {
//                 final delta = newPoints - member.points.toInt();
//                 if (delta != 0) {
//                   context.read<TeamManagementCubit>().updateMemberPoints(
//                         competitionId: competitionId,
//                         teamId: teamId,
//                         memberId: member.id,
//                         deltaPoints: delta,
//                       );
//                 }
//               }
//               Navigator.pop(dialogContext);
//             },
//             child: const Text(
//               'Save',
//               style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text(
//             rank,
//             style: const TextStyle(color: Colors.white38, fontSize: 12),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               member.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 13,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
          
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (!isFinished)
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle_outline, color: Colors.white38, size: 18),
//                   onPressed: () => _updatePoints(context, -1),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   splashRadius: 16,
//                 ),
//               InkWell(
//                 onTap: isFinished ? null : () => _showEditPointsDialog(context),
//                 borderRadius: BorderRadius.circular(4),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   child: Text(
//                     '${member.points} pts',
//                     style: TextStyle(
//                       color: const Color(0xFFFFC107),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                       decoration: isFinished ? TextDecoration.none : TextDecoration.underline,
//                       decorationStyle: TextDecorationStyle.dashed,
//                     ),
//                   ),
//                 ),
//               ),
//               if (!isFinished) ...[
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107), size: 18),
//                   onPressed: () => _updatePoints(context, 1),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   splashRadius: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
//                   onPressed: onDelete,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   splashRadius: 16,
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }