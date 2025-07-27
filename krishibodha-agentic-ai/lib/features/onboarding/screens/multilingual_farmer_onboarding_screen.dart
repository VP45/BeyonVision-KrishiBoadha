import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/language/providers/language_provider.dart';
import 'package:myapp/features/onboarding/providers/onboarding_provider.dart';
import 'package:myapp/models/farmer_profile.dart';
import 'package:myapp/services/firestore_service.dart';

class MultilingualFarmerOnboardingScreen extends ConsumerStatefulWidget {
  const MultilingualFarmerOnboardingScreen({super.key});

  @override
  ConsumerState<MultilingualFarmerOnboardingScreen> createState() =>
      _MultilingualFarmerOnboardingScreenState();
}

class _MultilingualFarmerOnboardingScreenState
    extends ConsumerState<MultilingualFarmerOnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool isLoading = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _farmingExperienceController =
      TextEditingController();

  List<String> selectedCrops = [];
  final List<String> availableCrops = [
    'Wheat',
    'Rice',
    'Corn',
    'Tomato',
    'Potato',
    'Onion',
    'Sugarcane',
    'Cotton',
    'Soybean',
    'Mustard',
    'Groundnut',
  ];

  // Form keys for validation
  final GlobalKey<FormState> _personalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _farmFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set default/dummy values for quick onboarding
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _nameController.text = 'राज कुमार'; // Default farmer name
    _phoneController.text = '9876543210'; // Default phone
    _villageController.text = 'रामपुर'; // Default village
    _districtController.text = 'आगरा'; // Default district
    _stateController.text = 'उत्तर प्रदेश'; // Default state
    _farmSizeController.text = '5'; // Default 5 acres
    _farmingExperienceController.text = '10'; // Default 10 years experience
    selectedCrops = ['Wheat', 'Rice']; // Default crops
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _farmSizeController.dispose();
    _farmingExperienceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String translate(String key) {
    final language = ref.read(languageProvider);
    return AppLocalizations.translate(key, language) ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
                : null,
        title: Text(
          translate('complete_profile'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                _buildPersonalDetailsPage(),
                _buildFarmDetailsPage(),
                _buildCropsSelectionPage(),
              ],
            ),
          ),

          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:
                    index <= currentPage ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('farmer_details'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate('enter_your_details'),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _nameController,
              label: translate('name'),
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _phoneController,
              label: translate('phone_number'),
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                if (value.length < 10) {
                  return translate('invalid_phone');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _villageController,
              label: translate('village'),
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _districtController,
              label: translate('district'),
              icon: Icons.map,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _stateController,
              label: translate('state'),
              icon: Icons.public,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _farmFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('farm_information'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate('enter_your_details'),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _farmSizeController,
              label: translate('farm_size'),
              icon: Icons.agriculture,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                if (double.tryParse(value) == null) {
                  return translate('invalid_number');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _farmingExperienceController,
              label: translate('farming_experience'),
              icon: Icons.timeline,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return translate('required_field');
                }
                if (int.tryParse(value) == null) {
                  return translate('invalid_number');
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('crops_grown'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the crops you grow on your farm',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
            ),
            itemCount: availableCrops.length,
            itemBuilder: (context, index) {
              final crop = availableCrops[index];
              final isSelected = selectedCrops.contains(crop);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedCrops.remove(crop);
                    } else {
                      selectedCrops.add(crop);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color:
                            isSelected ? AppColors.primary : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          crop,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? AppColors.primary : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        currentPage == 2
                            ? translate('submit')
                            : translate('next'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSubmit() async {
    if (currentPage == 0) {
      if (_personalFormKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (currentPage == 1) {
      if (_farmFormKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      await _submitFarmerProfile();
    }
  }

  Future<void> _submitFarmerProfile() async {
    if (selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one crop'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final language = ref.read(languageProvider);
      final profile = FarmerProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        village: _villageController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        farmSize: double.parse(_farmSizeController.text.trim()),
        cropsGrown: selectedCrops,
        farmingExperience: int.parse(_farmingExperienceController.text.trim()),
        preferredLanguage: language,
        isComplete: true,
      );

      final farmerId = await FirestoreService.saveFarmerProfile(profile);
      print('Farmer profile saved with ID: $farmerId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Move to map screen for farm details
        ref.read(onboardingProvider.notifier).completeFarmerOnboarding();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
