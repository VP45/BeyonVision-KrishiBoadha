import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/widgets/gradient_button.dart';
import '../../../models/farmer_profile.dart';

class FarmerProfileSummaryScreen extends ConsumerStatefulWidget {
  final FarmerProfile profile;

  const FarmerProfileSummaryScreen({super.key, required this.profile});

  @override
  ConsumerState<FarmerProfileSummaryScreen> createState() =>
      _FarmerProfileSummaryScreenState();
}

class _FarmerProfileSummaryScreenState
    extends ConsumerState<FarmerProfileSummaryScreen> {
  late FarmerProfile _editableProfile;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _editableProfile = widget.profile;
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers['name'] = TextEditingController(
      text: _editableProfile.name ?? '',
    );
    _controllers['description'] = TextEditingController(
      text: _editableProfile.description ?? '',
    );
    _controllers['goals'] = TextEditingController(
      text: _editableProfile.goals ?? '',
    );
    _controllers['crops'] = TextEditingController(
      text: _editableProfile.crops.join(', '),
    );
    _controllers['aadhar'] = TextEditingController(
      text: _editableProfile.aadharNumber ?? '',
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    // Update the profile with edited values
    _editableProfile = _editableProfile.copyWith(
      name:
          _controllers['name']!.text.trim().isEmpty
              ? null
              : _controllers['name']!.text.trim(),
      description:
          _controllers['description']!.text.trim().isEmpty
              ? null
              : _controllers['description']!.text.trim(),
      goals:
          _controllers['goals']!.text.trim().isEmpty
              ? null
              : _controllers['goals']!.text.trim(),
      crops:
          _controllers['crops']!.text.trim().isEmpty
              ? []
              : _controllers['crops']!.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
      aadharNumber:
          _controllers['aadhar']!.text.replaceAll(RegExp(r'[^\d]'), '').isEmpty
              ? null
              : _controllers['aadhar']!.text.replaceAll(RegExp(r'[^\d]'), ''),
      isComplete: true,
    );

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('किसान प्रोफाइल सफलतापूर्वक सहेजी गई!'),
        backgroundColor: AppColors.successColor,
      ),
    );

    // Navigate back to main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'किसान प्रोफाइल सारांश',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Success indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.successColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'पंजीकरण पूरा हो गया! कृपया अपनी जानकारी की जांच करें।',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Editable profile form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion progress
                    _buildCompletionIndicator(),

                    const SizedBox(height: 24),

                    // Editable fields
                    _buildEditableField(
                      'नाम',
                      'name',
                      Icons.person,
                      'अपना पूरा नाम दर्ज करें',
                    ),

                    const SizedBox(height: 16),

                    // Location (read-only for now)
                    if (_editableProfile.hasLocation) _buildLocationField(),

                    const SizedBox(height: 16),

                    _buildEditableField(
                      'विवरण',
                      'description',
                      Icons.description,
                      'अपने खेती के अनुभव के बारे में बताएं',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    _buildEditableField(
                      'लक्ष्य',
                      'goals',
                      Icons.flag,
                      'आप खेती से क्या हासिल करना चाहते हैं?',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    _buildEditableField(
                      'फसलें',
                      'crops',
                      Icons.grass,
                      'फसलों के नाम कॉमा से अलग करके लिखें',
                    ),

                    const SizedBox(height: 16),

                    _buildEditableField(
                      'आधार नंबर',
                      'aadhar',
                      Icons.credit_card,
                      '12 अंकों का आधार नंबर',
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.edit),
                            label: const Text('और संपादन'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GradientButton(
                            text: 'प्रोफाइल सहेजें',
                            onPressed: _saveChanges,
                            height: 48,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    double completion = _editableProfile.completionPercentage;
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'प्रोफाइल पूर्णता',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${completion.toInt()}%',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                completion >= 100 ? AppColors.successColor : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String key,
    IconData icon,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Card(
      elevation: 1,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllers[key],
              maxLines: maxLines,
              keyboardType: keyboardType,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                counterText: maxLength != null ? null : '',
              ),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Card(
      elevation: 1,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'स्थान',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'अक्षांश: ${_editableProfile.latitude!.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'देशांतर: ${_editableProfile.longitude!.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
