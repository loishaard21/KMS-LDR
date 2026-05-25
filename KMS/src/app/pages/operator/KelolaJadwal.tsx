import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save } from "lucide-react";
import { fetchSchedules, fetchSeminars, createSchedule, updateSchedule, deleteSchedule } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

function JadwalForm({
  seminars,
  onSave,
  onClose,
  jadwal,
}: {
  seminars: any[];
  onSave: (d: any) => void;
  onClose: () => void;
  jadwal?: any | null;
}) {
  const [form, setForm] = useState({
    seminarId: jadwal?.seminarId || "",
    date: jadwal?.date || "",
    month: jadwal?.month || "",
    year: jadwal?.year || "",
    title: jadwal?.title || "",
    location: jadwal?.location || "",
    status: jadwal?.status || "Pendaftaran Dibuka",
  });

  const pick = (id: string) => {
    const s = seminars.find(x => x.id === id);
    if (s) setForm(f => ({ ...f, seminarId: id, title: s.title, location: s.location }));
  };

  return (
    <form onSubmit={e => { e.preventDefault(); onSave(form); }} className="p-6 space-y-4">
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Pilih Seminar</label>
        <select value={form.seminarId} onChange={e => pick(e.target.value)} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
          <option value="">-- Pilih Seminar --</option>
          {seminars.map(s => <option key={s.id} value={s.id}>{s.title}</option>)}
        </select>
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Kegiatan <span className="text-red-500">*</span></label>
        <input required value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} placeholder="Nama kegiatan..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Lokasi <span className="text-red-500">*</span></label>
        <input required value={form.location} onChange={e => setForm(f => ({ ...f, location: e.target.value }))} placeholder="Lokasi kegiatan..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
      </div>
      <div className="grid grid-cols-3 gap-3">
        <div>
          <label className="block text-xs font-medium text-[#374151] mb-1">Tgl <span className="text-red-500">*</span></label>
          <input required value={form.date} onChange={e => setForm(f => ({ ...f, date: e.target.value }))} placeholder="25" className="w-full px-3 py-2 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
        </div>
        <div>
          <label className="block text-xs font-medium text-[#374151] mb-1">Bulan <span className="text-red-500">*</span></label>
          <input required value={form.month} onChange={e => setForm(f => ({ ...f, month: e.target.value }))} placeholder="Apr" className="w-full px-3 py-2 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
        </div>
        <div>
          <label className="block text-xs font-medium text-[#374151] mb-1">Tahun <span className="text-red-500">*</span></label>
          <input required value={form.year} onChange={e => setForm(f => ({ ...f, year: e.target.value }))} placeholder="2025" className="w-full px-3 py-2 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
        </div>
      </div>
      <div>
        <label className="block text-sm font-medium text-[#374151] mb-1.5">Status</label>
        <select value={form.status} onChange={e => setForm(f => ({ ...f, status: e.target.value }))} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
          <option>Pendaftaran Dibuka</option>
          <option>Kuota Penuh</option>
          <option>Selesai</option>
        </select>
      </div>
      <div className="flex justify-end gap-3 pt-2 border-t border-[#E2E8F0]">
        <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
        <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] flex items-center gap-2"><Save size={14} /> Simpan</button>
      </div>
    </form>
  );
}

export function KelolaJadwal() {
  const [jadwal, setJadwal] = useState<any[]>([]);
  const [seminarList, setSeminarList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editJadwal, setEditJadwal] = useState<any | null>(null);
  const { user } = useAuth();
  const isSuperAdmin = user?.role === "superadmin";

  const loadData = () => {
    setLoading(true);
    Promise.all([fetchSchedules(), fetchSeminars()])
      .then(([scheds, sems]) => { 
        if (!isSuperAdmin) {
          scheds = scheds.filter((s: any) => s.authorId === user?.id);
        }
        setJadwal(scheds); 
        setSeminarList(sems); 
        setLoading(false); 
      })
      .catch(err => { console.error(err); setLoading(false); });
  };
  useEffect(() => { loadData(); }, []);

  const openAdd = () => { setEditJadwal(null); setShowModal(true); };
  const openEdit = (item: any) => { setEditJadwal(item); setShowModal(true); };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus jadwal ini?")) {
      try { await deleteSchedule(id); loadData(); }
      catch (err) { console.error(err); alert("Gagal menghapus jadwal."); }
    }
  };

  const handleSave = async (data: any) => {
    try {
      if (editJadwal) {
        await updateSchedule(editJadwal.id, data);
      } else {
        await createSchedule({ ...data, authorId: user?.id });
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan jadwal.");
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Jadwal</h2>
          <p className="text-xs text-[#64748B]">Kelola jadwal seminar dan kegiatan yang tampil di portal.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
          <Plus size={16} /> Tambah Jadwal
        </button>
      </div>
      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tanggal</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Kegiatan</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Lokasi</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                {isSuperAdmin && <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Dibuat Oleh</th>}
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={isSuperAdmin ? 6 : 5} className="text-center py-4 text-xs text-[#94A3B8]">Memuat jadwal...</td></tr>
              ) : jadwal.length === 0 ? (
                <tr><td colSpan={isSuperAdmin ? 6 : 5} className="text-center py-8 text-sm text-[#94A3B8]">Belum ada jadwal. Klik "Tambah Jadwal" untuk menambahkan.</td></tr>
              ) : jadwal.map(item => (
                <tr key={item.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC]">
                  <td className="px-4 py-3">
                    <div className="w-12 h-12 rounded-xl bg-[#0052CC] flex flex-col items-center justify-center">
                      <span className="text-white font-bold text-sm leading-none">{item.date}</span>
                      <span className="text-white/80 text-xs">{item.month}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm font-medium text-[#1A2332]">{item.title}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{item.location}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full ${item.status === "Pendaftaran Dibuka" ? "bg-green-100 text-green-700" : item.status === "Selesai" ? "bg-gray-100 text-gray-600" : "bg-red-100 text-red-600"}`}>{item.status}</span>
                  </td>
                  {isSuperAdmin && <td className="px-4 py-3 text-xs text-[#64748B]">{item.author?.name || "Superadmin"}</td>}
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
          <div className="bg-white rounded-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <h2 className="font-semibold text-[#1A2332]">{editJadwal ? "Edit Jadwal" : "Tambah Jadwal"}</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <JadwalForm seminars={seminarList} onSave={handleSave} onClose={() => setShowModal(false)} jadwal={editJadwal} />
          </div>
        </div>
      )}
    </div>
  );
}
