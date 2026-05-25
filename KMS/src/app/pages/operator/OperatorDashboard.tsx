import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { BookOpen, Users, Award, TrendingUp, Eye, Edit, Trash2 } from "lucide-react";
import { fetchSeminars, fetchParticipants, deleteSeminar } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

const monthlyData = [
  { month: "Okt", peserta: 42 },
  { month: "Nov", peserta: 68 },
  { month: "Des", peserta: 35 },
  { month: "Jan", peserta: 89 },
  { month: "Feb", peserta: 120 },
  { month: "Mar", peserta: 156 },
];

export function OperatorDashboard() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [seminarList, setSeminarList] = useState<any[]>([]);
  const [participantList, setParticipantList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const loadData = () => {
    Promise.all([fetchSeminars(), fetchParticipants()])
      .then(([sems, parts]) => {
        // Filter seminars by authorId
        const filteredSems = user ? sems.filter((s: any) => s.authorId === user.id) : sems;
        setSeminarList(filteredSems);

        // Filter participants to only those registered for the operator's seminars
        const semIds = filteredSems.map((s: any) => s.id);
        const filteredParts = parts.filter((p: any) => semIds.includes(p.seminarId));
        setParticipantList(filteredParts);
        
        setLoading(false);
      })
      .catch(err => {
        console.error("Error loading dashboard data:", err);
        setLoading(false);
      });
  };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus seminar ini?")) {
      try { await deleteSeminar(id); loadData(); }
      catch { alert("Gagal menghapus seminar."); }
    }
  };

  const totalSeminars = seminarList.length;
  const totalParticipants = participantList.length;
  const certificatesCount = participantList.filter(p => p.status === "Certificate Issued" || p.status === "Attended").length;

  useEffect(() => { loadData(); }, []);

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: "Total Seminar", value: loading ? "..." : totalSeminars, sub: "+3 bulan ini", icon: BookOpen, color: "#0052CC", bg: "#EEF4FF" },
          { label: "Total Peserta", value: loading ? "..." : totalParticipants, sub: "+89 bulan ini", icon: Users, color: "#00B4D8", bg: "#E0F7FA" },
          { label: "Sertifikat Diterbitkan", value: loading ? "..." : certificatesCount, sub: "+124 bulan ini", icon: Award, color: "#22C55E", bg: "#F0FFF4" },
        ].map(stat => {
          const Icon = stat.icon;
          return (
            <div key={stat.label} className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="text-xs text-[#64748B] mb-1">{stat.label}</p>
                  <p className="text-2xl font-bold text-[#1A2332]">{stat.value}</p>
                </div>
                <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ backgroundColor: stat.bg }}>
                  <Icon size={20} style={{ color: stat.color }} />
                </div>
              </div>
              <div className="flex items-center gap-1 text-xs text-[#22C55E]">
                <TrendingUp size={12} />
                <span>{stat.sub}</span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Chart + Table */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Bar Chart */}
        <div className="lg:col-span-2 bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <h3 className="font-semibold text-[#1A2332] mb-4 text-sm">Tren Peserta Bulanan</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={monthlyData} barSize={20}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 12, border: "none", boxShadow: "0 4px 20px rgba(0,0,0,0.1)", fontSize: 12 }} />
              <Bar dataKey="peserta" fill="#0052CC" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Content Table */}
        <div className="lg:col-span-3 bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <div className="px-5 py-4 border-b border-[#F1F5F9]">
            <h3 className="font-semibold text-[#1A2332] text-sm">Konten Terbaru</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-[#F8FAFC]">
                  <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Kategori</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Judul</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Dibuat</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={5} className="text-center py-4 text-xs text-[#94A3B8]">Memuat konten...</td>
                  </tr>
                ) : (
                  seminarList.slice(0, 4).map(s => (
                    <tr key={s.id} className="border-t border-[#F1F5F9] hover:bg-[#FAFBFC]">
                      <td className="px-4 py-3">
                        <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{s.category}</span>
                      </td>
                      <td className="px-4 py-3 text-sm text-[#1A2332] max-w-[160px]">
                        <span className="truncate block">{s.title}</span>
                      </td>
                      <td className="px-4 py-3">
                        <span className={`text-xs px-2 py-0.5 rounded-full ${s.status === "Pendaftaran Dibuka" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>
                          {s.status === "Pendaftaran Dibuka" ? "Aktif" : "Penuh"}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-xs text-[#64748B]">Mar 2025</td>
                      <td className="px-4 py-3">
                     <div className="flex gap-1.5">
                          <button onClick={() => navigate(`/seminar/${s.id}`)} title="Lihat" className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC]"><Eye size={13} /></button>
                          <button onClick={() => navigate("/operator/kelola-seminar")} title="Kelola" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600"><Edit size={13} /></button>
                          <button onClick={() => handleDelete(s.id)} title="Hapus" className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
