import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import {
  Bold, Italic, Underline, AlignLeft, AlignCenter, AlignRight, AlignJustify,
  List, ListOrdered, Link as LinkIcon, Image as ImageIcon, Table, Smile,
  ChevronDown, Save, Eye, ArrowLeft, Heading1, Heading2, Strikethrough,
  Quote, Code, Minus
} from "lucide-react";

const categories = ["Form", "Berita", "SOSIALISASI", "Regulasi", "Panduan SPBE"];
const daftarTypes = ["Google Form", "Link Eksternal", "Upload File", "Teks/Info", "Nonaktif"];
const fontSizes = ["12px", "14px", "16px", "18px", "20px", "24px", "28px", "32px"];
const fontFamilies = ["Poppins", "Arial", "Times New Roman", "Georgia"];
const styles = ["Normal", "Heading 1", "Heading 2", "Heading 3", "Quote", "Code"];

const toolbarRow1 = [
  { icon: Bold, label: "bold" },
  { icon: Italic, label: "italic" },
  { icon: Underline, label: "underline" },
  { icon: Strikethrough, label: "strike" },
  { icon: Quote, label: "quote" },
  { icon: Code, label: "code" },
];
const toolbarRow2 = [
  { icon: AlignLeft, label: "align-left" },
  { icon: AlignCenter, label: "align-center" },
  { icon: AlignRight, label: "align-right" },
  { icon: AlignJustify, label: "align-justify" },
  { icon: List, label: "list" },
  { icon: ListOrdered, label: "ordered-list" },
  { icon: LinkIcon, label: "link" },
  { icon: ImageIcon, label: "image" },
  { icon: Table, label: "table" },
  { icon: Smile, label: "emoji" },
  { icon: Minus, label: "divider" },
];

