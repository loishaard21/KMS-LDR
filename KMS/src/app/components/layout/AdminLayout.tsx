import { useState } from "react";
import { Link, useLocation, useNavigate, Outlet } from "react-router";
import { useAuth } from "../../context/AuthContext";
import {
  LayoutDashboard, BookOpen, FileText, Calendar, Newspaper,
  Users, Upload, LogOut, ChevronRight, Menu, X, Settings,
  BarChart3, Layers, Download, Image, Video, MessageSquare,
  User, Tag, MonitorCheck, BookMarked, ChevronDown,
} from "lucide-react";

interface MenuItem {
  label: string;
  icon: any;
  path: string;
  children?: { label: string; path: string }[];
}

const operatorMenuItems: MenuItem[] = [
  { label: "Dashboard", icon: LayoutDashboard, path: "/operator/dashboard" },
  { label: "Kelola Seminar", icon: BookOpen, path: "/operator/kelola-seminar" },
  { label: "Kelola Materi", icon: FileText, path: "/operator/kelola-materi" },
  { label: "Kelola Jadwal", icon: Calendar, path: "/operator/kelola-jadwal" },
  { label: "Kelola Artikel", icon: Newspaper, path: "/operator/kelola-artikel" },
  { label: "Kelola Gallery", icon: Image, path: "/operator/kelola-gallery" },
  { label: "Kelola Regulasi", icon: FileText, path: "/operator/kelola-regulasi" },
  { label: "Kelola Evaluasi", icon: BarChart3, path: "/operator/kelola-evaluasi" },
  { label: "Data Peserta", icon: Users, path: "/operator/data-peserta" },
  { label: "Upload Informasi", icon: Upload, path: "/operator/upload-informasi" },
  { label: "Profil Saya", icon: User, path: "/operator/profil" },
];

const superAdminMenuItems: MenuItem[] = [
  { label: "Dashboard", icon: LayoutDashboard, path: "/superadmin/dashboard" },
  { label: "Indikator Pengetahuan", icon: BarChart3, path: "/superadmin/indikator" },
  { label: "Pages", icon: Layers, path: "/superadmin/pages" },
  {
    label: "Post",
    icon: FileText,
    path: "/superadmin/post",
    children: [
      { label: "All Posts", path: "/superadmin/post" },
      { label: "Add Posts", path: "/superadmin/post/create" },
    ],
  },
  { label: "Post Category", icon: Tag, path: "/superadmin/post-category" },
  { label: "Kelola Panduan", icon: BookOpen, path: "/superadmin/kelola-panduan" },
  { label: "Kelola Regulasi", icon: FileText, path: "/superadmin/kelola-regulasi" },
  { label: "Agenda", icon: Calendar, path: "/superadmin/agenda" },
  { label: "Download", icon: Download, path: "/superadmin/download" },
  { label: "Download Category", icon: BookMarked, path: "/superadmin/download-category" },
  { label: "Gallery", icon: Image, path: "/superadmin/gallery" },
  { label: "Album", icon: Image, path: "/superadmin/album" },
  { label: "Video", icon: Video, path: "/superadmin/video" },
  { label: "Contact", icon: MessageSquare, path: "/superadmin/contact" },
  { label: "Menu", icon: MonitorCheck, path: "/superadmin/menu" },
  { label: "Akun Operator", icon: User, path: "/superadmin/akun-operator" },
  { label: "Pengaturan", icon: Settings, path: "/superadmin/pengaturan" },
];

