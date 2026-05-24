import { Eye } from "lucide-react";
import { evaluasiList } from "../data/mockData";

export function Evaluasi() {
  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Penilaian</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Evaluasi Kegiatan</h1>
        <p className="text-[#64748B] text-sm">Rekap hasil evaluasi kegiatan seminar dan pelatihan Pemprov Lampung. Data bersifat publik dan hanya dapat dibaca.</p>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Kegiatan</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Kategori</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Periode</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Skor</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Status</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide">Detail</th>
              </tr>
            </thead>
            <tbody>
              {evaluasiList.map((item, idx) => (
                <tr key={item.id} className={`border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors ${idx % 2 === 0 ? "" : "bg-[#FAFBFC]"}`}>
                  <td className="px-5 py-4 text-sm font-medium text-[#1A2332]">{item.activity}</td>
                  <td className="px-5 py-4">
                    <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2.5 py-1 rounded-full font-medium">{item.category}</span>
                  </td>
                  <td className="px-5 py-4 text-sm text-[#64748B]">{item.period}</td>
                  <td className="px-5 py-4">
                    {item.score > 0 ? (
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-semibold text-[#1A2332]">{item.score}</span>
                        <div className="w-16 h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full"
                            style={{
                              width: `${item.score}%`,
                              backgroundColor: item.score >= 85 ? "#22C55E" : item.score >= 70 ? "#F59E0B" : "#EF4444"
                            }}
                          />
                        </div>
                      </div>
                    ) : (
                      <span className="text-sm text-[#94A3B8]">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${
                      item.status === "Selesai" ? "bg-green-100 text-green-700" : "bg-yellow-100 text-yellow-700"
                    }`}>
                      {item.status}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    <button className="flex items-center gap-1.5 text-xs text-[#0052CC] hover:underline">
                      <Eye size={13} /> Lihat
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <p className="text-xs text-[#94A3B8] mt-4">* Halaman ini bersifat read-only. Data evaluasi diperbarui secara berkala oleh administrator.</p>
    </div>
  );
}
