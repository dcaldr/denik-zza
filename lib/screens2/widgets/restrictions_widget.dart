import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';

class RestrictionsWidget extends StatefulWidget {
  final LogicInterface logic;
  final int? participantId;

  const RestrictionsWidget(
      {super.key, required this.logic, this.participantId});

  @override
  State<RestrictionsWidget> createState() => _RestrictionsWidgetState();

  void update() {
    // Note: Creating a new state instance here doesn't actually update the widget in the tree.
    // This seems to be a flaw in the original logic, but preserving it as requested (no logic changes).
    _RestrictionsWidgetState? state = _RestrictionsWidgetState();
    state._updateData();
  }
}

class _RestrictionsWidgetState extends State<RestrictionsWidget> {
  late final LogicInterface _logic;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreBelow = false;

  @override
  void initState() {
    super.initState();
    _logic = widget.logic;
    _fetchData();
    _scrollController.addListener(_updateScrollIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (!_scrollController.hasClients) return;
    final hasMore = _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 10;
    if (hasMore != _hasMoreBelow) {
      setState(() => _hasMoreBelow = hasMore);
    }
  }

  Future<void> _fetchData() async {
    await _logic.fetchData(widget.participantId);
    if (mounted) setState(() {});
  }

  Future<void> _updateData() async {
    await _logic.update();
    if (mounted) setState(() {});
  }

  void _addItem(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _logic.addItem(name);
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Removed SingleChildScrollView to prevent nested scroll wiggle.
    // Parent form handles scrolling. See /scroll-wiggle-prompt workflow.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _logic.getText(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.s),

        // Height-bounded list with scroll indicator (pattern from record_list_widget)
        if (_logic.items.isNotEmpty) _buildBoundedList(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // If width is too small, stack vertically
              if (constraints.maxWidth < 200) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildAutocomplete(),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: _buildAddButton(),
                    ),
                  ],
                );
              }

              // For normal widths, use horizontal layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAutocomplete(),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _buildAddButton(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds height-bounded list with scroll indicator when scrollable.
  Widget _buildBoundedList() {
    // Check for scroll indicator after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollIndicator();
    });

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 150),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _logic.items.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline, size: 16),
                title: Text(
                  _logic.items[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            },
          ),
          // Gradient indicator when there's more content below
          if (_hasMoreBelow)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.greyBackground.withValues(alpha: 0.0),
                        AppColors.greyBackground.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blueBackground,
                        borderRadius: AppRadii.containerRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_arrow_down,
                              size: 12, color: AppColors.blueText),
                          Text('více',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.blueText)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _logic.names.where((name) {
          return name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (selection) {
        // Autosuggest: fill field with selection, don't auto-add
        // User must press Enter or Add button to confirm
        _controller.text = selection;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Sync Autocomplete's controller value to our controller for Add button
        // Using addListener instead of replacing reference to avoid lifecycle issues
        textEditingController.addListener(() {
          if (_controller.text != textEditingController.text) {
            _controller.text = textEditingController.text;
          }
        });

        // Key for E2E testing - allows testing robots to find this field
        return TextField(
          key: Key('RestrictionsWidget_${_logic.getText()}_input'),
          controller: textEditingController,
          focusNode: focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            _addItem(value);
            onFieldSubmitted(); // Important for Autocomplete to close
          },
          decoration: const InputDecoration(
            labelText: 'Zadejte položku',
            // Border and styling handled by ZzaTheme
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    // Key for E2E testing - allows testing robots to tap add button
    return IconButton(
      key: Key('RestrictionsWidget_${_logic.getText()}_add_button'),
      icon: const Icon(Icons.add_circle),
      color: Theme.of(context).primaryColor,
      tooltip: 'Přidat',
      onPressed: () {
        // We need to access the text from the Autocomplete's controller
        // But since we can't easily access it here without complex state management,
        // we'll rely on the user pressing Enter or selecting from list for now,
        // OR we can try to use the _controller if we bound it correctly.
        // In the original code, _controller.value was set in fieldViewBuilder.
        // Let's try to capture the text in fieldViewBuilder.

        // Actually, the original code did: _controller.value = textEditingController.value;
        // So _controller.text should be valid.
        _addItem(_controller.text);
      },
    );
  }
}

abstract class LogicInterface {
  Future<void> fetchData([int? participantId]);
  void addItem(String name);
  List<String> get items;
  List<String> get names;
  String getText();
  Future<void> update();
}
