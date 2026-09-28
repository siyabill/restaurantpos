import { Search, X } from 'lucide-react';

interface Outlet {
  id: string;
  app_user_id: string;
  restaurantName: string;
  phone: string;
  email: string;
  address: string;
  gst_number: string;
  fssai_number: string;
  upi_id: string;
  status: string;
  expiry: number;
  restaurantCode: string;
  billSequence: number;
}

interface OutletsViewProps {
  filteredOutlets: Outlet[];
  searchQuery: string;
  setSearchQuery: (v: string) => void;
  handleExtendTrial: (appUserId: string, settingsId: string, days: number) => void;
  handleSuspendOutlet: (appUserId: string, settingsId: string) => void;
  handleManualUpgrade: (appUserId: string, settingsId: string, actionType: string) => void;
}

export function OutletsView({
  filteredOutlets,
  searchQuery,
  setSearchQuery,
  handleExtendTrial,
  handleSuspendOutlet,
  handleManualUpgrade,
}: OutletsViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">

      {/* Table search filter bar */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-900/40 border border-slate-800 rounded-3xl p-5 shrink-0">
        <div className="w-full sm:max-w-md relative">
          <Search size={16} className="absolute left-3.5 top-1/2 transform -translate-y-1/2 text-slate-500" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by restaurant name, code, or phone number..."
            className="w-full pl-10 pr-9 py-2.5 bg-slate-950 border border-slate-800 focus:border-indigo-500 focus:outline-none rounded-xl text-xs font-bold placeholder-slate-600 text-white"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-500 hover:text-slate-300 p-0.5 bg-slate-800 rounded-full"
            >
              <X size={10} />
            </button>
          )}
        </div>

        <div className="text-[10px] text-slate-400 font-bold bg-slate-900 border border-slate-850 px-3.5 py-2 rounded-xl shrink-0">
          Total Active Records: <span className="text-white font-black">{filteredOutlets.length} Outlets</span>
        </div>
      </div>

      {/* Data Table */}
      <div className="bg-slate-900/30 border border-slate-800 rounded-3xl p-6">
        <div className="overflow-x-auto min-h-[300px] scrollbar-thin">
          <table className="w-full text-left text-xs font-semibold">
            <thead>
              <tr className="border-b border-slate-800 text-slate-500 font-black uppercase tracking-wider text-[9px] pb-2">
                <th className="py-3">Outlet Info</th>
                <th>Code</th>
                <th>Status</th>
                <th>Expires At</th>
                <th className="text-right">Quick Plan Control</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/40 text-slate-300">
              {filteredOutlets.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-12 text-center text-slate-500 font-bold">
                    <span className="block text-sm mb-1.5">No matching outlets found! 🔍</span>
                    Spelling check karein ya search query badalke try karein.
                  </td>
                </tr>
              ) : (
                filteredOutlets.map((out) => (
                  <tr key={out.id} className="hover:bg-slate-900/30 transition-colors">
                    <td className="py-4 pr-2">
                      <span className="font-black text-slate-200 block text-xs truncate max-w-[180px]">
                        {out.restaurantName}
                      </span>
                      <span className="text-[10px] text-slate-400 mt-0.5 block">
                        {out.phone || 'No phone registered'}
                      </span>
                    </td>
                    <td className="font-mono text-slate-300 font-bold tracking-widest">{out.restaurantCode}</td>
                    <td>
                      {out.status === 'premium' && out.expiry > Date.now() ? (
                        <span className="px-2.5 py-0.5 text-[8px] font-black uppercase tracking-wider bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 rounded-full animate-pulse">
                          Premium
                        </span>
                      ) : out.status === 'suspended' ? (
                        <span className="px-2.5 py-0.5 text-[8px] font-black uppercase tracking-wider bg-red-500/10 text-red-400 border border-red-500/20 rounded-full">
                          Suspended
                        </span>
                      ) : (
                        <span className="px-2.5 py-0.5 text-[8px] font-black uppercase tracking-wider bg-red-500/10 text-red-400 border border-red-500/20 rounded-full">
                          Trial / Expired
                        </span>
                      )}
                    </td>
                    <td className="text-slate-400 font-mono text-[10px]">
                      {out.expiry ? new Date(out.expiry).toLocaleDateString() : '—'}
                    </td>
                    <td className="text-right py-3 pr-2">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleExtendTrial(out.app_user_id, out.id, 3)}
                          className="px-2.5 py-1.5 bg-indigo-500/10 hover:bg-indigo-500/20 text-indigo-400 border border-indigo-500/20 rounded-lg text-[9px] font-black uppercase tracking-wider transition-all active:scale-95 shrink-0"
                        >
                          +3 Days
                        </button>
                        <button
                          onClick={() => handleExtendTrial(out.app_user_id, out.id, 7)}
                          className="px-2.5 py-1.5 bg-indigo-500/10 hover:bg-indigo-500/20 text-indigo-400 border border-indigo-500/20 rounded-lg text-[9px] font-black uppercase tracking-wider transition-all active:scale-95 shrink-0"
                        >
                          +7 Days
                        </button>
                        {out.status !== 'suspended' && (
                          <button
                            onClick={() => handleSuspendOutlet(out.app_user_id, out.id)}
                            className="px-2.5 py-1.5 bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 rounded-lg text-[9px] font-black uppercase tracking-wider transition-all active:scale-95 shrink-0"
                          >
                            Suspend
                          </button>
                        )}
                        <select
                          onChange={(e) => {
                            if (e.target.value) {
                              handleManualUpgrade(out.app_user_id, out.id, e.target.value);
                              e.target.value = ''; // Reset selector
                            }
                          }}
                          className="bg-slate-950 border border-slate-800 text-[9px] text-slate-300 font-black px-2 py-1.5 rounded-lg focus:outline-none focus:border-indigo-500 cursor-pointer shrink-0 animate-pulse"
                        >
                          <option value="">More...</option>
                          <option value="M01">30 Days</option>
                          <option value="M06">180 Days</option>
                          <option value="Y01">365 Days</option>
                          <option value="LIF">Lifetime</option>
                          <option value="EXP">Downgrade</option>
                        </select>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
