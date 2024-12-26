import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reciplan3/util/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences prefs;
  bool isDarkMode = true;
  bool isHapticsEnabled = true;
  final String version = '1.0.0';
  final String buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('pref_theme') ?? true;
      isHapticsEnabled = prefs.getBool('pref_haptics') ?? true;
    });
  }

  Future<void> _updateHaptics(bool value) async {
    await prefs.setBool('pref_haptics', value);
    setState(() {
      isHapticsEnabled = value;
    });
  }

  Future<void> _exportRecipes() async {
    try {
      // Get recipes  database
      final List<Map<String, dynamic>> recipes =
          await _getAllUserCreatedRecipes();

      if (recipes.isEmpty) {
        _showSnackBar('No local recipes to export');
        return;
      }

      String fileName = await _showExportDialog();
      if (fileName.isEmpty) return;

      final String jsonString = jsonEncode(recipes);

      // Get the exported recipes from directory
      final directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName.json');

      await file.writeAsString(jsonString);
      _showSnackBar('Recipes exported successfully');
    } catch (e) {
      _showSnackBar('Error exporting recipes: ${e.toString()}');
    }
  }

  //Todo: Work on recipe Import and Export
  Future<void> _importRecipes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final File file = File(result.files.single.path!);
        final String contents = await file.readAsString();

        final List<dynamic> recipes = jsonDecode(contents);
        // Import recipes to database
        await _importRecipesToDatabase(recipes);
        _showSnackBar('Recipes imported successfully');
      }
    } catch (e) {
      _showSnackBar('Error importing recipes: ${e.toString()}');
    }
  }

  Future<String> _showExportDialog() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
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
    return result ?? '';
  }

  void _showDevInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Kojo Kakraba Eghan is a software developer and a Technology enthusiast with a passion in 3D modelling'),
            InkWell(
              onTap: () => _launchUrl('https://kojokeghan.wordpress.com/'),
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

  Future<void> _contactDev() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Eghan20@gmail.com',
      queryParameters: {
        'subject': 'Reciplan App',
      },
    );
    await _launchUrl(emailLaunchUri.toString());
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Could not launch $url');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<List<Map<String, dynamic>>> _getAllUserCreatedRecipes() async {
    // Todo: Implement get all user Recipes
    return [];
  }

  Future<void> _importRecipesToDatabase(List<dynamic> recipes) async {
    // Todo: Implement import logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle:
                Text(isDarkMode ? 'Disable dark mode' : 'Enable dark mode'),
            trailing:
                Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.updateTheme(value);
                },
              );
            }),
          ),
          ListTile(
            title: const Text('Haptics'),
            subtitle:
                Text(isHapticsEnabled ? 'Disable haptics' : 'Enable haptics'),
            trailing: Switch(
              value: isHapticsEnabled,
              onChanged: _updateHaptics,
            ),
          ),
          ListTile(
            title: const Text('Export Recipes'),
            subtitle: const Text('Export your recipes to a file'),
            onTap: _exportRecipes,
          ),
          ListTile(
            title: const Text('Import Recipes'),
            subtitle: const Text('Import recipes from a file'),
            onTap: _importRecipes,
          ),
          ListTile(
            title: const Text('Developer Info'),
            subtitle: const Text('View developer information'),
            onTap: _showDevInfo,
          ),
          ListTile(
            title: const Text('Contact Developer'),
            subtitle: const Text('Send an email to the developer'),
            onTap: _contactDev,
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: Text('v$version ($buildNumber)'),
          ),
        ],
      ),
    );
  }
}
