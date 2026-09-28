import { RefreshCw, ShieldCheck } from 'lucide-react';

interface BlockedUser {
  user_id: string;
  warning_count: number;
  blocked_at: string;
  blocked_until: string;
  blocked_reason: string;
}

interface Outlet {
  app_user_id: string;
  restaurantName: string;
  email: string;
}

interface BlockedViewProps {
  blockedUsers: BlockedUser[];
  blockedUsersLoading: boolean;
  unblockingId: string | null;
  outlets: Outlet[];
  fetchAdminData: () => void;
  handleUnblockUser: (userId: string) => void;
}

export function BlockedView({
  blockedUsers,
  blockedUsersLoading,
  unblockingId,
  outlets,
  fetchAdminData,
  handleUnblockUser,
}: BlockedViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">
      <div className="flex items-center justify-between border-b border-slate-900 pb-4">
        <div>
          <h3 className="font-extrabold text-base text-white uppercase tracking-tight">Blocked User Accounts</h3>
          <p className="text-xs text-slate-400 font-semibold mt-1">Manage rate limit violations and release accounts</p>
        </div>
        <button
          onClick={fetchAdminData}
          disabled={blockedUsersLoading}
          className="px-4 py-2 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-xl text-xs font-black text-white flex items-center gap-2 transition-all active:scale-95 disabled:opacity-50"
        >
          <RefreshCw size={13} className={blockedUsersLoading ? 'animate-spin' : ''} />
          {blockedUsersLoading ? 'Loading...' : 'Refresh Queue'}
        </button>
      </div>

      {blockedUsers.length === 0 ? (
        <div className="bg-slate-900/30 border border-slate-800 rounded-3xl p-12 text-center flex flex-col items-center gap-3">
          <div className="p-4 bg-emerald-500/10 text-emerald-400 rounded-full border border-emerald-500/20">
            <ShieldCheck size={36} />
          </div>
          <h4 className="font-black text-white uppercase text-sm mt-2">All Clear</h4>
          <p className="text-xs text-slate-400 max-w-[280px] leading-relaxed">
            No active accounts are currently locked or restricted due to rate limit abuse.
          </p>
        </div>
      ) : (
        <div className="bg-slate-900/30 border border-slate-800 rounded-3xl overflow-hidden shadow-2xl">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-slate-850 bg-slate-900/60 text-[10px] font-black uppercase text-slate-500 tracking-wider">
                  <th className="p-5">User ID</th>
                  <th className="p-5">Violations</th>
                  <th className="p-5">Blocked At</th>
                  <th className="p-5">Blocked Until</th>
                  <th className="p-5">Reason</th>
                  <th className="p-5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-850/60">
                {blockedUsers.map((u) => {
                  const remainingMin = Math.max(0, Math.ceil((new Date(u.blocked_until).getTime() - Date.now()) / 60000));
                  const outletInfo = outlets.find(o => o.app_user_id === u.user_id);
                  return (
                    <tr key={u.user_id} className="hover:bg-slate-900/20 transition-all text-xs font-semibold">
                      <td className="p-5">
                        <div className="flex flex-col">
                          <span className="font-mono text-indigo-400 text-[11px]">{u.user_id}</span>
                          {outletInfo && (
                            <span className="text-[10px] text-slate-400 font-bold mt-0.5">
                              Store: {outletInfo.restaurantName} ({outletInfo.email})
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="p-5">
                        <span className="px-2.5 py-1 rounded-full bg-red-500/10 text-red-400 border border-red-500/20 font-black text-[9px] uppercase tracking-wider">
                          {u.warning_count}/5 Warnings
                        </span>
                      </td>
                      <td className="p-5 text-slate-350 font-mono">
                        {new Date(u.blocked_at).toLocaleString()}
                      </td>
                      <td className="p-5">
                        <div className="flex flex-col">
                          <span className="text-red-400 font-black font-mono">
                            {remainingMin} min remaining
                          </span>
                          <span className="text-[9px] text-slate-500 font-mono mt-0.5">
                            Expires: {new Date(u.blocked_until).toLocaleTimeString()}
                          </span>
                        </div>
                      </td>
                      <td className="p-5 text-slate-400 font-medium">
                        {u.blocked_reason || 'Rate limit threshold exceeded'}
                      </td>
                      <td className="p-5 text-right">
                        <button
                          onClick={() => handleUnblockUser(u.user_id)}
                          disabled={unblockingId === u.user_id}
                          className="px-4 py-2 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 disabled:opacity-50 text-white text-[10px] font-black uppercase tracking-wider rounded-xl transition-all shadow-md shadow-emerald-500/10 active:scale-95"
                        >
                          {unblockingId === u.user_id ? 'Unblocking...' : 'Unblock User'}
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
