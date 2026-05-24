import React from "react";

const InformasiPembuka: React.FC = () => {
  return (
    <div className="w-full">

      {/* HEADER */}
      <div className="bg-gradient-to-r from-[#1d2b8f] to-[#2563eb] text-white rounded-2xl px-8 py-7 mb-6 shadow-lg">
        <h1 className="text-3xl font-bold">
          Definisi & Jenis Aplikasi SPBE
        </h1>

        <p className="text-sm mt-2 text-blue-100">
          Definisi, jenis aplikasi, dan alasan koordinasi dengan Diskominfotik
        </p>
      </div>

      {/* DEFINISI */}
      <div className="bg-white border border-[#DCE6FF] rounded-2xl p-6 mb-6 shadow-sm">
        <h2 className="text-[#1d2b8f] font-bold text-xl mb-3">
          DEFINISI
        </h2>

        <p className="text-gray-700 leading-relaxed">
          Aplikasi SPBE adalah satu atau sekumpulan program komputer dan
          prosedur yang dirancang untuk melakukan tugas atau fungsi layanan
          dalam penyelenggaraan pemerintahan berbasis elektronik.
        </p>
      </div>

      {/* DUA JENIS */}
      <div className="mb-6">
        <h2 className="text-[#1d2b8f] font-bold text-2xl mb-5">
          Dua Jenis Aplikasi
        </h2>

        <div className="grid md:grid-cols-2 gap-5">

          {/* Aplikasi Umum */}
          <div className="bg-[#fff5f5] border border-[#f5b5b5] rounded-2xl p-6 shadow-sm hover:shadow-md transition">

            <div className="flex items-center gap-2 mb-4">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>

              <h3 className="text-red-700 font-bold text-xl">
                Aplikasi Umum
              </h3>
            </div>

            <p className="font-semibold text-gray-800 mb-3">
              Digunakan secara berbagi pakai oleh lebih dari satu Perangkat Daerah
            </p>

            <p className="text-gray-700 text-sm leading-relaxed mb-5">
              Disediakan oleh instansi pemerintah pusat. Perangkat Daerah
              cukup menggunakan tanpa perlu membangun sendiri.
            </p>

            <div className="mb-5">
              <p className="font-semibold text-gray-800 mb-2">
                Contoh:
              </p>

              <ul className="list-disc list-inside text-sm text-gray-700 space-y-1">
                <li>MYASN — BKN</li>
                <li>SRIKANDI — Kemendagri</li>
                <li>SIMPEG — ANRI</li>
              </ul>
            </div>

            <div className="bg-red-100 text-red-700 text-center text-sm font-semibold py-3 rounded-xl">
              Tidak diwajibkan mengikuti prosedur Pergub No. 38/2025
            </div>
          </div>

          {/* Aplikasi Khusus */}
          <div className="bg-[#f4f8ff] border border-[#b7d0ff] rounded-2xl p-6 shadow-sm hover:shadow-md transition">

            <div className="flex items-center gap-2 mb-4">
              <div className="w-3 h-3 bg-blue-500 rounded-full"></div>

              <h3 className="text-blue-700 font-bold text-xl">
                Aplikasi Khusus
              </h3>
            </div>

            <p className="font-semibold text-gray-800 mb-3">
              Dikembangkan untuk mendukung tugas dan fungsi Perangkat Daerah tertentu
            </p>

            <p className="text-gray-700 text-sm leading-relaxed mb-5">
              Dibangun karena kebutuhan khusus yang tidak terpenuhi oleh
              aplikasi umum. Wajib mengikuti seluruh prosedur yang berlaku.
            </p>

            <div className="mb-5">
              <p className="font-semibold text-gray-800 mb-2">
                Contoh:
              </p>

              <ul className="list-disc list-inside text-sm text-gray-700 space-y-1">
                <li>SIKOJAH — Disnaker</li>
                <li>SIKAP — BKD</li>
                <li>SIMPEG — BKD</li>
              </ul>
            </div>

            <div className="bg-blue-100 text-blue-700 text-center text-sm font-semibold py-3 rounded-xl">
              Wajib mengikuti seluruh prosedur Pergub No. 38/2025
            </div>
          </div>

        </div>
      </div>

      {/* ALASAN */}
      <div className="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">

        <h2 className="text-[#1d2b8f] font-bold text-2xl mb-6">
          Mengapa Pembangunan Aplikasi Khusus Wajib Berkoordinasi dengan Diskominfotik?
        </h2>

        <div className="space-y-6">

          {/* ITEM 1 */}
          <div className="flex gap-4 items-start">
            <div className="min-w-[50px] h-[50px] rounded-full bg-[#e6edff] flex items-center justify-center text-[#1d2b8f] font-bold text-lg">
              1
            </div>

            <div>
              <h3 className="font-bold text-[#1d2b8f] text-lg">
                Arsitektur & Integrasi
              </h3>

              <p className="text-gray-700 text-sm mt-2 leading-relaxed">
                Diskominfotik memastikan aplikasi dibangun sesuai arsitektur
                SPBE daerah dan ditempatkan di Pusat Data yang dikelola
                Diskominfotik.
              </p>
            </div>
          </div>

          {/* ITEM 2 */}
          <div className="flex gap-4 items-start">
            <div className="min-w-[50px] h-[50px] rounded-full bg-[#e6edff] flex items-center justify-center text-[#1d2b8f] font-bold text-lg">
              2
            </div>

            <div>
              <h3 className="font-bold text-[#1d2b8f] text-lg">
                Kepatuhan Standar Teknis & Regulasi
              </h3>

              <p className="text-gray-700 text-sm mt-2 leading-relaxed">
                Pengajuan resmi memastikan aplikasi memenuhi standar keamanan,
                interoperabilitas, dan kualitas yang diwajibkan.
              </p>
            </div>
          </div>

          {/* ITEM 3 */}
          <div className="flex gap-4 items-start">
            <div className="min-w-[50px] h-[50px] rounded-full bg-[#e6edff] flex items-center justify-center text-[#1d2b8f] font-bold text-lg">
              3
            </div>

            <div>
              <h3 className="font-bold text-[#1d2b8f] text-lg">
                Pencatatan sebagai Aset Pemerintah Daerah
              </h3>

              <p className="text-gray-700 text-sm mt-2 leading-relaxed">
                Aplikasi yang diajukan resmi tercatat sebagai aset milik
                Pemerintah Daerah dan disimpan di repositori daerah.
              </p>
            </div>
          </div>

        </div>
      </div>

    </div>
  );
};

export default InformasiPembuka;