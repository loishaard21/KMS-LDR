import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, BarChart3, Search } from "lucide-react";
import { fetchEvaluations, createEvaluation, updateEvaluation, deleteEvaluation } from "../../data/api";

const categories = ["SPBE", "Kearsipan", "Transformasi Digital", "Pelayanan Publik", "Manajemen Pengetahuan"];

function EvaluasiForm({
  onSave,
  onClose,
  evaluasi,
}: {
  onSave: (d: any) => void;
  onClose: () => void;
  evaluasi?: any | null;
}) {
  const [form, setForm] = useState({
    activity: evaluasi?.activity || "",
    category: evaluasi?.category || categories[0],
    period: evaluasi?.period || "",
    score: evaluasi?.score !== undefined ? evaluasi.score : 0,
    status: evaluasi?.status || "Dalam Proses",
  });

  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form); }} className="p-6 space-y-4">
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Nama Kegiatan <span className="text-red-500">*</span></label>
        <input
          required
          type="text"
          value={form.activity}
          onChange={e => setForm(f => ({ ...f, activity: e.target.value }))}
          placeholder="Cth: Sosialisasi SPBE Pemprov Lampung 2025..."
          className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
        />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Kategori <span className="text-red-500">*</span></label>
          <select
            value={form.category}
            onChange={e => setForm(f => ({ ...f, category: e.target.value }))}
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
          >
            {categories.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Periode <span className="text-red-500">*</span></label>
          <input
            required
            type="text"
            value={form.period}
            onChange={e => setForm(f => ({ ...f, period: e.target.value }))}
            placeholder="Cth: Q1 2025 atau Sem. I 2025"
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Skor Evaluasi (0 - 100)</label>
          <input
            type="number"
            min={0}
            max={100}
            step={0.1}
            value={form.score}
            onChange={e => setForm(f => ({ ...f, score: Number(e.target.value) }))}
            placeholder="0"
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Status <span className="text-red-500">*</span></label>
          <select
            value={form.status}
            onChange={e => setForm(f => ({ ...f, status: e.target.value }))}
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
          >
            <option value="Selesai">Selesai</option>
            <option value="Dalam Proses">Dalam Proses</option>
          </select>
        </div>
      </div>

      <div className="flex justify-end gap-3 pt-4 border-t border-[#E2E8F0]">
        <button
          type="button"
          onClick={onClose}
          className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC] transition-colors"
        >
          Batal
        </button>
        <button
          type="submit"
          className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] flex items-center gap-2 transition-colors"
        >
          <Save size={14} /> Simpan
        </button>
      </div>
    </form>
  );
}

export function KelolaEvaluasi() {
  const [evaluations, setEvaluations] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editEvaluasi, setEditEvaluasi] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchEvaluations()
      .then(res => {
        setEvaluations(res);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setLoading(false);
      });
  };

  useEffect(() => {
    loadData();
  }, []);

  const openAdd = () => {
    setEditEvaluasi(null);
    setShowModal(true);
  };

  const openEdit = (item: any) => {
    setEditEvaluasi(item);
    setShowModal(true);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Apakah Anda yakin ingin menghapus data evaluasi ini?")) {
      try {
        await deleteEvaluation(id);
        loadData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus evaluasi.");
      }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editEvaluasi) {
        await updateEvaluation(editEvaluasi.id, data);
      } else {
        await createEvaluation(data);
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan evaluasi.");
    }
  };

  const filtered = evaluations.filter(e =>
    e.activity.toLowerCase().includes(search.toLowerCase()) ||
    e.category.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h2 className="font-bold text-[#1A2332] text-lg">Kelola Evaluasi</h2>
          <p className="text-xs text-[#64748B]">Kelola data rekapitulasi evaluasi kegiatan portal KMS oleh Operator.</p>
        </div>
        <button
          onClick={openAdd}
          className="flex items-center justify-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors"
        >
          <Plus size={16} /> Tambah Evaluasi
        </button>
      </div>

      {/* Search and stats bar */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between bg-white border border-[#E2E8F0] p-4 rounded-2xl" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.02)" }}>
        <div className="relative w-full sm:max-w-xs">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#94A3B8]" />
          <input
            type="text"
            placeholder="Cari kegiatan evaluasi..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
        </div>
        <span className="text-xs text-[#64748B] font-medium">Total: {filtered.length} Evaluasi</span>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden shadow-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.04)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/3">Kegiatan</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/6">Kategori</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/12">Periode</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/6">Skor</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/8">Status</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/8">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="text-center py-6 text-xs text-[#94A3B8]">Memuat evaluasi...</td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-10 text-sm text-[#94A3B8]">Belum ada data evaluasi.</td>
                </tr>
              ) : (
                filtered.map((item, idx) => {
                  const scoreColor = item.score >= 85 ? "#22C55E" : item.score >= 70 ? "#F59E0B" : "#EF4444";
                  return (
                    <tr key={item.id} className={`border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors ${idx % 2 === 0 ? "" : "bg-[#FAFBFC]"}`}>
                      <td className="px-5 py-4 text-xs font-semibold text-[#1A2332] leading-relaxed">
                        {item.activity}
                      </td>
                      <td className="px-5 py-4">
                        <span className="text-[10px] bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full font-medium">{item.category}</span>
                      </td>
                      <td className="px-5 py-4 text-xs text-[#64748B] font-medium">
                        {item.period}
                      </td>
                      <td className="px-5 py-4">
                        {item.score > 0 ? (
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-bold" style={{ color: scoreColor }}>{item.score}</span>
                            <div className="w-16 h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
                              <div
                                className="h-full rounded-full"
                                style={{
                                  width: `${item.score}%`,
                                  backgroundColor: scoreColor,
                                }}
                              />
                            </div>
                          </div>
                        ) : (
                          <span className="text-xs text-[#94A3B8]">—</span>
                        )}
                      </td>
                      <td className="px-5 py-4">
                        <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${
                          item.status === "Selesai" ? "bg-green-100 text-green-700" : "bg-yellow-100 text-yellow-700"
                        }`}>
                          {item.status}
                        </span>
                      </td>
                      <td className="px-5 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => openEdit(item)}
                            title="Edit Evaluasi"
                            className="p-2 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"
                          >
                            <Edit size={14} />
                          </button>
                          <button
                            onClick={() => handleDelete(item.id)}
                            title="Hapus Evaluasi"
                            className="p-2 rounded-lg hover:bg-red-50 text-red-500 transition-colors"
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <div className="flex items-center gap-2">
                <BarChart3 size={18} className="text-[#0052CC]" />
                <h2 className="font-bold text-[#1A2332] text-sm">{editEvaluasi ? "Edit Evaluasi" : "Tambah Evaluasi"}</h2>
              </div>
              <button
                onClick={() => setShowModal(false)}
                className="p-2 hover:bg-[#F8FAFC] rounded-lg transition-colors"
              >
                <X size={18} />
              </button>
            </div>
            <EvaluasiForm onSave={handleSave} onClose={() => setShowModal(false)} evaluasi={editEvaluasi} />
          </div>
        </div>
      )}
    </div>
  );
}
