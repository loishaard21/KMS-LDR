import { Link } from "react-router";
import { MapPin, Phone, Mail, ExternalLink } from "lucide-react";

export function Footer() {
  return (
    <footer className="bg-[#1A2332] text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="md:col-span-2">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-lg bg-[#0052CC] flex items-center justify-center">
                <span className="text-white text-sm font-bold">KMS</span>
              </div>
              <div>
                <div className="text-white font-semibold">KMS Pemprov Lampung</div>
                <div className="text-[#94A3B8] text-xs">Knowledge Management System</div>
              </div>
            </div>
            <p className="text-[#94A3B8] text-sm leading-relaxed mb-4">
              Portal manajemen pengetahuan Pemerintah Provinsi Lampung untuk mendukung peningkatan kompetensi ASN dan implementasi SPBE.
            </p>
            <div className="space-y-2">
              <div className="flex items-start gap-2 text-[#94A3B8] text-sm">
                <MapPin size={14} className="mt-0.5 flex-shrink-0 text-[#00B4D8]" />
                <span>Jl. W. R. Monginsidi No. 69, Bandar Lampung 35215</span>
              </div>
              <div className="flex items-center gap-2 text-[#94A3B8] text-sm">
                <Phone size={14} className="text-[#00B4D8]" />
                <span>(0721) 475270</span>
              </div>
              <div className="flex items-center gap-2 text-[#94A3B8] text-sm">
                <Mail size={14} className="text-[#00B4D8]" />
                <span>kominfo@lampungprov.go.id</span>
              </div>
            </div>
          </div>

          {/* Navigasi */}
          <div>
            <h4 className="text-white font-semibold mb-4 text-sm">Navigasi</h4>
            <ul className="space-y-2">
              {[
                { label: "Beranda", to: "/" },
                { label: "Seminar", to: "/seminar" },
                { label: "Jadwal", to: "/jadwal" },
                { label: "Regulasi", to: "/regulasi" },
                { label: "Artikel & Berita", to: "/artikel" },
                { label: "Evaluasi", to: "/evaluasi" },
              ].map(item => (
                <li key={item.to}>
                  <Link to={item.to} className="text-[#94A3B8] hover:text-[#00B4D8] text-sm transition-colors">
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Tautan */}
          <div>
            <h4 className="text-white font-semibold mb-4 text-sm">Tautan Terkait</h4>
            <ul className="space-y-2">
              {[
                "lampungprov.go.id",
              ].map(link => (
                <li key={link}>
                  <a href={`https://${link}`} target="_blank" rel="noreferrer" className="text-[#94A3B8] hover:text-[#00B4D8] text-sm transition-colors flex items-center gap-1">
                    {link}
                    <ExternalLink size={10} />
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      <div className="border-t border-[#2D3748]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex flex-col sm:flex-row items-center justify-center gap-2">
          <p className="text-[#64748B] text-xs">
            © 2025 Dinas Komunikasi dan Informatika Provinsi Lampung. LOISHA DIVA .
          </p>
        </div>
      </div>
    </footer>
  );
}
