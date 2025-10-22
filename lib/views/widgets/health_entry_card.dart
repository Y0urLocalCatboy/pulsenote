import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/health_entry.dart';
import '../../viewmodels/health_viewmodel.dart';
import '../../providers/theme_provider.dart';
import 'neon_container.dart';
import 'ecg_line_widget.dart';

class HealthEntryCard extends StatelessWidget {
  final HealthEntry entry;

  const HealthEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp);
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return NeonContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ECG Animation
          ECGLineWidget(pulseRate: entry.pulse, width: 80, height: 50),
          const SizedBox(width: 16),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: neonColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.pulse} BPM',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: neonColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'BP: ${entry.systolic}/${entry.diastolic} mmHg',
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: neonColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: neonColor.withOpacity(0.7)),
                iconSize: 20,
                onPressed: () => _showEditDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                iconSize: 20,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final pulseController = TextEditingController(text: entry.pulse.toString());
    final systolicController = TextEditingController(
      text: entry.systolic.toString(),
    );
    final diastolicController = TextEditingController(
      text: entry.diastolic.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final neonColor = context.watch<ThemeProvider>().neonColor;
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            'MODIFY DATA ENTRY',
            style: GoogleFonts.orbitron(color: neonColor, letterSpacing: 1.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pulseController,
                  style: GoogleFonts.robotoMono(color: neonColor),
                  decoration: InputDecoration(
                    labelText: 'PULSE (BPM)',
                    labelStyle: GoogleFonts.orbitron(
                      color: neonColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: systolicController,
                  style: GoogleFonts.robotoMono(color: neonColor),
                  decoration: InputDecoration(
                    labelText: 'SYSTOLIC (mmHg)',
                    labelStyle: GoogleFonts.orbitron(
                      color: neonColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diastolicController,
                  style: GoogleFonts.robotoMono(color: neonColor),
                  decoration: InputDecoration(
                    labelText: 'DIASTOLIC (mmHg)',
                    labelStyle: GoogleFonts.orbitron(
                      color: neonColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: neonColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'CANCEL',
                style: GoogleFonts.orbitron(
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'PURGE',
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      final pulse = int.tryParse(pulseController.text);
      final systolic = int.tryParse(systolicController.text);
      final diastolic = int.tryParse(diastolicController.text);

      if (pulse != null && systolic != null && diastolic != null) {
        final updatedEntry = entry.copyWith(
          pulse: pulse,
          systolic: systolic,
          diastolic: diastolic,
        );

        final viewModel = context.read<HealthViewModel>();
        await viewModel.updateEntry(updatedEntry);

        if (context.mounted) {
          final neonColor = context.read<ThemeProvider>().neonColor;
          if (viewModel.updateState.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ MEMORY SECTOR OVERWRITTEN',
                  style: GoogleFonts.orbitron(letterSpacing: 1),
                ),
                backgroundColor: neonColor.withOpacity(0.2),
              ),
            );
            viewModel.resetUpdateState();
          } else if (viewModel.updateState.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✗ UPDATE PROTOCOL FAILED: ${viewModel.updateState.error}',
                  style: GoogleFonts.orbitron(letterSpacing: 1),
                ),
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✗ CORRUPTED DATA STREAM',
                style: GoogleFonts.orbitron(letterSpacing: 1),
              ),
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
          );
        }
      }
    }

    pulseController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final neonColor = context.watch<ThemeProvider>().neonColor;
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            'PURGE DATA ENTRY',
            style: GoogleFonts.orbitron(color: Colors.red, letterSpacing: 1.5),
          ),
          content: Text(
            'WARNING: Irreversible memory wipe. Continue with data purge protocol?',
            style: GoogleFonts.robotoMono(
              color: Colors.grey[300],
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'CANCEL',
                style: GoogleFonts.orbitron(color: neonColor, letterSpacing: 1),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'PURGE',
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final viewModel = context.read<HealthViewModel>();
      await viewModel.deleteEntry(entry.id!);

      if (context.mounted && viewModel.deleteState.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'DELETION ERROR: ${viewModel.deleteState.error}',
              style: GoogleFonts.orbitron(letterSpacing: 1),
            ),
          ),
        );
      }
    }
  }
}
