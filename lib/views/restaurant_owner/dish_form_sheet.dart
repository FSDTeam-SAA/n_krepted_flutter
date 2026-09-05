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
  late final TextEditingController _specialtyController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _preparationController;
  late bool _isSignatureDish;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _newImages = [];
  final List<String> _existingImages = [];

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    _nameController = TextEditingController(text: d?.name ?? '');
    _priceController = TextEditingController(
      text: d != null ? d.price.toStringAsFixed(2) : '0.00',
    );
    _categoryController = TextEditingController(text: d?.category ?? '');
    _existingImages.addAll(
      d == null
          ? const <String>[]
          : d.images.isNotEmpty
          ? d.images
          : d.image.isNotEmpty
          ? [d.image]
          : const <String>[],
    );
    _descController = TextEditingController(text: d?.description ?? '');
    _specialtyController = TextEditingController(
      text: d?.specialtyDescription ?? '',
    );
    _ingredientsController = TextEditingController(
      text: d?.ingredients.join('\n') ?? '',
    );
    _preparationController = TextEditingController(
      text: d?.preparationProcess ?? '',
    );
    _isSignatureDish = d?.isSignatureDish ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _specialtyController.dispose();
    _ingredientsController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  int get _imageCount => _newImages.length + _existingImages.length;
  bool get _hasImage => _imageCount > 0;

  void _closeSheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _pickImages() async {
    final available = 4 - _imageCount;
    if (available <= 0) return;
    final selected = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || selected.isEmpty) return;
    setState(() => _newImages.addAll(selected.take(available)));
  }

  Future<void> _replaceMainImage() async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || selected == null) return;
    setState(() {
      if (_newImages.isNotEmpty) {
        _newImages[0] = selected;
      } else if (_existingImages.isNotEmpty) {
        _existingImages.removeAt(0);
        _newImages.insert(0, selected);
      } else {
        _newImages.add(selected);
      }
    });
  }

  void _removeImage(int index) => setState(() {
    if (index < _newImages.length) {
      _newImages.removeAt(index);
    } else {
      _existingImages.removeAt(index - _newImages.length);
    }
  });

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
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'category': _categoryController.text.trim(),
      'existingImages': _existingImages,
      'imageFiles': _newImages,
      'description': _descController.text.trim(),
      'specialtyDescription': _specialtyController.text.trim(),
      'ingredients': _ingredientsController.text
          .split(RegExp(r'[\n,]'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'preparationProcess': _preparationController.text.trim(),
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
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Gericht bearbeiten'
                          : 'Neues Gericht hinzufügen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: _closeSheet,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F7F8),
                      foregroundColor: AppColors.textDark,
                      minimumSize: const Size(42, 42),
                    ),
                  ),
                ],
              ),
              const Divider(height: 22, color: Color(0xFFE8ECEE)),

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
                decoration: _areaDecoration(
                  'Zutaten und Zubereitung kurz beschreiben...',
                ),
              ),

              const SizedBox(height: 12),
              _buildFieldLabel('Spezialität des Gerichts'),
              TextFormField(
                controller: _specialtyController,
                maxLines: 3,
                decoration: _areaDecoration(
                  'Was macht dieses Gericht besonders?',
                ),
              ),

              const SizedBox(height: 12),
              _buildFieldLabel('Zubereitungsmethode'),
              TextFormField(
                controller: _ingredientsController,
                minLines: 3,
                maxLines: 5,
                decoration: _areaDecoration(
                  'Hauptzutaten – eine Zutat pro Zeile',
                ),
              ),

              const SizedBox(height: 12),
              _buildFieldLabel('Herstellungsprozess'),
              TextFormField(
                controller: _preparationController,
                maxLines: 4,
                decoration: _areaDecoration(
                  'Zubereitung des Gerichts beschreiben...',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _hasImage ? _replaceMainImage : _pickImages,
          child: Container(
            height: 165,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: !_hasImage
                ? const _DishImagePlaceholder(label: 'Hauptfoto hinzufügen')
                : ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageAt(0),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: _DishImageAction(
                            icon: Icons.edit_outlined,
                            onTap: _replaceMainImage,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _DishImageAction(
                            icon: Icons.delete_outline,
                            onTap: () => _removeImage(0),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (slot) {
            final index = slot + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: slot == 0 ? 0 : 8),
                child: GestureDetector(
                  onTap: index < _imageCount ? null : _pickImages,
                  child: Container(
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: index >= _imageCount
                        ? const _DishImagePlaceholder(label: 'Weitere Bilder')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageAt(index),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: _DishImageAction(
                                    icon: Icons.close,
                                    onTap: () => _removeImage(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildImageAt(int index) {
    if (index < _newImages.length) {
      return Image.file(
        File(_newImages[index].path),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _DishBrokenImage(),
      );
    }
    return Image.network(
      _existingImages[index - _newImages.length],
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const _DishBrokenImage(),
    );
  }

  InputDecoration _areaDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.body(size: 13, color: AppColors.textGrey),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

class _DishImagePlaceholder extends StatelessWidget {
  final String label;

  const _DishImagePlaceholder({required this.label});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
        radius: 17,
        backgroundColor: Color(0xFFF4F6F6),
        child: Icon(Icons.add, color: AppColors.primary, size: 22),
      ),
      const SizedBox(height: 7),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey),
      ),
    ],
  );
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
