import { useState, useEffect } from "react";
import { Link } from "react-router";
import { ArrowUpRight } from "lucide-react";
import { fetchSchedules } from "../data/api";

export function Jadwal() {
  const [schedulesList, setSchedulesList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchSchedules()
      .then(res => {
        setSchedulesList(res);
        setLoading(false);
      })
      .catch(err => {
        console.error("Error fetching schedules:", err);
        setLoading(false);
      });
  }, []);

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="mb-8">
        <p className="text-[#0052CC] text-sm font-medium mb-1">Agenda</p>
        <h1 className="text-2xl font-bold text-[#1A2332] mb-1">Jadwal Seminar & Kegiatan</h1>
        <p className="text-[#64748B] text-sm">Daftar agenda seminar, workshop, dan pelatihan yang akan datang.</p>
      </div>

      <div className="space-y-4">
        {loading ? (
          <p className="text-sm text-[#64748B]">Memuat jadwal...</p>
        ) : (
          schedulesList.map(item => {
            const isFull = item.status === "Kuota Penuh";
          return (
            <div
              key={item.id}
              className="bg-white border border-[#E2E8F0] rounded-2xl p-5 flex items-center gap-5 hover:shadow-md transition-shadow"
              style={{ boxShadow: "0px 4px 20px rgba(0,82,204,0.05)" }}
            >
              {/* Date Box */}
              <div className="flex-shrink-0 w-16 h-16 rounded-xl bg-[#0052CC] flex flex-col items-center justify-center">
                <span className="text-white text-2xl font-bold leading-none">{item.date}</span>
                <span className="text-white/80 text-xs mt-0.5">{item.month} {item.year}</span>
              </div>

              {/* Info */}
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-[#1A2332] text-sm mb-1 truncate">{item.title}</h3>
                <p className="text-[#64748B] text-xs mb-2">{item.location}</p>
                <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${isFull ? "bg-red-100 text-red-600" : "bg-green-100 text-green-700"}`}>
                  {item.status}
                </span>
              </div>

              {/* Buttons */}
              <div className="flex-shrink-0 flex flex-col sm:flex-row gap-2">
                <Link
                  to={`/seminar/${item.seminarId}`}
                  className="text-xs font-medium px-4 py-2 rounded-xl border border-[#0052CC] text-[#0052CC] hover:bg-[#EEF4FF] transition-colors text-center"
                >
                  Detail
                </Link>
                {!isFull && (
                  <Link
                    to={`/seminar/${item.seminarId}`}
                    className="text-xs font-medium px-4 py-2 rounded-xl bg-[#22C55E] text-white hover:bg-[#16A34A] transition-colors flex items-center gap-1 justify-center"
                  >
                    Daftar <ArrowUpRight size={11} />
                  </Link>
                )}
              </div>
            </div>
          );
        })
      )}
      </div>
    </div>
  );
}
