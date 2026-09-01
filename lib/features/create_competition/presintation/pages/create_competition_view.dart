import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_cubit.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_state.dart';

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

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController();
  final _participantsController = TextEditingController();
  final _maxTeamsController = TextEditingController();
  final _membersController = TextEditingController();
  final _joinCodeController = TextEditingController();

  String _selectedType = "individual";
  bool _isPublic = true;
  String? _selectedCategory;

  DateTime? _startDate;
  DateTime? _endDate;

  static const List<String> _categories = [
    "Programming",
    "Mobile Development",
    "Web Development",
    "Artificial Intelligence",
    "Machine Learning",
    "Cyber Security",
    "Data Science",
    "UI/UX Design",
    "Algorithms",
    "Other",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _participantsController.dispose();
    _maxTeamsController.dispose();
    _membersController.dispose();
    _joinCodeController.dispose();
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

    setState(() {
      _selectedType = "individual";
      _isPublic = true;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _pickDate(bool start) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: start ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
    );

    if (date != null) {
      setState(() {
        if (start) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _onTypeChanged(String type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      if (_selectedType == "team") {
        _isPublic = true;
      }
    });
  }

  void _submit() {
    // 1. Guard against duplicate execution if cubit is already processing
    final cubit = context.read<CreateCompetitionCubit>();
    if (cubit.state is CreateCompetitionLoading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      context.showError("Please select both start and end dates");
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      context.showError("End date cannot be before start date");
      return;
    }

    int maxParticipants = 0;
    int? maxTeams;
    int? membersPerTeam;

    if (_selectedType == "individual") {
      maxParticipants = int.parse(_participantsController.text.trim());
    } else {
      maxTeams = int.parse(_maxTeamsController.text.trim());
      membersPerTeam = int.parse(_membersController.text.trim());
      maxParticipants = maxTeams * membersPerTeam;
    }

    // 2. Hide keyboard to prevent accidental double-taps during submission
    FocusScope.of(context).unfocus();

    cubit.submitCompetition(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      type: _selectedType,
      totalPoints: int.parse(_pointsController.text.trim()),
      startDate: _startDate!,
      endDate: _endDate!,
      maxParticipants: maxParticipants,
      isPublic: _selectedType == "individual" ? _isPublic : true,
      category: _selectedCategory!,
      maxTeams: maxTeams,
      membersPerTeam: membersPerTeam,
      joinCode: !_isPublic ? _joinCodeController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CreateCompetitionCubit, CreateCompetitionState>(
          listener: (context, state) {
            if (state is CreateCompetitionSuccess) {
              context.showSuccess("Competition Created");
              _resetForm();
              widget.onSuccess?.call();
              if (Navigator.canPop(context)) {
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.pop(context);
              }
            }

            if (state is CreateCompetitionError) {
              context.showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateCompetitionLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Competition",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    24.vs,
                    Row(
                      children: [
                        _typeButton("individual", Icons.person, "Individuals"),
                        16.hs,
                        _typeButton("team", Icons.groups, "Teams"),
                      ],
                    ),
                    24.vs,
                    AuthTextField(
                      label: "Competition Name",
                      hintText: "Flutter Championship",
                      prefixIcon: Icons.emoji_events,
                      controller: _nameController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    16.vs,
                    AuthTextField(
                      label: "Description",
                      hintText: "Rules and details",
                      prefixIcon: Icons.description,
                      controller: _descController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    16.vs,
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.surface,
                      decoration: _inputDecoration("Category", Icons.category),
                      items: _categories.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) => v == null ? "Select category" : null,
                    ),
                    16.vs,
                    AuthTextField(
                      label: "Total Points",
                      hintText: "1000",
                      prefixIcon: Icons.star,
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? "");
                        if (parsed == null || parsed <= 0) {
                          return "Enter a valid positive number";
                        }
                        return null;
                      },
                    ),
                    16.vs,
                    if (_selectedType == "individual")
                      AuthTextField(
                        label: "Max Participants",
                        hintText: "100",
                        prefixIcon: Icons.people,
                        controller: _participantsController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final parsed = int.tryParse(v ?? "");
                          if (parsed == null || parsed <= 0) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                    if (_selectedType == "team") ...[
                      AuthTextField(
                        label: "Maximum Teams",
                        hintText: "20",
                        prefixIcon: Icons.groups,
                        controller: _maxTeamsController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final parsed = int.tryParse(v ?? "");
                          if (parsed == null || parsed <= 0) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                      16.vs,
                      AuthTextField(
                        label: "Members Per Team",
                        hintText: "5",
                        prefixIcon: Icons.person_add,
                        controller: _membersController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final parsed = int.tryParse(v ?? "");
                          if (parsed == null || parsed <= 0) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                      ),
                    ],
                    16.vs,
                    Row(
                      children: [
                        Expanded(
                          child: _dateButton(
                            "Start Date",
                            _startDate,
                            () => _pickDate(true),
                          ),
                        ),
                        16.hs,
                        Expanded(
                          child: _dateButton(
                            "End Date",
                            _endDate,
                            () => _pickDate(false),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedType == "individual") ...[
                      16.vs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Public Competition",
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
                          label: "Join Code",
                          hintText: "Enter private access code",
                          prefixIcon: Icons.key,
                          controller: _joinCodeController,
                          validator: (v) {
                            if (!_isPublic && (v == null || v.trim().isEmpty)) {
                              return "Join code is required for private competitions";
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
                        // Disables taps when isLoading is true by assigning null
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                                "Launch Competition 🚀",
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
    );
  }

  Widget _typeButton(String type, IconData icon, String title) {
    final selected = _selectedType == type;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.black : Colors.white,
              ),
              8.hs,
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateButton(String title, DateTime? date, VoidCallback onTap) {
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
          date == null ? title : "${date.day}/${date.month}/${date.year}",
          style: TextStyle(
            color: date == null ? Colors.white70 : Colors.white,
          ),
        ),
      ),
    );
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