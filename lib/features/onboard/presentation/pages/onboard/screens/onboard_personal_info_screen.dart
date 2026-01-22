import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardPersonalInfoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardPersonalInfoScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardPersonalInfoScreen> createState() =>
      _OnboardPersonalInfoScreenState();
}

class _OnboardPersonalInfoScreenState
    extends State<OnboardPersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load existing values if any
    final cubit = context.read<OnboardCubit>();
    final profile = cubit.profile;
    
    // Load name
    if (profile.name != null) {
      _nameController.text = profile.name!;
    }
    
    // Load phone from Firebase Auth or profile
    final user = FirebaseAuth.instance.currentUser;
    if (user?.phoneNumber != null && profile.phone == null) {
      cubit.setPhone(user!.phoneNumber!);
    } else if (profile.phone != null) {
      // Phone already in profile
    }
    
    if (profile.height != null) {
      _heightController.text = profile.height!.toString();
    }
    if (profile.weight != null) {
      _weightController.text = profile.weight!.toString();
    }
    if (profile.age != null) {
      _ageController.text = profile.age!.toString();
    }
    if (profile.gender != null) {
      _selectedGender = profile.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDarkBlueGreen,
              AppColors.backgroundDarkBlueGreen.withOpacity(0.98),
              AppColors.backgroundDarkBlueGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textWhite,
                        ),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            context.pop();
                          }
                        },
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 20 : 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // AI Analysis Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDarkLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Waveform placeholder
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDarkBlueGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomPaint(
                                  painter: WaveformPainter(),
                                  child: Container(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI ANALYSIS',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Daily Insight',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You slept less yesterday—reduce intensity today.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(
                                color: AppColors.textGray,
                                thickness: 0.5,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.bedtime,
                                        color: AppColors.textGray,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '5h 20m Sleep',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: AppColors.textBlack,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Adjust Plan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Smart Coaching Title
                        const Text(
                          'Smart Coaching',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Receive daily AI-driven insights based on your sleep, activity, and health data.',
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 14 : 16,
                            color: AppColors.textGray,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Personal Info Fields
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name Input
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            hintText: 'John Doe',
                            hintStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Please enter a valid name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              context.read<OnboardCubit>().setName(value.trim());
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Height Input
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            hintText: '170',
                            hintStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            prefixIcon: const Icon(
                              Icons.height,
                              color: AppColors.primaryGreen,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Height is required';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height < 50 || height > 300) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              context.read<OnboardCubit>().setHeight(
                                    double.parse(value),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Weight Input
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            labelStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            hintText: '70',
                            hintStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            prefixIcon: const Icon(
                              Icons.monitor_weight,
                              color: AppColors.primaryGreen,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Weight is required';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight < 20 || weight > 300) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              context.read<OnboardCubit>().setWeight(
                                    double.parse(value),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Gender Selection
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGenderOption('male', 'Male'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGenderOption('female', 'Female'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGenderOption('other', 'Other'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Age Input
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            hintText: '25',
                            hintStyle: const TextStyle(
                              color: AppColors.textGray,
                            ),
                            prefixIcon: const Icon(
                              Icons.cake,
                              color: AppColors.primaryGreen,
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Age is required';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 13 || age > 120) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              context.read<OnboardCubit>().setAge(
                                    int.parse(value),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        // Pagination Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.textGray,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.textGray,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate form
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              // Check gender
                              if (_selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select your gender',
                                    ),
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                );
                                return;
                              }

                              // Save all form fields (this triggers onSaved callbacks)
                              _formKey.currentState!.save();
                              
                              // Explicitly set all values to ensure they're saved
                              final cubit = context.read<OnboardCubit>();
                              if (_nameController.text.isNotEmpty) {
                                cubit.setName(_nameController.text.trim());
                              }
                              if (_heightController.text.isNotEmpty) {
                                cubit.setHeight(double.parse(_heightController.text));
                              }
                              if (_weightController.text.isNotEmpty) {
                                cubit.setWeight(double.parse(_weightController.text));
                              }
                              if (_ageController.text.isNotEmpty) {
                                cubit.setAge(int.parse(_ageController.text));
                              }
                              cubit.setGender(_selectedGender!);
                              
                              // Set phone from Firebase Auth if available
                              final user = FirebaseAuth.instance.currentUser;
                              if (user?.phoneNumber != null) {
                                cubit.setPhone(user!.phoneNumber!);
                              }

                              // Continue to next screen
                              if (widget.onContinue != null) {
                                widget.onContinue!();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.textBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label) {
    final isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
        context.read<OnboardCubit>().setGender(value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.2)
              : AppColors.backgroundDarkLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderGreen.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Simple waveform painter for the AI Analysis card
class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // Create a simple waveform
    for (double x = 0; x < width; x += 8) {
      final y = centerY +
          (centerY * 0.7) *
              (0.5 + 0.5 * (x / width)) *
              (0.5 + 0.5 * (x % 20 / 20));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
