import { PrismaClient, Role } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Seed Users (operators & superadmin)
  const usersData = [
    {
      id: 'o1',
      name: 'Rini Agustina, S.Kom.',
      email: 'rini.agustina@lampungprov.go.id',
      password: 'operator123',
      role: Role.OPERATOR,
      status: 'Active',
      lastLogin: '31 Mar 2025, 09:14',
    },
    {
      id: 'o2',
      name: 'Dendi Pratama, S.T.',
      email: 'dendi.pratama@lampungprov.go.id',
      password: 'operator123',
      role: Role.OPERATOR,
      status: 'Active',
      lastLogin: '1 Apr 2025, 08:30',
    },
    {
      id: 'o3',
      name: 'Mega Sari, M.Kom.',
      email: 'mega.sari@lampungprov.go.id',
      password: 'operator123',
      role: Role.OPERATOR,
      status: 'Inactive',
      lastLogin: '15 Feb 2025, 14:22',
    },
    {
      id: 'o4',
      name: 'Superadmin KMS',
      email: 'admin@lampungprov.go.id',
      password: 'admin123',
      role: Role.SUPERADMIN,
      status: 'Active',
      lastLogin: '1 Apr 2025, 10:05',
    },
  ];

  const dbUsers: any[] = [];
  for (const u of usersData) {
    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: {},
      create: {
        name: u.name,
        email: u.email,
        password: u.password,
        role: u.role,
        status: u.status,
        lastLogin: u.lastLogin,
      },
    });
    dbUsers.push(user);
    console.log(`Created user: ${user.name} (${user.role})`);
  }

  // 2. Seed Articles
  const articlesData = [
    {
      id: '1',
      title: 'Pemprov Lampung Raih Nilai SPBE Memuaskan dalam Evaluasi Nasional 2024',
      category: 'Berita',
      date: '28 Maret 2025',
      excerpt: "Provinsi Lampung berhasil meraih predikat 'Memuaskan' dalam evaluasi implementasi Sistem Pemerintahan Berbasis Elektronik (SPBE) yang dilaksanakan KemenPANRB tahun 2024.",
      cover: 'https://images.unsplash.com/photo-1613441589134-3fc7f95a3e16?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=600',
      content: 'Pemerintah Provinsi Lampung berhasil meraih nilai SPBE yang memuaskan...',
    },
    {
      id: '2',
      title: 'Launching Aplikasi Satu Data Lampung: Integrasi Data Lintas OPD',
      category: 'Berita',
      date: '15 Maret 2025',
      excerpt: 'Dinas Kominfo Provinsi Lampung resmi meluncurkan aplikasi Satu Data Lampung yang mengintegrasikan data dari seluruh Organisasi Perangkat Daerah (OPD) di lingkungan Pemprov Lampung.',
      cover: 'https://images.unsplash.com/photo-1637308755606-266e7f2371d4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=600',
      content: 'Aplikasi Satu Data Lampung kini resmi diluncurkan...',
    },
  ];

  for (const a of articlesData) {
    await prisma.article.create({
      data: {
        title: a.title,
        category: a.category,
        date: a.date,
        excerpt: a.excerpt,
        cover: a.cover,
        content: a.content,
        // Link to the superadmin as the default author if available
        authorId: dbUsers.find(u => u.role === Role.SUPERADMIN)?.id,
      },
    });
  }
  console.log(`Created ${articlesData.length} articles.`);

  // 3. Seed Seminars
  const seminarsData = [
    {
      mockId: '1',
      title: 'Sosialisasi Sistem Pemerintahan Berbasis Elektronik (SPBE) 2025',
      category: 'SPBE',
      mode: 'Hybrid',
      status: 'Pendaftaran Dibuka',
      speaker: 'Dr. Ir. Budi Santoso, M.T.',
      speakerRole: 'Direktur Tata Kelola SPBE, Kemenpan-RB',
      speakerAvatar: 'https://i.pravatar.cc/150?img=11',
      date: '25 April 2025',
      time: '08.00 – 16.00 WIB',
      location: 'Aula Utama Pemprov Lampung, Bandar Lampung',
      capacity: 150,
      registered: 87,
      description: 'Sosialisasi mendalam mengenai implementasi SPBE di lingkungan Pemerintah Provinsi Lampung, mencakup roadmap digitalisasi, integrasi sistem, dan tata kelola data pemerintah.',
      requirements: [
        'ASN aktif di lingkungan Pemprov Lampung',
        'Membawa laptop/tablet pribadi',
        'Mengisi formulir pendaftaran sebelum hari-H',
        'Berpakaian formal (bebas rapih)',
      ],
      organizer: 'Dinas Kominfo Provinsi Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=5',
      cover: 'https://images.unsplash.com/photo-1616992510024-f1293eb00e41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Google Form',
      daftarUrl: 'https://forms.google.com/example',
      certificateUrl: 'https://drive.google.com/example',
    },
    {
      mockId: '2',
      title: 'Bimtek Pengelolaan Arsip Digital & Dokumen Elektronik Pemerintah',
      category: 'Kearsipan',
      mode: 'Online',
      status: 'Kuota Penuh',
      speaker: 'Dra. Sri Wahyuni, M.Si.',
      speakerRole: 'Kepala Bidang Kearsipan, ANRI',
      speakerAvatar: 'https://i.pravatar.cc/150?img=47',
      date: '10 Mei 2025',
      time: '09.00 – 12.00 WIB',
      location: 'Zoom Meeting (Online)',
      capacity: 100,
      registered: 100,
      description: 'Bimbingan teknis pengelolaan arsip digital yang meliputi standar metadata, klasifikasi dokumen elektronik, dan sistem manajemen arsip berbasis cloud sesuai regulasi ANRI.',
      requirements: [
        'Pegawai bidang kearsipan/persuratan',
        'Memiliki koneksi internet stabil',
        'Menginstal aplikasi Zoom',
        'Mengunduh materi pra-bimtek',
      ],
      organizer: 'Badan Arsip Daerah Provinsi Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=6',
      cover: 'https://images.unsplash.com/photo-1637308755606-266e7f2371d4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Nonaktif',
      daftarUrl: '',
      certificateUrl: 'https://drive.google.com/example2',
    },
    {
      mockId: '3',
      title: 'Workshop Transformasi Digital ASN: Kompetensi & Adaptasi',
      category: 'Transformasi Digital',
      mode: 'Offline',
      status: 'Pendaftaran Dibuka',
      speaker: 'Prof. Dr. Agus Prasetyo, MBA.',
      speakerRole: 'Guru Besar Administrasi Publik, Unila',
      speakerAvatar: 'https://i.pravatar.cc/150?img=12',
      date: '15 Mei 2025',
      time: '08.30 – 17.00 WIB',
      location: 'Hotel Novotel Lampung, Bandar Lampung',
      capacity: 80,
      registered: 45,
      description: 'Workshop intensif membangun kompetensi digital ASN mencakup literasi data, keamanan siber, pelayanan publik berbasis teknologi, dan manajemen perubahan di era transformasi digital.',
      requirements: [
        'ASN golongan III/a ke atas',
        'Membawa laptop yang terinstal Microsoft Office',
        'Menyelesaikan pre-test online',
        'Berpakaian formal',
      ],
      organizer: 'BPSDMD Provinsi Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=7',
      cover: 'https://images.unsplash.com/photo-1759922378187-11a435837df8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Google Form',
      daftarUrl: 'https://forms.google.com/example3',
      certificateUrl: 'https://drive.google.com/example3',
    },
    {
      mockId: '4',
      title: 'Seminar Nasional Inovasi Pelayanan Publik Berbasis Teknologi',
      category: 'Pelayanan Publik',
      mode: 'Hybrid',
      status: 'Pendaftaran Dibuka',
      speaker: 'Dr. Dewi Kusumawati, S.IP., M.Pol.',
      speakerRole: 'Deputi Pelayanan Publik, KemenPANRB',
      speakerAvatar: 'https://i.pravatar.cc/150?img=48',
      date: '20 Mei 2025',
      time: '09.00 – 15.00 WIB',
      location: 'Graha Pemprov Lampung & Zoom',
      capacity: 200,
      registered: 134,
      description: 'Seminar nasional membahas inovasi pelayanan publik digital terbaik dari berbagai daerah, benchmarking nasional, dan strategi peningkatan indeks kepuasan masyarakat.',
      requirements: [
        'Terbuka untuk umum & ASN',
        'Registrasi online wajib',
        'Membawa kartu identitas',
      ],
      organizer: 'Biro Organisasi Pemprov Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=8',
      cover: 'https://images.unsplash.com/photo-1672917187338-7f81ecac3d3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Link Eksternal',
      daftarUrl: 'https://seminar.lampungprov.go.id/daftar',
      certificateUrl: 'https://drive.google.com/example4',
    },
    {
      mockId: '5',
      title: 'Pelatihan Manajemen Pengetahuan Organisasi Pemerintah',
      category: 'Manajemen Pengetahuan',
      mode: 'Online',
      status: 'Pendaftaran Dibuka',
      speaker: 'Ir. Hendra Wijaya, M.M.',
      speakerRole: 'Konsultan KM, Lembaga Administrasi Negara',
      speakerAvatar: 'https://i.pravatar.cc/150?img=14',
      date: '28 Mei 2025',
      time: '08.00 – 11.00 WIB',
      location: 'Google Meet (Online)',
      capacity: 120,
      registered: 67,
      description: 'Pelatihan komprehensif tentang sistem manajemen pengetahuan organisasi pemerintah daerah, meliputi knowledge capture, sharing, dan implementation di era digital.',
      requirements: [
        'ASN & tenaga fungsional',
        'Koneksi internet minimal 10 Mbps',
        'Google Account aktif',
      ],
      organizer: 'Dinas Kominfo Provinsi Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=9',
      cover: 'https://images.unsplash.com/photo-1762330916242-08b27b39e265?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Google Form',
      daftarUrl: 'https://forms.google.com/example5',
      certificateUrl: 'https://drive.google.com/example5',
    },
    {
      mockId: '6',
      title: 'Bimtek Pengadaan Barang/Jasa Pemerintah Secara Elektronik',
      category: 'Pengadaan',
      mode: 'Offline',
      status: 'Kuota Penuh',
      speaker: 'Drs. Rudi Hartanto, M.M.',
      speakerRole: 'Kepala Bidang PBJ, LKPP Regional Sumatera',
      speakerAvatar: 'https://i.pravatar.cc/150?img=15',
      date: '5 Juni 2025',
      time: '08.00 – 17.00 WIB',
      location: 'Ruang Rapat Lantai 3, Gedung A Pemprov Lampung',
      capacity: 60,
      registered: 60,
      description: 'Bimbingan teknis penggunaan sistem LPSE, e-procurement, dan pengelolaan kontrak pengadaan barang/jasa pemerintah secara elektronik secara transparan.',
      requirements: [
        'Panitia pengadaan/PPK aktif',
        'Membawa NIPP & dokumen SK penugasan',
        'Membawa laptop pribadi',
      ],
      organizer: 'Biro Pengadaan Barang/Jasa Pemprov Lampung',
      organizerLogo: 'https://i.pravatar.cc/80?img=10',
      cover: 'https://images.unsplash.com/photo-1755548836775-39456093a0c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      daftarType: 'Nonaktif',
      daftarUrl: '',
      certificateUrl: 'https://drive.google.com/example6',
    },
  ];

  const dbSeminars: Record<string, any> = {};
  for (const s of seminarsData) {
    const sem = await prisma.seminar.create({
      data: {
        title: s.title,
        category: s.category,
        mode: s.mode,
        status: s.status,
        speaker: s.speaker,
        speakerRole: s.speakerRole,
        speakerAvatar: s.speakerAvatar,
        date: s.date,
        time: s.time,
        location: s.location,
        capacity: s.capacity,
        registered: s.registered,
        description: s.description,
        requirements: s.requirements,
        organizer: s.organizer,
        organizerLogo: s.organizerLogo,
        cover: s.cover,
        daftarType: s.daftarType,
        daftarUrl: s.daftarUrl,
        certificateUrl: s.certificateUrl,
      },
    });
    dbSeminars[s.mockId] = sem;
  }
  console.log(`Created ${Object.keys(dbSeminars).length} seminars.`);

  // 4. Seed Materials
  const materialsData = [
    {
      title: 'Modul SPBE: Tata Kelola Teknologi Informasi',
      description: 'Panduan lengkap implementasi tata kelola TI pemerintah sesuai Perpres 95/2018',
      icon: '📘',
      type: 'PDF',
      size: '2.4 MB',
      url: 'https://drive.google.com/example-materi1',
    },
    {
      title: 'Panduan Keamanan Informasi Pemerintah',
      description: 'Standar keamanan informasi dan proteksi data di lingkungan instansi pemerintah',
      icon: '🔐',
      type: 'PDF',
      size: '1.8 M B',
      url: 'https://drive.google.com/example-materi2',
    },
    {
      title: 'Template SOP Pelayanan Digital',
      description: 'Template standar prosedur operasional untuk layanan publik berbasis digital',
      icon: '📋',
      type: 'DOCX',
      size: '850 KB',
      url: 'https://drive.google.com/example-materi3',
    },
    {
      title: 'Buku Saku Transformasi Digital ASN',
      description: 'Referensi praktis kompetensi digital yang wajib dimiliki Aparatur Sipil Negara',
      icon: '📱',
      type: 'PDF',
      size: '3.1 MB',
      url: 'https://drive.google.com/example-materi4',
    },
  ];

  for (const m of materialsData) {
    await prisma.material.create({
      data: m,
    });
  }
  console.log(`Created ${materialsData.length} materials.`);

  // 5. Seed Schedules (linked to Seminars)
  const schedulesData = [
    { date: '25', month: 'Apr', year: '2025', title: 'Sosialisasi SPBE 2025', location: 'Aula Utama Pemprov Lampung', status: 'Pendaftaran Dibuka', mockSeminarId: '1' },
    { date: '10', month: 'Mei', year: '2025', title: 'Bimtek Pengelolaan Arsip Digital', location: 'Zoom Meeting', status: 'Kuota Penuh', mockSeminarId: '2' },
    { date: '15', month: 'Mei', year: '2025', title: 'Workshop Transformasi Digital ASN', location: 'Hotel Novotel Lampung', status: 'Pendaftaran Dibuka', mockSeminarId: '3' },
    { date: '20', month: 'Mei', year: '2025', title: 'Seminar Nasional Inovasi Pelayanan Publik', location: 'Graha Pemprov Lampung', status: 'Pendaftaran Dibuka', mockSeminarId: '4' },
    { date: '28', month: 'Mei', year: '2025', title: 'Pelatihan Manajemen Pengetahuan', location: 'Google Meet', status: 'Pendaftaran Dibuka', mockSeminarId: '5' },
    { date: '5', month: 'Jun', year: '2025', title: 'Bimtek Pengadaan Barang/Jasa', location: 'Gedung A Pemprov Lampung', status: 'Kuota Penuh', mockSeminarId: '6' },
  ];

  for (const sch of schedulesData) {
    await prisma.schedule.create({
      data: {
        date: sch.date,
        month: sch.month,
        year: sch.year,
        title: sch.title,
        location: sch.location,
        status: sch.status,
        seminarId: dbSeminars[sch.mockSeminarId]?.id || null,
      },
    });
  }
  console.log(`Created ${schedulesData.length} schedules.`);

  // 6. Seed Regulations
  const regulationsData = [
    // Perpres
    { group: 'Peraturan Presiden (Perpres)', title: 'Perpres No. 95 Tahun 2018 tentang Sistem Pemerintahan Berbasis Elektronik (SPBE)', url: '#' },
    { group: 'Peraturan Presiden (Perpres)', title: 'Perpres No. 39 Tahun 2019 tentang Satu Data Indonesia', url: '#' },
    { group: 'Peraturan Presiden (Perpres)', title: 'Perpres No. 132 Tahun 2022 tentang Arsitektur Sistem Pemerintahan Berbasis Elektronik Nasional', url: '#' },
    // Permen
    { group: 'Peraturan Menteri (Permen)', title: 'Permen PANRB No. 59 Tahun 2020 tentang Pemantauan dan Evaluasi SPBE', url: '#' },
    { group: 'Peraturan Menteri (Permen)', title: 'Permen Kominfo No. 8 Tahun 2019 tentang Penyelenggaraan Urusan Pemerintahan Konkuren Bidang Komunikasi dan Informatika', url: '#' },
    { group: 'Peraturan Menteri (Permen)', title: 'Permen PANRB No. 5 Tahun 2020 tentang Pedoman Manajemen Risiko SPBE', url: '#' },
    // Kepmen
    { group: 'Keputusan Menteri (Kepmen)', title: 'Kepmen PANRB No. 1 Tahun 2022 tentang Indeks SPBE Kementerian/Lembaga Tahun 2021', url: '#' },
    { group: 'Keputusan Menteri (Kepmen)', title: 'Kepmen Kominfo No. 1115 Tahun 2018 tentang Standar Interoperabilitas Integrasi Layanan Publik', url: '#' },
    // Pergub
    { group: 'Pergub Lampung', title: 'Pergub Lampung No. 41 Tahun 2023 tentang Penyelenggaraan SPBE di Lingkungan Pemprov Lampung', url: '#' },
    { group: 'Pergub Lampung', title: 'Pergub Lampung No. 12 Tahun 2022 tentang Tata Kelola Data Pemerintah Provinsi Lampung', url: '#' },
    { group: 'Pergub Lampung', title: 'Pergub Lampung No. 7 Tahun 2024 tentang Rencana Induk SPBE Provinsi Lampung 2024–2028', url: '#' },
  ];

  for (const r of regulationsData) {
    await prisma.regulation.create({
      data: r,
    });
  }
  console.log(`Created ${regulationsData.length} regulations.`);

  // 7. Seed Evaluations
  const evaluationsData = [
    { activity: 'Sosialisasi SPBE 2024', category: 'SPBE', period: 'Q4 2024', score: 87.5, status: 'Selesai' },
    { activity: 'Bimtek Arsip Digital', category: 'Kearsipan', period: 'Q3 2024', score: 92.0, status: 'Selesai' },
    { activity: 'Workshop Transformasi Digital', category: 'Transformasi Digital', period: 'Q3 2024', score: 85.3, status: 'Selesai' },
    { activity: 'Pelatihan KM Organisasi', category: 'Manajemen Pengetahuan', period: 'Q2 2024', score: 79.8, status: 'Selesai' },
    { activity: 'Seminar Pelayanan Publik', category: 'Pelayanan Publik', period: 'Q1 2025', score: 0, status: 'Dalam Proses' },
  ];

  for (const e of evaluationsData) {
    await prisma.evaluation.create({
      data: e,
    });
  }
  console.log(`Created ${evaluationsData.length} evaluations.`);

  // 8. Seed Participants
  const participantsData = [
    { name: 'Ahmad Fauzi, S.Kom.', nip: '198501012010011001', agency: 'Dinas Kominfo', seminarTitle: 'Sosialisasi SPBE 2025', date: '25 Apr 2025', status: 'Confirmed', mockSeminarId: '1' },
    { name: 'Siti Rahayu, S.IP.', nip: '199002152012012002', agency: 'Biro Umum', seminarTitle: 'Sosialisasi SPBE 2025', date: '25 Apr 2025', status: 'Attended', mockSeminarId: '1' },
    { name: 'Budi Prasetyo, M.T.', nip: '198712201009031003', agency: 'Dinas Kominfo', seminarTitle: 'Workshop Transformasi Digital ASN', date: '15 Mei 2025', status: 'Certificate Issued', mockSeminarId: '3' },
    { name: 'Dewi Lestari, S.E.', nip: '199503012014012004', agency: 'BPKAD', seminarTitle: 'Workshop Transformasi Digital ASN', date: '15 Mei 2025', status: 'Confirmed', mockSeminarId: '3' },
    { name: 'Hendra Kurniawan, S.H.', nip: '198806102011011005', agency: 'Biro Hukum', seminarTitle: 'Bimtek Pengelolaan Arsip Digital', date: '10 Mei 2025', status: 'Attended', mockSeminarId: '2' },
    { name: 'Rina Kartika, M.M.', nip: '199110252015012006', agency: 'BPSDMD', seminarTitle: 'Pelatihan Manajemen Pengetahuan', date: '28 Mei 2025', status: 'Confirmed', mockSeminarId: '5' },
  ];

  for (const p of participantsData) {
    await prisma.participant.create({
      data: {
        name: p.name,
        nip: p.nip,
        agency: p.agency,
        seminarTitle: p.seminarTitle,
        date: p.date,
        status: p.status,
        seminarId: dbSeminars[p.mockSeminarId]?.id || null,
      },
    });
  }
  console.log(`Created ${participantsData.length} participants.`);

  // 9. Seed Announcements / Zoom Links
  const announcementsData = [
    { title: 'Link Zoom Sosialisasi SPBE', type: 'Zoom Link', content: 'https://zoom.us/j/1234567890', hasFile: false, date: '20 Apr 2025', mockSeminarId: '1' },
    { title: 'Slide Materi Workshop Hari-1', type: 'Materi', content: 'Slide presentasi pembukaan.', hasFile: true, fileUrl: 'https://drive.google.com/example-slide', date: '14 Mei 2025', mockSeminarId: '3' },
    { title: 'Informasi Pengambilan Sertifikat', type: 'Info Sertifikat', content: 'Sertifikat tersedia di drive.', hasFile: false, date: '26 Apr 2025', mockSeminarId: '1' },
  ];

  for (const ann of announcementsData) {
    const sem = dbSeminars[ann.mockSeminarId];
    if (sem) {
      await prisma.announcement.create({
        data: {
          title: ann.title,
          type: ann.type,
          content: ann.content,
          hasFile: ann.hasFile,
          fileUrl: ann.fileUrl,
          date: ann.date,
          seminarId: sem.id,
        },
      });
    }
  }
  console.log(`Created ${announcementsData.length} announcements.`);

  // 10. Seed Guides (Panduan)
  const guidesData = [
    {
      title: 'Pengenalan Portal KMS',
      key: 'pengenalan-portal-kms',
      order: 1,
      content: `<h3>Apa itu Portal KMS?</h3>
<p>Knowledge Management System (KMS) Pemerintah Provinsi Lampung adalah platform digital terpadu yang dirancang untuk mengelola, menyimpan, dan berbagi pengetahuan di lingkungan ASN Pemprov Lampung.</p>
<h3>Tujuan Portal KMS</h3>
<ul>
  <li><strong>Sentralisasi Pengetahuan</strong> — Mengumpulkan seluruh informasi, regulasi, dan materi pelatihan dalam satu platform terintegrasi.</li>
  <li><strong>Peningkatan Kompetensi ASN</strong> — Memfasilitasi pembelajaran dan pengembangan kapasitas aparatur melalui seminar, bimtek, dan materi digital.</li>
  <li><strong>Transparansi Informasi</strong> — Menyediakan akses publik terhadap informasi kegiatan pemerintah provinsi terkait transformasi digital.</li>
  <li><strong>Mendukung SPBE</strong> — Menjadi bagian dari implementasi Sistem Pemerintahan Berbasis Elektronik sesuai Perpres No. 95 Tahun 2018.</li>
</ul>
<h3>Fitur Utama</h3>
<p>Portal KMS menyediakan beberapa fitur unggulan, antara lain: Manajemen Seminar & Pelatihan, Pusat Materi & Dokumen, Artikel & Berita, Regulasi SPBE, Jadwal Kegiatan, dan Evaluasi Kinerja.</p>`,
    },
    {
      title: 'Cara Mengakses Portal',
      key: 'cara-mengakses-portal',
      order: 2,
      content: `<h3>Akses Publik (Tanpa Login)</h3>
<p>Seluruh halaman informasi pada portal KMS dapat diakses secara bebas oleh masyarakat umum dan ASN tanpa perlu login. Anda dapat:</p>
<ul>
  <li>Melihat daftar seminar dan pelatihan yang tersedia.</li>
  <li>Membaca artikel dan berita terkini.</li>
  <li>Mengunduh materi dan dokumen yang dipublikasikan.</li>
  <li>Melihat jadwal kegiatan dan regulasi SPBE.</li>
</ul>
<h3>Akses Operator (Dengan Login)</h3>
<p>Bagi operator dan superadmin yang ditugaskan untuk mengelola konten, akses login tersedia melalui halaman <code>/login</code>. Langkah-langkahnya:</p>
<ol>
  <li>Klik menu <strong>"Login"</strong> pada navbar di bagian kanan atas.</li>
  <li>Masukkan <strong>email</strong> dan <strong>password</strong> yang telah didaftarkan oleh superadmin.</li>
  <li>Setelah berhasil login, Anda akan diarahkan ke dashboard sesuai peran (Operator / Superadmin).</li>
</ol>
<h3>Persyaratan Teknis</h3>
<p>Pastikan Anda menggunakan browser modern (Chrome, Firefox, Edge, atau Safari versi terbaru) untuk pengalaman terbaik.</p>`,
    },
    {
      title: 'Mengelola Seminar & Pelatihan',
      key: 'mengelola-seminar',
      order: 3,
      content: `<h3>Melihat Daftar Seminar</h3>
<p>Halaman <strong>Seminar</strong> menampilkan seluruh seminar dan pelatihan yang tersedia. Setiap kartu seminar menampilkan informasi penting seperti:</p>
<ul>
  <li><strong>Mode pelaksanaan</strong> — Online, Offline, atau Hybrid.</li>
  <li><strong>Status pendaftaran</strong> — Apakah masih terbuka atau kuota sudah penuh.</li>
  <li><strong>Kapasitas & jumlah peserta terdaftar</strong> — Ditampilkan dalam progress bar visual.</li>
  <li><strong>Narasumber</strong> — Nama dan jabatan pembicara.</li>
</ul>
<h3>Mendaftar Seminar</h3>
<p>Untuk mendaftar seminar, klik tombol <strong>"Daftar"</strong> pada kartu seminar. Anda akan diarahkan ke formulir pendaftaran eksternal (Google Form atau link registrasi lainnya) sesuai yang ditentukan penyelenggara.</p>
<h3>Bagi Operator: Mengelola Data Seminar</h3>
<p>Operator dapat menambah, mengedit, dan menghapus seminar melalui dashboard <strong>Kelola Seminar</strong>. Pastikan untuk mengisi seluruh informasi yang diperlukan termasuk cover, deskripsi, dan persyaratan peserta.</p>`,
    },
    {
      title: 'Mengakses Materi & Dokumen',
      key: 'mengakses-materi',
      order: 4,
      content: `<h3>Pusat Materi</h3>
<p>Halaman <strong>Materi</strong> menyediakan berbagai dokumen yang dapat diunduh secara gratis, meliputi:</p>
<ul>
  <li><strong>Modul pelatihan</strong> — Materi lengkap tentang SPBE, tata kelola TI, dan transformasi digital.</li>
  <li><strong>Template SOP</strong> — Standar prosedur operasional untuk pelayanan publik berbasis digital.</li>
  <li><strong>Buku saku</strong> — Referensi praktis untuk kompetensi digital ASN.</li>
  <li><strong>Panduan keamanan informasi</strong> — Standar proteksi data di lingkungan instansi pemerintah.</li>
</ul>
<h3>Cara Mengunduh</h3>
<p>Klik tombol <strong>"Unduh"</strong> pada kartu materi yang diinginkan. File akan langsung terunduh atau terbuka di tab baru tergantung jenis dokumen (PDF, DOCX, dll).</p>
<h3>Bagi Operator: Upload Materi Baru</h3>
<p>Operator dapat mengunggah materi baru melalui menu <strong>Kelola Materi</strong> di dashboard. Isi judul, deskripsi, tipe file, ukuran file, dan URL link unduhan.</p>`,
    },
    {
      title: 'Evaluasi & Pelaporan',
      key: 'evaluasi-pelaporan',
      order: 5,
      content: `<h3>Dashboard Evaluasi</h3>
<p>Halaman <strong>Evaluasi</strong> menampilkan ringkasan hasil evaluasi kegiatan yang telah dilaksanakan, meliputi:</p>
<ul>
  <li><strong>Nama kegiatan</strong> dan kategori pelaksanaan.</li>
  <li><strong>Periode</strong> pelaksanaan (per kuartal).</li>
  <li><strong>Skor evaluasi</strong> dari setiap kegiatan.</li>
  <li><strong>Status</strong> — Selesai atau Dalam Proses.</li>
</ul>
<h3>Indikator Kinerja</h3>
<p>Evaluasi menggunakan skala skor 0–100 dengan kategori:</p>
<ul>
  <li><strong>90–100:</strong> Sangat Baik</li>
  <li><strong>80–89:</strong> Baik</li>
  <li><strong>70–79:</strong> Cukup</li>
  <li><strong>Di bawah 70:</strong> Perlu Perbaikan</li>
</ul>
<h3>Bagi Operator: Input Data Evaluasi</h3>
<p>Operator dapat menambah dan memperbarui data evaluasi melalui menu <strong>Kelola Evaluasi</strong> di dashboard. Pastikan data skor dan status diperbarui secara berkala setelah setiap kegiatan selesai dilaksanakan.</p>`,
    },
  ];

  for (const g of guidesData) {
    await prisma.guide.create({
      data: {
        title: g.title,
        key: g.key,
        content: g.content,
        order: g.order,
        authorId: dbUsers.find(u => u.role === Role.SUPERADMIN)?.id,
      },
    });
  }
  console.log(`Created ${guidesData.length} guides.`);

  console.log('Seeding finished successfully.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
