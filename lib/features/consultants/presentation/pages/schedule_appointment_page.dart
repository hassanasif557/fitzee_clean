import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/consultants/data/datasources/consultant_remote_datasource.dart';
import 'package:fitzee_new/features/consultants/data/repositories/appointment_repository_impl.dart';
import 'package:fitzee_new/features/consultants/domain/entities/doctor.dart';
import 'package:fitzee_new/features/consultants/presentation/pages/payment_pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final Doctor doctor;

  const ScheduleAppointmentPage({super.key, required this.doctor});

  @override
  State<ScheduleAppointmentPage> createState() => _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  DateTime? selectedDate;
  String? selectedTime;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  static const int _daysAhead = 60;

  late final AppointmentRepositoryImpl _appointmentRepo;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    final remote = ConsultantRemoteDatasource(firestore);
    _appointmentRepo = AppointmentRepositoryImpl(firestore, remote);
  }

  List<DateTime> get _selectableDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekdays = widget.doctor.availableWeekdays;
    final list = <DateTime>[];
    for (var i = 0; i < _daysAhead; i++) {
      final d = today.add(Duration(days: i));
      if (weekdays.contains(d.weekday)) list.add(d);
    }
    return list;
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      selectedDate = date;
      selectedTime = null;
      _availableSlots = [];
      _loadingSlots = true;
    });
    final slotsForDay = widget.doctor.slotsForWeekday(date.weekday);
    if (slotsForDay.isEmpty) {
      setState(() {
        _loadingSlots = false;
        _availableSlots = [];
      });
      return;
    }
    try {
      final booked = await _appointmentRepo.getBookedSlots(widget.doctor.id, date);
      setState(() {
        _availableSlots = slotsForDay.where((s) => !booked.contains(s)).toList()..sort();
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _loadingSlots = false;
        _availableSlots = slotsForDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _selectableDates;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'Schedule appointment',
          style: TextStyle(color: AppColors.textWhite, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date section
            Text(
              'Select date',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final d = dates[i];
                  final isSelected = selectedDate != null &&
                      selectedDate!.year == d.year &&
                      selectedDate!.month == d.month &&
                      selectedDate!.day == d.day;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onDateSelected(d),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withOpacity(0.25)
                              : AppColors.backgroundDarkBlueGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.borderGreenDark.withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('EEE, MMM d').format(d),
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Time section
            Text(
              'Select time',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (selectedDate == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Choose a date first',
                  style: TextStyle(color: AppColors.textGray, fontSize: 14),
                ),
              )
            else if (_loadingSlots)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                  ),
                ),
              )
            else if (_availableSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No slots available on this day',
                  style: TextStyle(color: AppColors.textGray, fontSize: 14),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableSlots.map(_timeChip).toList(),
              ),
            const Spacer(),
            _priceCard(),
            const SizedBox(height: 16),
            _proceedButton(context),
          ],
        ),
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkBlueGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreenDark.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total', style: TextStyle(color: AppColors.textGray)),
          Text(
            '\$${widget.doctor.pricePerHour}',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proceedButton(BuildContext context) {
    final canProceed = selectedDate != null && selectedTime != null;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.textBlack,
          disabledBackgroundColor: AppColors.backgroundDarkBlueGreen,
          disabledForegroundColor: AppColors.textGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: canProceed
            ? () {
                final date = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      doctor: widget.doctor,
                      selectedDate: date,
                      selectedTime: selectedTime!,
                    ),
                  ),
                );
              }
            : null,
        child: const Text(
          'Proceed to Payment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _timeChip(String time) {
    final isSelected = selectedTime == time;
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textBlack : AppColors.textWhite,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryGreen : AppColors.borderGreenDark.withOpacity(0.4),
      ),
      onSelected: (_) => setState(() => selectedTime = time),
    );
  }
}
