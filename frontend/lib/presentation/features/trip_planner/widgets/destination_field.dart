import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import '../../../../data/api/api_client.dart';
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
  final GlobalKey _fieldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    // Initialize after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeState();
    });
  }

  // In the _initializeState method:
  void _initializeState() {
    final apiClient = Provider.of<ApiClient>(context, listen: false);

    setState(() {
      _state = DestinationFieldState(
        getCurrentLanguage: _getCurrentLanguage,
        apiClient: apiClient,
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
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      _state = DestinationFieldState(
        getCurrentLanguage: _getCurrentLanguage,
        apiClient: apiClient,
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
            // Add the key to this container to measure its width
            child: Container(
              key: _fieldKey,
              child: Autocomplete<String>(
                optionsBuilder: state.destinationOptionsBuilder,
                onSelected: state.onDestinationSelected,
                optionsViewBuilder: (context, onSelected, options) {
                  // Get the RenderBox of the field to determine its width
                  final RenderBox fieldBox =
                      _fieldKey.currentContext?.findRenderObject() as RenderBox;
                  final fieldWidth = fieldBox.size.width;

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Use the actual width of the field
                          maxWidth: fieldWidth,
                          maxHeight:
                              200, // Limit height to prevent too much vertical space
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
            ),
          );
        },
      ),
    );
  }
}
