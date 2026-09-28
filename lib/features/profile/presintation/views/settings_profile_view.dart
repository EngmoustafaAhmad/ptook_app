import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ⚡ Import Google Mobile Ads SDK
import 'package:image_picker/image_picker.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/context_extentions.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/auth/presintation/widgets/auth_text_field.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/profile/presintation/cubit/update_profile/update_profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/update_profile/update_profile_state.dart';

class SettingsProfileView extends StatefulWidget {
  final UserEntity currentUser;

  const SettingsProfileView({
    super.key,
    required this.currentUser,
  });

  @override
  State<SettingsProfileView> createState() => _SettingsProfileViewState();
}

class _SettingsProfileViewState extends State<SettingsProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _handleController;
  late final TextEditingController _bioController;

  // ⚡ AdMob Banner Ad State Variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // 🧪 Official Test Banner Ad Unit ID for Android
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _handleController = TextEditingController(text: widget.currentUser.handle);
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _loadBannerAd(); // ⚡ Initialize banner ad
  }

  // ⚡ Load Banner Ad Method
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Settings Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _bannerAd?.dispose(); // ⚡ Clean up memory when leaving screen
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<UpdateProfileCubit>().updateProfile(
          currentUser: widget.currentUser,
          name: _nameController.text,
          handle: _handleController.text,
          bio: _bioController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
        listener: (context, state) {
          if (state is UpdateProfileSuccess) {
            context.showSuccess(state.message);
            Navigator.pop(context);
          }
          if (state is UpdateProfileError) {
            context.showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is UpdateProfileLoading;
          final cubit = context.read<UpdateProfileCubit>();
          final pickedFile = cubit.selectedAvatarFile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Picker Widget
                  _buildAvatarPicker(pickedFile, cubit),
                  24.vs,

                  // Name Field
                  AuthTextField(
                    label: 'Full Name',
                    hintText: 'John Doe',
                    prefixIcon: Icons.person,
                    controller: _nameController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  16.vs,

                  // Handle Field
                  AuthTextField(
                    label: 'Handle / Username',
                    hintText: '@username',
                    prefixIcon: Icons.alternate_email,
                    controller: _handleController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Handle is required'
                        : null,
                  ),
                  16.vs,

                  // Bio Field
                  AuthTextField(
                    label: 'Bio',
                    hintText: 'Tell us something about yourself...',
                    prefixIcon: Icons.edit_note_rounded,
                    controller: _bioController,
                  ),
                  32.vs,

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Save Changes',
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
      // ⚡ Sticky Bottom Banner Ad
      bottomNavigationBar: _buildBannerAdWidget(),
    );
  }

  // --- Banner Ad Component ---
  Widget? _buildBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  Widget _buildAvatarPicker(XFile? pickedFile, UpdateProfileCubit cubit) {
    ImageProvider? imageProvider;

    if (pickedFile != null) {
      imageProvider = kIsWeb
          ? NetworkImage(pickedFile.path)
          : FileImage(File(pickedFile.path)) as ImageProvider;
    } else if (widget.currentUser.avatarUrl != null &&
        widget.currentUser.avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.currentUser.avatarUrl!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: AppColors.surface,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  widget.currentUser.initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        GestureDetector(
          onTap: cubit.pickAvatarImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.black,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}