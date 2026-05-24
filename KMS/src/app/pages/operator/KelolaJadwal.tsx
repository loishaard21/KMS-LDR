import { useState } from "react";
import { Plus, Edit, Trash2, X, Save } from "lucide-react";
import { jadwalList as initialJadwal } from "../../data/mockData";

export function KelolaJadwal() {
  const [jadwal, setJadwal] = useState(initialJadwal);
  const [showModal, setShowModal] = useState(false);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Jadwal</h2>
          <p className="text-xs text-[#64748B]">Kelola jadwal seminar dan kegiatan yang tampil di portal.</p>
        </div>
        <button onClick={() => setShowModal(true)} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
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
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {jadwal.map(item => (
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
                    <span className={`text-xs px-2 py-0.5 rounded-full ${item.status === "Pendaftaran Dibuka" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>{item.status}</span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600"><Edit size={13} /></button>
                      <button onClick={() => setJadwal(j => j.filter(x => x.id !== item.id))} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
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
              <h2 className="font-semibold text-[#1A2332]">Tambah Jadwal</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Pilih Seminar</label>
                <select className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
                  <option>-- Pilih Seminar --</option>
                  <option>Sosialisasi SPBE 2025</option>
                  <option>Workshop Transformasi Digital</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Tanggal</label>
                <input type="date" className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Status</label>
                <select className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
                  <option>Pendaftaran Dibuka</option>
                  <option>Kuota Penuh</option>
                </select>
              </div>
            </div>
            <div className="px-6 py-4 border-t border-[#E2E8F0] flex justify-end gap-3">
              <button onClick={() => setShowModal(false)} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
              <button onClick={() => setShowModal(false)} className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] flex items-center gap-2">
                <Save size={14} /> Simpan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
