import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, BookOpen } from "lucide-react";
import { fetchGuides, createGuide, updateGuide, deleteGuide } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

function GuideForm({
  onSave,
  onClose,
  guide,
}: {
  onSave: (d: any) => void;
  onClose: () => void;
  guide?: any | null;
}) {
  const [form, setForm] = useState({
    title: guide?.title || "",
    key: guide?.key || "",
    content: guide?.content || "",
    order: guide?.order ?? 0,
  });

  const generateKey = (title: string) =>
    title.toLowerCase().replace(/[^a-z0-9]+/g, "-");

  return (
    <form
      onSubmit={e => { e.preventDefault(); onSave(form); }}
      className="p-6 space-y-4 max-h-[80vh] overflow-y-auto"
    >
      <div className="grid grid-cols-2 gap-4">
        <div className="col-span-2">
          <label className="block text-sm font-medium text-[#374151] mb-1.5">
            Judul Panduan <span className="text-red-500">*</span>
          </label>
          <input
            required
            value={form.title}
            onChange={e => setForm(f => ({ ...f, title: e.target.value, key: generateKey(e.target.value) }))}
            placeholder="Contoh: Alur Pembangunan"
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">
            Slug / Key <span className="text-red-500">*</span>
          </label>
          <input
            required
            value={form.key}
            onChange={e => setForm(f => ({ ...f, key: e.target.value }))}
            placeholder="alur-pembangunan"
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC] font-mono"
          />
          <p className="text-xs text-[#94A3B8] mt-1">Identifier unik (diisi otomatis)</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-[#374151] mb-1.5">
            Urutan (Order)
          </label>
          <input
            type="number"
            value={form.order}
            onChange={e => setForm(f => ({ ...f, order: Number(e.target.value) }))}
            placeholder="1"
            min="0"
            className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]"
          />
          <p className="text-xs text-[#94A3B8] mt-1">Angka lebih kecil = tampil lebih awal</p>
        </div>
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">
          Isi Konten <span className="text-red-500">*</span>
        </label>
        <textarea
          required
          value={form.content}
          onChange={e => setForm(f => ({ ...f, content: e.target.value }))}
          placeholder="Tulis isi panduan di sini... (mendukung HTML sederhana)"
          rows={10}
          className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC] font-mono resize-y"
        />
        <p className="text-xs text-[#94A3B8] mt-1">Anda dapat menggunakan HTML seperti &lt;p&gt;, &lt;h3&gt;, &lt;ul&gt;, &lt;li&gt;, &lt;strong&gt;, dll.</p>
      </div>
      <div className="flex justify-end gap-3 pt-2 border-t border-[#E2E8F0]">
        <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
        <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#0052CC] text-white text-sm font-medium hover:bg-[#0047B3] flex items-center gap-2">
          <Save size={14} /> Simpan
        </button>
      </div>
    </form>
  );
}

export function KelolaPanduan() {
  const [guides, setGuides] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editGuide, setEditGuide] = useState<any | null>(null);
  const { user } = useAuth();

  const loadData = () => {
    setLoading(true);
    fetchGuides()
      .then(data => { setGuides(data); setLoading(false); })
      .catch(err => { console.error(err); setLoading(false); });
  };

  useEffect(() => { loadData(); }, []);

  const openAdd = () => { setEditGuide(null); setShowModal(true); };
  const openEdit = (item: any) => { setEditGuide(item); setShowModal(true); };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus panduan ini?")) {
      try { await deleteGuide(id); loadData(); }
      catch (err) { console.error(err); alert("Gagal menghapus panduan."); }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editGuide) {
        await updateGuide(editGuide.id, data);
      } else {
        await createGuide({ ...data, authorId: user?.id });
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan panduan. Pastikan slug/key tidak duplikat.");
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Panduan</h2>
          <p className="text-xs text-[#64748B]">Kelola konten halaman Panduan yang tampil di portal publik.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#0052CC] text-white text-sm font-medium rounded-xl hover:bg-[#0047B3] transition-colors">
          <Plus size={16} /> Tambah Panduan
        </button>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569] w-10">No.</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Judul</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Slug / Key</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Dibuat Oleh</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={5} className="text-center py-4 text-xs text-[#94A3B8]">Memuat panduan...</td></tr>
              ) : guides.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-12">
                    <div className="flex flex-col items-center gap-3 text-[#94A3B8]">
                      <BookOpen size={32} />
                      <p className="text-sm">Belum ada panduan. Klik "Tambah Panduan" untuk menambahkan.</p>
                    </div>
                  </td>
                </tr>
              ) : guides.map((item, idx) => (
                <tr key={item.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC]">
                  <td className="px-4 py-3">
                    <span className="w-7 h-7 rounded-lg bg-[#EEF4FF] text-[#0052CC] font-bold text-xs flex items-center justify-center">
                      {item.order}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-sm font-medium text-[#1A2332] max-w-[220px]">
                    <span className="line-clamp-1">{item.title}</span>
                  </td>
                  <td className="px-4 py-3">
                    <code className="text-xs bg-[#F1F5F9] px-2 py-1 rounded text-[#475569]">{item.key}</code>
                  </td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{item.author?.name || "Superadmin"}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button onClick={() => openEdit(item)} title="Edit" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"><Edit size={13} /></button>
                      <button onClick={() => handleDelete(item.id)} title="Hapus" className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-2xl">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <h2 className="font-semibold text-[#1A2332]">{editGuide ? "Edit Panduan" : "Tambah Panduan"}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <GuideForm onSave={handleSave} onClose={() => setShowModal(false)} guide={editGuide} />
          </div>
        </div>
      )}
    </div>
  );
}
