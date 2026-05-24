import { useState } from "react";
import { Plus, Edit, Trash2, Eye, X, Save, ToggleLeft, ToggleRight } from "lucide-react";
import { seminars as initialSeminars } from "../../data/mockData";

const daftarTypes = ["Google Form", "Link Eksternal", "Upload File", "Teks/Info", "Nonaktif"];

function SeminarFormModal({ onClose, seminar }: { onClose: () => void; seminar?: (typeof initialSeminars)[0] | null }) {
  const [form, setForm] = useState({
    title: seminar?.title || "",
    date: seminar?.date || "",
    speaker: seminar?.speaker || "",
    location: seminar?.location || "",
    capacity: seminar?.capacity?.toString() || "",
    description: seminar?.description || "",
    daftarType: seminar?.daftarType || "Google Form",
    daftarUrl: seminar?.daftarUrl || "",
    certificateUrl: seminar?.certificateUrl || "",
    active: true,
  });

  const handleChange = (k: string, v: string | boolean) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0] sticky top-0 bg-white">
          <h2 className="font-semibold text-[#1A2332]">{seminar ? "Edit Seminar" : "Tambah Seminar"}</h2>
          <button onClick={onClose} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="sm:col-span-2">
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Seminar</label>
              <input value={form.title} onChange={e => handleChange("title", e.target.value)} placeholder="Judul seminar..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Tanggal</label>
              <input type="date" value={form.date} onChange={e => handleChange("date", e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Kapasitas</label>
              <input type="number" value={form.capacity} onChange={e => handleChange("capacity", e.target.value)} placeholder="100" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Narasumber</label>
              <input value={form.speaker} onChange={e => handleChange("speaker", e.target.value)} placeholder="Nama narasumber..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Lokasi</label>
              <input value={form.location} onChange={e => handleChange("location", e.target.value)} placeholder="Lokasi kegiatan..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Deskripsi</label>
            <textarea value={form.description} onChange={e => handleChange("description", e.target.value)} rows={3} placeholder="Deskripsi seminar..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 outline-none transition-all resize-none" />
          </div>

          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Foto Cover</label>
            <div className="border-2 border-dashed border-[#E2E8F0] rounded-xl p-4 text-center hover:border-[#0052CC]/50 transition-colors cursor-pointer">
              <p className="text-xs text-[#94A3B8]">Klik atau drag foto cover di sini (JPG/PNG, maks. 2MB)</p>
            </div>
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
                   form.daftarType === "Upload File" ? "Upload File (PDF/DOCX)" : "URL Tautan"}
                </label>
                {form.daftarType === "Teks/Info" ? (
                  <textarea value={form.daftarUrl} onChange={e => handleChange("daftarUrl", e.target.value)} rows={2} placeholder="Tulis pesan/informasi..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white focus:border-[#0052CC] outline-none resize-none" />
                ) : form.daftarType === "Upload File" ? (
                  <div className="border-2 border-dashed border-[#E2E8F0] rounded-xl p-3 text-center cursor-pointer hover:border-[#0052CC]/50">
                    <p className="text-xs text-[#94A3B8]">Upload file PDF/DOCX...</p>
                  </div>
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

          <div className="flex items-center justify-between p-3 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl">
            <span className="text-sm font-medium text-[#374151]">Aktif / Tampilkan di Portal</span>
            <button onClick={() => handleChange("active", !form.active)} className={`w-10 h-6 rounded-full transition-colors ${form.active ? "bg-[#22C55E]" : "bg-[#94A3B8]"} relative`}>
              <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-all ${form.active ? "left-5" : "left-1"}`} />
            </button>
          </div>
        </div>
        <div className="px-6 py-4 border-t border-[#E2E8F0] flex justify-end gap-3 sticky bottom-0 bg-white">
          <button onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC] transition-colors">Batal</button>
          <button onClick={onClose} className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] transition-colors flex items-center gap-2">
            <Save size={14} /> Simpan
          </button>
        </div>
      </div>
    </div>
  );
}

export function KelolaSeminar() {
  const [seminars, setSeminars] = useState(initialSeminars);
  const [showModal, setShowModal] = useState(false);
  const [editSeminar, setEditSeminar] = useState<(typeof initialSeminars)[0] | null>(null);

  const openAdd = () => { setEditSeminar(null); setShowModal(true); };
  const openEdit = (s: (typeof initialSeminars)[0]) => { setEditSeminar(s); setShowModal(true); };
  const handleDelete = (id: string) => setSeminars(prev => prev.filter(s => s.id !== id));

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
              {seminars.map(s => (
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
                  <td className="px-4 py-3 text-xs text-[#64748B]">{s.registered}/{s.capacity}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC]"><Eye size={13} /></button>
                      <button onClick={() => openEdit(s)} className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600"><Edit size={13} /></button>
                      <button onClick={() => handleDelete(s.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && <SeminarFormModal onClose={() => setShowModal(false)} seminar={editSeminar} />}
    </div>
  );
}
