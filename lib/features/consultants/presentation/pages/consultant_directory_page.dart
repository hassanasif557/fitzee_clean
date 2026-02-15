import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/consultant_remote_datasource.dart';
import '../../data/repositories/consultant_repository_impl.dart';
import '../../domain/entities/doctor.dart';
import '../cubit/consultant_cubit.dart';
import '../cubit/consultant_state.dart';
import '../widgets/doctor_card.dart';

class ConsultantDirectoryPage extends StatefulWidget {
  const ConsultantDirectoryPage({super.key});

  @override
  State<ConsultantDirectoryPage> createState() => _ConsultantDirectoryPageState();
}

class _ConsultantDirectoryPageState extends State<ConsultantDirectoryPage> {
  String? _selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsultantCubit(
        ConsultantRepositoryImpl(
          ConsultantRemoteDatasource(FirebaseFirestore.instance),
        ),
      )..loadDoctors(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.backgroundDark,
              elevation: 0,
              pinned: true,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: Text(
                  'Consultants',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundDark,
                        AppColors.backgroundDark.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: BlocBuilder<ConsultantCubit, ConsultantState>(
                  builder: (context, state) {
                    if (state is! ConsultantLoaded) return const SizedBox.shrink();
                    final specialities = _specialitiesFrom(state.doctors);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speciality',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip('All', _selectedSpecialty == null || _selectedSpecialty == 'All'),
                            ...specialities.map((s) => _chip(s, _selectedSpecialty == s)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            BlocBuilder<ConsultantCubit, ConsultantState>(
              builder: (context, state) {
                if (state is ConsultantLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  );
                }
                if (state is ConsultantError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is ConsultantLoaded) {
                  final filtered = _filterDoctors(state.doctors, _selectedSpecialty);
                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _selectedSpecialty == null || _selectedSpecialty == 'All'
                              ? 'No consultants yet'
                              : 'No consultants in $_selectedSpecialty',
                          style: const TextStyle(color: AppColors.textGray),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: DoctorCard(doctor: filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _specialitiesFrom(List<Doctor> doctors) {
    final set = doctors.map((d) => d.speciality).where((s) => s.isNotEmpty).toSet();
    final list = set.toList()..sort();
    return list;
  }

  List<Doctor> _filterDoctors(List<Doctor> doctors, String? specialty) {
    if (specialty == null || specialty == 'All') return doctors;
    return doctors.where((d) => d.speciality == specialty).toList();
  }

  Widget _chip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedSpecialty = label == 'All' ? null : label),
      selectedColor: AppColors.primaryGreen.withOpacity(0.35),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryGreen : AppColors.textGray,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      side: BorderSide(
        color: selected ? AppColors.primaryGreen : AppColors.borderGreenDark.withOpacity(0.4),
      ),
    );
  }
}
