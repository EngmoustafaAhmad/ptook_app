// lib/features/competitions/presintation/views/create_competition_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_state.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';

class CreateCompetitionView extends StatefulWidget {
  final VoidCallback onSuccess; // تم تمريرها لإعادة توجيه الـ Index في الـ Scaffold للرئيسية
  const CreateCompetitionView({super.key, required this.onSuccess});

  @override
  State<CreateCompetitionView> createState() => _CreateCompetitionViewState();
}

class _CreateCompetitionViewState extends State<CreateCompetitionView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController();
  
  String _selectedType = 'individual'; // أو 'team'
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CreateCompetitionCubit, CreateCompetitionState>(
          listener: (context, state) {
            if (state is CreateCompetitionSuccess) {
              context.showSuccess("Competition Launched Successfully! 🚀");
              widget.onSuccess(); // العودة للرئيسية بصرياً وانكماش زر الزائد
            } else if (state is CreateCompetitionError) {
              context.showError(state.message);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Create Competition", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    24.vs,

                    // 🔀 مفتاح تبديل الأفراد والفرق الاحترافي (Toggle Tabs)
                    Row(
                      children: [
                        _buildTypeTab('individual', Icons.person_outline, "Individuals"),
                        16.hs,
                        _buildTypeTab('team', Icons.group_outlined, "Teams"),
                      ],
                    ),
                    24.vs,

                    // 📝 حقول البيانات الأساسية
                    AuthTextField(
                      label: "Competition Name",
                      hintText: "e.g. Flutter Championship",
                      prefixIcon: Icons.emoji_events_outlined,
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? "Name is required" : null,
                    ),
                    16.vs,

                    AuthTextField(
                      label: "Description",
                      hintText: "Explain the competition rules...",
                      prefixIcon: Icons.description_outlined,
                      controller: _descController,
                      validator: (v) => v!.isEmpty ? "Description is required" : null,
                    ),
                    16.vs,

                    AuthTextField(
                      label: "Total Prize Points",
                      hintText: "e.g. 2500",
                      prefixIcon: Icons.star_border,
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null ? "Enter a valid number" : null,
                    ),
                    24.vs,

                    // 🌍 إعدادات الخصوصية (Public / Private)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Public Competition", style: TextStyle(color: Colors.white, fontSize: 16)),
                        Switch(
                          value: _isPublic,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isPublic = val),
                        ),
                      ],
                    ),
                    32.vs,

                    // 🎯 زر الإطلاق الحركي المضيء
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state is CreateCompetitionLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state is CreateCompetitionLoading
                            ? const CircularProgressIndicator(color: AppColors.background)
                            : const Text("Launch Competition 🚀", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeTab(String type, IconData icon, String label) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.background : Colors.grey),
              8.hs,
              Text(label, style: TextStyle(color: isSelected ? AppColors.background : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<CreateCompetitionCubit>().submitCompetition(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            type: _selectedType,
            totalPoints: int.parse(_pointsController.text.trim()),
            endDate: DateTime.now().add(const Duration(days: 7)).toIso8601String(), // تاريخ افتراضي بعد أسبوع
            maxParticipants: 100,
            isPublic: _isPublic,
          );
    }
  }
}