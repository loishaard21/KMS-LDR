import { createBrowserRouter, Navigate } from "react-router";
import { PublicLayout } from "./components/layout/PublicLayout";
import { AdminLayout } from "./components/layout/AdminLayout";

// Public pages
import { Landing } from "./pages/Landing";
import { SeminarList } from "./pages/SeminarList";
import { SeminarDetail } from "./pages/SeminarDetail";
import Panduan from "./pages/Panduan"; // ✅ FIX (default import)
import { Regulasi } from "./pages/Regulasi";
import { Artikel, ArtikelDetail } from "./pages/Artikel";
import { Materi } from "./pages/Materi";
import { Evaluasi } from "./pages/Evaluasi";
import { AdminLogin } from "./pages/AdminLogin";

// Operator pages
import { OperatorDashboard } from "./pages/operator/OperatorDashboard";
import { KelolaSeminar } from "./pages/operator/KelolaSeminar";
import { KelolaMateri } from "./pages/operator/KelolaMateri";
import { KelolaJadwal } from "./pages/operator/KelolaJadwal";
import { KelolaArtikel } from "./pages/operator/KelolaArtikel";
import { DataPeserta } from "./pages/operator/DataPeserta";
import { UploadInformasi } from "./pages/operator/UploadInformasi";
import { ProfilSaya } from "./pages/operator/ProfilSaya";
import { KelolaGallery } from "./pages/operator/KelolaGallery";
import { KelolaPanduan } from "./pages/operator/KelolaPanduan";
import { KelolaEvaluasi } from "./pages/operator/KelolaEvaluasi";

// Super Admin pages
import { SuperAdminDashboard } from "./pages/superadmin/SuperAdminDashboard";
import { PostList } from "./pages/superadmin/PostList";
import { PostForm } from "./pages/superadmin/PostForm";
import { AkunOperator } from "./pages/superadmin/AkunOperator";
import { Pengaturan } from "./pages/superadmin/Pengaturan";
import { GenericPage } from "./pages/superadmin/GenericPage";
import { KelolaRegulasi } from "./pages/superadmin/KelolaRegulasi";

// Auth
import { useAuth } from "./context/AuthContext";
import { useEffect } from "react";
import { useNavigate } from "react-router";

function ProtectedRoute({
  children,
  requiredRole,
}: {
  children: React.ReactNode;
  requiredRole?: "operator" | "superadmin";
}) {
  const { user, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isAuthenticated) {
      navigate("/admin-login");
    } else if (requiredRole && user?.role !== requiredRole) {
      navigate(
        user?.role === "operator"
          ? "/operator/dashboard"
          : "/superadmin/dashboard"
      );
    }
  }, [isAuthenticated, user, navigate, requiredRole]);

  if (!isAuthenticated) return null;
  if (requiredRole && user?.role !== requiredRole) return null;
  return <>{children}</>;
}

export const router = createBrowserRouter([
  // Public routes
  {
    path: "/",
    element: <PublicLayout />,
    children: [
      { index: true, Component: Landing },
      { path: "seminar", Component: SeminarList },
      { path: "seminar/:id", Component: SeminarDetail },

      // ✅ ROUTE PANDUAN
      { path: "panduan", Component: Panduan },

      { path: "regulasi", Component: Regulasi },
      { path: "artikel", Component: Artikel },
      { path: "artikel/:id", Component: ArtikelDetail },
      { path: "materi", Component: Materi },
      { path: "evaluasi", Component: Evaluasi },
    ],
  },

  // Admin login
  { path: "/admin-login", Component: AdminLogin },

  // Operator
  {
    path: "/operator",
    element: (
      <ProtectedRoute>
        <AdminLayout />
      </ProtectedRoute>
    ),
    children: [
      { index: true, element: <Navigate to="/operator/dashboard" replace /> },
      { path: "dashboard", Component: OperatorDashboard },
      { path: "kelola-seminar", Component: KelolaSeminar },
      { path: "kelola-materi", Component: KelolaMateri },
      { path: "kelola-jadwal", Component: KelolaJadwal },
      { path: "kelola-artikel", Component: KelolaArtikel },
      { path: "kelola-gallery", Component: KelolaGallery },
      { path: "kelola-panduan", Component: KelolaPanduan },
      { path: "kelola-evaluasi", Component: KelolaEvaluasi },
      { path: "data-peserta", Component: DataPeserta },
      { path: "upload-informasi", Component: UploadInformasi },
      { path: "profil", Component: ProfilSaya },
    ],
  },

  // Super Admin
  {
    path: "/superadmin",
    element: (
      <ProtectedRoute requiredRole="superadmin">
        <AdminLayout />
      </ProtectedRoute>
    ),
    children: [
      { index: true, element: <Navigate to="/superadmin/dashboard" replace /> },
      { path: "dashboard", Component: SuperAdminDashboard },
      {
        path: "indikator",
        element: (
          <GenericPage
            title="Indikator Pengetahuan"
            description="Dashboard indikator dan KPI manajemen pengetahuan organisasi Pemprov Lampung."
          />
        ),
      },
      {
        path: "pages",
        element: (
          <GenericPage
            title="Pages"
            description="Kelola halaman statis portal KMS."
          />
        ),
      },
      { path: "post", Component: PostList },
      { path: "post/create", Component: PostForm },
      { path: "kelola-panduan", Component: KelolaPanduan },
      {
        path: "post-category",
        element: (
          <GenericPage
            title="Post Category"
            description="Kelola kategori artikel dan konten portal."
          />
        ),
      },
      { path: "agenda", Component: KelolaJadwal },
      {
        path: "download",
        element: (
          <GenericPage
            title="Download"
            description="Kelola file unduhan yang tersedia di portal."
          />
        ),
      },
      {
        path: "download-category",
        element: (
          <GenericPage
            title="Download Category"
            description="Kelola kategori file unduhan."
          />
        ),
      },
      { path: "gallery", Component: KelolaGallery },
      {
        path: "album",
        element: (
          <GenericPage
            title="Album"
            description="Kelola album foto."
          />
        ),
      },
      {
        path: "video",
        element: (
          <GenericPage
            title="Video"
            description="Kelola video dokumentasi kegiatan."
          />
        ),
      },
      {
        path: "contact",
        element: (
          <GenericPage
            title="Contact"
            description="Lihat dan kelola pesan kontak dari pengunjung portal."
          />
        ),
      },
      {
        path: "menu",
        element: (
          <GenericPage
            title="Menu"
            description="Konfigurasi menu navigasi portal."
          />
        ),
      },
      { path: "akun-operator", Component: AkunOperator },
      { path: "kelola-regulasi", Component: KelolaRegulasi },
      { path: "pengaturan", Component: Pengaturan },
    ],
  },

  // 404
  { path: "*", element: <Navigate to="/" replace /> },
]);