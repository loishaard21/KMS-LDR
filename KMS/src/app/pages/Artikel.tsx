import { useState, useEffect } from "react";
import { Link, useParams } from "react-router";
import { ChevronRight, Search } from "lucide-react";
import { fetchArticles } from "../data/api";

const categories = ["Semua", "Berita", "Sosialisasi", "Regulasi", "Panduan SPBE"];

export function Artikel() {
  const [activeCategory, setActiveCategory] = useState("Semua");
  const [search, setSearch] = useState("");
  const [articleList, setArticleList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchArticles()
      .then(res => {
        setArticleList(res);
        setLoading(false);
      })
      .catch(err => {
        console.error("Error fetching articles:", err);
        setLoading(false);
      });
  }, []);

  const filtered = articleList.filter(a => {
    const matchCat = activeCategory === "Semua" || a.category === activeCategory;
    const matchSearch = a.title.toLowerCase().includes(search.toLowerCase()) || a.excerpt.toLowerCase().includes(search.toLowerCase());
    return matchCat && matchSearch;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Informasi</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Artikel & Berita</h1>
        <p className="text-[#64748B] text-sm">Informasi terkini seputar SPBE, transformasi digital, dan kebijakan Pemprov Lampung.</p>
      </div>

      {/* Filter & Search */}
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <div className="flex gap-2 flex-wrap">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setActiveCategory(cat)}
              className={`px-4 py-2 rounded-xl text-xs font-medium transition-colors ${
                activeCategory === cat
                  ? "bg-[#0052CC] text-white"
                  : "bg-white border border-[#E2E8F0] text-[#475569] hover:border-[#0052CC]"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
        <div className="sm:ml-auto flex items-center bg-white border border-[#E2E8F0] rounded-xl px-3 py-2 gap-2">
          <Search size={14} className="text-[#94A3B8]" />
          <input
            type="text"
            placeholder="Cari artikel..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="text-sm outline-none placeholder-[#94A3B8] bg-transparent w-40"
          />
        </div>
      </div>

      {/* Grid */}
      {loading ? (
        <div className="text-center py-16 text-[#94A3B8]">Memuat artikel...</div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-[#94A3B8]">Tidak ada artikel yang ditemukan.</div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map(article => (
            <div key={article.id} className="bg-white rounded-2xl overflow-hidden border border-[#E2E8F0] hover:shadow-md transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
              <div className="relative h-44 overflow-hidden">
                <img src={article.cover} alt={article.title} className="w-full h-full object-cover hover:scale-105 transition-transform duration-500" />
                <div className="absolute top-3 left-3">
                  <span className="text-xs bg-[#0052CC] text-white px-2.5 py-1 rounded-full">{article.category}</span>
                </div>
              </div>
              <div className="p-5">
                <p className="text-[#94A3B8] text-xs mb-2">{article.date}</p>
                <h3 className="font-semibold text-[#1A2332] text-sm leading-snug mb-2 line-clamp-2">{article.title}</h3>
                <p className="text-[#64748B] text-xs leading-relaxed mb-4 line-clamp-3">{article.excerpt}</p>
                <Link to={`/artikel/${article.id}`} className="text-[#0052CC] text-xs font-medium hover:underline flex items-center gap-1">
                  Baca Selengkapnya <ChevronRight size={12} />
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export function ArtikelDetail() {
  const { id } = useParams();
  const [article, setArticle] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchArticles()
      .then(res => {
        const found = res.find((a: any) => a.id === id);
        setArticle(found);
        setLoading(false);
      })
      .catch(err => {
        console.error("Error fetching article detail:", err);
        setLoading(false);
      });
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-20 text-center">
        <p className="text-[#64748B]">Memuat artikel...</p>
      </div>
    );
  }

  if (!article) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-20 text-center">
        <p className="text-[#64748B]">Artikel tidak ditemukan.</p>
        <Link to="/artikel" className="text-[#0052CC] hover:underline mt-2 inline-block">← Kembali ke Artikel</Link>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-10">
      <Link to="/artikel" className="text-sm text-[#0052CC] hover:underline mb-6 inline-block">← Kembali ke Artikel</Link>
      <div className="relative h-64 rounded-2xl overflow-hidden mb-6">
        <img src={article.cover} alt={article.title} className="w-full h-full object-cover" />
      </div>
      <div className="flex gap-2 mb-3">
        <span className="text-xs bg-[#0052CC] text-white px-2.5 py-1 rounded-full">{article.category}</span>
        <span className="text-xs text-[#94A3B8]">{article.date}</span>
      </div>
      <h1 className="text-2xl font-bold text-[#1A2332] mb-4">{article.title}</h1>
      <p className="text-[#475569] text-sm leading-relaxed">{article.excerpt}</p>
      <p className="text-[#475569] text-sm leading-relaxed mt-4">{article.content}</p>
    </div>
  );
}
