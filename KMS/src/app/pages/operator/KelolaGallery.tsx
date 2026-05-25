import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, Image as ImageIcon } from "lucide-react";
import { fetchGalleries, createGallery, updateGallery, deleteGallery } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

function GalleryForm({
  onSave,
  onClose,
  gallery,
}: {
  onSave: (d: any) => void;
  onClose: () => void;
  gallery?: any | null;
}) {
  const [form, setForm] = useState({
    title: gallery?.title || "",
    description: gallery?.description || "",
    imageUrl: gallery?.imageUrl || "",
    date: gallery?.date || new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }),
  });

  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form); }} className="p-6 space-y-4">
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Foto <span className="text-red-500">*</span></label>
        <input required value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} placeholder="Nama kegiatan foto..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Deskripsi</label>
        <textarea value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} placeholder="Deskripsi singkat..." rows={3} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">URL Gambar <span className="text-red-500">*</span></label>
        <input required value={form.imageUrl} onChange={e => setForm(f => ({ ...f, imageUrl: e.target.value }))} placeholder="https://..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Tanggal</label>
        <input required value={form.date} onChange={e => setForm(f => ({ ...f, date: e.target.value }))} placeholder="Misal: 25 Mei 2025" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      
      <div className="flex justify-end gap-3 pt-2 border-t border-[#E2E8F0]">
        <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
        <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#0052CC] text-white text-sm font-medium hover:bg-[#0047B3] flex items-center gap-2"><Save size={14} /> Simpan</button>
      </div>
    </form>
  );
}

export function KelolaGallery() {
  const [galleries, setGalleries] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editGallery, setEditGallery] = useState<any | null>(null);
  
  const { user } = useAuth();
  const isSuperAdmin = user?.role === "superadmin";

  const loadData = () => {
    setLoading(true);
    fetchGalleries()
      .then(gals => {
        if (!isSuperAdmin) {
          gals = gals.filter((g: any) => g.authorId === user?.id);
        }
        setGalleries(gals);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setLoading(false);
      });
  };

  useEffect(() => { loadData(); }, []);

  const openAdd = () => { setEditGallery(null); setShowModal(true); };
  const openEdit = (item: any) => { setEditGallery(item); setShowModal(true); };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus foto gallery ini?")) {
      try { await deleteGallery(id); loadData(); }
      catch (err) { console.error(err); alert("Gagal menghapus gallery."); }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editGallery) {
        await updateGallery(editGallery.id, data);
      } else {
        await createGallery({ ...data, authorId: user?.id });
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan gallery.");
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Gallery</h2>
          <p className="text-xs text-[#64748B]">Kelola koleksi foto dan dokumentasi kegiatan.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#0052CC] text-white text-sm font-medium rounded-xl hover:bg-[#0047B3] transition-colors">
          <Plus size={16} /> Tambah Foto
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-full py-12 text-center text-sm text-[#94A3B8]">Memuat gallery...</div>
        ) : galleries.length === 0 ? (
          <div className="col-span-full py-12 text-center text-sm text-[#94A3B8] bg-white border border-dashed border-[#E2E8F0] rounded-2xl">
            Belum ada foto gallery. Klik "Tambah Foto" untuk menambahkan.
          </div>
        ) : galleries.map(item => (
          <div key={item.id} className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden hover:shadow-lg transition-shadow">
            <div className="aspect-video bg-[#F1F5F9] relative overflow-hidden">
              <img src={item.imageUrl} alt={item.title} className="w-full h-full object-cover" />
            </div>
            <div className="p-4 space-y-2 relative">
              <div className="flex justify-between items-start gap-2">
                <h3 className="font-semibold text-[#1A2332] text-sm line-clamp-1">{item.title}</h3>
                <div className="flex gap-1 flex-shrink-0">
                  <button onClick={() => openEdit(item)} className="p-1.5 text-yellow-600 hover:bg-yellow-50 rounded-lg"><Edit size={14} /></button>
                  <button onClick={() => handleDelete(item.id)} className="p-1.5 text-red-500 hover:bg-red-50 rounded-lg"><Trash2 size={14} /></button>
                </div>
              </div>
              <p className="text-xs text-[#64748B] line-clamp-2">{item.description}</p>
              <div className="flex justify-between items-center text-xs text-[#94A3B8] pt-2 border-t border-[#F1F5F9]">
                <span>{item.date}</span>
                {isSuperAdmin && <span className="flex items-center gap-1"><ImageIcon size={12}/> {item.author?.name || "Superadmin"}</span>}
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <h2 className="font-semibold text-[#1A2332]">{editGallery ? "Edit Foto" : "Tambah Foto"}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <GalleryForm onSave={handleSave} onClose={() => setShowModal(false)} gallery={editGallery} />
          </div>
        </div>
      )}
    </div>
  );
}
