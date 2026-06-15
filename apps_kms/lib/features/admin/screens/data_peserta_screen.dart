import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/participant_model.dart';
import '../providers/participant_provider.dart';

const _statusOptions = ['Confirmed', 'Attended', 'Certificate Issued'];

Color _statusColor(String status) {
  switch (status) {
    case 'Attended':
      return const Color(0xFFF59E0B);
    case 'Certificate Issued':
      return const Color(0xFF22C55E);
    default:
      return const Color(0xFF0052CC);
  }
}

Color _statusBg(String status) {
  switch (status) {
    case 'Attended':
      return const Color(0xFFFFFBEB);
    case 'Certificate Issued':
      return const Color(0xFFF0FFF4);
    default:
      return const Color(0xFFEEF4FF);
  }
}

class DataPesertaScreen extends ConsumerStatefulWidget {
  const DataPesertaScreen({super.key});

  @override
  ConsumerState<DataPesertaScreen> createState() => _DataPesertaScreenState();
}

class _DataPesertaScreenState extends ConsumerState<DataPesertaScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(participantProvider.notifier).fetchAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(participantProvider.notifier).fetchAll();
  }

  Future<void> _updateStatus(ParticipantModel p, String newStatus) async {
    final success = await ref.read(participantProvider.notifier).update(p.id, {'status': newStatus});
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah status.'), backgroundColor: Color(0xFFEF4444)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(participantProvider);
    final allParticipants = state.participants;

    final filtered = allParticipants.where((p) {
      final q = _search.toLowerCase();
      return (p.name.toLowerCase().contains(q)) ||
          (p.agency?.toLowerCase().contains(q) ?? false) ||
          (p.seminarTitle?.toLowerCase().contains(q) ?? false);
    }).toList();

    final totalPeserta = allParticipants.length;
    final totalHadir = allParticipants.where((p) => p.status == 'Attended').length;
    final totalCertificate = allParticipants.where((p) => p.status == 'Certificate Issued').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Data Peserta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0052CC)),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Header
                    const Text(
                      'Data Peserta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Manajemen data peserta seminar dan status kehadiran.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row
                    state.isLoading
                        ? _buildStatsLoading()
                        : Row(
                            children: [
                              Expanded(
                                child: _StatMini(
                                  label: 'Total Peserta',
                                  value: totalPeserta.toString(),
                                  color: const Color(0xFF0052CC),
                                  bg: const Color(0xFFEEF4FF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatMini(
                                  label: 'Hadir',
                                  value: totalHadir.toString(),
                                  color: const Color(0xFFF59E0B),
                                  bg: const Color(0xFFFFFBEB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatMini(
                                  label: 'Sertifikat Diterbitkan',
                                  value: totalCertificate.toString(),
                                  color: const Color(0xFF22C55E),
                                  bg: const Color(0xFFF0FFF4),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052CC).withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Cari peserta, instansi, atau seminar...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Count
                    if (!state.isLoading)
                      Text(
                        '${filtered.length} peserta ditemukan',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
            ),

            // List
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, color: Color(0xFFCBD5E1), size: 64),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada data peserta ditemukan.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ParticipantCard(
                      participant: filtered[index],
                      onUpdateStatus: (status) => _updateStatus(filtered[index], status),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
        ),
      )),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatMini({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052CC).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final ParticipantModel participant;
  final ValueChanged<String> onUpdateStatus;

  const _ParticipantCard({
    required this.participant,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052CC).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    participant.name.isNotEmpty ? participant.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0052CC),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    if (participant.nip != null && participant.nip!.isNotEmpty)
                      Text(
                        'NIP: ${participant.nip}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
              // Status Dropdown
              _StatusDropdown(
                currentStatus: participant.status,
                onChanged: onUpdateStatus,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Info grid
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (participant.agency != null && participant.agency!.isNotEmpty)
                _InfoChip(
                  icon: Icons.business_outlined,
                  label: participant.agency!,
                ),
              if (participant.seminarTitle != null && participant.seminarTitle!.isNotEmpty)
                _InfoChip(
                  icon: Icons.book_outlined,
                  label: participant.seminarTitle!,
                  maxWidth: 200,
                ),
              if (participant.date != null && participant.date!.isNotEmpty)
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: participant.date!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? maxWidth;

  const _InfoChip({required this.icon, required this.label, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 150),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({required this.currentStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(currentStatus);
    final bg = _statusBg(currentStatus);

    return GestureDetector(
      onTap: () => _showStatusPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStatus,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah Status Peserta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 16),
            ..._statusOptions.map((status) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: status == currentStatus ? FontWeight.bold : FontWeight.normal,
                      color: status == currentStatus ? _statusColor(status) : const Color(0xFF1A2332),
                    ),
                  ),
                  trailing: status == currentStatus
                      ? const Icon(Icons.check, color: Color(0xFF22C55E), size: 18)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (status != currentStatus) onChanged(status);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
