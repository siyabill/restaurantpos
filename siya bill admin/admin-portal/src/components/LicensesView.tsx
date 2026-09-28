import React from 'react';
import {
  KeyRound, Copy, CheckCircle2, Sparkles, Send, Receipt
} from 'lucide-react';
import { ConfirmConfig, Outlet, License } from './types';

interface LicensesViewProps {
  licenses: License[];
  outlets: Outlet[];
  targetRestaurantCode: string;
  selectedPlan: string;
  generatedKey: string;
  genLoading: boolean;
  setTargetRestaurantCode: (v: string) => void;
  setSelectedPlan: (v: string) => void;
  handleGenerateKey: (e: React.FormEvent) => void;
  copyKey: () => void;
  setConfirmConfig: (config: ConfirmConfig | null) => void;
  handleRevokeLicense: (licenseId: string, licenseKey: string, claimedByUserId: string | null) => void;
}

export function LicensesView({
  licenses,
  outlets,
  targetRestaurantCode,
  selectedPlan,
  generatedKey,
  genLoading,
  setTargetRestaurantCode,
  setSelectedPlan,
  handleGenerateKey,
  copyKey,
  setConfirmConfig,
  handleRevokeLicense,
}: LicensesViewProps) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start animate-in fade-in duration-200 slide-in-from-bottom-3">

      {/* Key Generator Card */}
      <div className="lg:col-span-1 bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col gap-5">
        <h3 className="font-extrabold text-sm text-white uppercase tracking-tight flex items-center gap-2 border-b border-slate-800 pb-3">
          <KeyRound className="text-indigo-400" size={16} />
          Key Generator Engine
        </h3>

        <form onSubmit={handleGenerateKey} className="flex flex-col gap-4">
          <div className="flex flex-col gap-1.5">
            <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Restaurant Code (Required)</label>
            <input
              type="text"
              required
              value={targetRestaurantCode}
              onChange={(e) => setTargetRestaurantCode(e.target.value)}
              placeholder="e.g. RES-G6T8X9"
              className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-black text-sm tracking-wider uppercase placeholder-slate-700"
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Select Premium Plan</label>
            <select
              value={selectedPlan}
              onChange={(e) => setSelectedPlan(e.target.value)}
              className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-bold text-sm bg-slate-950"
            >
              <option value="M01">Monthly Plan (30 Days)</option>
              <option value="M06">6 Months Plan (180 Days)</option>
              <option value="Y01">Yearly Plan (365 Days)</option>
              <option value="LIF">Lifetime Plan (Permanent Activation)</option>
            </select>
          </div>

          <button
            type="submit"
            disabled={genLoading}
            className="w-full py-3 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-xs uppercase tracking-wider shadow-md shadow-indigo-500/10 active:scale-95 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
          >
            <Sparkles size={14} />
            {genLoading ? 'Saving to Cloud...' : 'Generate Premium Key'}
          </button>
        </form>

        {generatedKey && (
          <div className="bg-slate-950 border border-slate-800 p-4 rounded-2xl flex flex-col gap-3 mt-2 animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between border-b border-slate-800 pb-2">
              <span className="text-[10px] font-black text-emerald-400 uppercase tracking-widest flex items-center gap-1.5">
                <CheckCircle2 size={12} />
                Ready to Send
              </span>
              <button
                onClick={copyKey}
                className="p-1.5 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-lg text-slate-400 active:scale-95 transition-colors"
                title="Copy License Key"
              >
                <Copy size={12} />
              </button>
            </div>
            <div className="text-[10.5px] font-mono font-black break-all text-slate-300 tracking-wider text-center p-2 bg-slate-900 rounded-xl border border-slate-855">
              {generatedKey}
            </div>

            {/* WhatsApp Quick Direct Share */}
            <a
              href={`https://api.whatsapp.com/send?text=${encodeURIComponent(`Pranam! Aapka Siya Bill POS Premium subscription plan activate kar diya gaya hai. \n\n🔑 License Key: ${generatedKey}\n\nApp me paste karke full access chalu karein.`)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="w-full py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-[10px] font-black rounded-xl uppercase tracking-wider flex items-center justify-center gap-2 transition-all active:scale-95 shadow-md shadow-emerald-700/10 mt-1"
            >
              <Send size={12} />
              Share via WhatsApp
            </a>
          </div>
        )}
      </div>

      {/* Claims audit logger table */}
      <div className="lg:col-span-2 bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col gap-4">
        <h3 className="font-extrabold text-sm text-white uppercase tracking-tight flex items-center gap-2 border-b border-slate-800 pb-3">
          <Receipt className="text-indigo-400" size={16} />
          Realtime License Claims Log
        </h3>

        <div className="overflow-x-auto max-h-[480px] scrollbar-thin">
          <table className="w-full text-left text-xs font-semibold">
            <thead>
              <tr className="border-b border-slate-800 text-slate-500 font-black uppercase tracking-wider text-[9px] pb-2">
                <th className="py-2.5">Key / Restaurant Code</th>
                <th>Plan</th>
                <th>Status</th>
                <th>Claimed By</th>
                <th>Claimed At</th>
                <th className="text-right pr-2">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/40 text-slate-300">
              {licenses.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-slate-500 font-bold">No generated license keys found in database!</td>
                </tr>
              ) : (
                licenses.map((lic) => (
                  <tr key={lic.id} className="hover:bg-slate-900/30 transition-colors">
                    <td className="py-3 pr-2">
                      <span className="font-mono text-[9px] block text-slate-400 truncate max-w-[180px]" title={lic.license_key}>
                        {lic.license_key}
                      </span>
                      <span className="text-[10px] font-black text-slate-200 mt-0.5 block tracking-widest">
                        {lic.restaurant_code}
                      </span>
                    </td>
                    <td className="capitalize font-bold text-slate-300">{lic.plan_type}</td>
                    <td>
                      {lic.status === 'claimed' ? (
                        <span className="px-2 py-0.5 text-[8px] font-black uppercase tracking-wider bg-orange-500/10 text-orange-400 border border-orange-500/20 rounded-full animate-pulse">
                          Claimed
                        </span>
                      ) : lic.status === 'revoked' ? (
                        <span className="px-2 py-0.5 text-[8px] font-black uppercase tracking-wider bg-red-500/10 text-red-400 border border-red-500/20 rounded-full">
                          Revoked
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 text-[8px] font-black uppercase tracking-wider bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full">
                          Active (Unused)
                        </span>
                      )}
                    </td>
                    <td className="text-[11px] text-slate-300 font-bold">
                      {lic.claimed_by_user_id ? (
                        (() => {
                          const match = outlets.find(o => o.app_user_id === lic.claimed_by_user_id);
                          return match ? (
                            <div className="flex flex-col gap-0.5">
                              <span className="font-black text-slate-200 block truncate max-w-[140px]">{match.restaurantName}</span>
                              <span className="text-[9px] text-slate-500 font-mono tracking-widest">{match.restaurantCode}</span>
                            </div>
                          ) : (
                            <span className="font-mono text-slate-500">{lic.claimed_by_user_id.substring(0, 8).toUpperCase()}</span>
                          );
                        })()
                      ) : (
                        <span className="text-slate-500">—</span>
                      )}
                    </td>
                    <td className="text-slate-400">{lic.claimed_at ? new Date(lic.claimed_at).toLocaleDateString() : '—'}</td>
                    <td className="text-right py-2.5 pr-2">
                      {lic.status !== 'revoked' ? (
                        <button
                          onClick={() => {
                            setConfirmConfig({
                              isOpen: true,
                              title: '⚠️ Revoke License?',
                              message: `Are you absolutely sure you want to revoke license key ${lic.license_key}? This will immediately terminate premium access for the matched outlet.`,
                              onConfirm: () => handleRevokeLicense(lic.id, lic.license_key, lic.claimed_by_user_id)
                            });
                          }}
                          className="px-2.5 py-1.5 bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 rounded-lg text-[9px] font-black uppercase tracking-wider transition-all active:scale-95"
                        >
                          Revoke
                        </button>
                      ) : (
                        <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider select-none">Revoked</span>
                      )}
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