export function AdminLayout() {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [postExpanded, setPostExpanded] = useState(false);

  const isOperator = user?.role === "operator";
  const menuItems = isOperator ? operatorMenuItems : superAdminMenuItems;
  const basePath = isOperator ? "/operator" : "/superadmin";

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  const isActive = (path: string) => location.pathname === path || location.pathname.startsWith(path + "/");

  const SidebarContent = () => (
    <div className="flex flex-col h-full">
      {/* Brand */}
      <div className="p-5 border-b border-[#2D3748]">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-lg bg-[#0052CC] flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs font-bold">KMS</span>
          </div>
          <div>
            <div className="text-white font-semibold text-sm leading-tight">KMS Pemprov</div>
            <div className="text-[#64748B] text-xs">Lampung</div>
          </div>
        </div>
      </div>

      {/* User Info */}
      <div className="px-4 py-3 border-b border-[#2D3748]">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[#0052CC] flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs font-medium">{user?.name?.charAt(0)}</span>
          </div>
          <div className="min-w-0">
            <div className="text-white text-xs font-medium truncate">{user?.name}</div>
            <div className="text-[#64748B] text-xs capitalize">{user?.role}</div>
          </div>
        </div>
      </div>

      {/* Menu */}
      <nav className="flex-1 px-3 py-4 overflow-y-auto">
        <div className="space-y-0.5">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.path);
            const hasChildren = 'children' in item && item.children;

            if (hasChildren) {
              return (
                <div key={item.path}>
                  <button
                    onClick={() => setPostExpanded(!postExpanded)}
                    className={`w-full flex items-center justify-between gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                      active ? "bg-[#0052CC] text-white" : "text-[#94A3B8] hover:bg-[#2D3748] hover:text-white"
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <Icon size={16} />
                      <span>{item.label}</span>
                    </div>
                    <ChevronDown size={14} className={`transition-transform ${postExpanded ? "rotate-180" : ""}`} />
                  </button>
                  {postExpanded && (
                    <div className="ml-8 mt-0.5 space-y-0.5">
                      {item.children!.map(child => (
                        <Link
                          key={child.path}
                          to={child.path}
                          onClick={() => setSidebarOpen(false)}
                          className={`block px-3 py-2 rounded-lg text-xs transition-colors ${
                            location.pathname === child.path
                              ? "bg-[#00B4D8]/20 text-[#00B4D8]"
                              : "text-[#64748B] hover:text-white hover:bg-[#2D3748]"
                          }`}
                        >
                          {child.label}
                        </Link>
                      ))}
                    </div>
                  )}
                </div>
              );
            }

            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                  active
                    ? "bg-[#0052CC] text-white"
                    : "text-[#94A3B8] hover:bg-[#2D3748] hover:text-white"
                }`}
              >
                <Icon size={16} />
                <span>{item.label}</span>
                {active && <ChevronRight size={14} className="ml-auto" />}
              </Link>
            );
          })}
        </div>
      </nav>

      {/* Logout */}
      <div className="p-3 border-t border-[#2D3748]">
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-[#94A3B8] hover:bg-red-500/10 hover:text-red-400 transition-colors"
        >
          <LogOut size={16} />
          <span>Logout</span>
        </button>
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-[#F8FAFC] overflow-hidden">
      {/* Desktop Sidebar */}
      <aside className="hidden lg:flex flex-col w-60 bg-[#1A2332] flex-shrink-0">
        <SidebarContent />
      </aside>

      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div className="lg:hidden fixed inset-0 z-50 flex">
          <div className="w-60 bg-[#1A2332] flex flex-col">
            <SidebarContent />
          </div>
          <div className="flex-1 bg-black/50" onClick={() => setSidebarOpen(false)} />
        </div>
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top Bar */}
        <header className="bg-white border-b border-[#E2E8F0] px-4 py-3 flex items-center gap-3 flex-shrink-0" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <button
            className="lg:hidden p-2 rounded-lg text-[#475569] hover:bg-[#F8FAFC]"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu size={18} />
          </button>
          <div>
            <h1 className="text-[#1A2332] font-semibold text-sm">
              {isOperator ? "Operator Dashboard" : "Super Admin Dashboard"}
            </h1>
            <p className="text-[#94A3B8] text-xs">KMS Pemprov Lampung</p>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <Link to="/" className="text-xs text-[#0052CC] hover:underline">← Lihat Portal</Link>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
