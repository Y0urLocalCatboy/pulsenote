import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/health_viewmodel.dart';
import '../../providers/theme_provider.dart';
import 'neon_container.dart';
import 'neon_button.dart';

class HealthEntryForm extends StatefulWidget {
  const HealthEntryForm({super.key});

  @override
  State<HealthEntryForm> createState() => _HealthEntryFormState();
}

class _HealthEntryFormState extends State<HealthEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _pulseController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  @override
  void dispose() {
    _pulseController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return Consumer<HealthViewModel>(
      builder: (context, viewModel, child) {
        return NeonContainer(
          padding: const EdgeInsets.all(20.0),
          pulsing: viewModel.isLoading,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD NEW READING',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: neonColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCyberTextField(
                  controller: _pulseController,
                  label: 'PULSE (BPM)',
                  icon: Icons.favorite,
                  hint: 'Baseline: 60-100 • Critical: <40/>200',
                  validator: _validatePulse,
                  neonColor: neonColor,
                ),
                const SizedBox(height: 16),
                _buildCyberTextField(
                  controller: _systolicController,
                  label: 'SYSTOLIC (mmHg)',
                  icon: Icons.arrow_upward,
                  hint: 'Peak pressure • Nominal: 90-120',
                  validator: _validateSystolic,
                  neonColor: neonColor,
                ),
                const SizedBox(height: 16),
                _buildCyberTextField(
                  controller: _diastolicController,
                  label: 'DIASTOLIC (mmHg)',
                  icon: Icons.arrow_downward,
                  hint: 'Base pressure • Nominal: 60-80',
                  validator: _validateDiastolic,
                  neonColor: neonColor,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NeonButton(
                      label: viewModel.isLoading ? 'SAVING...' : 'SAVE ENTRY',
                      icon: Icons.save,
                      onPressed: viewModel.isLoading
                          ? () {}
                          : () => _saveEntry(viewModel),
                    ),
                    if (viewModel.isHealthPlatformSupported &&
                        viewModel.healthAuthorized) ...[
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'SYNC FROM DEVICE',
                        icon: Icons.sync,
                        small: true,
                        onPressed: viewModel.isLoading
                            ? () {}
                            : () => _syncFromDevice(viewModel),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCyberTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    required Color neonColor,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.robotoMono(color: neonColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.orbitron(
          color: neonColor.withOpacity(0.7),
          fontSize: 12,
          letterSpacing: 1,
        ),
        helperText: hint,
        helperStyle: GoogleFonts.robotoMono(
          color: Colors.grey[600],
          fontSize: 10,
        ),
        prefixIcon: Icon(icon, color: neonColor, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: neonColor.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: neonColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
      ),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }

  String? _validatePulse(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠ HEARTRATE SENSOR OFFLINE';
    }
    final pulse = int.tryParse(value);
    if (pulse == null) {
      return '✗ MALFORMED DATA PACKET';
    }
    if (pulse < 40 || pulse > 200) {
      return '✗ BIOSIGNAL OUT OF BOUNDS [40-200]';
    }
    return null;
  }

  String? _validateSystolic(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠ SYSTOLIC SENSOR OFFLINE';
    }
    final systolic = int.tryParse(value);
    if (systolic == null) {
      return '✗ MALFORMED DATA PACKET';
    }
    if (systolic < 70 || systolic > 190) {
      return '✗ PRESSURE ANOMALY [70-190]';
    }
    return null;
  }

  String? _validateDiastolic(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠ DIASTOLIC SENSOR OFFLINE';
    }
    final diastolic = int.tryParse(value);
    if (diastolic == null) {
      return '✗ MALFORMED DATA PACKET';
    }
    if (diastolic < 40 || diastolic > 130) {
      return '✗ PRESSURE ANOMALY [40-130]';
    }
    return null;
  }

  Future<void> _saveEntry(HealthViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      await viewModel.saveEntry(
        pulse: int.parse(_pulseController.text),
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        syncToDevice: viewModel.healthAuthorized,
      );

      if (!mounted) return;

      if (viewModel.saveState.isSuccess) {
        final neonColor = context.read<ThemeProvider>().neonColor;
        _pulseController.clear();
        _systolicController.clear();
        _diastolicController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ BIODATA STREAM UPLOADED',
              style: GoogleFonts.orbitron(letterSpacing: 1),
            ),
            backgroundColor: neonColor.withOpacity(0.2),
          ),
        );
        viewModel.resetSaveState();
      } else if (viewModel.saveState.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✗ UPLOAD FAILED: ${viewModel.saveState.error}',
              style: GoogleFonts.orbitron(letterSpacing: 1),
            ),
            backgroundColor: Colors.red.withOpacity(0.2),
          ),
        );
      }
    }
  }

  Future<void> _syncFromDevice(HealthViewModel viewModel) async {
    await viewModel.syncFromDevice();

    if (!mounted) return;

    if (viewModel.syncState.isSuccess) {
      final neonColor = context.read<ThemeProvider>().neonColor;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ NEURAL LINK SYNC COMPLETE',
            style: GoogleFonts.orbitron(letterSpacing: 1),
          ),
          backgroundColor: neonColor.withOpacity(0.2),
        ),
      );
      viewModel.resetSyncState();
    } else if (viewModel.syncState.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✗ NEURAL LINK ERROR: ${viewModel.syncState.error}',
            style: GoogleFonts.orbitron(letterSpacing: 1),
          ),
          backgroundColor: Colors.red.withOpacity(0.2),
        ),
      );
    }
  }
}
