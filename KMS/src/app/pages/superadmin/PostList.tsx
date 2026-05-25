import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { Plus, Eye, Edit, Trash2, Search } from "lucide-react";
import { fetchArticles, fetchSeminars, deleteArticle, deleteSeminar } from "../../data/api";

export function PostList() {
  const navigate = useNavigate();
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [filterCat, setFilterCat] = useState("Semua");

  const loadData = () => {
    setLoading(true);
    Promise.all([fetchArticles(), fetchSeminars()])
      .then(([articlesRes, seminarsRes]) => {
        const merged = [
          ...articlesRes.map((a: any) => ({
            id: a.id, realId: a.id, title: a.title, category: a.category,
            date: a.date, status: "Aktif", 
            createdBy: a.author?.name || "System/Superadmin", 
            type: "Artikel",
          })),
          ...seminarsRes.map((s: any) => ({
            id: s.id, realId: s.id, title: s.title, category: s.category,
            date: s.date,
            status: s.status === "Pendaftaran Dibuka" ? "Aktif" : "Penuh",
            createdBy: s.author?.name || "System/Operator", 
            type: "Seminar",
          })),
        ];
        setPosts(merged);
        setLoading(false);
      })
      .catch(err => { console.error(err); setLoading(false); });
  };

  useEffect(() => { loadData(); }, []);

  const handleDelete = async (realId: string, type: string) => {
    if (confirm(`Apakah Anda yakin ingin menghapus ${type} ini?`)) {
      try {
        if (type === "Artikel") await deleteArticle(realId);
        else await deleteSeminar(realId);
        loadData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus konten.");
      }
    }
  };

  const handleView = (p: any) => {
    if (p.type === "Artikel") navigate(`/artikel/${p.realId}`);
    else navigate(`/seminar/${p.realId}`);
  };

  const categories = ["Semua", ...Array.from(new Set(posts.map(p => p.category)))];
  const filtered = posts.filter(p => {
    const matchSearch = p.title.toLowerCase().includes(search.toLowerCase());
    const matchCat = filterCat === "Semua" || p.category === filterCat;
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">All Posts</h2>
          <p className="text-xs text-[#64748B]">Kelola semua konten yang dipublikasikan di portal.</p>
        </div>
        <button
          onClick={() => navigate("/superadmin/post/create")}
          className="flex items-center gap-2 px-4 py-2.5 bg-[#00B4D8] text-white text-sm font-medium rounded-xl hover:bg-[#0097B8] transition-colors"
        >
          <Plus size={16} /> Add Post
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2.5 gap-2 flex-1 max-w-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <Search size={15} className="text-[#94A3B8]" />
          <input type="text" placeholder="Cari post..." value={search} onChange={e => setSearch(e.target.value)} className="text-sm outline-none placeholder-[#94A3B8] bg-transparent flex-1" />
        </div>
        <div className="flex gap-2 flex-wrap">
          {categories.slice(0, 6).map(cat => (
            <button key={cat} onClick={() => setFilterCat(cat)}
              className={`px-3 py-2 rounded-xl text-xs font-medium transition-colors ${filterCat === cat ? "bg-[#0052CC] text-white" : "bg-white border border-[#E2E8F0] text-[#475569] hover:border-[#0052CC]"}`}>
              {cat}
            </button>
          ))}
        </div>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Judul</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Kategori</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tipe</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Dibuat Oleh</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Tanggal</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={7} className="text-center py-4 text-xs text-[#94A3B8]">Memuat semua postingan...</td></tr>
              ) : filtered.map(p => (
                <tr key={`${p.type}-${p.id}`} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors">
                  <td className="px-4 py-3 max-w-[200px]"><span className="text-sm font-medium text-[#1A2332] line-clamp-1">{p.title}</span></td>
                  <td className="px-4 py-3"><span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{p.category}</span></td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${p.type === "Artikel" ? "bg-purple-100 text-purple-700" : "bg-blue-100 text-blue-700"}`}>{p.type}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${p.status === "Aktif" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>{p.status}</span>
                  </td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{p.createdBy}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B] whitespace-nowrap">{p.date}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button onClick={() => handleView(p)} title="Lihat" className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC] transition-colors"><Eye size={13} /></button>
                      <button onClick={() => navigate(p.type === "Seminar" ? "/operator/kelola-seminar" : "/superadmin/post/create")} title="Edit" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"><Edit size={13} /></button>
                      <button onClick={() => handleDelete(p.realId, p.type)} title="Hapus" className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!loading && filtered.length === 0 && (
          <div className="py-12 text-center text-[#94A3B8] text-sm">Tidak ada post yang ditemukan.</div>
        )}
      </div>
    </div>
  );
}
