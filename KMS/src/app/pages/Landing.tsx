import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router";
import { Search, Calendar, MapPin, Users, ChevronRight, Download, ArrowUpRight, Award, BookOpen, FileText, BarChart3, CheckCircle, HelpCircle } from "lucide-react";
import { fetchSeminars, fetchArticles, fetchMaterials } from "../data/api";

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
        <div className="h-full rounded-full transition-all" style={{ width: `${pct}%`, backgroundColor: color }} />
      </div>
    </div>
  );
}

function SeminarCard({ seminar }: { seminar: any }) {
  const isFull = seminar.status === "Kuota Penuh";
  return (
    <div className="bg-white rounded-2xl overflow-hidden border border-[#E2E8F0] hover:shadow-lg transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
      {/* Cover */}
      <div className="relative h-44 overflow-hidden">
        <img src={seminar.cover} alt={seminar.title} className="w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
        <div className="absolute top-3 left-3 flex gap-1.5">
          <ModeBadge mode={seminar.mode} />
          <StatusBadge status={seminar.status} />
        </div>
        <div className="absolute bottom-3 left-3">
          <span className="text-xs bg-[#0052CC] text-white px-2 py-0.5 rounded-full">{seminar.category}</span>
        </div>
      </div>

      <div className="p-4">
        <h3 className="font-semibold text-[#1A2332] text-sm leading-snug mb-3 line-clamp-2">{seminar.title}</h3>

        {/* Speaker */}
        <div className="flex items-center gap-2 mb-3">
          <img src={seminar.speakerAvatar} alt={seminar.speaker} className="w-7 h-7 rounded-full object-cover flex-shrink-0" />
          <div className="min-w-0">
            <div className="text-xs font-medium text-[#1A2332] truncate">{seminar.speaker}</div>
            <div className="text-xs text-[#94A3B8] truncate">{seminar.speakerRole}</div>
          </div>
        </div>

        {/* Date & Location */}
        <div className="space-y-1.5 mb-3">
          <div className="flex items-center gap-2 text-xs text-[#64748B]">
            <Calendar size={12} className="text-[#0052CC] flex-shrink-0" />
            <span>{seminar.date}</span>
          </div>
          <div className="flex items-center gap-2 text-xs text-[#64748B]">
            <MapPin size={12} className="text-[#0052CC] flex-shrink-0" />
            <span className="truncate">{seminar.location}</span>
          </div>
        </div>

        {/* Capacity */}
        <div className="mb-4">
          <CapacityBar registered={seminar.registered} capacity={seminar.capacity} />
        </div>

        {/* Buttons */}
        <div className="flex gap-2">
          <Link
            to={`/seminar/${seminar.id}`}
            className="flex-1 text-center text-xs font-medium px-3 py-2 rounded-xl border border-[#0052CC] text-[#0052CC] hover:bg-[#EEF4FF] transition-colors"
          >
            Detail
          </Link>
          {isFull ? (
            <button disabled className="flex-1 text-xs font-medium px-3 py-2 rounded-xl bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed">
              Penuh
            </button>
          ) : (
            <a
              href={seminar.daftarUrl || "#"}
              target="_blank"
              rel="noreferrer"
              className="flex-1 flex items-center justify-center gap-1 text-xs font-medium px-3 py-2 rounded-xl bg-[#22C55E] text-white hover:bg-[#16A34A] transition-colors"
            >
              Daftar <ArrowUpRight size={11} />
            </a>
          )}
        </div>
      </div>
    </div>
  );
}

