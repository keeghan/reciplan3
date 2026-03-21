import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/app/settings/app_settings_state.dart';
import 'package:reciplan3/logic/app/theme/app_theme_cubit.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/logic/settings/import_export_cubit.dart';
import 'package:reciplan3/logic/settings/import_export_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImportExportCubit(
        context.read<RecipeRepository>(),
        context.read<ImportExportService>(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImportExportCubit, ImportExportState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message != null) {
          MyUtils.showSnackBar(context, message);
          context.read<ImportExportCubit>().clearFeedback();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            BlocBuilder<AppThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDarkMode = themeMode == ThemeMode.dark;
                return ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(isDarkMode ? 'Disable dark mode' : 'Enable dark mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => context.read<AppThemeCubit>().setDarkMode(value),
                  ),
                );
              },
            ),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, state) {
                return ListTile(
                  title: const Text('Haptics'),
                  subtitle: Text(
                    state.hapticsEnabled ? 'Disable haptics' : 'Enable haptics',
                  ),
                  trailing: Switch(
                    value: state.hapticsEnabled,
                    onChanged: (value) =>
                        context.read<AppSettingsCubit>().setHapticsEnabled(value),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Export Recipes'),
              subtitle: const Text('Export your added recipes as a .json file'),
              onTap: () => _showExportDialog(context),
            ),
            ListTile(
              title: const Text('Import Recipes'),
              subtitle: const Text('Import recipes from a file'),
              onTap: () => context.read<ImportExportCubit>().importRecipes(),
            ),
            ListTile(
              title: const Text('Developer Info'),
              subtitle: const Text('View developer information'),
              onTap: () => _showDevInfo(context),
            ),
            ListTile(
              title: const Text('Contact Developer'),
              subtitle: const Text('Send an email to the developer'),
              onTap: () => _contactDev(context),
            ),
            const ListTile(
              title: Text('Version'),
              subtitle: Text('v1.0.0 (1)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Recipes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File Name',
            hintText: 'Enter file name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!context.mounted || result == null || result.trim().isEmpty) {
      return;
    }

    context.read<ImportExportCubit>().exportRecipes(result);
  }

  void _showDevInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kojo Kakraba Eghan is a software developer and a technology enthusiast with a passion in 3D modelling',
            ),
            InkWell(
              onTap: () => _launchUrl(context, 'https://kojokeghan.wordpress.com/'),
              child: const Text(
                'Developer Profile',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactDev(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'Eghan20@gmail.com',
      queryParameters: const {
        'subject': 'Reciplan App',
      },
    );
    await _launchUrl(context, emailUri.toString());
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      MyUtils.showSnackBar(context, 'Could not launch $url');
    }
  }
}
