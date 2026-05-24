import { useState } from "react";
import { Upload, FileText, Link as LinkIcon, Bell, Award, CheckCircle, X } from "lucide-react";
import { seminars } from "../../data/mockData";

const infoTypes = [
  { value: "Zoom Link", icon: LinkIcon, label: "Zoom Link", color: "#0052CC" },
  { value: "Materi", icon: FileText, label: "Materi", color: "#7C3AED" },
  { value: "Pengumuman", icon: Bell, label: "Pengumuman", color: "#F59E0B" },
  { value: "Info Sertifikat", icon: Award, label: "Info Sertifikat", color: "#22C55E" },
];

const recentUploads = [
  { id: "u1", seminar: "Sosialisasi SPBE 2025", type: "Zoom Link", title: "Link Zoom Sosialisasi SPBE", date: "20 Apr 2025" },
  { id: "u2", seminar: "Workshop Transformasi Digital ASN", type: "Materi", title: "Slide Materi Workshop Hari-1", date: "14 Mei 2025" },
  { id: "u3", seminar: "Sosialisasi SPBE 2025", type: "Info Sertifikat", title: "Informasi Pengambilan Sertifikat", date: "26 Apr 2025" },
];

export function UploadInformasi() {
  const [form, setForm] = useState({
    seminar: "",
    type: "Zoom Link",
    title: "",
    content: "",
    hasFile: false,
  });
  const [submitted, setSubmitted] = useState(false);

  const handleChange = (k: string, v: string | boolean) => setForm(f => ({ ...f, [k]: v }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3000);
    setForm({ seminar: "", type: "Zoom Link", title: "", content: "", hasFile: false });
  };

  const selectedType = infoTypes.find(t => t.value === form.type);

  return (
    <div className="space-y-6">
      <div>
        <h2 className="font-bold text-[#1A2332]">Upload Informasi</h2>
        <p className="text-xs text-[#64748B]">Upload informasi tambahan terkait seminar (Zoom Link, Materi, Pengumuman, dll).</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form */}
        <div className="lg:col-span-2">
          <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="px-6 py-4 border-b border-[#E2E8F0] bg-[#F8FAFC]">
              <h3 className="font-semibold text-[#1A2332] text-sm">Form Upload Informasi</h3>
            </div>

            {submitted && (
              <div className="mx-6 mt-4 p-3 bg-green-50 border border-green-200 rounded-xl flex items-center gap-2">
                <CheckCircle size={16} className="text-green-600" />
                <p className="text-sm text-green-700">Informasi berhasil diupload!</p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="p-6 space-y-5">
              {/* Select Seminar */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Pilih Seminar <span className="text-red-500">*</span></label>
                <select
                  value={form.seminar}
                  onChange={e => handleChange("seminar", e.target.value)}
                  required
                  className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
                >
                  <option value="">-- Pilih Seminar --</option>
                  {seminars.map(s => (
                    <option key={s.id} value={s.id}>{s.title}</option>
                  ))}
                </select>
              </div>

              {/* Type Selection */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-2">Tipe Informasi <span className="text-red-500">*</span></label>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  {infoTypes.map(type => {
                    const Icon = type.icon;
                    const isSelected = form.type === type.value;
                    return (
                      <button
                        key={type.value}
                        type="button"
                        onClick={() => handleChange("type", type.value)}
                        className={`flex flex-col items-center gap-2 p-3 rounded-xl border-2 text-center transition-all ${isSelected ? "border-[#0052CC] bg-[#EEF4FF]" : "border-[#E2E8F0] hover:border-[#0052CC]/50"}`}
                      >
                        <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ backgroundColor: isSelected ? `${type.color}20` : "#F1F5F9" }}>
                          <Icon size={16} style={{ color: isSelected ? type.color : "#94A3B8" }} />
                        </div>
                        <span className={`text-xs font-medium ${isSelected ? "text-[#0052CC]" : "text-[#64748B]"}`}>{type.label}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Title */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  value={form.title}
                  onChange={e => handleChange("title", e.target.value)}
                  placeholder="Judul informasi..."
                  required
                  className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
                />
              </div>

              {/* Content */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">
                  {form.type === "Zoom Link" ? "URL Zoom / Meeting Link" : "Konten / URL"}
                </label>
                <textarea
                  value={form.content}
                  onChange={e => handleChange("content", e.target.value)}
                  rows={3}
                  placeholder={form.type === "Zoom Link" ? "https://zoom.us/j/..." : "Tulis konten atau URL..."}
                  className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all resize-none"
                />
              </div>

              {/* File Upload (optional) */}
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">Lampiran File (Opsional)</label>
                <div
                  onClick={() => handleChange("hasFile", !form.hasFile)}
                  className={`border-2 border-dashed rounded-xl p-5 text-center cursor-pointer transition-all ${form.hasFile ? "border-[#22C55E] bg-green-50" : "border-[#E2E8F0] hover:border-[#0052CC]/50"}`}
                >
                  {form.hasFile ? (
                    <div className="flex items-center justify-center gap-2 text-green-600">
                      <CheckCircle size={18} />
                      <span className="text-sm font-medium">File terlampir: dokumen.pdf</span>
                      <button type="button" onClick={() => handleChange("hasFile", false)}>
                        <X size={14} />
                      </button>
                    </div>
                  ) : (
                    <>
                      <Upload size={24} className="mx-auto text-[#94A3B8] mb-2" />
                      <p className="text-xs text-[#64748B]">Klik untuk upload file (PDF/DOCX/PPTX, maks. 10MB)</p>
                    </>
                  )}
                </div>
              </div>

              <div className="flex justify-end">
                <button
                  type="submit"
                  className="px-6 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors flex items-center gap-2"
                >
                  <Upload size={14} /> Upload Informasi
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Recent Uploads */}
        <div>
          <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="px-4 py-4 border-b border-[#E2E8F0] bg-[#F8FAFC]">
              <h3 className="font-semibold text-[#1A2332] text-sm">Upload Terbaru</h3>
            </div>
            <div className="p-3 space-y-3">
              {recentUploads.map(upload => {
                const typeInfo = infoTypes.find(t => t.value === upload.type);
                const Icon = typeInfo?.icon || FileText;
                return (
                  <div key={upload.id} className="flex items-start gap-3 p-3 bg-[#F8FAFC] rounded-xl">
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0" style={{ backgroundColor: `${typeInfo?.color || "#94A3B8"}20` }}>
                      <Icon size={14} style={{ color: typeInfo?.color || "#94A3B8" }} />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-medium text-[#1A2332] line-clamp-1">{upload.title}</p>
                      <p className="text-xs text-[#64748B] truncate">{upload.seminar}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-xs text-[#94A3B8]">{upload.date}</span>
                        <span className="text-xs px-1.5 py-0.5 rounded-full bg-[#EEF4FF] text-[#0052CC]">{upload.type}</span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
