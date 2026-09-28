import {
  KeyRound, ShieldCheck, Building2, Sparkles, Send
} from 'lucide-react';

interface DashboardViewProps {
  dashboardMetrics: { totalOutlets: number; activePremium: number; totalKeys: number };
  activeBroadcast: string;
  announcementInput: string;
  broadcastingLoading: boolean;
  setActiveTab: (tab: string) => void;
  setAnnouncementInput: (v: string) => void;
  handleBroadcastAnnouncement: (e: React.FormEvent) => void;
  handleClearBroadcast: () => void;
}

export function DashboardView({
  dashboardMetrics,
  activeBroadcast,
  announcementInput,
  broadcastingLoading,
  setActiveTab,
  setAnnouncementInput,
  handleBroadcastAnnouncement,
  handleClearBroadcast,
}: DashboardViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">

      {/* Metrics cards grid */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div
          onClick={() => setActiveTab('outlets')}
          className="bg-slate-900/40 hover:bg-slate-900/80 cursor-pointer border border-slate-800/80 rounded-3xl p-6 flex items-center justify-between transition-all group active:scale-98"
        >
          <div className="flex flex-col">
            <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest group-hover:text-slate-400 transition-colors">Total Outlets</span>
            <h3 className="text-3xl font-black mt-1 text-white">{dashboardMetrics.totalOutlets}</h3>
          </div>
          <div className="p-4 bg-blue-500/10 text-blue-400 rounded-2xl border border-blue-500/20 group-hover:bg-blue-500/20 group-hover:scale-105 transition-all">
            <Building2 size={24} />
          </div>
        </div>

        <div
          onClick={() => setActiveTab('outlets')}
          className="bg-slate-900/40 hover:bg-slate-900/80 cursor-pointer border border-slate-800/80 rounded-3xl p-6 flex items-center justify-between transition-all group active:scale-98"
        >
          <div className="flex flex-col">
            <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest group-hover:text-slate-400 transition-colors">Active Premium Tiers</span>
            <h3 className="text-3xl font-black mt-1 text-emerald-400">{dashboardMetrics.activePremium}</h3>
          </div>
          <div className="p-4 bg-emerald-500/10 text-emerald-400 rounded-2xl border border-emerald-500/20 group-hover:bg-emerald-500/20 group-hover:scale-105 transition-all">
            <ShieldCheck size={24} />
          </div>
        </div>

        <div
          onClick={() => setActiveTab('licenses')}
          className="bg-slate-900/40 hover:bg-slate-900/80 cursor-pointer border border-slate-800/80 rounded-3xl p-6 flex items-center justify-between transition-all group active:scale-98"
        >
          <div className="flex flex-col">
            <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest group-hover:text-slate-400 transition-colors">Generated Licenses</span>
            <h3 className="text-3xl font-black mt-1 text-indigo-400">{dashboardMetrics.totalKeys}</h3>
          </div>
          <div className="p-4 bg-indigo-500/10 text-indigo-400 rounded-2xl border border-indigo-500/20 group-hover:bg-indigo-500/20 group-hover:scale-105 transition-all">
            <KeyRound size={24} />
          </div>
        </div>
      </div>

      {/* Status and quick navigation grids */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

        {/* System Health */}
        <div className="bg-slate-900/30 border border-slate-800/70 rounded-3xl p-6 flex flex-col gap-4">
          <h4 className="text-xs font-black text-white uppercase tracking-wider border-b border-slate-800 pb-3 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            System Infrastructure Status
          </h4>
          <div className="flex flex-col gap-3 mt-1">
            <div className="flex items-center justify-between text-xs font-semibold">
              <span className="text-slate-400">Supabase Cloud Database</span>
              <span className="px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-black text-[9px] uppercase tracking-wider">
                Online & Syncing
              </span>
            </div>
            <div className="flex items-center justify-between text-xs font-semibold">
              <span className="text-slate-400">Security Access Rules (RLS)</span>
              <span className="px-2.5 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-black text-[9px] uppercase tracking-wider">
                Strictly Guarded
              </span>
            </div>
            <div className="flex items-center justify-between text-xs font-semibold">
              <span className="text-slate-400">License Verification Module</span>
              <span className="px-2.5 py-0.5 rounded-full bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 font-black text-[9px] uppercase tracking-wider">
                SHA-Hash Verification Active
              </span>
            </div>
            <div className="flex items-center justify-between text-xs font-semibold">
              <span className="text-slate-400">Network Latency</span>
              <span className="text-emerald-400 font-mono font-bold text-xs">~28ms (Excellent)</span>
            </div>
          </div>
        </div>

        {/* Quick actions map */}
        <div className="bg-slate-900/30 border border-slate-800/70 rounded-3xl p-6 flex flex-col gap-4">
          <h4 className="text-xs font-black text-white uppercase tracking-wider border-b border-slate-800 pb-3">
            Quick Operational Shortcuts
          </h4>
          <div className="grid grid-cols-2 gap-3 mt-1">
            <button
              onClick={() => setActiveTab('licenses')}
              className="p-3 bg-slate-900/60 hover:bg-indigo-950/20 border border-slate-800 hover:border-indigo-500/20 rounded-2xl flex flex-col items-start gap-1.5 transition-all text-left group animate-pulse"
            >
              <KeyRound size={16} className="text-indigo-400 group-hover:scale-105 transition-transform" />
              <span className="text-[10px] font-black text-white uppercase tracking-wider">Generate Key</span>
              <span className="text-[9px] text-slate-500 font-medium leading-tight">Create premium keys instantly.</span>
            </button>

            <button
              onClick={() => setActiveTab('pricing')}
              className="p-3 bg-slate-900/60 hover:bg-pink-950/20 border border-slate-800 hover:border-pink-500/20 rounded-2xl flex flex-col items-start gap-1.5 transition-all text-left group"
            >
              <Sparkles size={16} className="text-pink-400 group-hover:scale-105 transition-transform" />
              <span className="text-[10px] font-black text-white uppercase tracking-wider">Manage Pricing</span>
              <span className="text-[9px] text-slate-500 font-medium leading-tight">Change costs and features.</span>
            </button>
          </div>
        </div>

      </div>

      {/* Ecosystem-Wide Announcements Broadcaster */}
      <div className="bg-gradient-to-r from-indigo-950/20 via-slate-900/40 to-pink-950/10 border border-slate-800 rounded-3xl p-6 flex flex-col gap-5 relative overflow-hidden">
        <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-48 h-48 bg-pink-500/5 rounded-full blur-3xl"></div>

        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-800 pb-3">
          <h4 className="text-xs font-black text-white uppercase tracking-wider flex items-center gap-2">
            <span className="p-1.5 bg-indigo-500/10 text-indigo-400 rounded-lg">
              <Sparkles size={14} className="animate-pulse" />
            </span>
            Ecosystem-Wide Announcements Broadcaster
          </h4>
          {activeBroadcast && (
            <div className="px-2.5 py-0.5 rounded-full bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 font-black text-[9px] uppercase tracking-wider flex items-center gap-1.5 self-start sm:self-auto">
              <span className="w-1.5 h-1.5 rounded-full bg-indigo-500 animate-ping"></span>
              Currently Broadcasting
            </div>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
          {/* Form input */}
          <form onSubmit={handleBroadcastAnnouncement} className="lg:col-span-2 flex flex-col gap-3.5">
            <div className="flex flex-col gap-1.5">
              <label className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Broadcast Notice Message</label>
              <input
                type="text"
                required
                value={announcementInput}
                onChange={(e) => setAnnouncementInput(e.target.value)}
                placeholder="e.g. System maintenance scheduled for midnight! Please save all active KOT orders."
                className="w-full p-3 bg-slate-950 border border-slate-850 focus:border-indigo-500 focus:outline-none rounded-xl text-xs font-bold placeholder-slate-700 text-white"
              />
            </div>
            <div className="flex items-center gap-3">
              <button
                type="submit"
                disabled={broadcastingLoading}
                className="px-5 py-2.5 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-[10px] uppercase tracking-wider shadow-md shadow-indigo-500/10 active:scale-95 transition-all disabled:opacity-50 flex items-center gap-1.5"
              >
                <Send size={12} />
                {broadcastingLoading ? 'Broadcasting...' : 'Broadcast Announcement'}
              </button>
              {activeBroadcast && (
                <button
                  type="button"
                  onClick={handleClearBroadcast}
                  disabled={broadcastingLoading}
                  className="px-5 py-2.5 bg-slate-800 hover:bg-red-950/40 hover:text-red-400 hover:border-red-900/40 border border-slate-700/50 text-slate-300 font-black rounded-xl text-[10px] uppercase tracking-wider active:scale-95 transition-all disabled:opacity-50"
                >
                  Clear Active Broadcast
                </button>
              )}
            </div>
          </form>

          {/* Live preview pane */}
          <div className="lg:col-span-1 bg-slate-950 border border-slate-855 p-4 rounded-2xl flex flex-col gap-2.5 min-h-[110px]">
            <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Live Client Preview Banner</span>
            {activeBroadcast ? (
              <div className="bg-gradient-to-r from-indigo-600 via-purple-600 to-indigo-600 text-white p-2.5 rounded-xl flex items-center justify-between text-[9px] font-black uppercase tracking-wider border border-indigo-700 shadow-lg shadow-indigo-500/10 animate-pulse">
                <span className="truncate max-w-[150px]">📢 {activeBroadcast}</span>
                <span className="text-[8px] bg-white/20 border border-white/20 px-1.5 py-0.5 rounded font-sans tracking-normal select-none">Dismiss</span>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center flex-1 text-center py-2 text-slate-600 font-bold text-[10px]">
                No active broadcast. All client screens are clean.
              </div>
            )}
          </div>
        </div>
      </div>

    </div>
  );
}
