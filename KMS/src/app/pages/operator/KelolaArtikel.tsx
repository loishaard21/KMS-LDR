import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, Bold, Italic, List, AlignLeft, Link as LinkIcon, Image, Eye } from "lucide-react";
import { useNavigate } from "react-router";
import { fetchArticles, createArticle, updateArticle, deleteArticle } from "../../data/api";
import { useAuth } from "../../context/AuthContext";

const articleCategories = ["Berita", "Sosialisasi", "Regulasi", "Panduan SPBE", "Form"];

function ArticleFormModal({
  onClose,
  onSave,
  article,
}: {
  onClose: () => void;
  onSave: (data: any) => void;
  article?: any | null;
}) {
  const [form, setForm] = useState({
    title: article?.title || "",
    category: article?.category || "Berita",
    content: article?.content || "",
    excerpt: article?.excerpt || "",
    cover: article?.cover || "https://images.unsplash.com/photo-1613441589134-3fc7f95a3e16?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=600",
    active: true,
  });
  const [activeFormat, setActiveFormat] = useState<string[]>([]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(form);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0] sticky top-0 bg-white">
          <h2 className="font-semibold text-[#1A2332]">{article ? "Edit Artikel" : "Tambah Artikel"}</h2>
          <button type="button" onClick={onClose} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Kategori</label>
            <select value={form.category} onChange={e => setForm(f => ({ ...f, category: e.target.value }))} className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]">
              {articleCategories.map(c => <option key={c}>{c}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul Artikel <span className="text-red-500">*</span></label>
            <input required value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} placeholder="Judul artikel..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20" />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Ringkasan</label>
            <textarea value={form.excerpt} onChange={e => setForm(f => ({ ...f, excerpt: e.target.value }))} rows={2} placeholder="Ringkasan singkat..." className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] resize-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">URL / Link Cover Image <span className="text-red-500">*</span></label>
            <input
              required
              type="text"
              value={form.cover}
              onChange={e => setForm(f => ({ ...f, cover: e.target.value }))}
              placeholder="https://images.unsplash.com/photo-..."
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20"
            />
          </div>

          {/* WYSIWYG Editor */}
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Konten Artikel <span className="text-red-500">*</span></label>
            <div className="border border-[#E2E8F0] rounded-xl overflow-hidden focus-within:border-[#0052CC] focus-within:ring-2 focus-within:ring-[#0052CC]/20">
              {/* Toolbar */}
              <div className="flex flex-wrap items-center gap-0.5 px-2 py-1.5 border-b border-[#E2E8F0] bg-[#F8FAFC]">
                {[
                  { icon: Bold, label: "bold" },
                  { icon: Italic, label: "italic" },
                  { icon: List, label: "list" },
                  { icon: AlignLeft, label: "align" },
                  { icon: LinkIcon, label: "link" },
                  { icon: Image, label: "image" },
                ].map(({ icon: Icon, label }) => (
                  <button key={label} type="button" onClick={() => setActiveFormat(f => f.includes(label) ? f.filter(x => x !== label) : [...f, label])}
                    className={`p-1.5 rounded-lg transition-colors ${activeFormat.includes(label) ? "bg-[#0052CC] text-white" : "text-[#64748B] hover:bg-[#E2E8F0]"}`}>
                    <Icon size={14} />
                  </button>
                ))}
                <div className="mx-1 w-px h-4 bg-[#E2E8F0]" />
                <select className="text-xs bg-transparent border-none outline-none text-[#64748B] px-1">
                  <option>Paragraph</option>
                  <option>Heading 1</option>
                  <option>Heading 2</option>
                </select>
              </div>
              <textarea
                required
                value={form.content}
                onChange={e => setForm(f => ({ ...f, content: e.target.value }))}
                rows={6}
                placeholder="Tulis konten artikel di sini..."
                className="w-full px-4 py-3 text-sm text-[#1A2332] outline-none resize-none placeholder-[#94A3B8] bg-white"
              />
            </div>
          </div>

          <div className="flex items-center justify-between p-3 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl">
            <span className="text-sm font-medium text-[#374151]">Aktif / Tampilkan di Portal</span>
            <button type="button" onClick={() => setForm(f => ({ ...f, active: !f.active }))} className={`w-10 h-6 rounded-full transition-colors ${form.active ? "bg-[#22C55E]" : "bg-[#94A3B8]"} relative`}>
              <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-all ${form.active ? "left-5" : "left-1"}`} />
            </button>
          </div>
        </div>
        <div className="px-6 py-4 border-t border-[#E2E8F0] flex justify-end gap-3 sticky bottom-0 bg-white">
          <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC]">Batal</button>
          <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] flex items-center gap-2">
            <Save size={14} /> Simpan
          </button>
        </div>
      </form>
    </div>
  );
}

export function KelolaArtikel() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [articles, setArticles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editArticle, setEditArticle] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchArticles()
      .then(res => {
        setArticles(res);
        setLoading(false);
      })
      .catch(err => { console.error(err); setLoading(false); });
  };

  useEffect(() => { loadData(); }, [user]);

  const openAdd = () => { setEditArticle(null); setShowModal(true); };
  const openEdit = (article: any) => { setEditArticle(article); setShowModal(true); };

  const handleSave = async (formData: any) => {
    try {
      const payload = {
        title: formData.title,
        category: formData.category,
        excerpt: formData.excerpt || formData.content?.substring(0, 150),
        cover: formData.cover,
        content: formData.content,
        authorId: user?.id,
      };
      if (editArticle) {
        await updateArticle(editArticle.id, payload);
      } else {
        await createArticle(payload);
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan artikel.");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Hapus artikel ini?")) {
      try {
        await deleteArticle(id);
        loadData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus artikel.");
      }
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Kelola Artikel</h2>
          <p className="text-xs text-[#64748B]">Kelola artikel, berita, dan informasi portal.</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors">
          <Plus size={16} /> Tambah Artikel
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          <p className="text-sm text-[#64748B]">Memuat artikel...</p>
        ) : articles.length === 0 ? (
          <div className="col-span-3 text-center py-12 text-sm text-[#94A3B8]">
            Belum ada artikel. Klik "Tambah Artikel" untuk membuat yang baru.
          </div>
        ) : articles.map(article => (
          <div key={article.id} className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden hover:shadow-md transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <img src={article.cover} alt={article.title} className="w-full h-36 object-cover" />
            <div className="p-4">
              <div className="flex items-center gap-2 mb-2">
                <span className="text-xs bg-[#EEF4FF] text-[#0052CC] px-2 py-0.5 rounded-full">{article.category}</span>
                <span className="text-xs text-[#94A3B8]">{article.date}</span>
              </div>
              <h3 className="font-semibold text-[#1A2332] text-sm line-clamp-2 mb-2">{article.title}</h3>
              <div className="flex justify-end gap-1.5 pt-2 border-t border-[#F1F5F9]">
                <button
                  onClick={() => navigate(`/artikel/${article.id}`)}
                  title="Lihat Artikel"
                  className="p-1.5 rounded-lg hover:bg-[#EEF4FF] text-[#0052CC] transition-colors"
                >
                  <Eye size={13} />
                </button>
                <button
                  onClick={() => openEdit(article)}
                  title="Edit Artikel"
                  className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"
                >
                  <Edit size={13} />
                </button>
                <button
                  onClick={() => handleDelete(article.id)}
                  title="Hapus Artikel"
                  className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"
                >
                  <Trash2 size={13} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && <ArticleFormModal onClose={() => setShowModal(false)} onSave={handleSave} article={editArticle} />}
    </div>
  );
}
