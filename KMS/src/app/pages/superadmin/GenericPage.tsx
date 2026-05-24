import { Construction } from "lucide-react";

interface GenericPageProps {
  title: string;
  description?: string;
}

export function GenericPage({ title, description }: GenericPageProps) {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <div className="w-16 h-16 bg-[#EEF4FF] rounded-2xl flex items-center justify-center mb-4">
        <Construction size={28} className="text-[#0052CC]" />
      </div>
      <h2 className="font-bold text-[#1A2332] mb-2">{title}</h2>
      <p className="text-sm text-[#64748B] max-w-md">
        {description || `Halaman ${title} sedang dalam pengembangan. Fitur akan segera tersedia.`}
      </p>
    </div>
  );
}
