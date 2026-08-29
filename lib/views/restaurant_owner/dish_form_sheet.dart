import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';

class DishFormSheet extends StatefulWidget {
  final DealDish? dish;

  const DishFormSheet({super.key, this.dish});

  @override
  State<DishFormSheet> createState() => _DishFormSheetState();
}

class _DishFormSheetState extends State<DishFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descController;
  late bool _isSignatureDish;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _newImage;
  String? _existingImage;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    _nameController = TextEditingController(text: d?.name ?? '');
    _priceController = TextEditingController(
      text: d != null ? d.price.toStringAsFixed(2) : '12.00',
    );
    _categoryController = TextEditingController(
      text: d?.category ?? 'Hauptspeise',
    );
    _existingImage = d?.image.isNotEmpty == true ? d!.image : null;
    _descController = TextEditingController(text: d?.description ?? '');
    _isSignatureDish = d?.isSignatureDish ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _hasImage => _newImage != null || _existingImage != null;

  Future<void> _pickImage() async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || selected == null) return;
    setState(() => _newImage = selected);
  }

  void _removeImage() {
    setState(() {
      _newImage = null;
      _existingImage = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte ein Gerichtbild ausw\u00e4hlen.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<OwnerRestaurantProvider>();

    final payload = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 12.0,
      'category': _categoryController.text.trim(),
      'existingImage': _existingImage,
      'imageFile': _newImage,
      'description': _descController.text.trim(),
      'isSignatureDish': _isSignatureDish,
    };

    bool success;
    if (widget.dish != null) {
      success = await provider.updateDish(widget.dish!.id, payload);
    } else {
      success = await provider.addDish(payload);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.dish != null
                ? 'Gericht erfolgreich aktualisiert.'
                : 'Gericht erfolgreich hinzugefügt.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Aktion fehlgeschlagen.'),
          backgroundColor: AppColors.badgeRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerRestaurantProvider>();
    final isEditing = widget.dish != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? 'Gericht bearbeiten'
                        : 'Neues Gericht hinzufügen',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildFieldLabel('Gerichtname'),
              CustomTextField(
                controller: _nameController,
                hintText: 'z. B. Signature Truffel Pasta',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Bitte Gerichtname eingeben'
                    : null,
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Preis (€)'),
                        CustomTextField(
                          controller: _priceController,
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Preis eingeben'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Kategorie'),
                        CustomTextField(
                          controller: _categoryController,
                          hintText: 'z. B. Hauptspeise',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildFieldLabel('Gerichtbild'),
              _buildImagePicker(),

              const SizedBox(height: 12),
              _buildFieldLabel('Beschreibung'),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Zutaten und Zubereitung kurz beschreiben...',
                  hintStyle: AppTextStyles.body(
                    size: 13,
                    color: AppColors.textGrey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorder,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBE7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFEEFB3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signature Dish',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Als Hauptspezialität in der App hervorheben',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isSignatureDish,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isSignatureDish = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              CustomButton(
                text: isEditing ? 'Gericht speichern' : 'Gericht hinzufügen',
                isLoading: provider.isActionLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: !_hasImage
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFF4F6F6),
                    child: Icon(Icons.add, color: AppColors.primary, size: 25),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hauptfoto hinzuf\u00fcgen',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _newImage != null
                        ? Image.file(
                            File(_newImage!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _DishBrokenImage(),
                          )
                        : Image.network(
                            _existingImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _DishBrokenImage(),
                          ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _DishImageAction(
                        icon: Icons.edit_outlined,
                        onTap: _pickImage,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _DishImageAction(
                        icon: Icons.delete_outline,
                        onTap: _removeImage,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DishImageAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DishImageAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _DishBrokenImage extends StatelessWidget {
  const _DishBrokenImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF3F4F6),
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.textGrey),
      ),
    );
  }
}
