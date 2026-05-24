import { useState } from "react";
import { useNavigate, Link } from "react-router";
import { useAuth } from "../context/AuthContext";
import { Eye, EyeOff, Lock, Mail, AlertCircle, ChevronLeft, Shield } from "lucide-react";

export function AdminLogin() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    const ok = await login(email, password);
    setLoading(false);
    if (ok) {
      const user = JSON.parse(localStorage.getItem("kms_user") || "{}");
      navigate(user.role === "superadmin" ? "/superadmin/dashboard" : "/operator/dashboard");
    } else {
      setError("Email atau password tidak valid.");
    }
  };

  const fillCredentials = (role: "operator" | "superadmin") => {
    if (role === "operator") {
      setEmail("operator@lampungprov.go.id");
      setPassword("operator123");
    } else {
      setEmail("admin@lampungprov.go.id");
      setPassword("admin123");
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex items-center justify-center px-4 py-10">
      <div className="w-full max-w-md">
        {/* Card */}
        <div className="bg-white rounded-2xl border border-[#E2E8F0] overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.08)" }}>
          {/* Header */}
          <div style={{ background: "linear-gradient(135deg, #0052CC 0%, #00B4D8 100%)" }} className="px-8 py-8 text-center">
            <div className="w-14 h-14 bg-white/20 rounded-2xl flex items-center justify-center mx-auto mb-3">
              <Shield size={28} className="text-white" />
            </div>
            <div className="text-white text-xl font-bold mb-1">Admin Panel</div>
            <div className="text-white/70 text-xs">KMS Pemprov Lampung</div>
          </div>

          <div className="px-8 py-8">
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Email */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-2">Email</label>
                <div className="relative">
                  <Mail size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#94A3B8]" />
                  <input
                    type="email"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    placeholder="admin@lampungprov.go.id"
                    required
                    className="w-full pl-9 pr-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white text-[#1A2332] placeholder-[#94A3B8] outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
                  />
                </div>
              </div>

              {/* Password */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-2">Password</label>
                <div className="relative">
                  <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#94A3B8]" />
                  <input
                    type={showPw ? "text" : "password"}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full pl-9 pr-10 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white text-[#1A2332] placeholder-[#94A3B8] outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
                  />
                  <button type="button" onClick={() => setShowPw(!showPw)} className="absolute right-3 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#475569]">
                    {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              {/* Error */}
              {error && (
                <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-xl">
                  <AlertCircle size={14} className="text-red-500 flex-shrink-0" />
                  <p className="text-xs text-red-600">{error}</p>
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 rounded-xl bg-[#0052CC] text-white text-sm font-semibold hover:bg-[#003D99] transition-colors disabled:opacity-60 flex items-center justify-center gap-2"
              >
                {loading ? (
                  <div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                ) : null}
                Sign In
              </button>
            </form>

            {/* Quick Login Shortcuts */}
            <div className="mt-5">
              <p className="text-center text-xs text-[#94A3B8] mb-3">Login Cepat (Demo)</p>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => fillCredentials("operator")}
                  className="py-2 px-3 rounded-xl border border-[#E2E8F0] text-xs text-[#475569] hover:border-[#0052CC] hover:text-[#0052CC] transition-colors"
                >
                  👤 Operator
                </button>
                <button
                  type="button"
                  onClick={() => fillCredentials("superadmin")}
                  className="py-2 px-3 rounded-xl border border-[#E2E8F0] text-xs text-[#475569] hover:border-[#0052CC] hover:text-[#0052CC] transition-colors"
                >
                  🔑 Super Admin
                </button>
              </div>
            </div>

            {/* Note */}
            <div className="mt-5 p-3 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl">
              <p className="text-xs text-[#64748B] text-center leading-relaxed">
                Login khusus administrator. Pengguna umum tidak memerlukan akun untuk mengakses portal.
              </p>
            </div>
          </div>
        </div>

        <div className="text-center mt-5">
          <Link to="/" className="inline-flex items-center gap-1.5 text-sm text-[#0052CC] hover:underline">
            <ChevronLeft size={14} /> Kembali ke Beranda
          </Link>
        </div>
      </div>
    </div>
  );
}
