import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'models.dart';

class SettingsDialog extends StatefulWidget {
  final PDFSettingsStruct settings;
  final ValueChanged<PDFSettingsStruct> onSettingsChanged;

  SettingsDialog({required this.settings, required this.onSettingsChanged});

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late PDFSettingsStruct _settings;
  late Color _headerColor;
  late Color _footerColor;
  late Color _infoBoxColor;
  late Color _borderColor;
  late Color _backgroundCircleColor1;
  late Color _backgroundCircleColor2;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _headerColor = _settings.headerColor;
    _footerColor = _settings.footerColor;
    _infoBoxColor = _settings.infoBoxColor;
    _borderColor = _settings.borderColor;
    _backgroundCircleColor1 = _settings.backgroundCircleColor1;
    _backgroundCircleColor2 = _settings.backgroundCircleColor2;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('PDF Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Page Format'),
              value: _settings.pageFormat,
              items: ['A3', 'A4', 'A5', 'Letter', 'Legal']
                  .map((format) => DropdownMenuItem(
                value: format,
                child: Text(format),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _settings.pageFormat = value!;
                });
              },
            ),
            SwitchListTile(
              title: Text('Landscape'),
              value: _settings.isLandscape,
              onChanged: (value) {
                setState(() {
                  _settings.isLandscape = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Logo'),
              value: _settings.showLogo,
              onChanged: (value) {
                setState(() {
                  _settings.showLogo = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Payment Methods'),
              value: _settings.showPaymentMethods,
              onChanged: (value) {
                setState(() {
                  _settings.showPaymentMethods = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Terms and Conditions'),
              value: _settings.showTermsAndConditions,
              onChanged: (value) {
                setState(() {
                  _settings.showTermsAndConditions = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Discount Percentage Column'),
              value: _settings.showDiscountPercentageColumn,
              onChanged: (value) {
                setState(() {
                  _settings.showDiscountPercentageColumn = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Discount Amount Column'),
              value: _settings.showDiscountAmountColumn,
              onChanged: (value) {
                setState(() {
                  _settings.showDiscountAmountColumn = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Tax Percentage Column'),
              value: _settings.showTaxPercentageColumn,
              onChanged: (value) {
                setState(() {
                  _settings.showTaxPercentageColumn = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Tax Amount Column'),
              value: _settings.showTaxAmountColumn,
              onChanged: (value) {
                setState(() {
                  _settings.showTaxAmountColumn = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Signature'),
              value: _settings.showSignature,
              onChanged: (value) {
                setState(() {
                  _settings.showSignature = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Unit Column'),
              value: _settings.showUnitColumn,
              onChanged: (value) {
                setState(() {
                  _settings.showUnitColumn = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Disable Colors'),
              value: _settings.disableColors,
              onChanged: (value) {
                setState(() {
                  _settings.disableColors = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Use Border Color'),
              value: _settings.useBorderColor,
              onChanged: (value) {
                setState(() {
                  _settings.useBorderColor = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show Background Shapes'),
              value: _settings.showBackgroundShapes,
              onChanged: (value) {
                setState(() {
                  _settings.showBackgroundShapes = value;
                });
              },
            ),
            ListTile(
              title: Text('Header Color'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _headerColor,
              ),
              onTap: () => _pickColor(context, 'Header Color', _headerColor, (color) {
                setState(() {
                  _headerColor = color;
                  _settings.headerColor = color;
                });
              }),
            ),
            ListTile(
              title: Text('Footer Color'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _footerColor,
              ),
              onTap: () => _pickColor(context, 'Footer Color', _footerColor, (color) {
                setState(() {
                  _footerColor = color;
                  _settings.footerColor = color;
                });
              }),
            ),
            ListTile(
              title: Text('Info Box Color'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _infoBoxColor,
              ),
              onTap: () => _pickColor(context, 'Info Box Color', _infoBoxColor, (color) {
                setState(() {
                  _infoBoxColor = color;
                  _settings.infoBoxColor = color;
                });
              }),
            ),
            ListTile(
              title: Text('Border Color'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _borderColor,
              ),
              onTap: () => _pickColor(context, 'Border Color', _borderColor, (color) {
                setState(() {
                  _borderColor = color;
                  _settings.borderColor = color;
                });
              }),
            ),
            ListTile(
              title: Text('Background Circle Color 1'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _backgroundCircleColor1,
              ),
              onTap: () => _pickColor(context, 'Background Circle Color 1', _backgroundCircleColor1, (color) {
                setState(() {
                  _backgroundCircleColor1 = color;
                  _settings.backgroundCircleColor1 = color;
                });
              }),
            ),
            ListTile(
              title: Text('Background Circle Color 2'),
              trailing: Container(
                width: 24,
                height: 24,
                color: _backgroundCircleColor2,
              ),
              onTap: () => _pickColor(context, 'Background Circle Color 2', _backgroundCircleColor2, (color) {
                setState(() {
                  _backgroundCircleColor2 = color;
                  _settings.backgroundCircleColor2 = color;
                });
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSettingsChanged(_settings);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  void _pickColor(BuildContext context, String title, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
