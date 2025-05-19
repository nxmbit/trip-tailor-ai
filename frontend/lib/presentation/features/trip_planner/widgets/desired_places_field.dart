import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/language_provider.dart';
import '../state/desired_places_field_state.dart';

class DesiredPlacesField extends StatefulWidget {
  final String? destination;
  final List<String>? initialPlaces;
  final Function(List<String>)? onPlacesChanged;

  const DesiredPlacesField({
    Key? key,
    required this.destination,
    this.initialPlaces,
    this.onPlacesChanged,
  }) : super(key: key);

  @override
  State<DesiredPlacesField> createState() => _DesiredPlacesFieldState();
}

class _DesiredPlacesFieldState extends State<DesiredPlacesField> {
  DesiredPlacesFieldState? _state;
  final GlobalKey _fieldKey = GlobalKey();
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
      _state = DesiredPlacesFieldState(
        getCurrentLanguage: _getCurrentLanguage,
        onPlacesChanged: widget.onPlacesChanged,
        initialDestination: widget.destination,
        initialPlaces: widget.initialPlaces,
      );
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
  void didUpdateWidget(DesiredPlacesField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update destination only if it has changed
    if (_state != null && widget.destination != oldWidget.destination) {
      _state!.updateDestination(widget.destination);
    }

    // Update callback if it changes
    if (_state != null && widget.onPlacesChanged != oldWidget.onPlacesChanged) {
      _state!.updateCallback(widget.onPlacesChanged);
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
      child: Consumer<DesiredPlacesFieldState>(
        builder: (context, state, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add the key to this container to measure its width
                Container(
                  key: _fieldKey,
                  child: Autocomplete<String>(
                    optionsBuilder: state.desiredPlacesOptionsBuilder,
                    onSelected: (String selection) {
                      // Use a post-frame callback to avoid setState during build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        state.onDesiredPlaceSelected(selection);
                      });
                    },
                    // Add this optionsViewBuilder to constrain the dropdown width
                    optionsViewBuilder: (context, onSelected, options) {
                      // Get the RenderBox of the field to determine its width
                      final RenderBox fieldBox =
                          _fieldKey.currentContext?.findRenderObject()
                              as RenderBox;
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
                      // Synchronize with state's controller without listeners
                      if (textEditingController.text !=
                          state.textController.text) {
                        textEditingController.text = state.textController.text;
                      }

                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        enabled: state.isEnabled,
                        decoration: InputDecoration(
                          labelText: tr(context, 'tripPlanner.desiredPlaces'),
                          hintText:
                              state.isEnabled
                                  ? '${tr(context, 'tripPlanner.desiredPlacesHint')} ${widget.destination}'
                                  : tr(
                                    context,
                                    'tripPlanner.selectDestinationFirst',
                                  ),
                          prefixIcon: const Icon(Icons.add_location),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: (String value) {
                          if (state.isEnabled && value.isNotEmpty) {
                            // Use post-frame callback for state changes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              state.onDesiredPlaceSelected(value);
                              // Keep focus for convenient multiple entries
                              FocusScope.of(context).requestFocus(focusNode);
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                if (state.hasPlaces) _buildDesiredPlacesChips(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesiredPlacesChips(DesiredPlacesFieldState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children:
            state.desiredPlaces
                .map(
                  (place) => Chip(
                    label: Text(place),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () {
                      // Use post-frame callback for state changes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        state.removePlace(place);
                      });
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}
