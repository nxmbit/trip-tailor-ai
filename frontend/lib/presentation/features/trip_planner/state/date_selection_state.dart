import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';

class DateSelectionState extends ChangeNotifier {
  // State variables
  DateTime? _startDate;
  DateTime? _endDate;

  // Trip duration constants
  static const int maxTripDays = 10;

  // Getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get hasStartDate => _startDate != null;
  bool get hasEndDate => _endDate != null;
  bool get hasValidDateRange => _startDate != null && _endDate != null;

  // Language function
  final Locale Function() getCurrentLocale;

  // Callbacks
  Function(DateTime?, DateTime?)? onDatesChanged;

  // Constructor
  DateSelectionState({
    required this.getCurrentLocale,
    this.onDatesChanged,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) {
    // Initialize with provided dates
    _startDate = initialStartDate;
    _endDate = initialEndDate;

    // Validate initial dates if both are provided
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        _endDate = null;
      }
    }
  }

  // Methods to update dates
  Future<void> selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _startDate ?? now;
    final firstDate = now;
    final lastDate = now.add(Duration(days: maxTripDays));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: getCurrentLocale(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      updateStartDate(picked);
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      // If no start date, select start date first
      await selectStartDate(context);
      if (_startDate == null) return; // User canceled start date selection
    }

    // Calculate date constraints
    final now = DateTime.now();
    final firstDate = _startDate!; // End date must be on or after start date

    // End date can't be more than 10 days from TODAY or more than maxTripDays from start date
    final lastDateFromToday = now.add(Duration(days: maxTripDays));
    final lastDateFromStart = _startDate!.add(Duration(days: maxTripDays - 1));

    // The last date is the earlier of the two constraints
    final lastDate =
        lastDateFromToday.isBefore(lastDateFromStart)
            ? lastDateFromToday
            : lastDateFromStart;

    // Calculate initial date, ensuring it's not after lastDate
    DateTime initialDate = _getEndDateInitialValue();
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: getCurrentLocale(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      updateEndDate(picked);
    }
  }

  DateTime _getEndDateInitialValue() {
    return _endDate ??
        (_startDate != null
            ? _startDate!.add(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 1)));
  }

  void updateStartDate(DateTime newStartDate) {
    _startDate = newStartDate;

    // If end date is before the new start date, reset it
    if (_endDate != null && _endDate!.isBefore(newStartDate)) {
      _endDate = null;
    }

    // If end date would make trip longer than allowed, reset it
    final maxAllowedEndDate = newStartDate.add(Duration(days: maxTripDays - 1));
    if (_endDate != null && _endDate!.isAfter(maxAllowedEndDate)) {
      _endDate = null;
    }

    // Notify listeners to update UI
    notifyListeners();

    // Notify parent
    _notifyParent();

    debugPrint('Updated start date: $_startDate');
  }

  void updateEndDate(DateTime newEndDate) {
    // Ensure end date is not before start date
    if (_startDate != null && newEndDate.isBefore(_startDate!)) {
      debugPrint('Invalid end date: Cannot be before start date');
      return;
    }

    // Ensure trip is not longer than allowed
    if (_startDate != null) {
      final maxAllowedEndDate = _startDate!.add(
        Duration(days: maxTripDays - 1),
      );
      if (newEndDate.isAfter(maxAllowedEndDate)) {
        debugPrint(
          'Invalid end date: Trip cannot be longer than $maxTripDays days',
        );
        return;
      }
    }

    _endDate = newEndDate;

    // Notify listeners to update UI
    notifyListeners();

    // Notify parent
    _notifyParent();

    debugPrint('Updated end date: $_endDate');
  }

  // Rest of the class remains the same...
  void clearDates() {
    _startDate = null;
    _endDate = null;

    // Notify listeners to update UI
    notifyListeners();

    // Notify parent
    _notifyParent();

    debugPrint('Cleared dates');
  }

  void updateCallback(Function(DateTime?, DateTime?)? newCallback) {
    onDatesChanged = newCallback;
  }

  // Notify parent on next frame to avoid rebuild errors
  void _notifyParent() {
    if (onDatesChanged != null) {
      Future.microtask(() {
        onDatesChanged!(_startDate, _endDate);
      });
    }
  }

  String formatDate(DateTime? date, BuildContext context) {
    if (date == null) return tr(context, 'tripPlanner.selectDate');
    return '${date.day}/${date.month}/${date.year}';
  }
}
