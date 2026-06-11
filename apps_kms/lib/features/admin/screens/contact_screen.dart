import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kontak & Dukungan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent, color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text(
                    'Tim Dukungan KMS',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Pemprov Lampung — Kami siap membantu Anda',
                    style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact info section
            const Text('Informasi Kontak',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
            const SizedBox(height: 12),

            _ContactCard(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF0052CC),
              iconBg: const Color(0xFFEEF4FF),
              label: 'Email',
              value: 'kms@lampungprov.go.id',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'kms@lampungprov.go.id'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email disalin ke clipboard'), backgroundColor: Color(0xFF22C55E)),
                );
              },
            ),
            const SizedBox(height: 10),
            _ContactCard(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFF22C55E),
              iconBg: const Color(0xFFF0FFF4),
              label: 'Telepon',
              value: '(0721) 123-4567',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '07211234567'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nomor telepon disalin'), backgroundColor: Color(0xFF22C55E)),
                );
              },
            ),
            const SizedBox(height: 10),
            _ContactCard(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFFFBEB),
              label: 'Alamat',
              value: 'Jl. Wolter Monginsidi No. 69, Telukbetung, Bandar Lampung',
              onTap: null,
            ),
            const SizedBox(height: 10),
            _ContactCard(
              icon: Icons.access_time_outlined,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
              label: 'Jam Operasional',
              value: 'Senin – Jumat: 08.00 – 16.00 WIB',
              onTap: null,
            ),

            const SizedBox(height: 24),

            // Quick message form
            const Text('Kirim Pesan Cepat',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
              ),
              child: _QuickMessageForm(),
            ),

            const SizedBox(height: 24),

            // About KMS
            const Text('Tentang KMS Pemprov Lampung',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A2332))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Knowledge Management System (KMS) Pemprov Lampung adalah platform digital untuk pengelolaan dan berbagi pengetahuan bagi aparatur sipil negara di lingkungan Pemerintah Provinsi Lampung. KMS mendukung pengembangan kompetensi ASN melalui seminar, materi pelatihan, panduan, dan informasi regulasi yang terintegrasi.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A2332))),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.content_copy_outlined, size: 16, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMessageForm extends StatefulWidget {
  @override
  State<_QuickMessageForm> createState() => _QuickMessageFormState();
}

class _QuickMessageFormState extends State<_QuickMessageForm> {
  final _nameCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0052CC))),
      );

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 48),
          SizedBox(height: 10),
          Text('Pesan terkirim!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
          SizedBox(height: 4),
          Text('Tim kami akan menghubungi Anda segera', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nama Anda', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(controller: _nameCtrl, decoration: _inputDecoration('Masukkan nama Anda')),
        const SizedBox(height: 12),
        const Text('Pesan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(controller: _msgCtrl, maxLines: 4, decoration: _inputDecoration('Tulis pesan Anda...')),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_nameCtrl.text.isNotEmpty && _msgCtrl.text.isNotEmpty) {
                setState(() => _sent = true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
            label: const Text('Kirim Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
