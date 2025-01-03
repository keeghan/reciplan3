import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reciplan3/data/entities/recipe.dart';
import 'package:reciplan3/util/storage_service.dart';
import 'package:reciplan3/util/theme_provider.dart';
import 'package:reciplan3/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../recipe_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences prefs;
  late RecipeViewModel _viewModel;
  bool isDarkMode = true;
  bool isHapticsEnabled = true;
  final String version = '1.0.0';
  final String buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<RecipeViewModel>();
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
      final List<Recipe>? recipes = await _viewModel.getUserCreatedRecipes();
      if (recipes == null) {
        if (mounted) MyUtils.showSnackBar(context, _viewModel.error.toString());
        return;
      }
      if (recipes.isEmpty) {
        if (mounted) MyUtils.showSnackBar(context, 'No local recipes to export');
        return;
      }
      final String jsonString = jsonEncode(recipes);

      String fileNamePrefix = await _showExportDialog();
      if (fileNamePrefix.isEmpty) return; //User cancelled dialog box
      String fileName = "$fileNamePrefix'_'${getDateTimeString()}";

      final  directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsString(jsonString);
      StorageService().copyToDownloads(filePath, fileName);
      if (mounted) MyUtils.showSnackBar(context, 'Exported to Downloads folder');
    } catch (e) {
      print(e);
      if (mounted) {
        MyUtils.showSnackBar(context, 'Error exporting recipes: ${e.toString()}');
      }
    }
  }

  Future<void> _importRecipes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final File file = File(result.files.single.path!);
        final String contents = await file.readAsString();

        final List<Recipe> recipes = await MyUtils.convertToRecipes(jsonDecode(contents));
        // Import recipes to database
        await _importRecipesToDatabase(recipes);
          if (mounted) MyUtils.showSnackBar(context, '${recipes.length} recipes imported');
      }
    } catch (e) {
      if (mounted) {
        MyUtils.showSnackBar(context, 'Error importing recipes: ${e.toString()}');
      }
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

  //TODO: fix message
  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!mounted) return;
      MyUtils.showSnackBar(context, 'Could not launch $url');
    }
  }

  Future<void> _importRecipesToDatabase(List<Recipe> recipes) async {
    try {
      await _viewModel.insertRecipes(recipes);
    } catch (e) {
      print(e);
      if (mounted) {
        MyUtils.showSnackBar(context, 'Error importing recipes: ${e.toString()}');
      }
    }
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
            subtitle: const Text('Export your added as a .Json file'),
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

  String getDateTimeString() {
    DateTime now = DateTime.now();
    String fileNameDateTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-'
        '${now.second.toString().padLeft(2, '0')}';
    return fileNameDateTime;
  }

}