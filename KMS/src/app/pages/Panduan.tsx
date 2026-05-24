import { useState } from "react";
import InformasiPembuka from "./InformasiPembuka";

const menus = [
  { title: "Informasi Pembuka", key: "info", content: <InformasiPembuka /> },
  { title: "Alur Pembangunan", key: "alur", content: <p>Isi alur pembangunan</p> },
  { title: "Dokumen Persiapan", key: "persiapan", content: <p>Isi dokumen persiapan</p> },
  { title: "Dokumen Pelaksanaan", key: "pelaksanaan", content: <p>Isi dokumen pelaksanaan</p> },
  { title: "Repositori & API", key: "repo", content: <p>Isi repositori & API</p> },
  { title: "Integrasi Layanan", key: "integrasi", content: <p>Isi integrasi layanan</p> },
  { title: "PSE & Pusat Data", key: "pse", content: <p>Isi PSE & pusat data</p> },
];

export default function Panduan() {
  const [active, setActive] = useState("info");

  const currentIndex = menus.findIndex((m) => m.key === active);

  const toggleMenu = (key: string) => {
    setActive(key);
  };

  return (
    <div className="flex max-w-6xl mx-auto p-6 gap-10">

      {/* SIDEBAR */}
      <div className="w-64 pt-[88px]">

        {menus.map((menu, index) => {
          const isActive = menu.key === active;
          const isDone = index < currentIndex;

          return (
            <div
              key={menu.key}
              className="relative flex items-start gap-4 h-[96px]"
            >
              {/* STEP */}
              <div className="relative flex flex-col items-center">

                {/* LINE */}
                {index !== menus.length - 1 && (
                  <div className="absolute top-8 w-[2px] h-[68px] bg-gray-300" />
                )}

                {/* DOT */}
                <div
                  className={`
                    z-10 w-8 h-8 rounded-full flex items-center justify-center
                    text-sm font-bold transition
                    ${
                      isActive
                        ? "bg-[#2563EB] text-white"
                        : isDone
                        ? "bg-[#93C5FD] text-white"
                        : "bg-gray-300 text-gray-600"
                    }
                  `}
                >
                  {index + 1}
                </div>
              </div>

              {/* TITLE */}
              <button
                onClick={() => toggleMenu(menu.key)}
                className={`text-left pt-1 text-sm font-medium transition ${
                  isActive ? "text-[#2563EB]" : "text-gray-500"
                }`}
              >
                {menu.title}
              </button>
            </div>
          );
        })}
      </div>

      {/* CONTENT AREA */}
      <div className="flex-1">

        {/* HEADER */}
        <h1 className="text-2xl font-bold text-[#1E293B] mb-6">
          {menus[currentIndex].title}
        </h1>

        {/* ACCORDION */}
        <div className="space-y-5">
          {menus.map((menu) => {
            const isOpen = menu.key === active;

            return (
              <div
                key={menu.key}
                className="bg-white border rounded-2xl overflow-hidden shadow-sm"
              >
                {/* HEADER */}
                <button
                  onClick={() => toggleMenu(menu.key)}
                  className="w-full flex items-center gap-3 px-6 py-7 text-left hover:bg-gray-50 transition"
                >
                  {/* ICON */}
                  <span
                    className={`text-xl transition-transform duration-200 text-[#2563EB] ${
                      isOpen ? "rotate-90" : "rotate-0"
                    }`}
                  >
                    &gt;
                  </span>

                  {/* TITLE */}
                  <h2
                    className={`text-lg font-semibold flex-1 ${
                      isOpen ? "text-[#2563EB]" : "text-[#1E293B]"
                    }`}
                  >
                    {menu.title}
                  </h2>
                </button>

                {/* CONTENT */}
                {isOpen && (
                  <div className="border-t p-6 bg-[#F8FAFC]">
                    {menu.content}
                  </div>
                )}
              </div>
            );
          })}
        </div>

      </div>
    </div>
  );
}