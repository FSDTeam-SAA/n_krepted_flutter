import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';
import 'restaurant_location_picker_screen.dart';
import 'owner_workspace_screen.dart';

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
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  final ImagePicker _imagePicker = ImagePicker();
  late final List<String> _existingImages;
  final List<XFile> _newImages = [];

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _titleController = TextEditingController(text: r?.title ?? '');
    _shortDescController = TextEditingController(
      text: r?.shortDescription ?? '',
    );
    _descController = TextEditingController(text: r?.description ?? '');
    _priceController = TextEditingController(
      text: r?.price != null ? r!.price.toStringAsFixed(2) : '15.00',
    );
    _existingImages = List<String>.from(r?.images ?? const <String>[]);
    _addressController = TextEditingController(text: r?.location.address ?? '');
    _cityController = TextEditingController(
      text: r?.location.city ?? 'München',
    );
    _countryController = TextEditingController(
      text: r?.location.country ?? 'Deutschland',
    );
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
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  int get _imageCount => _existingImages.length + _newImages.length;

  Future<void> _pickRestaurantImages() async {
    final remaining = 4 - _imageCount;
    if (remaining <= 0) {
      _showImageMessage('Maximal 4 Bilder sind erlaubt.');
      return;
    }

    final selected = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || selected.isEmpty) return;

    setState(() => _newImages.addAll(selected.take(remaining)));
    if (selected.length > remaining) {
      _showImageMessage(
        'Es wurden nur $remaining weitere Bilder hinzugef\u00fcgt.',
      );
    }
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
        _newImages.removeAt(0);
      } else if (_existingImages.isNotEmpty) {
        _existingImages.removeAt(0);
      }
      _newImages.insert(0, selected);
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _newImages.length) {
        _newImages.removeAt(index);
      } else {
        _existingImages.removeAt(index - _newImages.length);
      }
    });
  }

  void _showImageMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openLocationPicker() async {
    FocusScope.of(context).unfocus();

    final latitude = double.tryParse(_latController.text.trim()) ?? 48.137154;
    final longitude = double.tryParse(_lngController.text.trim()) ?? 11.576124;

    final selection = await Navigator.push<RestaurantLocationSelection>(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantLocationPickerScreen(
          initialLatitude: latitude,
          initialLongitude: longitude,
          initialAddress: _addressController.text.trim(),
          initialCity: _cityController.text.trim(),
          initialCountry: _countryController.text.trim(),
        ),
      ),
    );

    if (selection == null || !mounted) return;

    setState(() {
      if (selection.address.isNotEmpty) {
        _addressController.text = selection.address;
      }
      if (selection.city.isNotEmpty) {
        _cityController.text = selection.city;
      }
      if (selection.country.isNotEmpty) {
        _countryController.text = selection.country;
      }
      _latController.text = selection.latitude.toStringAsFixed(6);
      _lngController.text = selection.longitude.toStringAsFixed(6);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Standort wurde zum Formular hinzugefügt.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageCount == 0) {
      _showImageMessage('Bitte mindestens ein Restaurantbild ausw\u00e4hlen.');
      return;
    }

    final provider = context.read<OwnerRestaurantProvider>();

    final payload = {
      'title': _titleController.text.trim(),
      'shortDescription': _shortDescController.text.trim().isNotEmpty
          ? _shortDescController.text.trim()
          : _titleController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 15.0,
      'existingImages': List<String>.from(_existingImages),
      'imageFiles': List<XFile>.from(_newImages),
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
          MaterialPageRoute(builder: (_) => const OwnerWorkspaceScreen()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
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
                  MaterialPageRoute(
                    builder: (_) => const OwnerWorkspaceScreen(),
                  ),
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
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                      size: 13,
                      color: AppColors.textGrey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
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
                _buildFieldLabel('Restaurantbilder'),
                _buildRestaurantImagePicker(),

                const SizedBox(height: 24),
                _buildSectionHeader('Standort & Adresse'),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _openLocationPicker,
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          'Standort auf der Karte auswählen',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Adresse suchen oder direkt auf die Karte tippen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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

  Widget _buildRestaurantImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _imageCount == 0 ? _pickRestaurantImages : _replaceMainImage,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: _imageCount == 0
                ? const _ImageAddPlaceholder(
                    label: 'Hauptfoto hinzuf\u00fcgen',
                    large: true,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageAt(0),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: _ImageActionButton(
                            icon: Icons.edit_outlined,
                            onTap: _replaceMainImage,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _ImageActionButton(
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
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:
                (_imageCount - 1).clamp(0, 3) + (_imageCount < 4 ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, listIndex) {
              final imageIndex = listIndex + 1;
              if (imageIndex >= _imageCount) {
                return GestureDetector(
                  onTap: _pickRestaurantImages,
                  child: const SizedBox(
                    width: 105,
                    child: _ImageAddPlaceholder(label: 'Weitere Bilder'),
                  ),
                );
              }
              return SizedBox(
                width: 105,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageAt(imageIndex),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: _ImageActionButton(
                          icon: Icons.close,
                          compact: true,
                          onTap: () => _removeImage(imageIndex),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Bis zu 4 Bilder. Tippen Sie auf das Hauptbild, um es zu ersetzen.',
          style: AppTextStyles.body(size: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildImageAt(int index) {
    if (index < _newImages.length) {
      return Image.file(
        File(_newImages[index].path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrokenImagePlaceholder(),
      );
    }
    return Image.network(
      _existingImages[index - _newImages.length],
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _BrokenImagePlaceholder(),
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

class _ImageAddPlaceholder extends StatelessWidget {
  final String label;
  final bool large;

  const _ImageAddPlaceholder({required this.label, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: large ? 20 : 16,
          backgroundColor: const Color(0xFFF4F6F6),
          child: Icon(
            Icons.add,
            color: AppColors.primary,
            size: large ? 25 : 20,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }
}

class _ImageActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _ImageActionButton({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 5 : 7),
          child: Icon(icon, size: compact ? 15 : 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder();

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
