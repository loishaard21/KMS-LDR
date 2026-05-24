import { Download, Search } from "lucide-react";
import { materials } from "../data/mockData";
import { useState } from "react";

export function Materi() {
  const [search, setSearch] = useState("");
  const filtered = materials.filter(m =>
    m.title.toLowerCase().includes(search.toLowerCase()) ||
    m.description.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Sumber Belajar</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Materi & Dokumen</h1>
        <p className="text-[#64748B] text-sm">Unduh modul, panduan, dan template yang tersedia secara gratis untuk ASN Pemprov Lampung.</p>
      </div>

      <div className="flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2.5 gap-2 mb-8 max-w-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <Search size={16} className="text-[#94A3B8]" />
        <input
          type="text"
          placeholder="Cari materi..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="text-sm outline-none placeholder-[#94A3B8] bg-transparent flex-1"
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {filtered.map(mat => (
          <div key={mat.id} className="p-5 rounded-2xl border border-[#E2E8F0] bg-white hover:shadow-md transition-shadow group" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}>
            <div className="text-3xl mb-3">{mat.icon}</div>
            <h3 className="font-semibold text-[#1A2332] text-sm mb-2 leading-snug">{mat.title}</h3>
            <p className="text-[#64748B] text-xs leading-relaxed mb-4">{mat.description}</p>
            <div className="pt-3 border-t border-[#F1F5F9] flex items-center justify-between">
              <span className="text-xs text-[#94A3B8]">{mat.type} · {mat.size}</span>
              <a
                href={mat.url}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-1.5 text-xs font-medium text-white bg-[#0052CC] px-3 py-1.5 rounded-lg hover:bg-[#003D99] transition-colors"
              >
                <Download size={12} /> Unduh
              </a>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
