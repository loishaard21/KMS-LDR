import { useState, useEffect } from "react";
import { useParams, Link } from "react-router";
import { Calendar, MapPin, Users, Clock, ArrowUpRight, Download, CheckCircle, ChevronLeft, Building2, Tag } from "lucide-react";
import { fetchSeminar } from "../data/api";

export function SeminarDetail() {
  const { id } = useParams();
  const [seminar, setSeminar] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      fetchSeminar(id)
        .then(res => {
          setSeminar(res);
          setLoading(false);
        })
        .catch(err => {
          console.error("Error fetching seminar detail:", err);
          setLoading(false);
        });
    }
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center">
        <p className="text-[#64748B]">Memuat detail seminar...</p>
      </div>
    );
  }

  if (!seminar) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center">
        <p className="text-[#64748B]">Seminar tidak ditemukan.</p>
        <Link to="/seminar" className="text-[#0052CC] hover:underline mt-2 inline-block">← Kembali ke Daftar Seminar</Link>
      </div>
    );
  }

  const pct = Math.min(100, Math.round((seminar.registered / seminar.capacity) * 100));
  const color = pct >= 90 ? "#EF4444" : pct >= 60 ? "#F59E0B" : "#22C55E";
  const isFull = seminar.status === "Kuota Penuh";
  const sisa = seminar.capacity - seminar.registered;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Back */}
      <Link to="/seminar" className="inline-flex items-center gap-1.5 text-sm text-[#0052CC] hover:underline mb-6">
        <ChevronLeft size={16} /> Kembali ke Daftar Seminar
      </Link>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* LEFT COLUMN */}
        <div className="lg:col-span-2 space-y-6">
          {/* Cover */}
          <div className="relative rounded-2xl overflow-hidden h-64 sm:h-80">
            <img src={seminar.cover} alt={seminar.title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
            <div className="absolute bottom-5 left-5 right-5">
              <div className="flex flex-wrap gap-2 mb-3">
                <span className="text-xs bg-[#0052CC] text-white px-2.5 py-1 rounded-full flex items-center gap-1">
                  <Tag size={10} /> {seminar.category}
                </span>
                <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${
                  seminar.mode === "Hybrid" ? "bg-purple-500 text-white" :
                  seminar.mode === "Online" ? "bg-blue-500 text-white" : "bg-orange-500 text-white"
                }`}>{seminar.mode}</span>
                <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${isFull ? "bg-red-500 text-white" : "bg-green-500 text-white"}`}>
                  {seminar.status}
                </span>
              </div>
            </div>
          </div>

          {/* Title */}
          <div>
            <h1 className="text-2xl font-bold text-[#1A2332] leading-tight mb-4">{seminar.title}</h1>

            {/* Speaker Card */}
            <div className="flex items-center gap-4 p-4 bg-[#F8FAFC] border border-[#E2E8F0] rounded-2xl">
              <img src={seminar.speakerAvatar} alt={seminar.speaker} className="w-14 h-14 rounded-full object-cover flex-shrink-0 border-2 border-[#0052CC]/20" />
              <div>
                <div className="text-xs text-[#94A3B8] mb-0.5">Narasumber</div>
                <div className="font-semibold text-[#1A2332]">{seminar.speaker}</div>
                <div className="text-sm text-[#64748B]">{seminar.speakerRole}</div>
              </div>
            </div>
          </div>

          {/* Tentang Seminar */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h2 className="font-semibold text-[#1A2332] mb-3">Tentang Seminar</h2>
            <p className="text-[#475569] text-sm leading-relaxed">{seminar.description}</p>
          </div>

          {/* Persyaratan */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h2 className="font-semibold text-[#1A2332] mb-4">Persyaratan & Informasi</h2>
            <ul className="space-y-3">
              {seminar.requirements.map((req, i) => (
                <li key={i} className="flex items-start gap-3 text-sm text-[#475569]">
                  <CheckCircle size={16} className="text-[#22C55E] mt-0.5 flex-shrink-0" />
                  <span>{req}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Penyelenggara */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h2 className="font-semibold text-[#1A2332] mb-4">Penyelenggara</h2>
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-[#EEF4FF] rounded-xl flex items-center justify-center flex-shrink-0">
                <Building2 size={20} className="text-[#0052CC]" />
              </div>
              <div>
                <div className="font-medium text-[#1A2332]">{seminar.organizer}</div>
                <div className="text-sm text-[#64748B]">Pemerintah Provinsi Lampung</div>
              </div>
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN — Sticky */}
        <div className="lg:col-span-1">
          <div className="sticky top-24 space-y-4">
            <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
              <h2 className="font-semibold text-[#1A2332] mb-5">Informasi Kegiatan</h2>

              {/* Info Items */}
              <div className="space-y-4 mb-5">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#EEF4FF] flex items-center justify-center flex-shrink-0">
                    <Calendar size={14} className="text-[#0052CC]" />
                  </div>
                  <div>
                    <div className="text-xs text-[#94A3B8]">Tanggal</div>
                    <div className="text-sm font-medium text-[#1A2332]">{seminar.date}</div>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#EEF4FF] flex items-center justify-center flex-shrink-0">
                    <Clock size={14} className="text-[#0052CC]" />
                  </div>
                  <div>
                    <div className="text-xs text-[#94A3B8]">Waktu</div>
                    <div className="text-sm font-medium text-[#1A2332]">{seminar.time}</div>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#EEF4FF] flex items-center justify-center flex-shrink-0">
                    <MapPin size={14} className="text-[#0052CC]" />
                  </div>
                  <div>
                    <div className="text-xs text-[#94A3B8]">Lokasi</div>
                    <div className="text-sm font-medium text-[#1A2332]">{seminar.location}</div>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#EEF4FF] flex items-center justify-center flex-shrink-0">
                    <Users size={14} className="text-[#0052CC]" />
                  </div>
                  <div>
                    <div className="text-xs text-[#94A3B8]">Kapasitas</div>
                    <div className="text-sm font-medium text-[#1A2332]">{seminar.capacity} peserta</div>
                  </div>
                </div>
              </div>

              {/* Progress */}
              <div className="mb-5">
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-sm text-[#64748B]">{seminar.registered}/{seminar.capacity} peserta</span>
                  <span className="text-sm font-semibold" style={{ color }}>{sisa} sisa</span>
                </div>
                <div className="h-2 bg-[#E2E8F0] rounded-full overflow-hidden">
                  <div className="h-full rounded-full transition-all" style={{ width: `${pct}%`, backgroundColor: color }} />
                </div>
              </div>

              {/* Daftar Button */}
              {isFull ? (
                <button disabled className="w-full py-3 rounded-xl bg-[#E2E8F0] text-[#94A3B8] text-sm font-medium cursor-not-allowed mb-3">
                  Pendaftaran Ditutup
                </button>
              ) : (
                <a
                  href={seminar.daftarUrl || "#"}
                  target="_blank"
                  rel="noreferrer"
                  className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-[#22C55E] text-white text-sm font-semibold hover:bg-[#16A34A] transition-colors mb-3"
                >
                  Daftar Sekarang <ArrowUpRight size={16} />
                </a>
              )}

              {/* Certificate */}
              <a
                href={seminar.certificateUrl}
                target="_blank"
                rel="noreferrer"
                className="w-full flex items-center justify-center gap-2 py-3 rounded-xl border border-[#0052CC] text-[#0052CC] text-sm font-medium hover:bg-[#EEF4FF] transition-colors"
              >
                <Download size={14} /> Unduh Sertifikat ↗
              </a>

              {/* Notes */}
              <div className="mt-4 p-3 bg-[#F0FFF4] border border-[#BBF7D0] rounded-xl">
                <div className="flex items-start gap-2">
                  <CheckCircle size={14} className="text-[#22C55E] mt-0.5 flex-shrink-0" />
                  <p className="text-xs text-[#166534]">Tidak perlu membuat akun untuk mendaftar atau mengunduh sertifikat.</p>
                </div>
              </div>
            </div>

            <Link to="/seminar" className="flex items-center gap-1.5 text-sm text-[#0052CC] hover:underline">
              <ChevronLeft size={14} /> Kembali ke Daftar Seminar
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
