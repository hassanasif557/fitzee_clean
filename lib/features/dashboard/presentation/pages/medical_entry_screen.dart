import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/models/medical_entry.dart';
import 'package:fitzee_new/core/services/medical_entry_service.dart';
import 'package:intl/intl.dart';

class MedicalEntryScreen extends StatefulWidget {
  const MedicalEntryScreen({super.key});

  @override
  State<MedicalEntryScreen> createState() => _MedicalEntryScreenState();
}

class _MedicalEntryScreenState extends State<MedicalEntryScreen> {
  String _selectedType = 'blood_pressure';
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _customLabelController = TextEditingController();
  final _customValueController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _entryDateTime = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _sugarController.dispose();
    _customLabelController.dispose();
    _customValueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _entryDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_entryDateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _entryDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final description = _descriptionController.text.trim();
    final desc = description.isEmpty ? null : description;

    if (_selectedType == 'blood_pressure') {
      final sys = int.tryParse(_bpSystolicController.text.trim());
      final dia = int.tryParse(_bpDiastolicController.text.trim());
      if (sys == null || dia == null) {
        _showError('Enter valid systolic and diastolic values');
        return;
      }
      final entry = MedicalEntry(
        id: 'med_${_entryDateTime.millisecondsSinceEpoch}',
        dateTime: _entryDateTime,
        type: 'blood_pressure',
        label: 'Blood Pressure',
        valuePrimary: sys.toDouble(),
        valueSecondary: dia,
        description: desc,
      );
      await MedicalEntryService.saveMedicalEntry(entry);
    } else if (_selectedType == 'sugar_level') {
      final val = double.tryParse(_sugarController.text.trim());
      if (val == null) {
        _showError('Enter a valid sugar level');
        return;
      }
      final entry = MedicalEntry(
        id: 'med_${_entryDateTime.millisecondsSinceEpoch}',
        dateTime: _entryDateTime,
        type: 'sugar_level',
        label: 'Blood sugar (mg/dL)',
        valuePrimary: val,
        description: desc,
      );
      await MedicalEntryService.saveMedicalEntry(entry);
    } else {
      final label = _customLabelController.text.trim();
      if (label.isEmpty) {
        _showError('Enter a label for custom entry');
        return;
      }
      final valueText = _customValueController.text.trim();
      final valueNum = double.tryParse(valueText);
      final entry = MedicalEntry(
        id: 'med_${_entryDateTime.millisecondsSinceEpoch}',
        dateTime: _entryDateTime,
        type: 'custom',
        label: label,
        valuePrimary: valueNum,
        valueText: valueText.isEmpty ? null : valueText,
        description: desc,
      );
      await MedicalEntryService.saveMedicalEntry(entry);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical entry saved'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Add Medical Info',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date & time
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDarkBlueGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGreenDark.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_entryDateTime),
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('jm').format(_entryDateTime),
                          style: const TextStyle(color: AppColors.textGray, fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: AppColors.textGray, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Type selector
            const Text(
              'Type',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _typeChip('blood_pressure', 'Blood Pressure', Icons.bloodtype),
                const SizedBox(width: 8),
                _typeChip('sugar_level', 'Sugar Level', Icons.monitor_heart),
                const SizedBox(width: 8),
                _typeChip('custom', 'Custom', Icons.edit_note),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedType == 'blood_pressure') _buildBloodPressureFields(),
            if (_selectedType == 'sugar_level') _buildSugarFields(),
            if (_selectedType == 'custom') _buildCustomFields(),
            const SizedBox(height: 20),
            // Description (optional)
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                labelStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundDarkBlueGreen,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textBlack),
                      )
                    : const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type, String label, IconData icon) {
    final selected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen.withOpacity(0.25) : AppColors.backgroundDarkBlueGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryGreen : AppColors.borderGreenDark.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primaryGreen : AppColors.textGray, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? AppColors.primaryGreen : AppColors.textGray,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodPressureFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bpSystolicController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: 'Systolic (mmHg)',
                  labelStyle: const TextStyle(color: AppColors.textGray),
                  hintText: '120',
                  filled: true,
                  fillColor: AppColors.backgroundDarkBlueGreen,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _bpDiastolicController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: 'Diastolic (mmHg)',
                  labelStyle: const TextStyle(color: AppColors.textGray),
                  hintText: '80',
                  filled: true,
                  fillColor: AppColors.backgroundDarkBlueGreen,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSugarFields() {
    return TextField(
      controller: _sugarController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: 'Blood sugar (mg/dL)',
        labelStyle: const TextStyle(color: AppColors.textGray),
        hintText: 'e.g. 100',
        prefixIcon: const Icon(Icons.monitor_heart, color: AppColors.primaryGreen),
        filled: true,
        fillColor: AppColors.backgroundDarkBlueGreen,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCustomFields() {
    return Column(
      children: [
        TextField(
          controller: _customLabelController,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            labelText: 'Label (e.g. Weight, Temperature)',
            labelStyle: const TextStyle(color: AppColors.textGray),
            hintText: 'e.g. Weight',
            filled: true,
            fillColor: AppColors.backgroundDarkBlueGreen,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _customValueController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            labelText: 'Value (e.g. 70 kg, 98.6°F)',
            labelStyle: const TextStyle(color: AppColors.textGray),
            hintText: 'e.g. 70 kg',
            filled: true,
            fillColor: AppColors.backgroundDarkBlueGreen,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
