import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/services/participant_service.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';

import 'package:denik_zza/design_system/tokens/app_radii.dart';

/// A reusable widget for displaying a list of medical records
/// Replaces the old FullZraneniList from /screens folder
class RecordListWidget extends StatefulWidget {
  final MemoryOsoba participant;
  final double? height; // Optional height constraint
  final bool showRefreshButton; // Whether to show refresh button
  final VoidCallback? onRecordAdded; // Callback when a record is added

  const RecordListWidget({
    super.key,
    required this.participant,
    this.height,
    this.showRefreshButton = false,
    this.onRecordAdded,
  });

  @override
  State<RecordListWidget> createState() => _RecordListWidgetState();
}

class _RecordListWidgetState extends State<RecordListWidget> {
  final ParticipantService _participantService = ParticipantService();
  final ScrollController _scrollController = ScrollController();
  List<MemoryZaznam> _records = [];
  bool _isLoading = false;
  bool _hasMoreBelow = false;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
    _scrollController.addListener(_updateScrollIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final hasMore = currentScroll < maxScroll - 10; // 10px threshold

    if (hasMore != _hasMoreBelow) {
      setState(() {
        _hasMoreBelow = hasMore;
      });
    }
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _participantService
          .getParticipantRecords(widget.participant.id);
      setState(() {
        _records = records;
        _isLoading = false;
      });

      // Check if scrollable after rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollIndicator();
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při načítání záznamů: $error')),
        );
      }
    }
  }

  /// Public method to refresh records from external widgets
  void refreshRecords() {
    _fetchRecords();
    widget.onRecordAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildRecordsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Full width
      children: [
        if (widget.showRefreshButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lékařské záznamy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchRecords,
                  tooltip: 'Obnovit záznamy',
                ),
              ],
            ),
          ),
        Expanded(
          child: widget.height != null
              ? SizedBox(
                  height: widget.height,
                  width: double.infinity,
                  child: content,
                )
              : content,
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Zatím žádné zdravotní záznamy.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true, // Important: Allow ListView to size itself
          physics: const ClampingScrollPhysics(), // Prevent scrolling conflicts
          itemCount: _records.length,
          itemBuilder: (context, index) {
            final record = _records[index];
            return RecordListItem(record: record);
          },
        ),

        // Bottom fade indicator when there's more content below
        if (_hasMoreBelow)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.greyBackground.withValues(alpha: 0.0),
                      AppColors.greyBackground.withValues(alpha: 0.9),
                      AppColors.greyBackground,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.blueBackground,
                      borderRadius: AppRadii.containerRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.blueText,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'více',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blueText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact, flexible record item - defaults to single line, expands on tap
class RecordListItem extends StatefulWidget {
  final MemoryZaznam record;

  const RecordListItem({super.key, required this.record});

  @override
  State<RecordListItem> createState() => _RecordListItemState();
}

class _RecordListItemState extends State<RecordListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.greyBorder, width: 1),
          ),
        ),
        child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
      ),
    );
  }

  /// Compact single-line view: [Time] Title - Description...
  Widget _buildCompactView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Time badge (compact)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.blueBackground,
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
          child: Text(
            _formatTime(widget.record.casZaznamu),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.blueDark,
            ),
          ),
        ),

        // Separator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '—',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyIcon,
            ),
          ),
        ),

        // Description preview (flex takes remaining space)
        Flexible(
          flex: 3,
          child: Text(
            widget.record.popis ?? '--',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Print indicator (minimal)
        if (widget.record.isPrinted)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(
              Icons.print,
              size: 14,
              color: AppColors.greenIcon,
            ),
          ),

        // Expand indicator
        Icon(
          Icons.chevron_right,
          size: 16,
          color: AppColors.greyIcon,
        ),
      ],
    );
  }

  /// Expanded multi-line view with full details
  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            // Date and time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blueBackground,
                borderRadius: BorderRadius.circular(AppRadii.medium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.blueDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(widget.record.casZaznamu)} ${_formatTime(widget.record.casZaznamu)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blueDark,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Print status
            if (widget.record.isPrinted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.greenBackground,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.print,
                      size: 12,
                      color: AppColors.greenIcon,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Vytištěno',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.greenText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Collapse indicator
            Icon(
              Icons.expand_less,
              size: 18,
              color: AppColors.greyIcon,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Title
        Text(
          widget.record.nazev ?? 'Bez nadpisu',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 6),

        // Full description
        Text(
          widget.record.popis ?? '--',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.greyText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