export function PostForm() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    category: "Berita",
    title: "",
    seoTitle: "",
    content: "",
    daftarType: "Nonaktif",
    daftarUrl: "",
    certificateUrl: "",
    headline: false,
    active: true,
    hasImage: false,
  });
  const [activeFormat, setActiveFormat] = useState<string[]>([]);
  const [selectedFont, setSelectedFont] = useState("Poppins");
  const [selectedSize, setSelectedSize] = useState("16px");
  const [selectedStyle, setSelectedStyle] = useState("Normal");

  const handleChange = (k: string, v: string | boolean) => setForm(f => ({ ...f, [k]: v }));

  const toggleFormat = (label: string) =>
    setActiveFormat(f => f.includes(label) ? f.filter(x => x !== label) : [...f, label]);

  const handleSave = () => {
    alert("Post berhasil disimpan! (Demo)");
    navigate("/superadmin/post");
  };

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate("/superadmin/post")}
            className="p-2 rounded-xl border border-[#E2E8F0] hover:bg-[#F8FAFC] text-[#475569] transition-colors"
          >
            <ArrowLeft size={16} />
          </button>
          <div>
            <h2 className="font-bold text-[#1A2332]">Tambah Post</h2>
            <p className="text-xs text-[#64748B]">Buat konten baru untuk portal KMS</p>
          </div>
        </div>
        <div className="flex gap-2">
          <button className="flex items-center gap-2 px-4 py-2.5 border border-[#E2E8F0] text-[#475569] text-sm font-medium rounded-xl hover:bg-[#F8FAFC] transition-colors">
            <Eye size={14} /> Preview
          </button>
          <button
            onClick={handleSave}
            className="flex items-center gap-2 px-5 py-2.5 bg-[#22C55E] text-white text-sm font-medium rounded-xl hover:bg-[#16A34A] transition-colors"
          >
            <Save size={14} /> Simpan
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Editor */}
        <div className="lg:col-span-2 space-y-5">
          {/* Category */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <label className="block text-sm font-medium text-[#374151] mb-1.5">Kategori</label>
            <select
              value={form.category}
              onChange={e => handleChange("category", e.target.value)}
              className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
            >
              {categories.map(c => <option key={c}>{c}</option>)}
            </select>
          </div>

          {/* Title + SEO */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5 space-y-4" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Judul <span className="text-red-500">*</span></label>
              <input
                value={form.title}
                onChange={e => handleChange("title", e.target.value)}
                placeholder="Judul artikel/post..."
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">SEO Title</label>
              <input
                value={form.seoTitle}
                onChange={e => handleChange("seoTitle", e.target.value)}
                placeholder="Judul untuk mesin pencari (opsional)..."
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] focus:ring-2 focus:ring-[#0052CC]/20 transition-all"
              />
              <p className="text-xs text-[#94A3B8] mt-1">Biarkan kosong untuk menggunakan judul utama</p>
            </div>
          </div>

          {/* WYSIWYG Editor */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <div className="px-4 py-3 border-b border-[#E2E8F0] bg-[#F8FAFC]">
              <label className="text-sm font-medium text-[#374151]">Konten</label>
            </div>

            {/* Toolbar Row 1 */}
            <div className="flex flex-wrap items-center gap-1 px-3 py-2 border-b border-[#E2E8F0] bg-[#FAFBFC]">
              {/* Style dropdown */}
              <select
                value={selectedStyle}
                onChange={e => setSelectedStyle(e.target.value)}
                className="text-xs bg-white border border-[#E2E8F0] rounded-lg px-2 py-1.5 outline-none text-[#475569] mr-1"
              >
                {styles.map(s => <option key={s}>{s}</option>)}
              </select>
              <select
                value={selectedFont}
                onChange={e => setSelectedFont(e.target.value)}
                className="text-xs bg-white border border-[#E2E8F0] rounded-lg px-2 py-1.5 outline-none text-[#475569] mr-1"
              >
                {fontFamilies.map(f => <option key={f}>{f}</option>)}
              </select>
              <select
                value={selectedSize}
                onChange={e => setSelectedSize(e.target.value)}
                className="text-xs bg-white border border-[#E2E8F0] rounded-lg px-2 py-1.5 outline-none text-[#475569] mr-1"
              >
                {fontSizes.map(s => <option key={s}>{s}</option>)}
              </select>
              <div className="w-px h-5 bg-[#E2E8F0] mx-1" />
              {toolbarRow1.map(({ icon: Icon, label }) => (
                <button
                  key={label}
                  type="button"
                  onClick={() => toggleFormat(label)}
                  className={`p-1.5 rounded-lg transition-colors ${activeFormat.includes(label) ? "bg-[#0052CC] text-white" : "text-[#64748B] hover:bg-[#E2E8F0]"}`}
                  title={label}
                >
                  <Icon size={14} />
                </button>
              ))}
            </div>

            {/* Toolbar Row 2 */}
            <div className="flex flex-wrap items-center gap-1 px-3 py-2 border-b border-[#E2E8F0] bg-[#FAFBFC]">
              {toolbarRow2.map(({ icon: Icon, label }) => (
                <button
                  key={label}
                  type="button"
                  onClick={() => toggleFormat(label)}
                  className={`p-1.5 rounded-lg transition-colors ${activeFormat.includes(label) ? "bg-[#0052CC] text-white" : "text-[#64748B] hover:bg-[#E2E8F0]"}`}
                  title={label}
                >
                  <Icon size={14} />
                </button>
              ))}
            </div>

            <textarea
              value={form.content}
              onChange={e => handleChange("content", e.target.value)}
              rows={12}
              placeholder="Tulis konten artikel di sini..."
              className="w-full px-4 py-3 text-sm text-[#1A2332] outline-none resize-none placeholder-[#94A3B8] bg-white"
            />
          </div>

          {/* Daftar Button Config */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5 space-y-4" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h3 className="font-semibold text-[#1A2332] text-sm">Konfigurasi Tombol Daftar</h3>
            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">Tipe Tombol Daftar</label>
              <select
                value={form.daftarType}
                onChange={e => handleChange("daftarType", e.target.value)}
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
              >
                {daftarTypes.map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            {form.daftarType !== "Nonaktif" && (
              <div>
                <label className="block text-sm font-medium text-[#374151] mb-1.5">
                  {form.daftarType === "Teks/Info" ? "Isi Teks/Pesan" :
                   form.daftarType === "Upload File" ? "Upload File (PDF/DOCX)" : "URL Tautan"}
                </label>
                {form.daftarType === "Teks/Info" ? (
                  <textarea
                    value={form.daftarUrl}
                    onChange={e => handleChange("daftarUrl", e.target.value)}
                    rows={2}
                    placeholder="Tulis pesan/informasi..."
                    className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC] resize-none"
                  />
                ) : form.daftarType === "Upload File" ? (
                  <div className="border-2 border-dashed border-[#E2E8F0] rounded-xl p-3 text-center cursor-pointer hover:border-[#0052CC]/50">
                    <p className="text-xs text-[#94A3B8]">Upload file PDF/DOCX...</p>
                  </div>
                ) : (
                  <input
                    value={form.daftarUrl}
                    onChange={e => handleChange("daftarUrl", e.target.value)}
                    placeholder="https://..."
                    className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
                  />
                )}
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-[#374151] mb-1.5">URL Sertifikat (Google Drive)</label>
              <input
                value={form.certificateUrl}
                onChange={e => handleChange("certificateUrl", e.target.value)}
                placeholder="https://drive.google.com/..."
                className="w-full px-4 py-2.5 text-sm border border-[#E2E8F0] rounded-xl bg-white outline-none focus:border-[#0052CC]"
              />
            </div>
          </div>
        </div>

        {/* Sidebar Settings */}
        <div className="space-y-4">
          {/* Image Upload */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h3 className="font-semibold text-[#1A2332] text-sm mb-3">Gambar Utama</h3>
            <div
              onClick={() => handleChange("hasImage", !form.hasImage)}
              className={`border-2 border-dashed rounded-xl p-6 text-center cursor-pointer transition-all ${form.hasImage ? "border-[#0052CC] bg-[#EEF4FF]" : "border-[#E2E8F0] hover:border-[#0052CC]/50"}`}
            >
              {form.hasImage ? (
                <div className="text-[#0052CC]">
                  <ImageIcon size={24} className="mx-auto mb-2" />
                  <p className="text-xs font-medium">foto-cover.jpg</p>
                  <p className="text-xs text-[#94A3B8] mt-0.5">Klik untuk ganti</p>
                </div>
              ) : (
                <>
                  <ImageIcon size={24} className="mx-auto text-[#94A3B8] mb-2" />
                  <p className="text-xs text-[#64748B]">Upload gambar cover</p>
                  <p className="text-xs text-[#94A3B8] mt-0.5">JPG/PNG · Maks. 2MB</p>
                </>
              )}
            </div>
          </div>

          {/* Settings */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5 space-y-4" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h3 className="font-semibold text-[#1A2332] text-sm">Pengaturan Post</h3>

            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-[#374151]">Headline</div>
                <div className="text-xs text-[#94A3B8]">Tampilkan sebagai berita utama</div>
              </div>
              <button
                type="button"
                onClick={() => handleChange("headline", !form.headline)}
                className={`w-11 h-6 rounded-full transition-colors relative ${form.headline ? "bg-[#00B4D8]" : "bg-[#E2E8F0]"}`}
              >
                <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-all ${form.headline ? "left-6" : "left-1"}`} />
              </button>
            </div>

            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm font-medium text-[#374151]">Aktif</div>
                <div className="text-xs text-[#94A3B8]">Tampilkan di portal publik</div>
              </div>
              <button
                type="button"
                onClick={() => handleChange("active", !form.active)}
                className={`w-11 h-6 rounded-full transition-colors relative ${form.active ? "bg-[#22C55E]" : "bg-[#E2E8F0]"}`}
              >
                <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-all ${form.active ? "left-6" : "left-1"}`} />
              </button>
            </div>
          </div>

          {/* Category Badge Preview */}
          <div className="bg-white border border-[#E2E8F0] rounded-2xl p-5" style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}>
            <h3 className="font-semibold text-[#1A2332] text-sm mb-3">Preview Badge</h3>
            <div className="flex flex-wrap gap-2">
              <span className="text-xs bg-[#0052CC] text-white px-2.5 py-1 rounded-full">{form.category}</span>
              {form.headline && <span className="text-xs bg-[#F59E0B] text-white px-2.5 py-1 rounded-full">Headline</span>}
              {form.active && <span className="text-xs bg-[#22C55E] text-white px-2.5 py-1 rounded-full">Aktif</span>}
            </div>
          </div>

          {/* Save Button */}
          <button
            onClick={handleSave}
            className="w-full flex items-center justify-center gap-2 py-3 bg-[#22C55E] text-white text-sm font-semibold rounded-xl hover:bg-[#16A34A] transition-colors"
          >
            <Save size={16} /> Simpan / Update
          </button>
        </div>
      </div>
    </div>
  );
}
