import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import 'file_viewer_logic.dart';
import 'file_viewer_screen_widget.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/screens2/widgets/zza_scrollable.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';

/// Custom ScrollBehavior that enables mouse drag for PageView on desktop.
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class IntakeMainContent extends StatefulWidget {
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Directory? zpusobilostFolder;
  final ParticipantRegistrationForm participantRegistrationForm;

  const IntakeMainContent({
    super.key,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.zpusobilostFolder,
    required this.participantRegistrationForm,
  });

  @override
  State<IntakeMainContent> createState() => _IntakeMainContentState();
}

class _IntakeMainContentState extends State<IntakeMainContent> {
  final ScrollController _formScrollController = ScrollController();
  final PageController _pageController = PageController();

  // File cache for state preservation across layout changes
  String? _cachedFilePath;
  Uint8List? _cachedFileBytes;

  /// Checks if a file has been uploaded for the selected person
  bool get _hasUploadedFile {
    return widget.zpusobilostFolder != null &&
        widget.selectedPerson?.potvrzeniPath != null &&
        widget.selectedPerson!.potvrzeniPath!.isNotEmpty;
  }

  /// Gets the full file path for the current person's file
  String? _buildFullFilePath() {
    if (!_hasUploadedFile) return null;
    return '${widget.zpusobilostFolder!.path}/${widget.selectedPerson!.potvrzeniPath}';
  }

  @override
  void initState() {
    super.initState();
    // Clear focus when page changes for accessibility
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    // Unfocus any text fields when switching pages
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _formScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Stable callback for file bytes loaded (avoids closure allocation per build)
  void _handleBytesLoaded(Uint8List bytes, String forPath) {
    // Only cache if still same file (person hasn't changed)
    final currentPath = _buildFullFilePath();
    if (forPath == currentPath) {
      setState(() {
        _cachedFilePath = forPath;
        _cachedFileBytes = bytes;
      });
    }
  }

  /// Navigate to previous page
  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Navigate to next page
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Navigate to specific page (for clickable dots)
  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      // Use LayoutBuilder for parent-relative sizing instead of MediaQuery.
      // See /flutter-ui workflow: "Use constraints, not percentages".
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);


