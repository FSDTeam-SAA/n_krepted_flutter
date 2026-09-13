import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';
import '../../core/constants/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _email, _phone, _address;
  Uint8List? _avatar;
  String? _avatarName;
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _name = TextEditingController(text: user?.name);
    _email = TextEditingController(text: user?.email);
    _phone = TextEditingController(text: user?.phoneNumber);
    _address = TextEditingController(text: user?.cityState);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _avatar = bytes;
          _avatarName = file.name;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bild konnte nicht geladen werden.')),
        );
      }
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading || !_form.currentState!.validate()) return;
    final success = await auth.updateProfile(
      name: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      cityState: _address.text.trim(),
      avatarBytes: _avatar,
      avatarName: _avatarName,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.read<AppLanguageProvider>().text(
                  'Profil gespeichert.',
                  'Profile saved.',
                )
              : auth.errorMessage ?? 'Speichern fehlgeschlagen.',
        ),
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final language = context.watch<AppLanguageProvider>();
    final avatarUrl = auth.currentUser?.avatar;
    final ImageProvider? image = _avatar != null
        ? MemoryImage(_avatar!)
        : avatarUrl?.isNotEmpty == true
        ? CachedNetworkImageProvider(avatarUrl!)
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language.text('Profil bearbeiten', 'Edit profile'),
          style: const TextStyle(fontSize: AppFontSizes.title),
        ),
      ),
      body: OwnerPageBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: const Color(0xFFF1F1F1),
                                backgroundImage: image,
                                child: image == null
                                    ? const Icon(
                                        Icons.person,
                                        color: AppColors.textGrey,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFFF9DF),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 38),
                        CustomTextField(
                          controller: _name,
                          hintText: language.text('Benutzer', 'Name'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? language.text(
                                  'Name eingeben.',
                                  'Enter your name.',
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _email,
                          hintText: 'E-Mail',
                          readOnly: true,
                          suffixIcon: const Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phone,
                          hintText: language.text('Telefon', 'Phone'),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _address,
                          hintText: language.text('Adresse', 'Address'),
                        ),
                        const Spacer(),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: language.text('Speichern', 'Save'),
                          isLoading: auth.isLoading,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
