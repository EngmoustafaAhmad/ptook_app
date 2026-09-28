// features/create_competition/presentation/views/create_competition_view.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/app_scaffold.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/core/utils/power_guard.dart'; // ⚡ PowerGuard Utility
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_cubit.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_state.dart';

enum CompetitionType { individual, team }

class CreateCompetitionView extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateCompetitionView({
    super.key,
    this.onSuccess,
  });

  @override
  State<CreateCompetitionView> createState() => _CreateCompetitionViewState();
}

class _CreateCompetitionViewState extends State<CreateCompetitionView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _pointsController;
  late final TextEditingController _participantsController;
  late final TextEditingController _maxTeamsController;
  late final TextEditingController _membersController;
  late final TextEditingController _joinCodeController;
  late final TextEditingController _linkUrlController;

  CompetitionType _selectedType = CompetitionType.individual;
  bool _isPublic = true;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  static const List<String> _categories = [
    'Programming',
    'Mobile Development',
    'Web Development',
    'Artificial Intelligence',
    'Machine Learning',
    'Cyber Security',
    'Data Science',
    'UI/UX Design',
    'Algorithms',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _pointsController = TextEditingController();
    _participantsController = TextEditingController();
    _maxTeamsController = TextEditingController();
    _membersController = TextEditingController();
    _joinCodeController = TextEditingController();
    _linkUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _participantsController.dispose();
    _maxTeamsController.dispose();
    _membersController.dispose();
    _joinCodeController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descController.clear();
    _pointsController.clear();
    _participantsController.clear();
    _maxTeamsController.clear();
    _membersController.clear();
    _joinCodeController.clear();
    _linkUrlController.clear();

    context.read<CreateCompetitionCubit>().clearImage();

    setState(() {
      _selectedType = CompetitionType.individual;
      _isPublic = true;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: initialDate,
    );

    if (date == null || !mounted) return;

    setState(() {
      if (isStartDate) {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = date;
      }
    });
  }

  void _onTypeChanged(CompetitionType type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      if (_selectedType == CompetitionType.team) {
        _isPublic = true;
      }
    });
  }

  void _submit() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      context.showError('Please log in first.');
      return;
    }

    final cubit = context.read<CreateCompetitionCubit>();
    if (cubit.state is CreateCompetitionLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      context.showError('Please select both start and end dates');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      context.showError('End date cannot be before start date');
      return;
    }

    int maxParticipants = 0;
    int? maxTeams;
    int? membersPerTeam;

    if (_selectedType == CompetitionType.individual) {
      maxParticipants = int.parse(_participantsController.text.trim());
    } else {
      maxTeams = int.parse(_maxTeamsController.text.trim());
      membersPerTeam = int.parse(_membersController.text.trim());
      maxParticipants = maxTeams * membersPerTeam;
    }

    FocusScope.of(context).unfocus();

    // ⚡ Execute Power Guard Check Before Submitting
    PowerGuard.executeWithPowerCheck(
      context: context,
      userId: currentUserId,
      onPowerAvailable: () async {
        cubit.submitCompetition(
          status: 'active',
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          type: _selectedType.name,
          totalPoints: int.parse(_pointsController.text.trim()),
          startDate: _startDate!,
          endDate: _endDate!,
          maxParticipants: maxParticipants,
          isPublic: _selectedType == CompetitionType.individual ? _isPublic : true,
          category: _selectedCategory!,
          maxTeams: maxTeams,
          membersPerTeam: membersPerTeam,
          joinCode: !_isPublic ? _joinCodeController.text.trim() : null,
          linkUrl: _linkUrlController.text.trim().isNotEmpty
              ? _linkUrlController.text.trim()
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocConsumer<CreateCompetitionCubit, CreateCompetitionState>(
            listener: (context, state) {
              if (state is CreateCompetitionSuccess) {
                context.showSuccess('Competition Created Successfully! 🚀');
                _resetForm();
                widget.onSuccess?.call();

                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid ?? '';

                // 🎯 Clean Navigation Route: Replaces full stack directly with AppScaffold
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppScaffold(userId: currentUserId),
                  ),
                  (route) => false,
                );
              }

              if (state is CreateCompetitionError) {
                context.showError(state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is CreateCompetitionLoading;
              final cubit = context.read<CreateCompetitionCubit>();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Competition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      24.vs,
                      _ImagePickerBox(
                        imagePath: cubit.selectedImageFile?.path,
                        onTap: cubit.pickImage,
                        onClear: cubit.clearImage,
                      ),
                      24.vs,
                      _TypeSelector(
                        selectedType: _selectedType,
                        onTypeChanged: _onTypeChanged,
                      ),
                      24.vs,
                      AuthTextField(
                        label: 'Competition Name',
                        hintText: 'Flutter Championship',
                        prefixIcon: Icons.emoji_events,
                        controller: _nameController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      16.vs,
                      AuthTextField(
                        label: 'Description',
                        hintText: 'Rules and details',
                        prefixIcon: Icons.description,
                        controller: _descController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      16.vs,
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: AppColors.surface,
                        decoration:
                            _inputDecoration('Category', Icons.category),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v),
                        validator: (v) =>
                            v == null ? 'Select category' : null,
                      ),
                      16.vs,
                      AuthTextField(
                        label: 'Total Points',
                        hintText: '1000',
                        prefixIcon: Icons.star,
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        validator: _positiveNumberValidator,
                      ),
                      16.vs,
                      AuthTextField(
                        label: 'Participant Community Link',
                        hintText: 'Link to Telegram, Discord, or WhatsApp',
                        prefixIcon: Icons.link,
                        controller: _linkUrlController,
                        keyboardType: TextInputType.url,
                        validator: _urlValidator,
                      ),
                      16.vs,
                      if (_selectedType == CompetitionType.individual) ...[
                        AuthTextField(
                          label: 'Max Participants',
                          hintText: '100',
                          prefixIcon: Icons.people,
                          controller: _participantsController,
                          keyboardType: TextInputType.number,
                          validator: _positiveNumberValidator,
                        ),
                      ] else ...[
                        AuthTextField(
                          label: 'Maximum Teams',
                          hintText: '20',
                          prefixIcon: Icons.groups,
                          controller: _maxTeamsController,
                          keyboardType: TextInputType.number,
                          validator: _positiveNumberValidator,
                        ),
                        16.vs,
                        AuthTextField(
                          label: 'Members Per Team',
                          hintText: '5',
                          prefixIcon: Icons.person_add,
                          controller: _membersController,
                          keyboardType: TextInputType.number,
                          validator: _positiveNumberValidator,
                        ),
                      ],
                      16.vs,
                      Row(
                        children: [
                          Expanded(
                            child: _DateTile(
                              title: 'Start Date',
                              date: _startDate,
                              onTap: () => _pickDate(isStartDate: true),
                            ),
                          ),
                          16.hs,
                          Expanded(
                            child: _DateTile(
                              title: 'End Date',
                              date: _endDate,
                              onTap: () => _pickDate(isStartDate: false),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedType == CompetitionType.individual) ...[
                        16.vs,
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Public Competition',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Switch(
                              value: _isPublic,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isPublic = v),
                            ),
                          ],
                        ),
                        if (!_isPublic) ...[
                          16.vs,
                          AuthTextField(
                            label: 'Join Code',
                            hintText: 'Enter private access code',
                            prefixIcon: Icons.key,
                            controller: _joinCodeController,
                            validator: (v) {
                              if (!_isPublic &&
                                  (v == null || v.trim().isEmpty)) {
                                return 'Join code is required for private competitions';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                      24.vs,
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Launch Competition 🚀',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  String? _urlValidator(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final uri = Uri.tryParse(value.trim());
      if (uri == null || !uri.hasAbsolutePath) {
        return 'Enter a valid URL';
      }
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _ImagePickerBox({
    required this.imagePath,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage) ...[
              if (kIsWeb)
                Image.network(imagePath!, fit: BoxFit.cover)
              else
                Image.file(File(imagePath!), fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    onPressed: onClear,
                  ),
                ),
              ),
            ] else ...[
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload Competition Banner / Image',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final CompetitionType selectedType;
  final ValueChanged<CompetitionType> onTypeChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeTile(
          type: CompetitionType.individual,
          label: 'Individuals',
          icon: Icons.person,
          isSelected: selectedType == CompetitionType.individual,
          onTap: () => onTypeChanged(CompetitionType.individual),
        ),
        16.hs,
        _TypeTile(
          type: CompetitionType.team,
          label: 'Teams',
          icon: Icons.groups,
          isSelected: selectedType == CompetitionType.team,
          onTap: () => onTypeChanged(CompetitionType.team),
        ),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  final CompetitionType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
              ),
              8.hs,
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String title;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({
    required this.title,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date == null
              ? title
              : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
          style: TextStyle(
            color: date == null ? Colors.white70 : Colors.white,
          ),
        ),
      ),
    );
  }
}