          if (isNarrow) {
            // Mobile: Horizontal PageView with status bar and page dots
            return Column(
              children: [
                // Status Bar showing file status + swipe hint
                _buildFileStatusBar(),
                // PageView with form and file viewer
                Expanded(
                  child: Stack(
                    children: [
                      // Wrap PageView in ScrollConfiguration for mouse drag on PC
                      ScrollConfiguration(
                        behavior: _MouseDragScrollBehavior(),
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Page 1: Form (scrolls vertically)
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _buildLeftColumn(context, constraints, isNarrow),
                            ),
                            // Page 2: FileViewer (full height with save hint)
                            Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: _buildRightColumn(
                                        context, constraints, isNarrow,
                                        isPageView: true),
                                  ),
                                ),
                                // Hint for save button location
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Přejeďte zpět pro uložení',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Left arrow button
                      Positioned(
                        left: 4,
                        top: 0,
                        bottom: 40, // Leave room for dots
                        child: Center(
                          child: _buildArrowButton(
                            icon: Icons.chevron_left,
                            onPressed: _goToPreviousPage,
                            tooltip: 'Předchozí stránka',
                          ),
                        ),
                      ),
                      // Right arrow button
                      Positioned(
                        right: 4,
                        top: 0,
                        bottom: 40,
                        child: Center(
                          child: _buildArrowButton(
                            icon: Icons.chevron_right,
                            onPressed: _goToNextPage,
                            tooltip: 'Další stránka',
                          ),
                        ),
                      ),
                      // Clickable page indicator dots at bottom
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(child: _buildClickablePageDots()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Desktop/Tablet: Side-by-side
          // Use wideContentMaxWidth for the row
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.wideContentMaxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: Form
                  Expanded(
                    flex: 4,
                    child: _buildLeftColumn(context, constraints, isNarrow),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  // Right Column: Camera/Gallery (Always fills remaining vertical space)
                  Expanded(
                    flex: 3,
                    child: _buildRightColumn(context, constraints, isNarrow),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn(
      BuildContext context, BoxConstraints constraints, bool isNarrow) {
    if (isNarrow) {
      // Mobile: Just return the form.
      // The parent (build method) will wrap this in a ScrollView/Column.
      return widget.participantRegistrationForm;
    }

    // --- Bell Curve Density (Using SCREEN dimensions) ---
    // Mobile (<600): Standard (Touch)
    // Tablet/Laptop (600-1399 OR short): Compact (Dense)
    // Desktop (Width>=1400 AND Height>=900): Standard (Breathing room)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 1400 && screenHeight >= 900;
    final bool useStandardDensity = isMobile || isDesktop;

    // 2. Layout (Scroll): Depends on HEIGHT.
    // If we don't have enough vertical space for the Fixed Layout, use Scrollable.
    // Laptops (768px) usually fall into 'isCompactHeight' (< 800), so they get scrolling.
    final bool useScrollableLayout =
        AppBreakpoints.isCompactHeight(constraints.maxHeight);

    // Create the appropriate Theme (Density + Padding)
    final themeData = Theme.of(context).copyWith(
      visualDensity: useStandardDensity
          ? VisualDensity.standard
          : VisualDensity.compact,
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            isDense: !useStandardDensity,
            // Use default Material padding for Standard, dense for Compact
            contentPadding: useStandardDensity
                ? null 
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
    );

    final themedForm = Theme(
      data: themeData,
      child: widget.participantRegistrationForm,
    );

    if (useScrollableLayout) {
      // < 800px Height: Wrap in ScrollView to handle overflow gracefully
      return ZzaScrollable(
        controller: _formScrollController,
        child: SingleChildScrollView(
          controller: _formScrollController,
          child: themedForm,
        ),
      );
    }

    // Default Desktop (> 800px Height): Return validation form directly (Fixed Layout).
    return themedForm;
  }

  Widget _buildRightColumn(
      BuildContext context, BoxConstraints parentConstraints, bool isNarrow,
      {bool isPageView = false}) {
    final child = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isNarrow)
          Expanded(child: _buildFileViewer())
        else if (isPageView)
          Expanded(child: _buildFileViewer())  // Full height in PageView
        else
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: _buildFileViewer()),
      ],
    );

    // On Desktop (Not Narrow), we want Expanded behavior
    // On Mobile (Narrow), we function as content
    return child;
  }

  Widget _buildFileViewer() {
    final currentPath = _buildFullFilePath();

    if (currentPath != null) {
      // Clear cache if path changed (different person selected)
      Uint8List? bytesToUse;
      if (_cachedFilePath == currentPath) {
        bytesToUse = _cachedFileBytes;
      } else {
        // Path changed, clear old cache
        _cachedFilePath = null;
        _cachedFileBytes = null;
      }

      return FileViewerScreen(
        initialFilePath: currentPath,
        cachedBytes: bytesToUse,
        onBytesLoaded: _handleBytesLoaded,
      );
    } else {
      return FileViewerLogic(onFileUploaded: widget.onFileUploaded);
    }
  }

  /// Status bar showing file status and swipe hint
  Widget _buildFileStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: _hasUploadedFile ? Colors.green.shade50 : Colors.grey.shade100,
      child: Row(
        children: [
          Icon(
            _hasUploadedFile ? Icons.insert_drive_file : Icons.add_photo_alternate,
            size: 16,
            color: _hasUploadedFile ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            _hasUploadedFile ? 'Soubor nahrán' : 'Žádný soubor',
            style: TextStyle(
              fontSize: 12,
              color: _hasUploadedFile ? Colors.green.shade700 : Colors.grey,
            ),
          ),
          const Spacer(),
          const Icon(Icons.swipe, size: 14, color: Colors.grey),
          const Text(' ←→', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  /// Clickable page indicator dots with larger touch targets
  Widget _buildClickablePageDots() {
    return ListenableBuilder(
      listenable: _pageController,
      builder: (context, child) {
        final page = _pageController.hasClients
            ? (_pageController.page?.round() ?? 0)
            : 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _clickableDot(active: page == 0, targetPage: 0),
            const SizedBox(width: 12),
            _clickableDot(active: page == 1, targetPage: 1),
          ],
        );
      },
    );
  }

  /// Clickable page indicator dot with larger touch target (24x24)
  Widget _clickableDot({required bool active, required int targetPage}) {
    return GestureDetector(
      onTap: () => _goToPage(targetPage),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        child: Container(
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.blueText : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// Arrow button for PageView navigation with accessibility support
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.grey.shade600),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        shape: const CircleBorder(),
      ),
    );
  }
}
