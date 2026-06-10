import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, FileText, ExternalLink, Search } from "lucide-react";
import { fetchRegulations, createRegulation, updateRegulation, deleteRegulation } from "../../data/api";

const groupColors: Record<string, string> = {
  "Undang-undang": "#F59E0B",
  "Peraturan Presiden": "#0052CC",
  "Keputusan Presiden": "#F59E0B",
  "Peraturan Menteri": "#7C3AED",
  "Keputusan Menteri": "#00B4D8",
  "Peraturan Daerah": "#F59E0B",
  "Peraturan Gubernur": "#F59E0B",
  "Keputusan Gubernur": "#F59E0B",
};

const groups = [
  "Peraturan Presiden",
  "Peraturan Menteri",
  "Keputusan Menteri",
  "Undang-undang",
  "Keputusan Presiden",
  "Peraturan Daerah",
  "Peraturan Gubernur",
  "Keputusan Gubernur",

];

function RegulasiForm({
  onSave,
  onClose,
  regulasi,
}: {
  onSave: (d: any) => void;
  onClose: () => void;
  regulasi?: any | null;
}) {
  const [form, setForm] = useState({
    group: regulasi?.group || groups[0],
    title: regulasi?.title || "",
    url: regulasi?.url || "",
  });

  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form); }} className="p-6 space-y-4">
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Kelompok Regulasi <span className="text-red-500">*</span></label>
        <select
          value={form.group}
          onChange={e => setForm(f => ({ ...f, group: e.target.value }))}
          className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
        >
          {groups.map(g => <option key={g} value={g}>{g}</option>)}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Regulasi <span className="text-red-500">*</span></label>
        <textarea
          required
          rows={3}
          value={form.title}
          onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
          placeholder="Cth: Perpres No. 95 Tahun 2018 tentang Sistem Pemerintahan Berbasis Elektronik (SPBE)..."
          className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC] resize-none"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">URL / Link Dokumen <span className="text-red-500">*</span></label>
        <input
          required
          type="text"
          value={form.url}
          onChange={e => setForm(f => ({ ...f, url: e.target.value }))}
          placeholder="https://jdih.lampungprov.go.id/..."
          className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
        />
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

export function KelolaRegulasi() {
  const [regulations, setRegulations] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editRegulasi, setEditRegulasi] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchRegulations()
      .then(res => {
        setRegulations(res);
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
    setEditRegulasi(null);
    setShowModal(true);
  };

  const openEdit = (item: any) => {
    setEditRegulasi(item);
    setShowModal(true);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Apakah Anda yakin ingin menghapus regulasi ini?")) {
      try {
        await deleteRegulation(id);
        loadData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus regulasi.");
      }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editRegulasi) {
        await updateRegulation(editRegulasi.id, data);
      } else {
        await createRegulation(data);
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan regulasi.");
    }
  };

  const filtered = regulations.filter(r =>
    r.title.toLowerCase().includes(search.toLowerCase()) ||
    r.group.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h2 className="font-bold text-[#1A2332] text-lg">Kelola Regulasi</h2>
          <p className="text-xs text-[#64748B]">Kelola hukum, peraturan presiden, kementerian, dan pergub terkait SPBE.</p>
        </div>
        <button
          onClick={openAdd}
          className="flex items-center justify-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors"
        >
          <Plus size={16} /> Tambah Regulasi
        </button>
      </div>

      {/* Search and stats bar */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between bg-white border border-[#E2E8F0] p-4 rounded-2xl" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.02)" }}>
        <div className="relative w-full sm:max-w-xs">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#94A3B8]" />
          <input
            type="text"
            placeholder="Cari regulasi..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
        </div>
        <span className="text-xs text-[#64748B] font-medium">Total: {filtered.length} Regulasi</span>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden shadow-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.04)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/4">Kelompok</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/2">Judul Regulasi</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/12">Link</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-[#475569] uppercase tracking-wide w-1/6">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={4} className="text-center py-6 text-xs text-[#94A3B8]">Memuat regulasi...</td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={4} className="text-center py-10 text-sm text-[#94A3B8]">Belum ada data regulasi.</td>
                </tr>
              ) : (
                filtered.map((item, idx) => {
                  const color = groupColors[item.group] || "#0052CC";
                  return (
                    <tr key={item.id} className={`border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors ${idx % 2 === 0 ? "" : "bg-[#FAFBFC]"}`}>
                      <td className="px-5 py-4">
                        <div className="flex items-center gap-2">
                          <div className="w-1.5 h-4 rounded-full flex-shrink-0" style={{ backgroundColor: color }} />
                          <span className="text-xs font-semibold text-[#1A2332]">{item.group}</span>
                        </div>
                      </td>
                      <td className="px-5 py-4 text-xs font-medium text-[#1A2332] leading-relaxed">
                        {item.title}
                      </td>
                      <td className="px-5 py-4">
                        <a
                          href={item.url}
                          target="_blank"
                          rel="noreferrer"
                          title="Buka Link Dokumen"
                          className="inline-flex items-center justify-center p-1.5 rounded-lg bg-[#F1F5F9] text-[#64748B] hover:bg-[#EEF4FF] hover:text-[#0052CC] transition-colors"
                        >
                          <ExternalLink size={13} />
                        </a>
                      </td>
                      <td className="px-5 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => openEdit(item)}
                            title="Edit Regulasi"
                            className="p-2 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"
                          >
                            <Edit size={14} />
                          </button>
                          <button
                            onClick={() => handleDelete(item.id)}
                            title="Hapus Regulasi"
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
                <FileText size={18} className="text-[#0052CC]" />
                <h2 className="font-bold text-[#1A2332] text-sm">{editRegulasi ? "Edit Regulasi" : "Tambah Regulasi"}</h2>
              </div>
              <button
                onClick={() => setShowModal(false)}
                className="p-2 hover:bg-[#F8FAFC] rounded-lg transition-colors"
              >
                <X size={18} />
              </button>
            </div>
            <RegulasiForm onSave={handleSave} onClose={() => setShowModal(false)} regulasi={editRegulasi} />
          </div>
        </div>
      )}
    </div>
  );
}
