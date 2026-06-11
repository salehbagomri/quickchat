import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:quickchat/l10n/app_localizations.dart';

class PhoneInputCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onCountryChanged;
  final AppLocalizations l10n;

  const PhoneInputCard({
    required this.controller,
    required this.onCountryChanged,
    required this.l10n,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CountryCodePicker(
              onChanged: (code) => onCountryChanged(code.dialCode ?? '+967'),
              initialSelection: 'YE',
              favorite: const ['+967', '+966', '+20', '+971'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              backgroundColor: cs.surface,
              barrierColor: Colors.black54,
              dialogBackgroundColor: cs.surface,
              searchDecoration: InputDecoration(
                hintText: l10n.search,
                hintStyle: TextStyle(color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dialogTextStyle: TextStyle(color: cs.onSurface, fontSize: 16),
              searchStyle: TextStyle(color: cs.onSurface, fontSize: 16),
              textStyle: TextStyle(color: cs.onSurface, fontSize: 16),
              closeIcon: Icon(Icons.close, color: cs.onSurface),
              emptySearchBuilder: (_) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noResults,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: l10n.enterPhoneNumber,
                  border: InputBorder.none,
                  filled: false,
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
