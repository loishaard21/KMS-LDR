import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/seminar_model.dart';
import '../../../core/theme/app_theme.dart';

class GuestSeminarDetailScreen extends StatelessWidget {
  final SeminarModel seminar;

  const GuestSeminarDetailScreen({super.key, required this.seminar});

  Future<void> _launchRegisterUrl(BuildContext context) async {
    final url = seminar.daftarUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link pendaftaran tidak tersedia')),
      );
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      // Direct fallback
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka link: $url')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (seminar.registered / seminar.capacity * 100).clamp(0, 100).round();
    final isFull = seminar.status == 'Kuota Penuh';
    final isOffline = seminar.mode.toLowerCase() == 'offline';
    final isOnline = seminar.mode.toLowerCase() == 'online';
    final modeColor = isOffline ? Colors.orange : isOnline ? Colors.blue : Colors.purple;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Agenda'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                image: seminar.cover != null && seminar.cover!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(seminar.cover!), fit: BoxFit.cover)
                    : null,
              ),
              child: seminar.cover == null || seminar.cover!.isEmpty
                  ? const Center(child: Icon(Icons.image, color: Color(0xFF94A3B8), size: 48))
                  : null,
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: modeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seminar.mode,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seminar.status,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          seminar.category,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    seminar.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2332), height: 1.3),
                  ),
                  const SizedBox(height: 20),

                  // Speaker Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE2E8F0),
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF64748B), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NARASUMBER / PEMATERI',
                                style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                seminar.speaker,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                              ),
                              Text(
                                seminar.speakerRole,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event Details Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal', seminar.date),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildDetailRow(Icons.access_time, 'Waktu', seminar.time ?? '—'),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildDetailRow(Icons.location_on_outlined, 'Lokasi', seminar.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Capacity Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kapasitas Pendaftaran',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: pct >= 90 ? const Color(0xFFEF4444) : pct >= 60 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: seminar.registered / seminar.capacity,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              pct >= 90 ? const Color(0xFFEF4444) : pct >= 60 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Telah terdaftar ${seminar.registered} dari total ${seminar.capacity} kuota peserta.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Deskripsi Kegiatan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      seminar.description != null && seminar.description!.isNotEmpty
                          ? seminar.description!
                          : 'Tidak ada deskripsi untuk kegiatan ini.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isFull ? null : () => _launchRegisterUrl(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isFull ? 'Kuota Penuh' : 'Daftar Sekarang',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0052CC), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 12, color: Color(0xFF1A2332), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
