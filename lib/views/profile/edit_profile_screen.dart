import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _cityController = TextEditingController(text: user?.cityState ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Future<void> _handleSave() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      cityState: _cityController.text.trim(),
      avatarFile: _pickedImage,
    );

    if (!mounted) return;

    if (success) {
      final language = context.read<AppLanguageProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language.text(
              'Profil erfolgreich aktualisiert!',
              'Profile updated successfully!',
            ),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                context.read<AppLanguageProvider>().text(
                  'Fehler beim Speichern.',
                  'Failed to save changes.',
                ),
          ),
          backgroundColor: AppColors.badgeRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final language = context.watch<AppLanguageProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          user?.isRestaurantOwner == true
              ? language.text('Inhaberprofil bearbeiten', 'Edit owner profile')
              : language.text('Profil bearbeiten', 'Edit profile'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Avatar Pick Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (user?.avatar != null
                                      ? CachedNetworkImageProvider(
                                          user!.avatar!,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child: _pickedImage == null && user?.avatar == null
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                hintText: language.text('Vollständiger Name', 'Full name'),
                labelText: language.text('Name', 'Name'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                hintText: 'name@example.com',
                labelText: language.text('E-Mail-Konto', 'Account email'),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.lock_outline,
                  size: 17,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                hintText: '+49 151 23456789',
                labelText: language.text('Telefonnummer', 'Phone number'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _cityController,
                hintText: 'München, Deutschland',
                labelText: language.text('Stadt / Region', 'City / region'),
              ),

              const SizedBox(height: 36),

              CustomButton(
                text: language.text('Speichern', 'Save'),
                isLoading: authProvider.isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
