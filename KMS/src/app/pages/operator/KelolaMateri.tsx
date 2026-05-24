import { useState } from "react";
import { Plus, Edit, Trash2, Download, X, Save } from "lucide-react";
import { materials as initialMaterials } from "../../data/mockData";

export function KelolaMateri() {
  const [materials, setMaterials] = useState(initialMaterials);
  const [showModal, setShowModal] = useState(false);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Materi</h2>
          <p className="text-xs text-[#64748B]">Upload dan kelola modul, panduan, dan dokumen materi.</p>
        </div>
        <button onClick={() => setShowModal(true)} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
          <Plus size={16} /> Tambah Materi
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {materials.map(mat => (
          <div key={mat.id} className="bg-white border border-[#E2E8F0] rounded-2xl p-5 hover:shadow-md transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="text-3xl mb-3">{mat.icon}</div>
            <h3 className="font-semibold text-[#1A2332] text-sm mb-1 leading-snug">{mat.title}</h3>
            <p className="text-[#64748B] text-xs mb-3 leading-relaxed">{mat.description}</p>
            <div className="flex items-center justify-between pt-3 border-t border-[#F1F5F9]">
              <span className="text-xs text-[#94A3B8]">{mat.type} · {mat.size}</span>
              <div className="flex gap-1.5">
                <a href={mat.url} target="_blank" rel="noreferrer" className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC]"><Download size={13} /></a>
                <button className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600"><Edit size={13} /></button>
                <button onClick={() => setMaterials(m => m.filter(x => x.id !== mat.id))} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
              <h2 className="font-semibold text-[#1A2332]">Tambah Materi</h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Materi</label>
                <input placeholder="Judul materi..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC]" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Deskripsi</label>
                <textarea rows={2} placeholder="Deskripsi singkat..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl outline-none focus:border-[#0052CC] resize-none" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Upload File</label>
                <div className="border-2 border-dashed border-[#E2E8F0] rounded-xl p-4 text-center cursor-pointer hover:border-[#0052CC]/50">
                  <p className="text-xs text-[#94A3B8]">PDF/DOCX/PPTX · Maks. 10MB</p>
                </div>
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
