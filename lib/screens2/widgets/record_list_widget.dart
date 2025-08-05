import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/services/participant_service.dart';

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
  List<MemoryZaznam> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final records = await _participantService.getParticipantRecords(widget.participant.id);
      setState(() {
        _records = records;
        _isLoading = false;
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
    
    // Apply height constraint if specified, otherwise expand
    if (widget.height != null) {
      content = SizedBox(
        height: widget.height,
        width: double.infinity, // Ensure full width
        child: content,
      );
    } else {
      content = SizedBox(
        width: double.infinity, // Ensure full width
        child: content,
      );
    }

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
        widget.height != null ? Expanded(child: content) : content,
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

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return RecordListItem(record: record);
      },
    );
  }
}

/// Individual record item widget - similar to ZraneniListItem from old system
class RecordListItem extends StatelessWidget {
  final MemoryZaznam record;

  const RecordListItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      child: Container(
        width: double.infinity, // Ensure full width
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time column (similar to old system)
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(record.casZaznamu)),
                    Text(_formatTime(record.casZaznamu)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.nazev ?? 'Bez nadpisu'),
                    Text(
                      record.popis ?? '--',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Print status icon
              if (record.isPrinted)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.print, size: 16),
                ),
            ],
          ),
        ),
      ),
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
