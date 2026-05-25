import { useState, useEffect } from "react";
import { Plus, Edit, Trash2, X, Save, CheckCircle, Eye, EyeOff } from "lucide-react";
import { fetchUsers, createUser, updateUser, deleteUser } from "../../data/api";

const roles = ["Operator", "Super Admin"];
const statuses = ["Active", "Inactive"];

function OperatorModal({
  onClose,
  onSave,
  operator,
}: {
  onClose: () => void;
  onSave: (data: any) => void;
  operator?: any | null;
}) {
  const [form, setForm] = useState({
    name: operator?.name || "",
    email: operator?.email || "",
    password: "",
    role: operator
      ? (operator.role === "SUPERADMIN" || operator.role === "superadmin" ? "Super Admin" : "Operator")
      : "Operator",
    status: operator?.status || "Active",
  });
  const [showPw, setShowPw] = useState(false);
  const isEdit = !!operator;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(form);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="bg-white rounded-2xl w-full max-w-md">
        <div className="flex items-center justify-between px-6 py-4 border-b border-[#E2E8F0]">
          <h2 className="font-semibold text-[#1A2332]">{isEdit ? "Edit Operator" : "Tambah Operator"}</h2>
          <button type="button" onClick={onClose} className="p-2 hover:bg-[#F8FAFC] rounded-lg"><X size={18} /></button>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Nama Lengkap <span className="text-red-500">*</span></label>
            <input
              required
              value={form.name}
              onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
              placeholder="Nama lengkap..."
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Email <span className="text-red-500">*</span></label>
            <input
              required
              type="email"
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              placeholder="email@lampungprov.go.id"
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">
              {isEdit ? "Password Baru (kosongkan jika tidak diubah)" : "Password Sementara"} {!isEdit && <span className="text-red-500">*</span>}
            </label>
            <div className="relative">
              <input
                required={!isEdit}
                type={showPw ? "text" : "password"}
                value={form.password}
                onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
                placeholder={isEdit ? "Biarkan kosong jika tidak diubah..." : "Minimal 8 karakter..."}
                className="w-full px-4 py-2.5 pr-10 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
              <button
                type="button"
                onClick={() => setShowPw(v => !v)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-[#94A3B8] hover:text-[#475569]"
              >
                {showPw ? <EyeOff size={15} /> : <Eye size={15} />}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Role</label>
            <select
              value={form.role}
              onChange={e => setForm(f => ({ ...f, role: e.target.value }))}
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
            >
              {roles.map(r => <option key={r}>{r}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Status</label>
            <select
              value={form.status}
              onChange={e => setForm(f => ({ ...f, status: e.target.value }))}
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
            >
              {statuses.map(s => <option key={s}>{s}</option>)}
            </select>
          </div>
        </div>
        <div className="px-6 py-4 border-t border-[#E2E8F0] flex justify-end gap-3">
          <button type="button" onClick={onClose} className="px-5 py-2.5 rounded-xl border border-[#E2E8F0] text-sm text-[#475569] hover:bg-[#F8FAFC] transition-colors">Batal</button>
          <button type="submit" className="px-5 py-2.5 rounded-xl bg-[#22C55E] text-white text-sm font-medium hover:bg-[#16A34A] transition-colors flex items-center gap-2">
            <Save size={14} /> Simpan
          </button>
        </div>
      </form>
    </div>
  );
}

export function AkunOperator() {
  const [operators, setOperators] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editOperator, setEditOperator] = useState<any | null>(null);

  const loadData = () => {
    setLoading(true);
    fetchUsers()
      .then(res => { setOperators(res); setLoading(false); })
      .catch(err => { console.error(err); setLoading(false); });
  };

  useEffect(() => { loadData(); }, []);

  const openAdd = () => { setEditOperator(null); setShowModal(true); };
  const openEdit = (op: any) => { setEditOperator(op); setShowModal(true); };

  const handleSave = async (data: any) => {
    try {
      const payload: any = {
        name: data.name,
        email: data.email,
        role: data.role === "Super Admin" ? "superadmin" : "operator",
        status: data.status,
      };
      if (data.password) payload.password = data.password;

      if (editOperator) {
        await updateUser(editOperator.id, payload);
      } else {
        await createUser({ ...payload, password: data.password || "operator123" });
      }
      loadData();
      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan data operator.");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Apakah Anda yakin ingin menghapus akun operator ini?")) {
      try {
        await deleteUser(id);
        loadData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus operator.");
      }
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-bold text-[#1A2332]">Akun Operator</h2>
          <p className="text-xs text-[#64748B]">Kelola akun operator dan super admin portal KMS.</p>
        </div>
        <button
          onClick={openAdd}
          className="flex items-center gap-2 px-4 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors"
        >
          <Plus size={16} /> Tambah Operator
        </button>
      </div>

      <div className="p-4 bg-[#EEF4FF] border border-[#0052CC]/20 rounded-2xl flex items-start gap-3">
        <CheckCircle size={16} className="text-[#0052CC] mt-0.5 flex-shrink-0" />
        <p className="text-xs text-[#0052CC]">
          Hanya Super Admin yang dapat menambah, mengedit, atau menghapus akun operator.
          Tidak tersedia fitur registrasi mandiri untuk pengguna umum.
        </p>
      </div>

      <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-[#F8FAFC] border-b border-[#E2E8F0]">
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Nama</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Email</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Role</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Last Login</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-[#475569]">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="text-center py-4 text-xs text-[#94A3B8]">Memuat data operator...</td>
                </tr>
              ) : operators.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-8 text-sm text-[#94A3B8]">Belum ada operator terdaftar.</td>
                </tr>
              ) : operators.map(op => {
                const isSuper = op.role === "SUPERADMIN" || op.role === "superadmin";
                return (
                  <tr key={op.id} className="border-b border-[#F1F5F9] hover:bg-[#FAFBFC] transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-[#0052CC] flex items-center justify-center flex-shrink-0">
                          <span className="text-white text-xs font-semibold">{op.name.charAt(0).toUpperCase()}</span>
                        </div>
                        <span className="text-sm font-medium text-[#1A2332]">{op.name}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-[#64748B]">{op.email}</td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${isSuper ? "bg-purple-100 text-purple-700" : "bg-[#EEF4FF] text-[#0052CC]"}`}>
                        {isSuper ? "Super Admin" : "Operator"}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${op.status === "Active" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-600"}`}>
                        {op.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs text-[#64748B] whitespace-nowrap">{op.lastLogin || "-"}</td>
                    <td className="px-4 py-3">
                      <div className="flex gap-1.5">
                        <button
                          onClick={() => openEdit(op)}
                          title="Edit"
                          className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"
                        >
                          <Edit size={13} />
                        </button>
                        <button
                          onClick={() => handleDelete(op.id)}
                          title="Hapus"
                          className="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"
                        >
                          <Trash2 size={13} />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && <OperatorModal onClose={() => setShowModal(false)} onSave={handleSave} operator={editOperator} />}
    </div>
  );
}