export function Landing() {
  const [searchQuery, setSearchQuery] = useState("");
  const navigate = useNavigate();
  const [seminarList, setSeminarList] = useState<any[]>([]);
  const [articleList, setArticleList] = useState<any[]>([]);
  const [materialList, setMaterialList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([fetchSeminars(), fetchArticles(), fetchMaterials()])
      .then(([sems, arts, mats]) => {
        setSeminarList(sems);
        setArticleList(arts);
        setMaterialList(mats);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Fetch landing data error:", err);
        setLoading(false);
      });
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) navigate(`/seminar?q=${encodeURIComponent(searchQuery)}`);
  };

  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden min-h-[90vh] flex items-center">

  {/* Background Image */}
  <div
    className="absolute inset-0 bg-center bg-cover"
    style={{
      backgroundImage: "url('./pemrov.png')",
    }}
  />

  {/* Overlay Biru Transparan */}
  <div
    className="absolute inset-0"
    style={{
      background:
        "linear-gradient(135deg, rgba(0,82,204,0.75) 0%, rgba(0,180,216,0.65) 100%)",
    }}
  />

  {/* Blur Effect */}
  <div className="absolute inset-0">
    <div className="absolute top-10 left-10 w-72 h-72 bg-white/10 rounded-full blur-3xl" />
    <div className="absolute bottom-0 right-10 w-96 h-96 bg-white/10 rounded-full blur-3xl" />
  </div>

  {/* Content */}
  <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28 w-full">

    <div className="text-center max-w-3xl mx-auto">

      <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur text-white text-xs px-4 py-1.5 rounded-full mb-5">
        <div className="w-1.5 h-1.5 bg-[#22C55E] rounded-full animate-pulse" />
        Portal Resmi Pemerintah Provinsi Lampung
      </div>

      <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4 leading-tight">
        Knowledge Management System
        <br />
        <span className="text-[#D6EFFF]">
          Pemerintahan Digital
        </span>
      </h1>

      <p className="text-white/90 text-base mb-8 leading-relaxed">
        Platform terpadu manajemen pengetahuan, seminar,
        dan pelatihan ASN Pemerintah Provinsi Lampung
        untuk mendorong transformasi digital dan
        peningkatan kompetensi.
      </p>

      {/* Search */}
      <form onSubmit={handleSearch} className="max-w-xl mx-auto">
        <div className="flex items-center bg-white rounded-2xl p-1.5 shadow-lg">

          <Search
            size={18}
            className="ml-3 text-[#94A3B8] flex-shrink-0"
          />

          <input
            type="text"
            placeholder="Cari seminar, materi, artikel..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 px-3 py-2 text-sm text-[#1A2332] outline-none bg-transparent"
          />

          <button
            type="submit"
            className="bg-[#0052CC] text-white text-sm font-medium px-5 py-2.5 rounded-xl hover:bg-[#003D99] transition-colors"
          >
            Cari
          </button>

        </div>
      </form>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-10">

        {[
          { label: "Total Seminar", value: "48", icon: BookOpen },
          { label: "Peserta Aktif", value: "1.247", icon: Users },
          { label: "Sertifikat", value: "3.892", icon: Award },
          { label: "Materi Tersedia", value: "124", icon: FileText },
        ].map((stat) => {
          const Icon = stat.icon;

          return (
            <div
              key={stat.label}
              className="bg-white/15 backdrop-blur border border-white/20 rounded-2xl p-4 text-center"
            >
              <Icon
                size={20}
                className="mx-auto text-white/80 mb-1.5"
              />

              <div className="text-2xl font-bold text-white">
                {stat.value}
              </div>

              <div className="text-white/70 text-xs mt-0.5">
                {stat.label}
              </div>
            </div>
          );
        })}

      </div>

    </div>

  </div>

