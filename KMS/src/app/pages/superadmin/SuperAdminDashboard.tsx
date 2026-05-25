import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from "recharts";
import { BookOpen, Users, Award, TrendingUp, Eye, Edit, Trash2, FileText } from "lucide-react";
import { fetchSeminars, fetchArticles, fetchParticipants, deleteSeminar } from "../../data/api";

const monthlyData = [
  { month: "Okt", peserta: 42, seminar: 3 },
  { month: "Nov", peserta: 68, seminar: 4 },
  { month: "Des", peserta: 35, seminar: 2 },
  { month: "Jan", peserta: 89, seminar: 5 },
  { month: "Feb", peserta: 120, seminar: 6 },
  { month: "Mar", peserta: 156, seminar: 7 },
];

export function SuperAdminDashboard() {
  const navigate = useNavigate();
  const [seminarList, setSeminarList] = useState<any[]>([]);
  const [articleList, setArticleList] = useState<any[]>([]);
  const [participantsCount, setParticipantsCount] = useState(0);
  const [loading, setLoading] = useState(true);

  const loadData = () => {
    Promise.all([fetchSeminars(), fetchArticles(), fetchParticipants()])
      .then(([sems, arts, parts]) => {
        setSeminarList(sems);
        setArticleList(arts);
        setParticipantsCount(parts.length);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setLoading(false);
      });
  };

  const handleDeleteSeminar = async (id: string) => {
    if (confirm("Hapus seminar ini?")) {
      try { await deleteSeminar(id); loadData(); }
      catch { alert("Gagal menghapus seminar."); }
    }
  };

  const totalCertificates = seminarList.filter(s => s.certificateUrl && s.certificateUrl !== "").length;

  useEffect(() => { loadData(); }, []);

  const categoryCounts: Record<string, number> = {};
  seminarList.forEach(s => {
    categoryCounts[s.category] = (categoryCounts[s.category] || 0) + 1;
  });

  const totalCategories = Object.values(categoryCounts).reduce((a, b) => a + b, 0) || 1;
  const colors = ["#0052CC", "#00B4D8", "#7C3AED", "#22C55E", "#F59E0B"];
  const categoryData = Object.keys(categoryCounts).map((name, idx) => ({
    name,
    value: Math.round(((categoryCounts[name] || 0) / totalCategories) * 100),
    color: colors[idx % colors.length],
  }));

  const systemStats = [
    { label: "Total Seminar", value: loading ? "..." : seminarList.length.toString(), sub: "+3 bulan ini", icon: BookOpen, color: "#0052CC", bg: "#EEF4FF" },
    { label: "Total Peserta", value: loading ? "..." : participantsCount.toString(), sub: "+89 bulan ini", icon: Users, color: "#00B4D8", bg: "#E0F7FA" },
    { label: "Sertifikat Diterbitkan", value: loading ? "..." : totalCertificates.toString(), sub: "+12 bulan ini", icon: Award, color: "#22C55E", bg: "#F0FFF4" },
    { label: "Total Artikel", value: loading ? "..." : articleList.length.toString(), sub: "+5 bulan ini", icon: FileText, color: "#7C3AED", bg: "#F5F3FF" },
  ];

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {systemStats.map(stat => {
          const Icon = stat.icon;
          return (
            <div key={stat.label} className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
              <div className="flex items-start justify-between mb-3">
                <div>
                  <p className="text-xs text-[#64748B] mb-1">{stat.label}</p>
                  <p className="text-2xl font-bold text-[#1A2332]">{stat.value}</p>
                </div>
                <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ backgroundColor: stat.bg }}>
                  <Icon size={18} style={{ color: stat.color }} />
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

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Bar Chart */}
        <div className="lg:col-span-2 bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-[#1A2332] text-sm">Tren Peserta Bulanan</h3>
            <span className="text-xs text-[#94A3B8]">6 bulan terakhir</span>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={monthlyData} barSize={20}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 12, border: "none", boxShadow: "0 4px 20px rgba(0,0,0,0.1)", fontSize: 12 }} />
              <Bar dataKey="peserta" fill="#0052CC" radius={[4, 4, 0, 0]} name="Peserta" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Pie Chart */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <h3 className="font-semibold text-[#1A2332] text-sm mb-4">Distribusi Kategori</h3>
          <ResponsiveContainer width="100%" height={120}>
            <PieChart>
              <Pie data={categoryData.length ? categoryData : [{ name: "Belum Ada", value: 100 }]} cx="50%" cy="50%" outerRadius={50} dataKey="value">
                {categoryData.length ? categoryData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                )) : <Cell fill="#94A3B8" />}
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 12, border: "none", fontSize: 11 }} />
            </PieChart>
          </ResponsiveContainer>
          <div className="space-y-1.5 mt-2">
            {categoryData.map(cat => (
              <div key={cat.name} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ backgroundColor: cat.color }} />
                  <span className="text-xs text-[#64748B]">{cat.name}</span>
                </div>
                <span className="text-xs font-medium text-[#1A2332]">{cat.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Content Table */}
      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="px-5 py-4 border-b border-[#F1F5F9] flex items-center justify-between">
          <h3 className="font-semibold text-[#1A2332] text-sm">Konten Terbaru</h3>
          <span className="text-xs text-[#94A3B8]">Semua OPD</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Kategori</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Judul</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Dibuat Oleh</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tanggal</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="text-center py-4 text-xs text-[#94A3B8]">Memuat konten...</td>
                </tr>
              ) : seminarList.slice(0, 5).map(s => (
                <tr key={s.id} className="border-t border-[#F1F5F9] hover:bg-[#FAFBFC]">
                  <td className="px-4 py-3">
                    <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{s.category}</span>
                  </td>
                  <td className="px-4 py-3 text-sm text-[#1A2332] max-w-[200px]">
                    <span className="truncate block">{s.title}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full ${s.status === "Pendaftaran Dibuka" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>
                      {s.status === "Pendaftaran Dibuka" ? "Aktif" : "Penuh"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{s.author?.name || "Superadmin"}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{s.date}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button onClick={() => navigate(`/seminar/${s.id}`)} title="Lihat" className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC]"><Eye size={13} /></button>
                      <button onClick={() => navigate("/superadmin/post")} title="Edit" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600"><Edit size={13} /></button>
                      <button onClick={() => handleDeleteSeminar(s.id)} title="Hapus" className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
