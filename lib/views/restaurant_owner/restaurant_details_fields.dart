import 'package:flutter/material.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../data/models/deal_model.dart';

Map<String, dynamic> restaurantExtraFields(DealModel? r) => {
  'contactEmail': r?.contactEmail ?? '',
  'category': r?.categories.isNotEmpty == true
      ? r!.categories.join(', ')
      : r?.category?.categoryName ?? '',
  'contactPhone': r?.contactPhone ?? '',
  'timeZone': r?.timeZone ?? 'Europe/Berlin',
  'priceRange': r?.priceRange ?? r'$$',
  'opensAt': r?.opensAt?.toUtc().toIso8601String() ?? '',
  'offers': r?.offers ?? <String>[],
  'showTeamReviews': r?.showTeamReviews ?? true,
  'openingHours':
      [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ]
          .map(
            (day) =>
                r?.openingHoursSchedule
                    .where((h) => h['day'] == day)
                    .firstOrNull ??
                {'day': day, 'open': '09:00', 'close': '22:00', 'closed': true},
          )
          .toList(),
};

class RestaurantDetailsFields extends StatelessWidget {
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChange;
  const RestaurantDetailsFields({
    super.key,
    required this.value,
    required this.onChange,
  });
  void _update(String key, dynamic v) => onChange({...value, key: v});
  @override
  Widget build(BuildContext context) {
    final hours = (value['openingHours'] as List)
        .map((v) => Map<String, dynamic>.from(v))
        .toList();
    const labels = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Kontakt & Öffnungszeiten',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        for (final entry in {
          'contactEmail': 'Restaurant-E-Mail',
          'contactPhone': 'Telefon',
          'timeZone': 'Zeitzone',
          'category': 'Küchenart',
        }.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              initialValue: value[entry.key]?.toString() ?? '',
              decoration: InputDecoration(labelText: entry.value),
              onChanged: (v) => _update(entry.key, v),
            ),
          ),
        AppDropdown<String>(
          value: value['priceRange'],
          decoration: const InputDecoration(labelText: 'Preisklasse'),
          items: [
            r'$',
            r'$$',
            r'$$$',
            r'$$$$',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => _update('priceRange', v),
        ),
        const SizedBox(height: 24),
        const Text(
          'Öffnungszeiten',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < hours.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(labels[i])),
                Switch(
                  value: hours[i]['closed'] != true,
                  onChanged: (v) {
                    hours[i]['closed'] = !v;
                    _update('openingHours', hours);
                  },
                ),
                for (final key in ['open', 'close'])
                  Expanded(
                    child: TextButton(
                      onPressed: hours[i]['closed'] == true
                          ? null
                          : () async {
                              final parts = hours[i][key].toString().split(':');
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.tryParse(parts[0]) ?? 9,
                                  minute: int.tryParse(parts.last) ?? 0,
                                ),
                              );
                              if (time != null) {
                                hours[i][key] =
                                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                _update('openingHours', hours);
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 44),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(hours[i][key].toString()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Eröffnung (optional)'),
          subtitle: Text(
            value['opensAt']?.toString().isNotEmpty == true
                ? DateTime.parse(value['opensAt']).toLocal().toString()
                : 'Kein Datum',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _update('opensAt', ''),
          ),
          onTap: () async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: now.subtract(const Duration(days: 365)),
              lastDate: now.add(const Duration(days: 3650)),
            );
            if (date == null || !context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 0),
            );
            if (time != null) {
              _update(
                'opensAt',
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ).toUtc().toIso8601String(),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: (value['offers'] as List).join('\n'),
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Angebotstexte (eine Zeile pro Angebot)',
          ),
          onChanged: (v) => _update('offers', v.split('\n')),
        ),
      ],
    );
  }
}
