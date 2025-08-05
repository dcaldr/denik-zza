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

    return ListView.builder(
      shrinkWrap: true, // Important: Allow ListView to size itself
      physics: const ClampingScrollPhysics(), // Prevent scrolling conflicts
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
      elevation: 2,
      child: SizedBox(
        width: double.infinity, // Ensure full width
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and date/time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with improved styling
                  Expanded(
                    child: Text(
                      record.nazev ?? 'Bez nadpisu',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date and time on one line with icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(record.casZaznamu)} ${_formatTime(record.casZaznamu)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description with better formatting
              Text(
                record.popis ?? '--',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Print status icon in trailing position
          trailing: record.isPrinted
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.print,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
                )
              : null,
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
