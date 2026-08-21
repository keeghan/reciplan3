import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/app/settings/app_settings_state.dart';
import 'package:reciplan3/logic/app/theme/app_theme_cubit.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/logic/settings/import_export_cubit.dart';
import 'package:reciplan3/logic/settings/import_export_state.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'package:reciplan3/util/utils.dart';

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
        appBar: AppBar(title: const Text('Settings')),
        body: _buildSettingsContent(context),
      ),
    );
  }

  // Builds settings for the current window width.
  Widget _buildSettingsContent(BuildContext context) {
    final windowClass = AppBreakpoints.windowClass(context);
    final padding = EdgeInsets.fromLTRB(
      AppBreakpoints.gutter(context),
      8,
      AppBreakpoints.gutter(context),
      32,
    );
    if (windowClass == AppWindowClass.compact) {
      return ListView(
        padding: padding,
        children: _stackedSettings(context),
      );
    }
    if (windowClass == AppWindowClass.medium) {
      return AppConstrainedContent(
        maxWidth: AppBreakpoints.readableContent,
        padding: padding,
        child: ListView(children: _stackedSettings(context)),
      );
    }
    return AppConstrainedContent(
      maxWidth: AppBreakpoints.standardContent,
      padding: padding,
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SettingsSection(
                  title: 'Appearance',
                  subtitle: 'Make Reciplan feel right for you.',
                  card: _appearanceCard(context),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _SettingsSection(
                  title: 'Your data',
                  subtitle: 'Move or back up recipes you created.',
                  card: _dataCard(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SettingsSection(
            title: 'About',
            subtitle: 'Reciplan information and support.',
            card: _aboutCard(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _stackedSettings(BuildContext context) {
    return [
      _SettingsSection(
        title: 'Appearance',
        subtitle: 'Make Reciplan feel right for you.',
        card: _appearanceCard(context),
      ),
      const SizedBox(height: 28),
      _SettingsSection(
        title: 'Your data',
        subtitle: 'Move or back up recipes you created.',
        card: _dataCard(context),
      ),
      const SizedBox(height: 28),
      _SettingsSection(
        title: 'About',
        subtitle: 'Reciplan information and support.',
        card: _aboutCard(context),
      ),
    ];
  }

  Widget _appearanceCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          BlocBuilder<AppThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                subtitle: Text(isDark ? 'On' : 'Off'),
                value: isDark,
                onChanged: context.read<AppThemeCubit>().setDarkMode,
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, state) {
              return SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: const Text('Haptics'),
                subtitle: Text(state.hapticsEnabled ? 'On' : 'Off'),
                value: state.hapticsEnabled,
                onChanged: context.read<AppSettingsCubit>().setHapticsEnabled,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dataCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.file_upload_outlined,
            title: 'Export recipes',
            subtitle: 'Save your recipes as a JSON file',
            onTap: () => _showExportDialog(context),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.file_download_outlined,
            title: 'Import recipes',
            subtitle: 'Add recipes from a compatible file',
            onTap: context.read<ImportExportCubit>().importRecipes,
          ),
        ],
      ),
    );
  }

  Widget _aboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Developer',
            subtitle: 'Meet the maker of Reciplan',
            onTap: () => _showDevInfo(context),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.mail_outline,
            title: 'Contact developer',
            subtitle: 'Send feedback or ask for help',
            onTap: () => _contactDev(context),
          ),
          const Divider(height: 1, indent: 56),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(
                  info == null ? 'Loading…' : '${info.version} (${info.buildNumber})',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Requests an export file name.
  Future<void> _showExportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export recipes'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'File name',
            hintText: 'My recipes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Export'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || result == null || result.trim().isEmpty) {
      return;
    }
    context.read<ImportExportCubit>().exportRecipes(result);
  }

  // Shows developer details.
  void _showDevInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.person_outline),
        title: const Text('Kojo Kakraba Eghan'),
        content: const Text(
          'Software developer and technology enthusiast with a passion for 3D modelling.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.tonal(
            onPressed: () => _launchUrl(
              context,
              'https://kojokeghan.wordpress.com/',
            ),
            child: const Text('View profile'),
          ),
        ],
      ),
    );
  }

  // Opens a new developer email.
  Future<void> _contactDev(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'Eghan20@gmail.com',
      queryParameters: const {'subject': 'Reciplan App'},
    );
    await _launchUrl(context, emailUri.toString());
  }

  // Opens an external URL.
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      MyUtils.showSnackBar(context, 'Could not open the link');
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget card;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        card,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
