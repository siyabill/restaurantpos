import { Activity, Search, Edit, X } from 'lucide-react';
import { AdminBill, Outlet } from './types';

interface AuditsViewProps {
  outlets: Outlet[];
  allBills: AdminBill[];
  liveRestaurantsCount: number;
  staffSearchQuery: string;
  selectedLiveOutlet: Outlet | null;
  editingBillSeq: string;
  updatingSeq: boolean;
  setStaffSearchQuery: (v: string) => void;
  setSelectedLiveOutlet: (outlet: Outlet | null) => void;
  setEditingBillSeq: (v: string) => void;
  handleUpdateBillSeq: () => void;
}

export function AuditsView({
  outlets,
  allBills,
  liveRestaurantsCount,
  staffSearchQuery,
  selectedLiveOutlet,
  editingBillSeq,
  updatingSeq,
  setStaffSearchQuery,
  setSelectedLiveOutlet,
  setEditingBillSeq,
  handleUpdateBillSeq,
}: AuditsViewProps) {
  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-white flex items-center gap-3">
            <Activity className="w-8 h-8 text-emerald-400" />
            Live Outlets Status
          </h1>
          <p className="text-zinc-400 mt-2">Monitor all registered restaurant outlets, view details and adjust bill sequences.</p>
        </div>
        <div className="flex items-center gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
            <input
              type="text"
              placeholder="Search outlets..."
              value={staffSearchQuery}
              onChange={(e) => setStaffSearchQuery(e.target.value)}
              className="w-64 bg-zinc-900/50 border border-zinc-800 rounded-xl py-2 pl-10 pr-4 text-white focus:outline-none focus:border-emerald-500/50 transition-colors"
            />
          </div>
          <div className="text-[12px] font-black bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-4 py-2 rounded-xl flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            {liveRestaurantsCount} Currently Online
          </div>
        </div>
      </div>

      {/* List of Outlets */}
      <div className="bg-zinc-900/50 border border-zinc-800/50 rounded-2xl overflow-hidden backdrop-blur-sm mt-6">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-zinc-800 bg-black/20 text-xs font-semibold text-zinc-400 uppercase tracking-wider">
                <th className="p-4">Restaurant Name</th>
                <th className="p-4">Phone</th>
                <th className="p-4">Status</th>
                <th className="p-4">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-800/50">
              {outlets.filter(o =>
                o.restaurantName.toLowerCase().includes(staffSearchQuery.toLowerCase()) ||
                o.phone.includes(staffSearchQuery)
              ).map(outlet => (
                <tr key={outlet.id} className="hover:bg-zinc-800/20 transition-colors">
                  <td className="p-4 font-bold text-emerald-300">{outlet.restaurantName}</td>
                  <td className="p-4 text-zinc-300">{outlet.phone}</td>
                  <td className="p-4">
                    {outlet.status === 'premium' ? (
                      <span className="px-3 py-1 rounded-full text-[10px] font-bold bg-amber-500/20 text-amber-400 border border-amber-500/20">PREMIUM</span>
                    ) : (
                      <span className="px-3 py-1 rounded-full text-[10px] font-bold bg-zinc-800 text-zinc-400">FREE / EXPIRED</span>
                    )}
                  </td>
                  <td className="p-4">
                    <button
                      onClick={() => {
                        setSelectedLiveOutlet(outlet);
                        setEditingBillSeq(outlet.billSequence?.toString() || '1');
                      }}
                      className="px-4 py-2 bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-400 rounded-lg text-xs font-bold transition-colors flex items-center gap-2"
                    >
                      <Search className="w-3 h-3" /> View Details
                    </button>
                  </td>
                </tr>
              ))}
              {outlets.length === 0 && (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-zinc-500">No outlets found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal for Outlet Details */}
      {selectedLiveOutlet && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
          <div className="bg-zinc-950 border border-zinc-800 rounded-3xl p-6 w-full max-w-lg shadow-2xl relative">
            <button
              onClick={() => setSelectedLiveOutlet(null)}
              className="absolute top-4 right-4 p-2 text-zinc-400 hover:text-white rounded-full hover:bg-zinc-800 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
            <h2 className="text-2xl font-black text-white mb-6 pr-8">
              {selectedLiveOutlet.restaurantName}
            </h2>

            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-zinc-900/50 p-4 rounded-xl border border-zinc-800/50">
                  <div className="text-xs text-zinc-500 uppercase font-bold mb-1">Total Bills</div>
                  <div className="text-2xl font-black text-emerald-400">
                    {allBills.filter(b => b.app_user_id === selectedLiveOutlet.app_user_id).length}
                  </div>
                </div>
                <div className="bg-zinc-900/50 p-4 rounded-xl border border-zinc-800/50">
                  <div className="text-xs text-zinc-500 uppercase font-bold mb-1">Phone</div>
                  <div className="text-lg font-bold text-white">{selectedLiveOutlet.phone || 'N/A'}</div>
                </div>
              </div>

              <div className="bg-zinc-900/50 p-4 rounded-xl border border-zinc-800/50 space-y-2">
                <div className="flex justify-between border-b border-zinc-800 pb-2">
                  <span className="text-zinc-500 text-sm">Email</span>
                  <span className="text-zinc-300 font-medium truncate max-w-[200px]" title={selectedLiveOutlet.email}>{selectedLiveOutlet.email || '-'}</span>
                </div>
                <div className="flex justify-between border-b border-zinc-800 pb-2 pt-2">
                  <span className="text-zinc-500 text-sm">Address</span>
                  <span className="text-zinc-300 font-medium text-right max-w-[200px] truncate" title={selectedLiveOutlet.address}>{selectedLiveOutlet.address || '-'}</span>
                </div>
                <div className="flex justify-between border-b border-zinc-800 pb-2 pt-2">
                  <span className="text-zinc-500 text-sm">GST No.</span>
                  <span className="text-zinc-300 font-medium">{selectedLiveOutlet.gst_number || '-'}</span>
                </div>
                <div className="flex justify-between pt-2">
                  <span className="text-zinc-500 text-sm">FSSAI No.</span>
                  <span className="text-zinc-300 font-medium">{selectedLiveOutlet.fssai_number || '-'}</span>
                </div>
              </div>

              {/* Bill Sequence Editor */}
              <div className="bg-zinc-900/80 p-5 rounded-xl border border-emerald-500/20 mt-4">
                <label className="text-xs text-emerald-400 uppercase font-bold mb-3 flex items-center gap-2">
                  <Edit className="w-4 h-4" /> Edit Bill Sequence Number
                </label>
                <div className="flex items-center gap-3">
                  <input
                    type="number"
                    value={editingBillSeq}
                    onChange={(e) => setEditingBillSeq(e.target.value)}
                    className="flex-1 bg-black border border-zinc-800 rounded-xl px-4 py-3 text-white font-bold focus:outline-none focus:border-emerald-500/50"
                  />
                  <button
                    onClick={handleUpdateBillSeq}
                    disabled={updatingSeq}
                    className="px-6 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-black rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {updatingSeq ? 'Saving...' : 'Save'}
                  </button>
                </div>
                <p className="text-[10px] text-zinc-500 mt-2">Update the next bill number for this outlet. This takes effect immediately on their next local database sync.</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
