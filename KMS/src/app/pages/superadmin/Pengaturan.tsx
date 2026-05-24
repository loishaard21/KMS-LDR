import { useState } from "react";
import { Save, CheckCircle, AlertTriangle, Globe, Link as LinkIcon, Settings } from "lucide-react";

export function Pengaturan() {
  const [settings, setSettings] = useState({
    siteName: "KMS Pemprov Lampung",
    tagline: "Portal Manajemen Pengetahuan Pemerintah Provinsi Lampung",
    defaultFormUrl: "https://forms.google.com/default",
    defaultDriveUrl: "https://drive.google.com/default",
    maintenanceMode: false,
  });
  const [saved, setSaved] = useState(false);

  const handleChange = (k: string, v: string | boolean) => setSettings(s => ({ ...s, [k]: v }));

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="font-bold text-[#1A2332]">Pengaturan Sistem</h2>
        <p className="text-xs text-[#64748B]">Konfigurasi global portal KMS Pemprov Lampung.</p>
      </div>

      {saved && (
        <div className="p-3 bg-green-50 border border-green-200 rounded-xl flex items-center gap-2">
          <CheckCircle size={16} className="text-green-600" />
          <p className="text-sm text-green-700">Pengaturan berhasil disimpan!</p>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Site Info */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <div className="px-5 py-4 border-b border-[#E2E8F0] bg-[#F8FAFC] flex items-center gap-2">
            <Globe size={16} className="text-[#0052CC]" />
            <h3 className="font-semibold text-[#1A2332] text-sm">Informasi Situs</h3>
          </div>
          <div className="p-5 space-y-4">
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Nama Situs</label>
              <input
                value={settings.siteName}
                onChange={e => handleChange("siteName", e.target.value)}
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Tagline</label>
              <input
                value={settings.tagline}
                onChange={e => handleChange("tagline", e.target.value)}
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
              <p className="text-xs text-[#94A3B8] mt-1">Ditampilkan di header dan metadata situs</p>
            </div>
          </div>
        </div>

        {/* Default URLs */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <div className="px-5 py-4 border-b border-[#E2E8F0] bg-[#F8FAFC] flex items-center gap-2">
            <LinkIcon size={16} className="text-[#00B4D8]" />
            <h3 className="font-semibold text-[#1A2332] text-sm">URL Default</h3>
          </div>
          <div className="p-5 space-y-4">
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Default Google Form URL</label>
              <input
                value={settings.defaultFormUrl}
                onChange={e => handleChange("defaultFormUrl", e.target.value)}
                placeholder="https://forms.google.com/..."
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
              <p className="text-xs text-[#94A3B8] mt-1">Digunakan saat seminar tidak memiliki URL pendaftaran khusus</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Default Google Drive URL (Sertifikat)</label>
              <input
                value={settings.defaultDriveUrl}
                onChange={e => handleChange("defaultDriveUrl", e.target.value)}
                placeholder="https://drive.google.com/..."
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
              <p className="text-xs text-[#94A3B8] mt-1">Folder sertifikat default di Google Drive</p>
            </div>
          </div>
        </div>

        {/* System Controls */}
        <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden lg:col-span-2" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
          <div className="px-5 py-4 border-b border-[#E2E8F0] bg-[#F8FAFC] flex items-center gap-2">
            <Settings size={16} className="text-[#475569]" />
            <h3 className="font-semibold text-[#1A2332] text-sm">Kontrol Sistem</h3>
          </div>
          <div className="p-5">
            <div className={`flex items-center justify-between p-4 rounded-2xl border-2 transition-all ${settings.maintenanceMode ? "border-red-200 bg-red-50" : "border-[#E2E8F0] bg-[#F8FAFC]"}`}>
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${settings.maintenanceMode ? "bg-red-100" : "bg-[#E2E8F0]"}`}>
                  <AlertTriangle size={18} className={settings.maintenanceMode ? "text-red-500" : "text-[#94A3B8]"} />
                </div>
                <div>
                  <div className="font-medium text-[#1A2332] text-sm">Mode Maintenance</div>
                  <div className="text-xs text-[#64748B]">
                    {settings.maintenanceMode
                      ? "Portal sedang dalam mode pemeliharaan. Hanya admin yang dapat mengakses."
                      : "Portal aktif dan dapat diakses oleh publik."}
                  </div>
                </div>
              </div>
              <button
                onClick={() => handleChange("maintenanceMode", !settings.maintenanceMode)}
                className={`w-12 h-7 rounded-full transition-colors relative flex-shrink-0 ${settings.maintenanceMode ? "bg-red-500" : "bg-[#E2E8F0]"}`}
              >
                <div className={`w-5 h-5 bg-white rounded-full absolute top-1 transition-all shadow-sm ${settings.maintenanceMode ? "left-6" : "left-1"}`} />
              </button>
            </div>

            {settings.maintenanceMode && (
              <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-xl flex items-start gap-2">
                <AlertTriangle size={14} className="text-red-500 mt-0.5 flex-shrink-0" />
                <p className="text-xs text-red-600">
                  <span className="font-semibold">Peringatan:</span> Mode maintenance aktif. Portal tidak dapat diakses oleh pengguna umum saat ini.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Save Button */}
      <div className="flex justify-end">
        <button
          onClick={handleSave}
          className="flex items-center gap-2 px-6 py-3 bg-[#22C55E] text-white text-sm font-semibold rounded-xl hover:bg-[#16A34A] transition-colors"
        >
          <Save size={16} /> Simpan Pengaturan
        </button>
      </div>
    </div>
  );
}
