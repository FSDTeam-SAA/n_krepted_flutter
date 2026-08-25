import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../main_navigation/main_bottom_nav.dart';

class CreateEditRestaurantScreen extends StatefulWidget {
  final DealModel? restaurant;
  final bool isResubmission;
  final bool isInitialSetup;

  const CreateEditRestaurantScreen({
    super.key,
    this.restaurant,
    this.isResubmission = false,
    this.isInitialSetup = false,
  });

  @override
  State<CreateEditRestaurantScreen> createState() =>
      _CreateEditRestaurantScreenState();
}

class _CreateEditRestaurantScreenState
    extends State<CreateEditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _titleController = TextEditingController(text: r?.title ?? '');
    _shortDescController =
        TextEditingController(text: r?.shortDescription ?? '');
    _descController = TextEditingController(text: r?.description ?? '');
    _priceController = TextEditingController(
      text: r?.price != null ? r!.price.toStringAsFixed(2) : '15.00',
    );
    _imageController = TextEditingController(
      text: r?.images.isNotEmpty == true ? r!.images.first : '',
    );
    _addressController =
        TextEditingController(text: r?.location.address ?? '');
    _cityController =
        TextEditingController(text: r?.location.city ?? 'München');
    _countryController =
        TextEditingController(text: r?.location.country ?? 'Deutschland');
    _latController = TextEditingController(
      text: r?.location.latitude != null
          ? r!.location.latitude.toString()
          : '48.137154',
    );
    _lngController = TextEditingController(
      text: r?.location.longitude != null
          ? r!.location.longitude.toString()
          : '11.576124',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<OwnerRestaurantProvider>();

    final payload = {
      'title': _titleController.text.trim(),
      'shortDescription': _shortDescController.text.trim().isNotEmpty
          ? _shortDescController.text.trim()
          : _titleController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 15.0,
      'images': _imageController.text.trim().isNotEmpty
          ? [_imageController.text.trim()]
          : [
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80'
            ],
      'location': {
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'latitude': double.tryParse(_latController.text.trim()) ?? 48.137154,
        'longitude': double.tryParse(_lngController.text.trim()) ?? 11.576124,
      },
    };

    bool success;
    if (widget.isResubmission) {
      success = await provider.resubmitRestaurant(payload);
    } else if (widget.restaurant != null) {
      success = await provider.updateRestaurant(payload);
    } else {
      success = await provider.submitRestaurant(payload);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.restaurant != null && !widget.isResubmission
                ? 'Restaurantangaben erfolgreich aktualisiert.'
                : 'Restaurant erfolgreich zur Genehmigung eingereicht.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (widget.isInitialSetup) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainBottomNav()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
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
    AppSizes.init(context);
    final provider = context.watch<OwnerRestaurantProvider>();
    final isEditing = widget.restaurant != null && !widget.isResubmission;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Restaurant bearbeiten'
              : widget.isResubmission
                  ? 'Erneut einreichen'
                  : 'Restaurant erstellen',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (widget.isInitialSetup)
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainBottomNav()),
                  (route) => false,
                );
              },
              child: const Text(
                'Später',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isResubmission &&
                    widget.restaurant?.rejectionReason != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grund der Ablehnung durch Admin:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.restaurant!.rejectionReason!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildSectionHeader('Basisinformationen'),
                const SizedBox(height: 12),

                _buildFieldLabel('Restaurantname'),
                CustomTextField(
                  controller: _titleController,
                  hintText: 'z. B. Sonnengarten Restaurant',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte Restaurantname eingeben'
                      : null,
                ),

                const SizedBox(height: 14),
                _buildFieldLabel('Startpreis (€)'),
                CustomTextField(
                  controller: _priceController,
                  hintText: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte Startpreis eingeben'
                      : null,
                ),

                const SizedBox(height: 14),
                _buildFieldLabel('Kurzbeschreibung'),
                CustomTextField(
                  controller: _shortDescController,
                  hintText: 'Kurze Zusammenfassung für die Kartenansicht',
                ),

                const SizedBox(height: 14),
                _buildFieldLabel('Detaillierte Beschreibung'),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte Beschreibung eingeben'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Detaillierte Beschreibung Ihres Restaurants...',
                    hintStyle: AppTextStyles.body(
                        size: 13, color: AppColors.textGrey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.inputBorder, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                _buildFieldLabel('Titelbild-URL'),
                CustomTextField(
                  controller: _imageController,
                  hintText: 'https://images.unsplash.com/...',
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Standort & Adresse'),
                const SizedBox(height: 12),

                _buildFieldLabel('Straße & Hausnummer'),
                CustomTextField(
                  controller: _addressController,
                  hintText: 'z. B. Marienplatz 1',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte Adresse eingeben'
                      : null,
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Stadt'),
                          CustomTextField(
                            controller: _cityController,
                            hintText: 'z. B. München',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bitte Stadt eingeben'
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
                          _buildFieldLabel('Land'),
                          CustomTextField(
                            controller: _countryController,
                            hintText: 'Deutschland',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Bitte Land eingeben'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Breitengrad (Lat)'),
                          CustomTextField(
                            controller: _latController,
                            hintText: '48.137154',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Längengrad (Lng)'),
                          CustomTextField(
                            controller: _lngController,
                            hintText: '11.576124',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: isEditing
                      ? 'Änderungen speichern'
                      : widget.isResubmission
                          ? 'Erneut zur Genehmigung einreichen'
                          : 'Restaurant zur Genehmigung einreichen',
                  isLoading: provider.isActionLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
