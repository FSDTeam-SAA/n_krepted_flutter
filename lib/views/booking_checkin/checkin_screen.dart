import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/check_in_model.dart';
import '../../data/models/deal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/check_in_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/constants/app_text_styles.dart';

class CheckinScreen extends StatefulWidget {
  final DealModel deal;

  const CheckinScreen({super.key, required this.deal});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _guestCount = 1;
  bool _locating = false;

  Future<Position?> _getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showError(
          'Bitte aktivieren Sie die Standortdienste und versuchen Sie es erneut.',
          settings: Geolocator.openLocationSettings,
        );
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showError(
          'Die Standortberechtigung ist für einen Check-in erforderlich.',
        );
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Bitte erlauben Sie den Standortzugriff in den App-Einstellungen.',
          settings: Geolocator.openAppSettings,
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      _showError(
        'Kein aktuelles GPS-Signal. Bitte im Freien mit genauem Standort erneut versuchen.',
        settings: Geolocator.openLocationSettings,
      );
      return null;
    } catch (_) {
      _showError(
        'Ihr aktueller Standort konnte nicht ermittelt werden. Bitte Standort und App-Berechtigung prüfen.',
        settings: Geolocator.openAppSettings,
      );
      return null;
    }
  }

  Future<void> _handleCheckin() async {
    if (_locating || context.read<CheckInProvider>().isLoading) return;
    if (context.read<AuthProvider>().currentUser == null) {
      _showError('Bitte melden Sie sich zuerst an.');
      return;
    }
    if (!widget.deal.location.hasCoordinates) {
      _showError(
        'Für dieses Restaurant fehlt der Kartenstandort. Der Betreiber muss zuerst die Koordinaten hinterlegen.',
      );
      return;
    }

    setState(() => _locating = true);
    final position = await _getCurrentPosition();
    if (mounted) setState(() => _locating = false);
    if (!mounted || position == null) return;
    context.read<LocationProvider>().update(position);

    final checkIn = await context.read<CheckInProvider>().checkIn(
      restaurantId: widget.deal.id,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      partySize: _guestCount,
    );
    if (!mounted) return;

    if (checkIn == null) {
      _showError(
        context.read<CheckInProvider>().errorMessage ??
            'Der Check-in konnte nicht verifiziert werden.',
      );
      return;
    }
    _showSuccessDialog(checkIn);
  }

  void _showError(String message, {Future<bool> Function()? settings}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        action: settings == null
            ? null
            : SnackBarAction(
                label: 'Einstellungen',
                textColor: Colors.white,
                onPressed: () async {
                  await settings();
                },
              ),
        content: Text(message),
        backgroundColor: AppColors.badgeRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(CheckInModel checkIn) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 44,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Erfolgreich eingecheckt!',
              style: TextStyle(
                fontSize: AppFontSizes.title,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ihr Standort bei ${widget.deal.restaurantName} wurde in ${checkIn.distanceMeters.round()} m Entfernung verifiziert. Personen: ${checkIn.partySize}.',
              style: const TextStyle(
                fontSize: AppFontSizes.labelSmall,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Fertig',
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, checkIn);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final checkInProvider = context.watch<CheckInProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Im Restaurant einchecken',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        deal.firstImage,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFE0F7FA),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.restaurantName,
                            style: const TextStyle(
                              fontSize: AppFontSizes.subtitle,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              deal.location.address,
                              deal.location.city,
                            ].where((value) => value.isNotEmpty).join(', '),
                            style: const TextStyle(
                              fontSize: AppFontSizes.small,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.my_location, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Der Check-in ist nur vor Ort möglich. Ihr aktueller GPS-Standort muss höchstens 100 Meter vom Restaurant entfernt sein.',
                        style: TextStyle(
                          fontSize: AppFontSizes.labelSmall,
                          height: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Anzahl der Personen',
                style: TextStyle(
                  fontSize: AppFontSizes.button,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personen',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: _guestCount > 1
                              ? () => setState(() => _guestCount--)
                              : null,
                        ),
                        Text(
                          '$_guestCount',
                          style: const TextStyle(
                            fontSize: AppFontSizes.subtitle,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: _guestCount < 50
                              ? () => setState(() => _guestCount++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              if (!deal.location.hasCoordinates)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Check-in noch nicht verfügbar: Der Betreiber muss zuerst den Kartenstandort dieses Restaurants hinterlegen.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
              CustomButton(
                text: 'Standort prüfen & einchecken',
                isLoading: checkInProvider.isLoading || _locating,
                onPressed: deal.location.hasCoordinates ? _handleCheckin : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
