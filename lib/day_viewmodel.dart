import 'package:flutter/foundation.dart';
import '../../data/repositories/day_repository.dart';
import '../../data/entities/day.dart';

class DayViewModel extends ChangeNotifier {
  final DayRepository _dayRepository;
  List<Day> _days = [];
  bool _isLoading = false;
  String? _error;

  DayViewModel(this._dayRepository);

  // Getters
  List<Day> get days => _days;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all days
  Future<void> loadDays() async {
    try {
      _isLoading = true;
      notifyListeners();
      _days = await _dayRepository.getAllDays();
      _error = null;
    } catch (e) {
      _error = 'Failed to load days: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new day
  Future<void> createDay(Day day) async {
    try {
      await _dayRepository.createDay(day);
      await loadDays();
    } catch (e) {
      _error = 'Failed to create day: $e';
      notifyListeners();
    }
  }

  // Update existing day
  // Future<void> updateDay(int dayId, int recipeId, int mealType) async {
  //   try {
  //     await _dayRepository.updateDayMeal(dayId, recipeId, mealType);
  //     await loadDays();
  //   } catch (e) {
  //     _error = 'Failed to update day: $e';
  //     notifyListeners();
  //   }
  // }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
