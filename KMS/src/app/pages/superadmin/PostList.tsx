import { useState } from "react";
import { Link } from "react-router";
import { Plus, Eye, Edit, Trash2, Search } from "lucide-react";
import { articles, seminars } from "../../data/mockData";

const allPosts = [
  ...articles.map(a => ({ id: `a-${a.id}`, title: a.title, category: a.category, date: a.date, status: "Aktif", createdBy: "Rini Agustina", type: "Artikel" })),
  ...seminars.map(s => ({ id: `s-${s.id}`, title: s.title, category: s.category, date: s.date, status: s.status === "Pendaftaran Dibuka" ? "Aktif" : "Penuh", createdBy: "Dendi Pratama", type: "Seminar" })),
];

export function PostList() {
  const [posts, setPosts] = useState(allPosts);
  const [search, setSearch] = useState("");
  const [filterCat, setFilterCat] = useState("Semua");

  const categories = ["Semua", ...Array.from(new Set(allPosts.map(p => p.category)))];

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
        <Link
          to="/superadmin/post/create"
          className="flex items-center gap-2 px-4 py-2.5 bg-[#00B4D8] text-white text-sm font-medium rounded-xl hover:bg-[#0097B8] transition-colors"
        >
          <Plus size={16} /> Add Post
        </Link>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2.5 gap-2 flex-1 max-w-sm" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <Search size={15} className="text-[#94A3B8]" />
          <input
            type="text"
            placeholder="Cari post..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="text-sm outline-none placeholder-[#94A3B8] bg-transparent flex-1"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          {categories.slice(0, 6).map(cat => (
            <button
              key={cat}
              onClick={() => setFilterCat(cat)}
              className={`px-3 py-2 rounded-xl text-xs font-medium transition-colors ${filterCat === cat ? "bg-[#0052CC] text-white" : "bg-white border border-[#E2E8F0] text-[#475569] hover:border-[#0052CC]"}`}
            >
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
              {filtered.map(p => (
                <tr key={p.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors">
                  <td className="px-4 py-3 max-w-[200px]">
                    <span className="text-sm font-medium text-[#1A2332] line-clamp-1">{p.title}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{p.category}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-xs text-[#64748B]">{p.type}</span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${p.status === "Aktif" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>
                      {p.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-[#64748B]">{p.createdBy}</td>
                  <td className="px-4 py-3 text-xs text-[#64748B] whitespace-nowrap">{p.date}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC]"><Eye size={13} /></button>
                      <Link to="/superadmin/post/create" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 inline-flex"><Edit size={13} /></Link>
                      <button onClick={() => setPosts(prev => prev.filter(x => x.id !== p.id))} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filtered.length === 0 && (
          <div className="py-12 text-center text-[#94A3B8] text-sm">Tidak ada post yang ditemukan.</div>
        )}
      </div>
    </div>
  );
}
