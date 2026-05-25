import { useState, useEffect } from "react";
import { Download, Search, ChevronDown } from "lucide-react";
import { fetchParticipants, updateParticipant } from "../../data/api";

const statusOptions = ["Confirmed", "Attended", "Certificate Issued"];
const statusColors: Record<string, string> = {
  "Confirmed": "bg-blue-100 text-blue-700",
  "Attended": "bg-yellow-100 text-yellow-700",
  "Certificate Issued": "bg-green-100 text-green-700",
};

export function DataPeserta() {
  const [peserta, setPeserta] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const loadData = () => {
    setLoading(true);
    fetchParticipants()
      .then(res => { setPeserta(res); setLoading(false); })
      .catch(err => { console.error(err); setLoading(false); });
  };
  useEffect(() => { loadData(); }, []);

  const filtered = peserta.filter(p =>
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    p.agency.toLowerCase().includes(search.toLowerCase()) ||
    (p.seminarTitle || "").toLowerCase().includes(search.toLowerCase())
  );

  const handleUpdateStatus = async (id: string, status: string) => {
    try {
      await updateParticipant(id, { status });
      setPeserta(prev => prev.map(p => p.id === id ? { ...p, status } : p));
    } catch (err) {
      console.error(err);
      alert("Gagal mengubah status.");
    }
  };

  const handleExport = () => {
    const headers = ["Nama", "NIP", "Instansi", "Seminar", "Tanggal", "Status"];
    const rows = filtered.map(p => [p.name, p.nip, p.agency, p.seminarTitle || "", p.date, p.status]);
    const csv = [headers, ...rows].map(r => r.join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = "data-peserta.csv"; a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Data Peserta</h2>
          <p className="text-xs text-[#64748B]">Manajemen data peserta seminar dan status kehadiran.</p>
        </div>
        <button onClick={handleExport} className="flex items-center gap-2 px-4 py-2.5 bg-[#0052CC] text-white text-sm font-medium rounded-xl hover:bg-[#003D99] transition-colors">
          <Download size={15} /> Export Excel
        </button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        {[
          { label: "Total Peserta", value: peserta.length, color: "#0052CC", bg: "#EEF4FF" },
          { label: "Hadir", value: peserta.filter(p => p.status === "Attended").length, color: "#F59E0B", bg: "#FFFBEB" },
          { label: "Sertifikat Diterbitkan", value: peserta.filter(p => p.status === "Certificate Issued").length, color: "#22C55E", bg: "#F0FFF4" },
        ].map(stat => (
          <div key={stat.label} className="bg-white border border-[#E2E8F0] rounded-2xl p-4" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="text-xs text-[#64748B] mb-1">{stat.label}</div>
            <div className="text-2xl font-bold" style={{ color: stat.color }}>{loading ? "..." : stat.value}</div>
          </div>
        ))}
      </div>

      <div className="flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2.5 gap-2 max-w-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <Search size={15} className="text-[#94A3B8]" />
        <input type="text" placeholder="Cari peserta..." value={search} onChange={e => setSearch(e.target.value)} className="text-sm outline-none placeholder-[#94A3B8] bg-transparent flex-1" />
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Nama</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">NIP</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Instansi</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Seminar</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tanggal</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={6} className="text-center py-4 text-xs text-[#94A3B8]">Memuat data peserta...</td></tr>
              ) : filtered.map(p => (
                <tr key={p.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors">
                  <td className="px-4 py-3 text-sm font-medium text-[#1A2332]">{p.name}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B] font-mono">{p.nip}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{p.agency}</td>
                  <td className="px-4 py-3 text-xs text-[#475569] max-w-[180px]"><span className="truncate block">{p.seminarTitle}</span></td>
                  <td className="px-4 py-3 text-xs text-[#64748B] whitespace-nowrap">{p.date}</td>
                  <td className="px-4 py-3">
                    <div className="relative inline-block">
                      <select value={p.status} onChange={e => handleUpdateStatus(p.id, e.target.value)}
                        className={`text-xs px-3 py-1.5 rounded-full appearance-none pr-6 cursor-pointer font-medium outline-none ${statusColors[p.status] || "bg-gray-100 text-gray-700"}`}>
                        {statusOptions.map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                      <ChevronDown size={10} className="absolute right-1.5 top-1/2 -translate-y-1/2 pointer-events-none" />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!loading && filtered.length === 0 && (
          <div className="py-12 text-center text-[#94A3B8] text-sm">Tidak ada data peserta yang ditemukan.</div>
        )}
      </div>
    </div>
  );
}
