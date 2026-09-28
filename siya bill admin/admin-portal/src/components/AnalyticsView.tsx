import {
  AlertCircle, RefreshCw, Sparkles, TrendingUp, Award, BarChart3
} from 'lucide-react';
import { AdminBill, Outlet } from './types';

interface AnalyticsViewProps {
  allBills: AdminBill[];
  outlets: Outlet[];
  analyticsLoading: boolean;
  analyticsErrorMsg: string;
  analyticsPeriod: string;
  setAnalyticsPeriod: (v: string) => void;
}

export function AnalyticsView({
  allBills,
  outlets,
  analyticsLoading,
  analyticsErrorMsg,
  analyticsPeriod,
  setAnalyticsPeriod,
}: AnalyticsViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">

      {/* Controls and filters */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-900/40 border border-slate-800 rounded-3xl p-5 shrink-0">
        <div>
          <h3 className="font-extrabold text-sm text-white uppercase tracking-tight">Ecosystem Financial Dashboard</h3>
          <p className="text-[11px] text-slate-400 font-semibold mt-0.5">Realtime comparative analytics aggregating Supabase bills data</p>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Time Horizon:</span>
          <select
            value={analyticsPeriod}
            onChange={(e) => setAnalyticsPeriod(e.target.value)}
            className="bg-slate-950 border border-slate-800 rounded-xl text-[10px] text-slate-300 font-black p-2.5 focus:outline-none cursor-pointer"
          >
            <option value="all">All Time</option>
            <option value="30days">Last 30 Days</option>
            <option value="today">Today</option>
          </select>
        </div>
      </div>

      {analyticsLoading && allBills.length === 0 ? (
        <div className="flex items-center justify-center py-16 text-slate-500 font-bold text-xs">
          <RefreshCw size={18} className="animate-spin mr-2" />
          Compiling ecosystem reports and aggregations...
        </div>
      ) : analyticsErrorMsg ? (
        <div className="p-4 bg-red-950/20 border border-red-900/40 text-red-400 rounded-2xl text-xs font-bold flex items-center gap-2">
          <AlertCircle size={16} />
          {analyticsErrorMsg}
        </div>
      ) : (() => {
        // Filter bills based on period selection
        const filteredBills = allBills.filter(bill => {
          if (analyticsPeriod === 'today') {
            const todayStr = new Date().toDateString();
            return new Date(bill.timestamp).toDateString() === todayStr;
          }
          if (analyticsPeriod === '30days') {
            const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
            return new Date(bill.timestamp).getTime() >= thirtyDaysAgo;
          }
          return true;
        });

        // Compute high level ecosystem metrics
        const totalSales = filteredBills.reduce((sum, b) => sum + (parseFloat(String(b.total)) || 0), 0);
        const totalTx = filteredBills.length;
        const averageTicket = totalTx > 0 ? (totalSales / totalTx) : 0;

        // Group sales by outlet restaurant
        const outletSalesMap: { [key: string]: { name: string; sales: number; count: number } } = {};
        filteredBills.forEach(bill => {
          const appId = bill.app_user_id || 'unknown';
          if (!outletSalesMap[appId]) {
            const out = outlets.find(o => o.app_user_id === appId);
            outletSalesMap[appId] = {
              name: out ? out.restaurantName : `Outlet (${appId.substring(0, 6).toUpperCase()})`,
              sales: 0,
              count: 0
            };
          }
          outletSalesMap[appId].sales += (parseFloat(String(bill.total)) || 0);
          outletSalesMap[appId].count += 1;
        });

        const leaderboards = Object.entries(outletSalesMap)
          .map(([appId, val]) => ({ appId, ...val }))
          .sort((a, b) => b.sales - a.sales);

        // Construct simplified dynamic sales trend for SVGs (Group by day for last 7 active slots)
        const salesByDayMap: { [key: string]: number } = {};
        filteredBills.slice(0, 100).forEach(b => {
          const d = new Date(b.timestamp).toLocaleDateString([], { month: 'short', day: 'numeric' });
          salesByDayMap[d] = (salesByDayMap[d] || 0) + (parseFloat(String(b.total)) || 0);
        });
        const trendData = Object.entries(salesByDayMap).slice(0, 7).reverse();

        return (
          <div className="flex flex-col gap-6 animate-in fade-in duration-300">

            {/* Aggregates row */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="bg-slate-900/30 border border-slate-800/80 rounded-3xl p-6 flex flex-col gap-1 relative overflow-hidden">
                <div className="absolute top-0 right-0 transform translate-x-8 -translate-y-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-xl"></div>
                <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Ecosystem Revenue (Sales)</span>
                <h3 className="text-3xl font-black text-white mt-1">₹{totalSales.toLocaleString('en-IN', { maximumFractionDigits: 2 })}</h3>
                <span className="text-[9px] text-emerald-400 font-bold mt-1 flex items-center gap-1">
                  <TrendingUp size={10} /> Active volume sync
                </span>
              </div>

              <div className="bg-slate-900/30 border border-slate-800/80 rounded-3xl p-6 flex flex-col gap-1 relative overflow-hidden">
                <div className="absolute top-0 right-0 transform translate-x-8 -translate-y-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-xl"></div>
                <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Total Bill Checkouts</span>
                <h3 className="text-3xl font-black text-indigo-400 mt-1">{totalTx.toLocaleString()} Tx</h3>
                <span className="text-[9px] text-indigo-400 font-bold mt-1 flex items-center gap-1">
                  <RefreshCw size={10} className="animate-spin" /> Live sync logs
                </span>
              </div>

              <div className="bg-slate-900/30 border border-slate-800/80 rounded-3xl p-6 flex flex-col gap-1 relative overflow-hidden">
                <div className="absolute top-0 right-0 transform translate-x-8 -translate-y-8 w-24 h-24 bg-pink-500/5 rounded-full blur-xl"></div>
                <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Average Transaction Cost</span>
                <h3 className="text-3xl font-black text-pink-400 mt-1">₹{averageTicket.toLocaleString('en-IN', { maximumFractionDigits: 2 })}</h3>
                <span className="text-[9px] text-pink-400 font-bold mt-1 flex items-center gap-1">
                  <Sparkles size={10} /> Yield efficiency
                </span>
              </div>
            </div>

            {/* Double Columns: Leaderboard & Visual SVG Graph */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

              {/* Left: Outlet sales Leaderboard */}
              <div className="bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col gap-4">
                <h3 className="font-extrabold text-sm text-white uppercase tracking-tight flex items-center gap-2 border-b border-slate-800 pb-3">
                  <Award className="text-indigo-400" size={16} />
                  Outlet Sales Leaderboard
                </h3>

                <div className="overflow-y-auto max-h-[350px] pr-1 flex flex-col gap-2.5 scrollbar-thin">
                  {leaderboards.length === 0 ? (
                    <div className="text-center py-12 text-slate-500 font-bold">
                      No financial records found for time interval.
                    </div>
                  ) : (
                    leaderboards.map((row, idx) => {
                      const rankGrad =
                        idx === 0 ? 'from-yellow-500 to-amber-600 text-black font-black' :
                        idx === 1 ? 'from-slate-300 to-slate-400 text-black font-black' :
                        idx === 2 ? 'from-amber-650 to-orange-700 text-white font-black' :
                        'bg-slate-850 text-slate-400 border border-slate-800';

                      return (
                        <div
                          key={row.appId}
                          className="bg-slate-900/40 hover:bg-slate-900/80 border border-slate-800/80 rounded-2xl p-3.5 flex items-center justify-between transition-all group active:scale-99"
                        >
                          <div className="flex items-center gap-3.5 min-w-0">
                            {/* Rank identifier */}
                            <div className={`w-6 h-6 rounded-full flex items-center justify-center text-[10px] uppercase tracking-wider bg-gradient-to-br shrink-0 ${rankGrad}`}>
                              {idx + 1}
                            </div>
                            <div className="min-w-0">
                              <span className="font-black text-slate-200 block text-xs truncate max-w-[160px] group-hover:text-white">
                                {row.name}
                              </span>
                              <span className="text-[9.5px] text-slate-505 font-mono tracking-widest">
                                {row.count} Bills Checked out
                              </span>
                            </div>
                          </div>

                          <div className="text-right">
                            <span className="font-mono text-xs font-black text-emerald-400 block">
                              ₹{row.sales.toLocaleString('en-IN', { maximumFractionDigits: 0 })}
                            </span>
                            <span className="text-[9px] font-bold text-slate-505 uppercase tracking-widest block mt-0.5">
                              Avg: ₹{(row.sales / row.count).toFixed(0)}
                            </span>
                          </div>
                        </div>
                      );
                    })
                  )}
                </div>
              </div>

              {/* Right: SVG billing graph trend */}
              <div className="bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col gap-4">
                <h3 className="font-extrabold text-sm text-white uppercase tracking-tight flex items-center gap-2 border-b border-slate-800 pb-3">
                  <TrendingUp className="text-indigo-400" size={16} />
                  Live Billing Volume Trends
                </h3>

                {trendData.length === 0 ? (
                  <div className="flex flex-col items-center justify-center flex-1 py-12 text-slate-550 font-bold text-xs gap-2">
                    <BarChart3 size={24} className="text-slate-650" />
                    No chronological trend data compiled.
                  </div>
                ) : (() => {
                  const maxVal = Math.max(...trendData.map(t => t[1] as number), 1000);
                  return (
                    <div className="flex flex-col justify-between flex-1 gap-4 pt-2">
                      <div className="h-[200px] w-full flex items-end justify-between gap-4 px-2 relative">
                        {/* Dotted lines overlay */}
                        <div className="absolute inset-y-0 left-0 right-0 flex flex-col justify-between pointer-events-none select-none opacity-20">
                          <div className="border-t border-dashed border-slate-700 w-full"></div>
                          <div className="border-t border-dashed border-slate-700 w-full"></div>
                          <div className="border-t border-dashed border-slate-700 w-full"></div>
                          <div className="border-t border-dashed border-slate-700 w-full"></div>
                        </div>

                        {trendData.map(([day, val]) => {
                          const numVal = val as number;
                          const pct = (numVal / maxVal) * 100;
                          return (
                            <div key={day} className="flex-1 flex flex-col items-center gap-2.5 h-full justify-end group z-10">
                              <div className="text-[8.5px] font-black text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity bg-slate-955 border border-slate-850 px-1.5 py-0.5 rounded font-mono select-none">
                                ₹{numVal.toFixed(0)}
                              </div>
                              <div
                                style={{ height: `${Math.max(pct, 5)}%` }}
                                className="w-full sm:max-w-[40px] bg-gradient-to-t from-indigo-600/70 to-pink-500/80 rounded-t-xl transition-all duration-500 group-hover:brightness-125 border-t border-pink-400/40 relative shadow-inner cursor-pointer"
                              >
                                <div className="absolute inset-0 bg-white/5 opacity-0 group-hover:opacity-100 rounded-t-xl transition-opacity"></div>
                              </div>
                              <span className="text-[9px] font-bold text-slate-505 truncate max-w-[50px]">{day}</span>
                            </div>
                          );
                        })}
                      </div>
                      <span className="text-[10px] text-center text-slate-400 font-bold block pt-2 border-t border-slate-850">
                        Aggregated financial performance (X-Axis: Days, Y-Axis: Sales ₹)
                      </span>
                    </div>
                  );
                })()}
              </div>

            </div>
          </div>
        );
      })()}
    </div>
  );
}
