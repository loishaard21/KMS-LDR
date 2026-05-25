import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, Download, X, Save } from "lucide-react";
import { fetchMaterials, createMaterial, updateMaterial, deleteMaterial } from "../../data/api";

const materialTypes = ["PDF", "DOCX", "PPTX", "XLSX", "Video", "Link"];
const materialIcons: Record<string, string> = {
  PDF: "📄", DOCX: "📝", PPTX: "📊", XLSX: "📋", Video: "🎥", Link: "🔗",
};

function MateriForm({
  onSave,
  onClose,
  materi,
}: {
  onSave: (d: any) => void;
  onClose: () => void;
  materi?: any | null;
}) {
  const [form, setForm] = useState({
    title: materi?.title || "",
    description: materi?.description || "",
    icon: materi?.icon || "📘",
    type: materi?.type || "PDF",
    size: materi?.size || "1.0 MB",
    url: materi?.url || "",
  });

  const handleTypeChange = (type: string) => {
    setForm(f => ({ ...f, type, icon: materialIcons[type] || "📘" }));
  };

  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form); }} className="p-6 space-y-4">
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Materi <span className="text-red-500">*</span></label>
        <input required value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} placeholder="Judul materi..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Deskripsi <span className="text-red-500">*</span></label>
        <textarea required rows={2} value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} placeholder="Deskripsi singkat..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC] resize-none" />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Tipe</label>
          <select value={form.type} onChange={e => handleTypeChange(e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
            {materialTypes.map(t => <option key={t}>{t}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">Ukuran File</label>
          <input value={form.size} onChange={e => setForm(f => ({ ...f, size: e.target.value }))} placeholder="Cth: 2.4 MB" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
        </div>
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">URL / Link File <span className="text-red-500">*</span></label>
        <input required value={form.url} onChange={e => setForm(f => ({ ...f, url: e.target.value }))} placeholder="https://drive.google.com/... atau URL lainnya" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div className="flex justify-end gap-3 pt-2 border-t border-[#E2E8F0]">
        <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
        <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] flex items-center gap-2">
          <Save size={14} /> Simpan
        </button>
      </div>
    </form>
  );
}

export function KelolaMateri() {
  const [materials, setMaterials] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editMateri, setEditMateri] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchMaterials()
      .then(res => { setMaterials(res); setLoading(false); })
      .catch(err => { console.error(err); setLoading(false); });
  };
  useEffect(() => { loadData(); }, []);

  const openAdd = () => { setEditMateri(null); setShowModal(true); };
  const openEdit = (mat: any) => { setEditMateri(mat); setShowModal(true); };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus materi ini?")) {
      try { await deleteMaterial(id); loadData(); }
      catch (err) { console.error(err); alert("Gagal menghapus materi."); }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editMateri) {
        await updateMaterial(editMateri.id, data);
      } else {
        await createMaterial(data);
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan materi.");
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Materi</h2>
          <p className="text-xs text-[#64748B]">Upload dan kelola modul, panduan, dan dokumen materi.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
          <Plus size={16} /> Tambah Materi
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          <p className="text-sm text-[#64748B]">Memuat materi...</p>
        ) : materials.length === 0 ? (
          <div className="col-span-3 text-center py-12 text-sm text-[#94A3B8]">
            Belum ada materi. Klik "Tambah Materi" untuk menambahkan.
          </div>
        ) : materials.map(mat => (
          <div key={mat.id} className="bg-white border border-[#E2E8F0] rounded-2xl p-5 hover:shadow-md transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="text-3xl mb-3">{mat.icon}</div>
            <h3 className="font-semibold text-[#1A2332] text-sm mb-1 leading-snug">{mat.title}</h3>
            <p className="text-[#64748B] text-xs mb-3 leading-relaxed">{mat.description}</p>
            <div className="flex items-center justify-between pt-3 border-t border-[#F1F5F9]">
              <span className="text-xs text-[#94A3B8]">{mat.type} · {mat.size}</span>
              <div className="flex gap-1.5">
                <a href={mat.url} target="_blank" rel="noreferrer" title="Download" className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC] transition-colors"><Download size={13} /></a>
                <button onClick={() => openEdit(mat)} title="Edit" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"><Edit size={13} /></button>
                <button onClick={() => handleDelete(mat.id)} title="Hapus" className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"><Trash2 size={13} /></button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <h2 className="font-semibold text-[#1A2332]">{editMateri ? "Edit Materi" : "Tambah Materi"}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <MateriForm onSave={handleSave} onClose={() => setShowModal(false)} materi={editMateri} />
          </div>
        </div>
      )}
    </div>
  );
}
