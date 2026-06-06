import { Eye, X, TrendingUp, TrendingDown, Minus, BarChart3 } from "lucide-react";
import { fetchEvaluations } from "../data/api";
import { useState, useEffect } from "react";

function EvaluasiDetailModal({ item, onClose }: { item: any; onClose: () => void }) {
  const scoreColor =
    item.score >= 85 ? "#22C55E" : item.score >= 70 ? "#F59E0B" : "#EF4444";
  const scoreLabel =
    item.score >= 85 ? "Sangat Baik" : item.score >= 70 ? "Cukup Baik" : item.score > 0 ? "Perlu Perhatian" : "Belum Ada Skor";
    
  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
          <div className="flex items-center gap-2">
            <BarChart3 size={18} className="text-[#0052CC]" />
            <h2 className="font-semibold text-[#1A2332] text-sm">Detail Evaluasi</h2>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-[#F8FAFC] rounded-lg transition-colors">
            <X size={16} />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-5">
          {/* Nama Kegiatan */}
          <div>
            <p className="text-xs text-[#94A3B8] mb-1 uppercase tracking-wide">Nama Kegiatan</p>
            <p className="text-base font-semibold text-[#1A2332]">{item.activity}</p>
          </div>

          {/* Info Grid */}
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-[#F8FAFC] rounded-xl p-3">
              <p className="text-xs text-[#94A3B8] mb-1">Kategori</p>
              <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2.5 py-1 rounded-full font-medium">
                {item.category}
              </span>
            </div>
            <div className="bg-[#F8FAFC] rounded-xl p-3">
              <p className="text-xs text-[#94A3B8] mb-1">Periode</p>
              <p className="text-sm font-medium text-[#1A2332]">{item.period}</p>
            </div>
          </div>

          {/* Skor */}
          <div className="bg-[#F8FAFC] rounded-xl p-4">
            <div className="flex items-center justify-between mb-3">
              <p className="text-xs text-[#94A3B8] uppercase tracking-wide">Skor Evaluasi</p>
              <span
                className="text-xs px-2.5 py-1 rounded-full font-medium"
                style={{
                  backgroundColor: item.score > 0 ? `${scoreColor}20` : "#F1F5F9",
                  color: item.score > 0 ? scoreColor : "#94A3B8",
                }}
              >
                {scoreLabel}
              </span>
            </div>
            {item.score > 0 ? (
              <>
                <div className="flex items-end gap-2 mb-2">
                  <span className="text-4xl font-bold" style={{ color: scoreColor }}>
                    {item.score}
                  </span>
                  <span className="text-sm text-[#94A3B8] mb-1">/ 100</span>
                </div>
                <div className="w-full h-3 bg-[#E2E8F0] rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{ width: `${item.score}%`, backgroundColor: scoreColor }}
                  />
                </div>
              </>
            ) : (
              <div className="flex items-center gap-2 text-[#94A3B8]">
                <Minus size={16} />
                <span className="text-sm">Belum ada skor untuk kegiatan ini</span>
              </div>
            )}
          </div>

          {/* Status */}
          <div className="flex items-center justify-between">
            <p className="text-xs text-[#94A3B8] uppercase tracking-wide">Status</p>
            <span
              className={`text-xs px-3 py-1.5 rounded-full font-medium ${
                item.status === "Selesai"
                  ? "bg-green-100 text-green-700"
                  : "bg-yellow-100 text-yellow-700"
              }`}
            >
              {item.status}
            </span>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 pb-5">
          <button
            onClick={onClose}
            className="w-full py-2.5 rounded-xl bg-[#EEF4FF] text-[#0052CC] text-sm font-medium hover:bg-[#DBEAFE] transition-colors"
          >
            Tutup
          </button>
        </div>
      </div>
    </div>
  );
}

export function Evaluasi() {
  const [evaluationList, setEvaluationList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedItem, setSelectedItem] = useState<any | null>(null);

  useEffect(() => {
    fetchEvaluations()
      .then(res => {
        setEvaluationList(res);
        setLoading(false);
      })
      .catch(err => {
        console.error("Error fetching evaluations:", err);
        setLoading(false);
      });
  }, []);

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Penilaian</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Evaluasi SPBE</h1>
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
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-5 py-4 text-sm text-[#64748B] text-center">
                    Memuat evaluasi...
                  </td>
                </tr>
              ) : evaluationList.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-5 py-8 text-sm text-[#94A3B8] text-center">
                    Belum ada data evaluasi.
                  </td>
                </tr>
              ) : (
                evaluationList.map((item, idx) => (
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
                      <button
                        onClick={() => setSelectedItem(item)}
                        className="flex items-center gap-1.5 text-xs text-[#0052CC] hover:underline font-medium"
                      >
                        <Eye size={13} /> Lihat
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <p className="text-xs text-[#94A3B8] mt-4">* Halaman ini bersifat read-only. Data evaluasi diperbarui secara berkala oleh administrator.</p>

      {selectedItem && (
        <EvaluasiDetailModal item={selectedItem} onClose={() => setSelectedItem(null)} />
      )}
    </div>
  );
}
