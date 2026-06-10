import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router";
import { Plus, Edit, Trash2, Eye, X, Save, ImagePlus, UploadCloud } from "lucide-react";
import { fetchSeminars, createSeminar, updateSeminar, deleteSeminar } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

const daftarTypes = ["Google Form", "Link Eksternal", "Upload File", "Teks/Info", "Nonaktif"];
const modeOptions = ["Hybrid", "Online", "Offline"];
const categoryOptions = ["SPBE", "Kompetensi", "Kepemimpinan", "Teknis", "Fungsional"];
const statusOptions = ["Pendaftaran Dibuka", "Kuota Penuh", "Selesai"];

function SeminarFormModal({ onClose, seminar, onSave }: { onClose: () => void; seminar?: any | null; onSave: (data: any) => void }) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [coverPreview, setCoverPreview] = useState<string>(seminar?.cover || "");
  const [coverBase64, setCoverBase64] = useState<string>("");

  const [form, setForm] = useState({
    title: seminar?.title || "",
    category: seminar?.category || "SPBE",
    mode: seminar?.mode || "Hybrid",
    status: seminar?.status || "Pendaftaran Dibuka",
    date: seminar?.date || "",
    time: seminar?.time || "",
    speaker: seminar?.speaker || "",
    speakerRole: seminar?.speakerRole || "",
    location: seminar?.location || "",
    capacity: seminar?.capacity?.toString() || "100",
    registered: seminar?.registered?.toString() || "0",
    organizer: seminar?.organizer || "",
    description: seminar?.description || "",
    daftarType: seminar?.daftarType || "Google Form",
    daftarUrl: seminar?.daftarUrl || "",
    certificateUrl: seminar?.certificateUrl || "",
  });

  // Convert uploaded file to base64
  const handleCoverChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      const result = ev.target?.result as string;
      setCoverPreview(result);
      setCoverBase64(result);
    };
    reader.readAsDataURL(file);
  };

  const removeCover = () => {
    setCoverPreview("");
    setCoverBase64("");
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  // Auto-suggest status based on registered vs capacity
  const handleRegisteredChange = (val: string) => {
    const reg = parseInt(val) || 0;
    const cap = parseInt(form.capacity) || 100;
    let suggestedStatus = form.status;
    if (reg >= cap && cap > 0) suggestedStatus = "Kuota Penuh";
    else if (reg < cap && form.status === "Kuota Penuh") suggestedStatus = "Pendaftaran Dibuka";
    setForm(f => ({ ...f, registered: val, status: suggestedStatus }));
  };

  const handleChange = (k: string, v: string | boolean) => setForm(f => ({ ...f, [k]: v }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({ ...form, cover: coverBase64 || undefined });
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0] sticky top-0 bg-white">
          <h2 className="font-semibold text-[#1A2332]">{seminar ? "Edit Seminar" : "Tambah Seminar"}</h2>
          <button type="button" onClick={onClose} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="sm:col-span-2">
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Seminar <span className="text-red-500">*</span></label>
              <input required value={form.title} onChange={e => handleChange("title", e.target.value)} placeholder="Judul seminar..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Kategori</label>
              <select value={form.category} onChange={e => handleChange("category", e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none">
                {categoryOptions.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Mode Pelaksanaan</label>
              <select value={form.mode} onChange={e => handleChange("mode", e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none">
                {modeOptions.map(m => <option key={m}>{m}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Status</label>
              <select value={form.status} onChange={e => handleChange("status", e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none">
                {statusOptions.map(s => <option key={s}>{s}</option>)}
              </select>
            </div>
            {/* Kapasitas & Jumlah Terdaftar */}
            
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">
                Jumlah Terdaftar
                <span className="ml-1 text-xs font-normal text-[#94A3B8]">(update manual)</span>
              </label>
              <input
                type="number"
                min={0}
                max={parseInt(form.capacity) || 9999}
                value={form.registered}
                onChange={e => handleRegisteredChange(e.target.value)}
                placeholder="0"
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all"
              />
              {/* Progress bar preview */}
              {parseInt(form.capacity) > 0 && (
                <div className="mt-2">
                  <div className="flex justify-between text-xs text-[#94A3B8] mb-1">
                    <span>{form.registered} terdaftar</span>
                    <span>{Math.round((parseInt(form.registered) || 0) / (parseInt(form.capacity) || 1) * 100)}%</span>
                  </div>
                  <div className="w-full h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all ${
                        (parseInt(form.registered) || 0) >= (parseInt(form.capacity) || 1)
                          ? 'bg-red-500'
                          : (parseInt(form.registered) || 0) / (parseInt(form.capacity) || 1) >= 0.8
                          ? 'bg-amber-500'
                          : 'bg-[#22C55E]'
                      }`}
                      style={{ width: `${Math.min(100, Math.round((parseInt(form.registered) || 0) / (parseInt(form.capacity) || 1) * 100))}%` }}
                    />
                  </div>
                  {parseInt(form.registered) >= parseInt(form.capacity) && parseInt(form.capacity) > 0 && (
                    <p className="text-xs text-amber-600 mt-1">⚠ Kuota penuh — status otomatis diubah ke "Kuota Penuh"</p>
                  )}
                </div>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Tanggal <span className="text-red-500">*</span></label>
              <input required value={form.date} onChange={e => handleChange("date", e.target.value)} placeholder="Cth: 25 April 2025" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Waktu <span className="text-red-500">*</span></label>
              <input required value={form.time} onChange={e => handleChange("time", e.target.value)} placeholder="Cth: 09.00 - 12.00 WIB" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Narasumber <span className="text-red-500">*</span></label>
              <input required value={form.speaker} onChange={e => handleChange("speaker", e.target.value)} placeholder="Nama narasumber..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Jabatan Narasumber <span className="text-red-500">*</span></label>
              <input required value={form.speakerRole} onChange={e => handleChange("speakerRole", e.target.value)} placeholder="Cth: Kepala Dinas Kominfo" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Lokasi <span className="text-red-500">*</span></label>
              <input required value={form.location} onChange={e => handleChange("location", e.target.value)} placeholder="Lokasi kegiatan..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Kapasitas</label>
              <input required type="number" value={form.capacity} onChange={e => handleChange("capacity", e.target.value)} placeholder="100" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
          {/* Cover Image Upload */}
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">
              Gambar Cover
              <span className="ml-1 text-xs font-normal text-[#94A3B8]">(opsional — pakai default jika kosong)</span>
            </label>
            <input ref={fileInputRef} type="file" accept="image/*" onChange={handleCoverChange} className="hidden" />
            {coverPreview ? (
              <div className="relative rounded-xl overflow-hidden border border-[#E2E8F0]">
                <img src={coverPreview} alt="Cover preview" className="w-full h-36 object-cover" />
                <button
                  type="button"
                  onClick={removeCover}
                  className="absolute top-2 right-2 p-1 bg-white/90 rounded-full text-red-500 hover:bg-white shadow-sm"
                >
                  <X size={14} />
                </button>
                <div className="absolute bottom-2 left-2 px-2 py-0.5 bg-black/50 text-white text-xs rounded-full">Cover dipilih</div>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="w-full border-2 border-dashed border-[#E2E8F0] rounded-xl p-5 flex flex-col items-center gap-2 hover:border-[#0052CC]/50 hover:bg-[#F8FAFC] transition-all"
              >
                <UploadCloud size={24} className="text-[#94A3B8]" />
                <span className="text-sm text-[#64748B]">Klik untuk upload foto cover</span>
                <span className="text-xs text-[#94A3B8]">JPG, PNG · Maks 5MB</span>
              </button>
            )}
          </div>

          <div className="sm:col-span-2">
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Penyelenggara <span className="text-red-500">*</span></label>
            <input required value={form.organizer} onChange={e => handleChange("organizer", e.target.value)} placeholder="Cth: Dinas Kominfo Pemprov Lampung" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
          </div>
        </div>

          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Deskripsi</label>
            <textarea required value={form.description} onChange={e => handleChange("description", e.target.value)} rows={3} placeholder="Deskripsi seminar..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all resize-none" />
          </div>

          {/* Daftar Button Config */}
          <div className="bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl p-4 space-y-3">
            <label className="block text-sm font-semibold text-[#374151]">Konfigurasi Tombol Daftar</label>
            <div>
              <label className="block text-xs font-medium text-[#374151] mb-1.5">Tipe Tombol Daftar</label>
              <select value={form.daftarType} onChange={e => handleChange("daftarType", e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none">
                {daftarTypes.map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            {form.daftarType !== "Nonaktif" && (
              <div>
                <label className="block text-xs font-medium text-[#374151] mb-1.5">
                  {form.daftarType === "Teks/Info" ? "Isi Teks/Pesan" :
                   form.daftarType === "Upload File" ? "URL File" : "URL Tautan"}
                </label>
                {form.daftarType === "Teks/Info" ? (
                  <textarea value={form.daftarUrl} onChange={e => handleChange("daftarUrl", e.target.value)} rows={2} placeholder="Tulis pesan/informasi..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none resize-none" />
                ) : (
                  <input value={form.daftarUrl} onChange={e => handleChange("daftarUrl", e.target.value)} placeholder="https://..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none" />
                )}
              </div>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">URL Sertifikat (Google Drive)</label>
            <input value={form.certificateUrl} onChange={e => handleChange("certificateUrl", e.target.value)} placeholder="https://drive.google.com/..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
          </div>
        </div>
        <div className="px-6 py-4 border-t border-[#E2E8F0] flex justify-end gap-3 sticky bottom-0 bg-white">
          <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC] transition-colors">Batal</button>
          <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] transition-colors flex items-center gap-2">
            <Save size={14} /> Simpan
          </button>
        </div>
      </form>
    </div>
  );
}

export function KelolaSeminar() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [seminars, setSeminars] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editSeminar, setEditSeminar] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchSeminars()
      .then(res => {
        // Filter by authorId if the logged-in user is an operator
        if (user && user.role === "operator") {
          setSeminars(res.filter((s: any) => s.authorId === user.id));
        } else {
          setSeminars(res);
        }
        setLoading(false);
      })
      .catch(err => {
        console.error("Error loading seminars:", err);
        setLoading(false);
      });
  };

  useEffect(() => {
    loadData();
  }, [user]);

  const openAdd = () => { setEditSeminar(null); setShowModal(true); };
  const openEdit = (s: any) => { setEditSeminar(s); setShowModal(true); };

  const handleSave = async (formData: any) => {
    try {
      const payload = {
        title: formData.title,
        category: formData.category,
        mode: formData.mode,
        status: formData.status,
        speaker: formData.speaker,
        speakerRole: formData.speakerRole,
        date: formData.date,
        time: formData.time,
        location: formData.location,
        capacity: Number(formData.capacity),
        registered: Number(formData.registered) || 0,
        organizer: formData.organizer,
        description: formData.description,
        daftarType: formData.daftarType,
        daftarUrl: formData.daftarUrl,
        certificateUrl: formData.certificateUrl,
        authorId: user?.id,
        ...(formData.cover ? { cover: formData.cover } : {}),
      };
      if (editSeminar) {
        await updateSeminar(editSeminar.id, payload);
      } else {
        await createSeminar(payload);
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error("Error saving seminar:", err);
      alert("Gagal menyimpan data seminar. Pastikan semua field wajib sudah diisi.");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Apakah Anda yakin ingin menghapus seminar ini?")) {
      try {
        await deleteSeminar(id);
        loadData();
      } catch (err) {
        console.error("Error deleting seminar:", err);
        alert("Gagal menghapus data seminar.");
      }
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Seminar</h2>
          <p className="text-xs text-[#64748B]">Manajemen seminar, pelatihan, dan workshop.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
          <Plus size={16} /> Tambah Seminar
        </button>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Judul</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Kategori</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tanggal</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Mode</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tipe Daftar</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Peserta</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={8} className="text-center py-4 text-xs text-[#94A3B8]">Memuat data seminar...</td>
                </tr>
              ) : seminars.length === 0 ? (
                <tr>
                  <td colSpan={8} className="text-center py-8 text-sm text-[#94A3B8]">Belum ada data seminar. Klik "Tambah Seminar" untuk menambahkan.</td>
                </tr>
              ) : seminars.map(s => (
                <tr key={s.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC]">
                  <td className="px-4 py-3 max-w-[200px]">
                    <span className="text-sm font-medium text-[#1A2332] line-clamp-2 leading-snug">{s.title}</span>
                  </td>
                  <td className="px-4 py-3"><span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{s.category}</span></td>
                  <td className="px-4 py-3 text-xs text-[#64748B] whitespace-nowrap">{s.date}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${s.mode === "Hybrid" ? "bg-purple-100 text-purple-700" : s.mode === "Online" ? "bg-blue-100 text-blue-700" : "bg-orange-100 text-orange-700"}`}>{s.mode}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full ${s.status === "Pendaftaran Dibuka" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>{s.status}</span>
                  </td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{s.daftarType}</td>
                  <td className="px-4 py-3 min-w-[120px]">
                    <div className="space-y-1">
                      <div className="flex justify-between text-xs">
                        <span className="font-medium text-[#1A2332]">{s.registered}<span className="text-[#94A3B8]">/{s.capacity}</span></span>
                        <span className={`text-xs font-medium ${
                          s.registered >= s.capacity ? 'text-red-500' :
                          s.registered / s.capacity >= 0.8 ? 'text-amber-600' : 'text-[#22C55E]'
                        }`}>{Math.round((s.registered / s.capacity) * 100)}%</span>
                      </div>
                      <div className="w-full h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all ${
                            s.registered >= s.capacity ? 'bg-red-500' :
                            s.registered / s.capacity >= 0.8 ? 'bg-amber-500' : 'bg-[#22C55E]'
                          }`}
                          style={{ width: `${Math.min(100, Math.round((s.registered / s.capacity) * 100))}%` }}
                        />
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button
                        onClick={() => navigate(`/seminar/${s.id}`)}
                        title="Lihat Detail"
                        className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC] transition-colors"
                      >
                        <Eye size={13} />
                      </button>
                      <button
                        onClick={() => openEdit(s)}
                        title="Edit"
                        className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"
                      >
                        <Edit size={13} />
                      </button>
                      <button
                        onClick={() => handleDelete(s.id)}
                        title="Hapus"
                        className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"
                      >
                        <Trash2 size={13} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && <SeminarFormModal onClose={() => setShowModal(false)} seminar={editSeminar} onSave={handleSave} />}
    </div>
  );
}
