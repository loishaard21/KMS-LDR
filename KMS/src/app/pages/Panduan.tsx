import { useState, useEffect } from "react";
import { fetchGuides } from "../data/api";

export default function Panduan() {
  const [guides, setGuides] = useState<any[]>([]);
  const [active, setActive] = useState<string>("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchGuides()
      .then(data => {
        setGuides(data);
        if (data.length > 0) setActive(data[0].key);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  const currentIndex = guides.findIndex(m => m.key === active);
  const currentGuide = guides[currentIndex];

  if (loading) {
    return (
      <div className="flex max-w-6xl mx-auto p-6 gap-10 min-h-[60vh] items-center justify-center">
        <p className="text-sm text-gray-500">Memuat panduan...</p>
      </div>
    );
  }

  if (guides.length === 0) {
    return (
      <div className="flex max-w-6xl mx-auto p-6 gap-10 min-h-[60vh] items-center justify-center">
        <p className="text-sm text-gray-500">Belum ada konten panduan yang tersedia.</p>
      </div>
    );
  }

  return (
    <div className="flex max-w-6xl mx-auto p-6 gap-10">

      {/* SIDEBAR */}
      <div className="w-64 pt-[88px]">
        {guides.map((menu, index) => {
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
                {index !== guides.length - 1 && (
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
                  {menu.order || index + 1}
                </div>
              </div>

              {/* TITLE */}
              <button
                onClick={() => setActive(menu.key)}
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
          {currentGuide?.title}
        </h1>

        {/* ACCORDION */}
        <div className="space-y-5">
          {guides.map((menu) => {
            const isOpen = menu.key === active;

            return (
              <div
                key={menu.key}
                className="bg-white border rounded-2xl overflow-hidden shadow-sm"
              >
                {/* HEADER */}
                <button
                  onClick={() => setActive(menu.key)}
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
                    <div
                      className="prose prose-sm max-w-none text-[#374151]"
                      dangerouslySetInnerHTML={{ __html: menu.content }}
                    />
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