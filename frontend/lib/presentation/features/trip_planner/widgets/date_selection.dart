import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/language_provider.dart';
import '../state/date_selection_state.dart';

class DateSelectionRow extends StatefulWidget {
  final Function(DateTime?, DateTime?)? onDatesChanged;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateSelectionRow({
    Key? key,
    this.onDatesChanged,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  State<DateSelectionRow> createState() => _DateSelectionRowState();
}

class _DateSelectionRowState extends State<DateSelectionRow> {
  DateSelectionState? _state;

  @override
  void initState() {
    super.initState();
    // Initialize after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeState();
    });
  }

  void _initializeState() {
    setState(() {
      _state = DateSelectionState(
        getCurrentLocale: _getCurrentLocale,
        onDatesChanged: widget.onDatesChanged,
        initialStartDate: widget.initialStartDate,
        initialEndDate: widget.initialEndDate,
      );
    });
  }

  Locale _getCurrentLocale() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.locale;
  }

  @override
  void didUpdateWidget(DateSelectionRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update callback if it changes
    if (_state != null && widget.onDatesChanged != oldWidget.onDatesChanged) {
      _state!.updateCallback(widget.onDatesChanged);
    }

    // Update initial dates if they change and are different from current state
    if (_state != null) {
      bool needsUpdate = false;

      if (widget.initialStartDate != oldWidget.initialStartDate &&
          widget.initialStartDate != _state!.startDate) {
        needsUpdate = true;
      }

      if (widget.initialEndDate != oldWidget.initialEndDate &&
          widget.initialEndDate != _state!.endDate) {
        needsUpdate = true;
      }

      if (needsUpdate) {
        _state = DateSelectionState(
          getCurrentLocale: _getCurrentLocale,
          onDatesChanged: widget.onDatesChanged,
          initialStartDate: widget.initialStartDate,
          initialEndDate: widget.initialEndDate,
        );
      }
    }
  }

  @override
  void dispose() {
    _state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If state isn't initialized yet, show loading indicator
    if (_state == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      );
    }

    return ChangeNotifierProvider.value(
      value: _state!,
      child: Consumer<DateSelectionState>(
        builder: (context, state, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context: context,
                    state: state,
                    isStartDate: true,
                    labelText: tr(context, 'tripPlanner.startDate'),
                    date: state.startDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context: context,
                    state: state,
                    isStartDate: false,
                    labelText: tr(context, 'tripPlanner.endDate'),
                    date: state.endDate,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required DateSelectionState state,
    required bool isStartDate,
    required String labelText,
    required DateTime? date,
  }) {
    final isEnabled = isStartDate || state.hasStartDate;
    return InkWell(
      onTap:
          isEnabled
              ? () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (isStartDate) {
                    state.selectStartDate(context);
                  } else {
                    state.selectEndDate(context);
                  }
                });
              }
              : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          enabled: isEnabled,
        ),
        child: Text(
          state.formatDate(date, context),
          style: TextStyle(
            color:
                isEnabled
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
