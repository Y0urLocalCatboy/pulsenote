import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../views/achievements_page.dart';
import '../views/analysis_page.dart';
import '../views/charts_page.dart';
import '../views/statistics_page.dart';
import 'widgets/achievement_dialog.dart';
import 'widgets/health_entry_card.dart';
import 'widgets/health_entry_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? _achievementSubscription;
  StreamSubscription? _rankUpSubscription;

  @override
  void initState() {
    super.initState();
    // Request permissions after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HealthViewModel>();
      if (viewModel.isHealthPlatformSupported) {
        viewModel.requestHealthPermissions();
      }

      // Listen for achievement unlocks
      _achievementSubscription = viewModel.onAchievementUnlocked.listen((
        achievement,
      ) {
        if (mounted) {
          _showAchievementDialog(achievement);
        }
      });

      // Listen for rank ups
      _rankUpSubscription = viewModel.onRankUp.listen((rankInfo) {
        if (mounted) {
          _showRankUpDialog(rankInfo);
        }
      });
    });
  }

  @override
  void dispose() {
    _achievementSubscription?.cancel();
    _rankUpSubscription?.cancel();
    super.dispose();
  }

  void _showAchievementDialog(achievement) {
    final neonColor = context.read<ThemeProvider>().neonColor;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
        neonColor: neonColor,
      ),
    );
  }

  void _showRankUpDialog(rankInfo) {
    final neonColor = context.read<ThemeProvider>().neonColor;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RankUpDialog(rankInfo: rankInfo, neonColor: neonColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PULSENOTE',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisPage()),
              );
            },
            tooltip: 'Health Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartsPage()),
              );
            },
            tooltip: 'View Charts',
          ),
          IconButton(
            icon: const Icon(Icons.auto_graph),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsPage()),
              );
            },
            tooltip: 'Statistics & Records',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsPage(),
                ),
              );
            },
            tooltip: 'Achievements',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              context.read<ThemeProvider>().cycleColorScheme();
            },
            tooltip: 'Change Neon Color',
          ),
          Consumer<HealthViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isHealthPlatformSupported &&
                  viewModel.healthAuthorized) {
                return IconButton(
                  icon: const Icon(Icons.health_and_safety),
                  onPressed: () => _showHealthInfo(context),
                  tooltip: 'Health integration active',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              neonColor.withOpacity(0.05),
              const Color(0xFF0A0A0A),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HealthEntryForm(),
              const SizedBox(height: 32),
              Text(
                'RECENT ENTRIES',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: neonColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<HealthViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.entries.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: neonColor.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.monitor_heart_outlined,
                            size: 48,
                            color: neonColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'NO DATA DETECTED',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              color: neonColor.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Initialize biodata capture protocol',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.entries.length,
                    itemBuilder: (context, index) {
                      return HealthEntryCard(entry: viewModel.entries[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<HealthViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isHealthPlatformSupported &&
              !viewModel.healthAuthorized) {
            return FloatingActionButton.extended(
              onPressed: () async {
                await viewModel.requestHealthPermissions();
                if (context.mounted && viewModel.healthAuthorized) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'HEALTH INTEGRATION ENABLED',
                        style: GoogleFonts.orbitron(letterSpacing: 1),
                      ),
                      backgroundColor: neonColor.withOpacity(0.2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.health_and_safety),
              label: Text(
                'ENABLE SYNC',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showHealthInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Colors.green),
            SizedBox(width: 8),
            Text('Health Integration'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✓ Connected to Apple Health / Google Health Connect'),
            SizedBox(height: 8),
            Text('Your entries are automatically synced to your health app.'),
            SizedBox(height: 8),
            Text(
              'Use the "Sync from Health App" button to import existing data.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
