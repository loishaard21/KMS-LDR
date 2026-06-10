import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _siteNameController = TextEditingController(text: 'KMS Pemprov Lampung');
  final _taglineController = TextEditingController(
    text: 'Portal Manajemen Pengetahuan Pemerintah Provinsi Lampung',
  );
  final _formUrlController = TextEditingController(text: 'https://forms.google.com/default');
  final _driveUrlController = TextEditingController(text: 'https://drive.google.com/default');

  bool _maintenanceMode = false;
  bool _isSaved = false;

  @override
  void dispose() {
    _siteNameController.dispose();
    _taglineController.dispose();
    _formUrlController.dispose();
    _driveUrlController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      _isSaved = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Sistem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isSaved) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Pengaturan berhasil disimpan!',
                      style: TextStyle(color: Color(0xFF15803D), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Site Info Card
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
                    children: const [
                      Icon(Icons.public, color: AppTheme.primaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Informasi Situs',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  CustomTextField(
                    controller: _siteNameController,
                    labelText: 'Nama Situs',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _taglineController,
                    labelText: 'Tagline',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ditampilkan di header dan metadata portal.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Default URLs Card
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
                    children: const [
                      Icon(Icons.link, color: AppTheme.secondaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'URL Default',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  CustomTextField(
                    controller: _formUrlController,
                    labelText: 'Default Google Form URL',
                    hintText: 'https://forms.google.com/...',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Digunakan jika seminar tidak memiliki URL pendaftaran khusus.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _driveUrlController,
                    labelText: 'Default Google Drive URL (Sertifikat)',
                    hintText: 'https://drive.google.com/...',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Folder sertifikat default di Google Drive.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // System Controls Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _maintenanceMode ? const Color(0xFFFEF2F2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _maintenanceMode ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.settings, color: Color(0xFF475569), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Kontrol Sistem',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2332)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _maintenanceMode
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: _maintenanceMode
                                  ? AppTheme.dangerColor
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mode Maintenance',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2332),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _maintenanceMode
                                    ? 'Portal hanya dapat diakses admin.'
                                    : 'Portal aktif diakses publik.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _maintenanceMode,
                        activeColor: AppTheme.dangerColor,
                        onChanged: (val) {
                          setState(() {
                            _maintenanceMode = val;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_maintenanceMode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline, color: AppTheme.dangerColor, size: 14),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Peringatan: Mode maintenance aktif. Portal tidak dapat diakses publik.',
                              style: TextStyle(color: AppTheme.dangerColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Simpan Pengaturan',
              onPressed: _handleSave,
              icon: Icons.save_outlined,
              color: AppTheme.successColor,
            ),
          ],
        ),
      ),
    );
  }
}
