import { useState } from "react";
import { Link, useSearchParams } from "react-router";
import { Search, Calendar, MapPin, ArrowUpRight, Filter } from "lucide-react";
import { seminars } from "../data/mockData";

function ModeBadge({ mode }: { mode: string }) {
  const colors: Record<string, string> = {
    Hybrid: "bg-purple-100 text-purple-700",
    Online: "bg-blue-100 text-blue-700",
    Offline: "bg-orange-100 text-orange-700",
  };
  return <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${colors[mode] || "bg-gray-100 text-gray-700"}`}>{mode}</span>;
}

function StatusBadge({ status }: { status: string }) {
  const isFull = status === "Kuota Penuh";
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${isFull ? "bg-red-100 text-red-600" : "bg-green-100 text-green-700"}`}>
      {status}
    </span>
  );
}

function CapacityBar({ registered, capacity }: { registered: number; capacity: number }) {
  const pct = Math.min(100, Math.round((registered / capacity) * 100));
  const color = pct >= 90 ? "#EF4444" : pct >= 60 ? "#F59E0B" : "#22C55E";
  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <span className="text-xs text-[#64748B]">{registered}/{capacity} peserta</span>
        <span className="text-xs font-medium" style={{ color }}>{pct}%</span>
      </div>
      <div className="h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
        <div className="h-full rounded-full" style={{ width: `${pct}%`, backgroundColor: color }} />
      </div>
    </div>
  );
}

export function SeminarList() {
  const [searchParams] = useSearchParams();
  const [search, setSearch] = useState(searchParams.get("q") || "");
  const [filterMode, setFilterMode] = useState("Semua");
  const [filterStatus, setFilterStatus] = useState("Semua");

  const filtered = seminars.filter(s => {
    const matchSearch = s.title.toLowerCase().includes(search.toLowerCase()) ||
      s.category.toLowerCase().includes(search.toLowerCase()) ||
      s.speaker.toLowerCase().includes(search.toLowerCase());
    const matchMode = filterMode === "Semua" || s.mode === filterMode;
    const matchStatus = filterStatus === "Semua" || s.status === filterStatus;
    return matchSearch && matchMode && matchStatus;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Header */}
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Agenda KMS</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Seminar & Pelatihan</h1>
        <p className="text-[#64748B] text-sm">Daftar seluruh seminar, workshop, dan pelatihan yang diselenggarakan Pemprov Lampung.</p>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3 mb-8">
        <div className="flex-1 flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2.5 gap-2" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <Search size={16} className="text-[#94A3B8]" />
          <input
            type="text"
            placeholder="Cari seminar..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="flex-1 text-sm text-[#1A2332] outline-none placeholder-[#94A3B8] bg-transparent"
          />
        </div>
        <select
          value={filterMode}
          onChange={e => setFilterMode(e.target.value)}
          className="bg-white border border-[#E2E8F0] rounded-xl px-4 py-2.5 text-sm text-[#475569] outline-none focus:border-[#0052CC]"
        >
          {["Semua", "Hybrid", "Online", "Offline"].map(m => <option key={m}>{m}</option>)}
        </select>
        <select
          value={filterStatus}
          onChange={e => setFilterStatus(e.target.value)}
          className="bg-white border border-[#E2E8F0] rounded-xl px-4 py-2.5 text-sm text-[#475569] outline-none focus:border-[#0052CC]"
        >
          {["Semua", "Pendaftaran Dibuka", "Kuota Penuh"].map(s => <option key={s}>{s}</option>)}
        </select>
      </div>

      {/* Grid */}
      {filtered.length === 0 ? (
        <div className="text-center py-16 text-[#94A3B8]">
          <Filter size={40} className="mx-auto mb-3 opacity-40" />
          <p>Tidak ada seminar yang sesuai filter.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map(s => {
            const isFull = s.status === "Kuota Penuh";
            return (
              <div key={s.id} className="bg-white rounded-2xl overflow-hidden border border-[#E2E8F0] hover:shadow-lg transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
                <div className="relative h-44 overflow-hidden">
                  <img src={s.cover} alt={s.title} className="w-full h-full object-cover" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
                  <div className="absolute top-3 left-3 flex gap-1.5">
                    <ModeBadge mode={s.mode} />
                    <StatusBadge status={s.status} />
                  </div>
                  <div className="absolute bottom-3 left-3">
                    <span className="text-xs bg-[#0052CC] text-white px-2 py-0.5 rounded-full">{s.category}</span>
                  </div>
                </div>
                <div className="p-4">
                  <h3 className="font-semibold text-[#1A2332] text-sm leading-snug mb-3 line-clamp-2">{s.title}</h3>
                  <div className="flex items-center gap-2 mb-3">
                    <img src={s.speakerAvatar} alt={s.speaker} className="w-7 h-7 rounded-full object-cover flex-shrink-0" />
                    <div className="min-w-0">
                      <div className="text-xs font-medium text-[#1A2332] truncate">{s.speaker}</div>
                      <div className="text-xs text-[#94A3B8] truncate">{s.speakerRole}</div>
                    </div>
                  </div>
                  <div className="space-y-1.5 mb-3">
                    <div className="flex items-center gap-2 text-xs text-[#64748B]">
                      <Calendar size={12} className="text-[#0052CC]" />
                      <span>{s.date}</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-[#64748B]">
                      <MapPin size={12} className="text-[#0052CC]" />
                      <span className="truncate">{s.location}</span>
                    </div>
                  </div>
                  <div className="mb-4">
                    <CapacityBar registered={s.registered} capacity={s.capacity} />
                  </div>
                  <div className="flex gap-2">
                    <Link to={`/seminar/${s.id}`} className="flex-1 text-center text-xs font-medium px-3 py-2 rounded-xl border border-[#0052CC] text-[#0052CC] hover:bg-[#EEF4FF] transition-colors">
                      Detail
                    </Link>
                    {isFull ? (
                      <button disabled className="flex-1 text-xs font-medium px-3 py-2 rounded-xl bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed">Penuh</button>
                    ) : (
                      <a href={s.daftarUrl || "#"} target="_blank" rel="noreferrer" className="flex-1 flex items-center justify-center gap-1 text-xs font-medium px-3 py-2 rounded-xl bg-[#22C55E] text-white hover:bg-[#16A34A] transition-colors">
                        Daftar <ArrowUpRight size={11} />
                      </a>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
