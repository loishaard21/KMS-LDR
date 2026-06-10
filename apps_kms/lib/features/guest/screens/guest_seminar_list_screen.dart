import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/seminar_model.dart';
import '../../admin/providers/seminar_provider.dart';
import 'guest_seminar_detail_screen.dart';

class GuestSeminarListScreen extends ConsumerStatefulWidget {
  final String? initialSearchQuery;

  const GuestSeminarListScreen({super.key, this.initialSearchQuery});

  @override
  ConsumerState<GuestSeminarListScreen> createState() => _GuestSeminarListScreenState();
}

class _GuestSeminarListScreenState extends ConsumerState<GuestSeminarListScreen> {
  late TextEditingController _searchController;
  String _selectedMode = 'Semua';
  String _selectedStatus = 'Semua';

  final List<String> _modes = ['Semua', 'Hybrid', 'Online', 'Offline'];
  final List<String> _statuses = ['Semua', 'Pendaftaran Dibuka', 'Kuota Penuh'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seminarProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seminarState = ref.watch(seminarProvider);

    // Apply search and dropdown filters locally
    final query = _searchController.text.trim().toLowerCase();
    final filteredSeminars = seminarState.seminars.where((s) {
      final matchSearch = s.title.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query) ||
          s.speaker.toLowerCase().contains(query);

      final matchMode = _selectedMode == 'Semua' || s.mode == _selectedMode;
      final matchStatus = _selectedStatus == 'Semua' || s.status == _selectedStatus;

      return matchSearch && matchMode && matchStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Seminar & Pelatihan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari seminar...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Mode Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMode,
                        decoration: const InputDecoration(
                          labelText: 'Mode',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _modes.map((mode) {
                          return DropdownMenuItem(value: mode, child: Text(mode, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMode = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStatus = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Seminars List
          Expanded(
            child: seminarState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSeminars.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_list_off, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada seminar yang sesuai filter.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(seminarProvider.notifier).fetchAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredSeminars.length,
                          itemBuilder: (context, index) {
                            final s = filteredSeminars[index];
                            return _buildSeminarCard(context, s);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeminarCard(BuildContext context, SeminarModel seminar) {
    final pct = (seminar.registered / seminar.capacity * 100).clamp(0, 100).round();
    final isFull = seminar.status == 'Kuota Penuh';
    final isOffline = seminar.mode.toLowerCase() == 'offline';
    final isOnline = seminar.mode.toLowerCase() == 'online';
    final modeColor = isOffline ? Colors.orange : isOnline ? Colors.blue : Colors.purple;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GuestSeminarDetailScreen(seminar: seminar)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image cover with badges
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  image: seminar.cover != null && seminar.cover!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(seminar.cover!), fit: BoxFit.cover)
                      : null,
                ),
                child: Stack(
                  children: [
                    if (seminar.cover == null || seminar.cover!.isEmpty)
                      const Center(child: Icon(Icons.image, color: Color(0xFF94A3B8), size: 36)),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: modeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              seminar.mode,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isFull ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              seminar.status,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seminar.category,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seminar.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A2332), height: 1.3),
                  ),
                  const SizedBox(height: 12),

                  // Speaker Profile Row
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE2E8F0),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF64748B), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seminar.speaker,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                            ),
                            Text(
                              seminar.speakerRole,
                              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location and Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF0052CC)),
                      const SizedBox(width: 6),
                      Text(seminar.date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF0052CC)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          seminar.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Capacity progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${seminar.registered}/${seminar.capacity} peserta',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: pct >= 90 ? const Color(0xFFEF4444) : pct >= 60 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: seminar.registered / seminar.capacity,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 90 ? const Color(0xFFEF4444) : pct >= 60 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
