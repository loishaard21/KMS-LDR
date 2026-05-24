import { Download, FileText } from "lucide-react";
import { regulasiList } from "../data/mockData";

const groupColors: Record<string, string> = {
  "Peraturan Presiden (Perpres)": "#0052CC",
  "Peraturan Menteri (Permen)": "#7C3AED",
  "Keputusan Menteri (Kepmen)": "#00B4D8",
  "Pergub Lampung": "#22C55E",
};

export function Regulasi() {
  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Hukum & Kebijakan</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Regulasi</h1>
        <p className="text-[#64748B] text-sm">Kumpulan regulasi terkait SPBE, tata kelola pemerintahan digital, dan kebijakan Provinsi Lampung.</p>
      </div>

      <div className="space-y-8">
        {regulasiList.map(group => {
          const color = groupColors[group.group] || "#0052CC";
          return (
            <div key={group.group}>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-1 h-6 rounded-full" style={{ backgroundColor: color }} />
                <h2 className="font-bold text-[#1A2332]">{group.group}</h2>
              </div>
              <div className="space-y-3">
                {group.items.map(item => (
                  <div
                    key={item.id}
                    className="bg-white border border-[#E2E8F0] rounded-2xl p-4 flex items-center gap-4 hover:shadow-md transition-shadow group"
                    style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}
                  >
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ backgroundColor: `${color}15` }}>
                      <FileText size={18} style={{ color }} />
                    </div>
                    <p className="flex-1 text-sm text-[#1A2332] font-medium leading-snug">{item.title}</p>
                    <a
                      href={item.url}
                      target="_blank"
                      rel="noreferrer"
                      className="flex-shrink-0 flex items-center gap-1.5 text-xs font-medium px-3 py-2 rounded-xl border transition-colors"
                      style={{ borderColor: color, color }}
                    >
                      <Download size={12} /> DOWNLOAD
                    </a>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
