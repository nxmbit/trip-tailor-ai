import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/language_provider.dart';
import '../state/destination_field_state.dart';

class DestinationField extends StatefulWidget {
  final Function(String?)? onDestinationChanged;
  final String? initialDestination;

  const DestinationField({
    Key? key,
    this.onDestinationChanged,
    this.initialDestination,
  }) : super(key: key);

  @override
  State<DestinationField> createState() => _DestinationFieldState();
}

class _DestinationFieldState extends State<DestinationField> {
  DestinationFieldState? _state;

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
      _state = DestinationFieldState(
        getCurrentLanguage: _getCurrentLanguage,
        onDestinationChanged: widget.onDestinationChanged,
      );

      if (widget.initialDestination != null) {
        _state!.onDestinationSelected(widget.initialDestination!);
      }
    });
  }

  String _getCurrentLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.locale.languageCode;
  }

  @override
  void didUpdateWidget(DestinationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update callback if it changes
    if (_state != null &&
        widget.onDestinationChanged != oldWidget.onDestinationChanged) {
      _state = DestinationFieldState(
        getCurrentLanguage: _getCurrentLanguage,
        onDestinationChanged: widget.onDestinationChanged,
      );

      if (widget.initialDestination != null) {
        _state!.onDestinationSelected(widget.initialDestination!);
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

    // Using Consumer pattern instead of separate widget class
    return ChangeNotifierProvider.value(
      value: _state!,
      child: Consumer<DestinationFieldState>(
        builder: (context, state, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Autocomplete<String>(
              optionsBuilder: state.destinationOptionsBuilder,
              onSelected: state.onDestinationSelected,
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Set initial text if a destination is already selected
                if (state.selectedDestination != null &&
                    textEditingController.text.isEmpty) {
                  textEditingController.text = state.selectedDestination!;
                }

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: tr(context, 'tripPlanner.destination'),
                    hintText: tr(context, 'tripPlanner.destinationHint'),
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                  onChanged: state.handleDestinationFieldChange,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
