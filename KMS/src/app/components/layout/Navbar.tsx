import { useState } from "react";
import { Link, useLocation } from "react-router";
import { Menu, X } from "lucide-react";

const navLinks = [
  { label: "Beranda", path: "/" },
  { label: "Seminar", path: "/seminar" },
  { label: "Materi", path: "/materi" },
  { label: "Panduan", path: "/panduan" }, // ✅ FIX DI SINI
  { label: "Regulasi", path: "/regulasi" },
  { label: "Artikel", path: "/artikel" },
  { label: "Evaluasi", path: "/evaluasi" },
];

export function Navbar() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === "/") return location.pathname === "/";
    return location.pathname.startsWith(path);
  };

  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50 bg-white border-b border-[#E2E8F0]"
      style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">

          {/* Logo */}
          <Link to="/" className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-[#0052CC] flex items-center justify-center">
              <span className="text-white text-xs font-bold">KMS</span>
            </div>
            <div className="hidden sm:block">
              <div className="text-[#0052CC] font-semibold text-sm leading-tight">
                KMS Pemprov
              </div>
              <div className="text-[#64748B] text-xs leading-tight">
                Lampung
              </div>
            </div>
          </Link>

          {/* Desktop Nav */}
          <div className="hidden md:flex items-center gap-1">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className={`px-3 py-2 rounded-lg text-sm transition-colors ${
                  isActive(link.path)
                    ? "text-[#0052CC] bg-[#EEF4FF] font-medium"
                    : "text-[#475569] hover:text-[#0052CC] hover:bg-[#F8FAFC]"
                }`}
              >
                {link.label}
              </Link>
            ))}
          </div>

          {/* Mobile Toggle */}
          <button
            className="md:hidden p-2 rounded-lg text-[#475569] hover:bg-[#F8FAFC]"
            onClick={() => setMobileOpen(!mobileOpen)}
          >
            {mobileOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {mobileOpen && (
        <div className="md:hidden border-t border-[#E2E8F0] bg-white">
          <div className="px-4 py-3 space-y-1">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                onClick={() => setMobileOpen(false)}
                className={`block px-3 py-2 rounded-lg text-sm ${
                  isActive(link.path)
                    ? "text-[#0052CC] bg-[#EEF4FF] font-medium"
                    : "text-[#475569] hover:text-[#0052CC]"
                }`}
              >
                {link.label}
              </Link>
            ))}
          </div>
        </div>
      )}
    </nav>
  );
}