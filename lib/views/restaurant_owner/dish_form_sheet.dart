import 'package:flutter/material.dart';
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
  late final TextEditingController _imageController;
  late final TextEditingController _descController;
  late bool _isSignatureDish;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    _nameController = TextEditingController(text: d?.name ?? '');
    _priceController = TextEditingController(
      text: d != null ? d.price.toStringAsFixed(2) : '12.00',
    );
    _categoryController = TextEditingController(text: d?.category ?? 'Hauptspeise');
    _imageController = TextEditingController(text: d?.image ?? '');
    _descController = TextEditingController(text: d?.description ?? '');
    _isSignatureDish = d?.isSignatureDish ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<OwnerRestaurantProvider>();

    final payload = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 12.0,
      'category': _categoryController.text.trim(),
      'image': _imageController.text.trim().isNotEmpty
          ? _imageController.text.trim()
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
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
          content: Text(
            provider.errorMessage ?? 'Aktion fehlgeschlagen.',
          ),
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
                    isEditing ? 'Gericht bearbeiten' : 'Neues Gericht hinzufügen',
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
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bitte Gerichtname eingeben' : null,
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
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
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
              _buildFieldLabel('Bild-URL'),
              CustomTextField(
                controller: _imageController,
                hintText: 'https://images.unsplash.com/...',
              ),

              const SizedBox(height: 12),
              _buildFieldLabel('Beschreibung'),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Zutaten und Zubereitung kurz beschreiben...',
                  hintStyle: AppTextStyles.body(size: 13, color: AppColors.textGrey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.inputBorder, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
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
}