</section>

      {/* Seminar Grid */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="flex items-end justify-between mb-8">
          <div>
            <p className="text-[#0052CC] text-sm font-medium mb-1">Agenda Terkini</p>
            <h2 className="text-2xl font-bold text-[#1A2332]">Seminar & Pelatihan</h2>
          </div>
          <Link to="/seminar" className="text-sm text-[#0052CC] hover:underline flex items-center gap-1">
            Lihat Semua <ChevronRight size={14} />
          </Link>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {loading ? (
            <p className="text-xs text-[#64748B]">Memuat agenda...</p>
          ) : (
            seminarList.slice(0, 3).map(s => <SeminarCard key={s.id} seminar={s} />)
          )}
        </div>
      </section>

      {/* Feature Cards */}
      <section className="bg-white border-y border-[#E2E8F0]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center mb-10">
            <p className="text-[#0052CC] text-sm font-medium mb-1">Layanan Kami</p>
            <h2 className="text-2xl font-bold text-[#1A2332]">Fitur Unggulan Platform</h2>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-5">
            {[
              {
                icon: Calendar,
                title: "Jadwal",
                desc: "Pantau seluruh agenda seminar dan pelatihan yang akan datang secara lengkap dan terstruktur.",
                color: "#0052CC",
                to: "/seminar",
              },
              {
                icon: FileText,
                title: "Regulasi",
                desc: "Akses dokumen regulasi SPBE terkini mulai dari Perpres, Permen, Kepmen hingga Pergub Lampung.",
                color: "#00B4D8",
                to: "/regulasi",
              },
              {
                icon: BookOpen,
                title: "Artikel & Berita",
                desc: "Baca artikel informatif dan berita terkini seputar SPBE, transformasi digital, dan tata kelola pemerintahan.",
                color: "#7C3AED",
                to: "/artikel",
              },
              {
                icon: BarChart3,
                title: "Evaluasi",
                desc: "Pantau hasil evaluasi kegiatan dan indikator kinerja pengetahuan organisasi Pemprov Lampung.",
                color: "#22C55E",
                to: "/evaluasi",
              },
              {
                icon: HelpCircle,
                title: "Panduan",
                desc: "Pelajari cara menggunakan portal KMS, mengelola seminar, mengakses materi, dan fitur lainnya.",
                color: "#F59E0B",
                to: "/panduan",
              },
            ].map(f => {
              const Icon = f.icon;
              return (
                <Link
                  key={f.title}
                  to={f.to}
                  className="group p-6 rounded-2xl border border-[#E2E8F0] hover:border-[#0052CC]/30 bg-[#F8FAFC] hover:bg-white transition-all hover:shadow-md"
                  style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}
                >
                  <div className="w-11 h-11 rounded-xl flex items-center justify-center mb-4" style={{ backgroundColor: `${f.color}15` }}>
                    <Icon size={22} style={{ color: f.color }} />
                  </div>
                  <h3 className="font-semibold text-[#1A2332] mb-2">{f.title}</h3>
                  <p className="text-[#64748B] text-sm leading-relaxed mb-4">{f.desc}</p>
                  <span className="text-sm font-medium flex items-center gap-1 group-hover:gap-2 transition-all" style={{ color: f.color }}>
                    Selengkapnya <ChevronRight size={14} />
                  </span>
                </Link>
              );
            })}
          </div>
        </div>
      </section>

      {/* Latest Articles */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="flex items-end justify-between mb-8">
          <div>
            <p className="text-[#0052CC] text-sm font-medium mb-1">Informasi Terkini</p>
            <h2 className="text-2xl font-bold text-[#1A2332]">Artikel & Berita</h2>
          </div>
          <Link to="/artikel" className="text-sm text-[#0052CC] hover:underline flex items-center gap-1">
            Lihat Semua <ChevronRight size={14} />
          </Link>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          {loading ? (
            <p className="text-xs text-[#64748B]">Memuat artikel...</p>
          ) : (
            articleList.slice(0, 3).map(article => (
              <div key={article.id} className="bg-white rounded-2xl overflow-hidden border border-[#E2E8F0] hover:shadow-md transition-shadow" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
                <div className="relative h-44 overflow-hidden">
                  <img src={article.cover} alt={article.title} className="w-full h-full object-cover hover:scale-105 transition-transform duration-500" />
                  <div className="absolute top-3 left-3">
                    <span className="text-xs bg-[#0052CC] text-white px-2 py-0.5 rounded-full">{article.category}</span>
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
            ))
          )}
        </div>
      </section>

      {/* Materials */}
      <section className="bg-white border-t border-[#E2E8F0]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center mb-10">
            <p className="text-[#0052CC] text-sm font-medium mb-1">Sumber Belajar</p>
            <h2 className="text-2xl font-bold text-[#1A2332]">Materi & Dokumen</h2>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {loading ? (
              <p className="text-xs text-[#64748B]">Memuat materi...</p>
            ) : (
              materialList.map(mat => (
                <div key={mat.id} className="p-5 rounded-2xl border border-[#E2E8F0] hover:border-[#0052CC]/30 bg-[#F8FAFC] hover:bg-white transition-all group" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}>
                  <div className="text-3xl mb-3">{mat.icon}</div>
                  <h3 className="font-semibold text-[#1A2332] text-sm mb-2 leading-snug">{mat.title}</h3>
                  <p className="text-[#64748B] text-xs leading-relaxed mb-3">{mat.description}</p>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-[#94A3B8]">{mat.type} · {mat.size}</span>
                    <a
                      href={mat.url}
                      target="_blank"
                      rel="noreferrer"
                      className="flex items-center gap-1 text-xs font-medium text-[#0052CC] hover:text-[#003D99]"
                    >
                      <Download size={12} /> Unduh
                    </a>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section style={{ background: "linear-gradient(135deg, #0052CC 0%, #00B4D8 100%)" }} className="relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14 text-center relative">
          <CheckCircle size={40} className="mx-auto text-white/60 mb-4" />
          <h2 className="text-2xl font-bold text-white mb-3">Tidak Perlu Membuat Akun</h2>
          <p className="text-white/80 text-sm max-w-lg mx-auto mb-6">
            Seluruh konten portal KMS dapat diakses oleh masyarakat umum dan ASN tanpa perlu mendaftar atau login. Daftar seminar langsung via tautan yang tersedia.
          </p>
          <Link to="/seminar" className="inline-flex items-center gap-2 bg-white text-[#0052CC] font-semibold text-sm px-6 py-3 rounded-xl hover:bg-[#F0F7FF] transition-colors">
            Lihat Seminar <ChevronRight size={16} />
          </Link>
        </div>
      </section>
    </div>
  );
}
