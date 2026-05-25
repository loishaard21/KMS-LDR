import { useState } from "react";
import { useAuth } from "../../context/AuthContext";
import { updateUser } from "../../data/api";
import { 
  User, Lock, Save, Key, Mail, CheckCircle, AlertCircle, ShieldCheck, RefreshCw, Eye, EyeOff 
} from "lucide-react";

export function ProfilSaya() {
  const { user, updateUserSession } = useAuth();
  
  // Form states
  const [name, setName] = useState(user?.name || "");
  const [email, setEmail] = useState(user?.email || "");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  
  // UI states
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center h-[50vh] text-[#64748B]">
        <AlertCircle size={40} className="text-red-500 mb-2 animate-bounce" />
        <p className="font-medium text-sm">Sesi telah berakhir atau data pengguna tidak ditemukan.</p>
      </div>
    );
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg("");
    setSuccessMsg("");

    // Basic Validations
    if (!name.trim()) {
      setErrorMsg("Nama tidak boleh kosong.");
      return;
    }
    if (!email.trim()) {
      setErrorMsg("Email tidak boleh kosong.");
      return;
    }

    // Password validations if filled
    if (newPassword || confirmPassword) {
      if (newPassword.length < 6) {
        setErrorMsg("Password baru minimal harus 6 karakter.");
        return;
      }
      if (newPassword !== confirmPassword) {
        setErrorMsg("Konfirmasi password tidak cocok dengan password baru.");
        return;
      }
    }

    try {
      setSaving(true);
      
      const payload: any = {
        name: name.trim(),
        email: email.trim(),
      };
      
      if (newPassword) {
        payload.password = newPassword;
      }

      await updateUser(user.id, payload);
      
      // Update session in context so sidebar/navbar instantly reflects changes
      updateUserSession({
        name: payload.name,
        email: payload.email,
      });

      // Clear password fields on success
      setNewPassword("");
      setConfirmPassword("");
      setSuccessMsg("Profil dan pengaturan keamanan berhasil diperbarui!");
      
      // Auto clear success message after 5 seconds
      setTimeout(() => setSuccessMsg(""), 5000);

    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || "Gagal memperbarui profil. Silakan coba lagi.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Page Title & Intro */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-[#1A2332] text-xl font-bold">Pengaturan Profil</h2>
          <p className="text-[#94A3B8] text-xs mt-1">Kelola data profil pribadi dan ubah password keamanan akun Anda.</p>
        </div>
        <div className="flex items-center gap-2 self-start md:self-auto">
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
            Status Akun: Active
          </span>
          <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-200 capitalize">
            {user.role}
          </span>
        </div>
      </div>

      {/* User Header Profile Card */}
      <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 flex flex-col md:flex-row items-center gap-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}>
        <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-[#0052CC] to-[#00B4D8] text-white flex items-center justify-center font-bold text-3xl shadow-md border-4 border-white">
          {user.name ? user.name.charAt(0).toUpperCase() : "U"}
        </div>
        <div className="text-center md:text-left space-y-1">
          <h3 className="text-lg font-bold text-[#1A2332]">{user.name}</h3>
          <p className="text-sm text-[#64748B] flex items-center justify-center md:justify-start gap-1">
            <Mail size={14} className="text-[#94A3B8]" />
            {user.email}
          </p>
          <div className="text-xs text-[#94A3B8] pt-1">
            Hak Akses: <span className="font-semibold text-[#0052CC] capitalize">{user.role}</span>
          </div>
        </div>
      </div>

      {/* Forms Section */}
      <form onSubmit={handleSave} className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        {/* General Settings */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 space-y-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}>
          <div className="flex items-center gap-2 pb-2 border-b border-[#F1F5F9]">
            <div className="p-1.5 rounded-lg bg-[#EEF4FF] text-[#0052CC]">
              <User size={18} />
            </div>
            <h4 className="font-semibold text-sm text-[#1A2332]">Informasi Dasar</h4>
          </div>

          <div className="space-y-4">
            <div>
              <label htmlFor="name" className="block text-xs font-semibold text-[#475569] mb-1.5">Nama Lengkap</label>
              <input
                id="name"
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full text-sm px-4 py-2.5 rounded-xl border border-[#E2E8F0] text-[#1A2332] placeholder-[#94A3B8] focus:outline-none focus:border-[#0052CC] focus:ring-1 focus:ring-[#0052CC] transition-all bg-white"
                placeholder="Masukkan nama lengkap"
                required
              />
            </div>

            <div>
              <label htmlFor="email" className="block text-xs font-semibold text-[#475569] mb-1.5">Alamat Email</label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full text-sm px-4 py-2.5 rounded-xl border border-[#E2E8F0] text-[#1A2332] placeholder-[#94A3B8] focus:outline-none focus:border-[#0052CC] focus:ring-1 focus:ring-[#0052CC] transition-all bg-white"
                placeholder="name@kms.id"
                required
              />
            </div>
          </div>
        </div>

        {/* Security Settings (Change Password) */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 space-y-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.03)" }}>
          <div className="flex items-center gap-2 pb-2 border-b border-[#F1F5F9]">
            <div className="p-1.5 rounded-lg bg-red-50 text-red-500">
              <Lock size={18} />
            </div>
            <h4 className="font-semibold text-sm text-[#1A2332]">Ubah Password</h4>
          </div>

          <div className="space-y-4">
            <div>
              <label htmlFor="newPassword" className="block text-xs font-semibold text-[#475569] mb-1.5">
                Password Baru <span className="text-[#94A3B8] font-normal">(Kosongkan jika tidak diganti)</span>
              </label>
              <div className="relative">
                <input
                  id="newPassword"
                  type={showPassword ? "text" : "password"}
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  className="w-full text-sm pl-4 pr-10 py-2.5 rounded-xl border border-[#E2E8F0] text-[#1A2332] placeholder-[#94A3B8] focus:outline-none focus:border-[#0052CC] focus:ring-1 focus:ring-[#0052CC] transition-all bg-white"
                  placeholder="Min. 6 karakter"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#475569] transition-colors"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <div>
              <label htmlFor="confirmPassword" className="block text-xs font-semibold text-[#475569] mb-1.5">Konfirmasi Password Baru</label>
              <div className="relative">
                <input
                  id="confirmPassword"
                  type={showConfirmPassword ? "text" : "password"}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="w-full text-sm pl-4 pr-10 py-2.5 rounded-xl border border-[#E2E8F0] text-[#1A2332] placeholder-[#94A3B8] focus:outline-none focus:border-[#0052CC] focus:ring-1 focus:ring-[#0052CC] transition-all bg-white"
                  placeholder="Ulangi password baru"
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#475569] transition-colors"
                >
                  {showConfirmPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Status / Alert Bar & Save Action */}
        <div className="col-span-1 lg:col-span-2 flex flex-col md:flex-row items-center justify-between gap-4 p-5 bg-slate-50 border border-[#E2E8F0] rounded-2xl">
          
          <div className="w-full md:flex-1">
            {errorMsg && (
              <div className="flex items-center gap-2 text-xs text-red-600 bg-red-50 border border-red-200 px-4 py-2.5 rounded-xl animate-fade-in">
                <AlertCircle size={15} className="flex-shrink-0" />
                <span className="font-medium">{errorMsg}</span>
              </div>
            )}
            
            {successMsg && (
              <div className="flex items-center gap-2 text-xs text-emerald-700 bg-emerald-50 border border-emerald-200 px-4 py-2.5 rounded-xl animate-fade-in">
                <CheckCircle size={15} className="flex-shrink-0" />
                <span className="font-medium">{successMsg}</span>
              </div>
            )}

            {!errorMsg && !successMsg && (
              <div className="flex items-center gap-2 text-xs text-[#64748B]">
                <ShieldCheck size={16} className="text-[#94A3B8]" />
                <span>Semua pembaruan data dilindungi oleh enkripsi keamanan server KMS.</span>
              </div>
            )}
          </div>

          <div className="w-full md:w-auto">
            <button
              type="submit"
              disabled={saving}
              className={`w-full md:w-auto inline-flex items-center justify-center gap-2 px-6 py-2.5 text-sm font-bold text-white rounded-xl shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-[#0052CC]/50 ${
                saving 
                  ? "bg-[#0052CC]/75 cursor-not-allowed" 
                  : "bg-[#0052CC] hover:bg-[#0052CC]/90 active:scale-[0.98]"
              }`}
            >
              {saving ? (
                <>
                  <RefreshCw size={15} className="animate-spin" />
                  <span>Menyimpan...</span>
                </>
              ) : (
                <>
                  <Save size={15} />
                  <span>Simpan Perubahan</span>
                </>
              )}
            </button>
          </div>
        </div>

      </form>
    </div>
  );
}
