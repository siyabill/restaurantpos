import {
  AlertCircle, Plus, RefreshCw, Sparkles, Edit, Trash2
} from 'lucide-react';
import { ConfirmConfig } from './types';

interface Plan {
  id: string;
  name: string;
  price: number;
  duration_days: number;
  features: string[];
  is_active: boolean;
}

interface PricingViewProps {
  dbPlans: Plan[];
  dbPlansLoading: boolean;
  dbPlansErrorMsg: string;
  openPlanForm: (plan?: Plan) => void;
  handleTogglePlanActive: (plan: Plan) => void;
  handleDeletePlan: (planId: string) => void;
  setConfirmConfig: (config: ConfirmConfig | null) => void;
}

export function PricingView({
  dbPlans,
  dbPlansLoading,
  dbPlansErrorMsg,
  openPlanForm,
  handleTogglePlanActive,
  handleDeletePlan,
  setConfirmConfig,
}: PricingViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">
      {dbPlansErrorMsg && (
        <div className="p-4 bg-red-950/40 border border-red-800/60 text-red-400 rounded-2xl text-xs font-bold flex items-center gap-2">
          <AlertCircle size={16} />
          {dbPlansErrorMsg}
        </div>
      )}

      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-900/40 border border-slate-800 rounded-3xl p-5 shrink-0">
        <div>
          <h3 className="font-extrabold text-sm text-white uppercase tracking-tight">Active Pricing Tiers</h3>
          <p className="text-[11px] text-slate-400 font-semibold mt-0.5">Manage subscription packages offered to outlets</p>
        </div>
        <button
          onClick={() => openPlanForm()}
          className="px-4 py-2.5 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-xs uppercase tracking-wider shadow-md shadow-indigo-500/10 active:scale-95 transition-all flex items-center gap-1.5"
        >
          <Plus size={14} />
          Create New Plan
        </button>
      </div>

      {dbPlansLoading && dbPlans.length === 0 ? (
        <div className="flex items-center justify-center py-16 text-slate-500 font-bold text-xs">
          <RefreshCw size={20} className="animate-spin mr-2" />
          Syncing with Subscription Plans Database...
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {dbPlans.map((plan) => (
            <div
              key={plan.id}
              className={`bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col justify-between transition-all hover:border-slate-700/60 relative overflow-hidden group ${!plan.is_active ? 'opacity-60' : ''}`}
            >
              <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-32 h-32 bg-indigo-500/5 rounded-full blur-2xl group-hover:bg-indigo-500/10 transition-colors"></div>

              <div className="flex flex-col gap-4 relative z-10">
                <div className="flex items-center justify-between border-b border-slate-800/80 pb-3">
                  <div>
                    <h4 className="font-black text-sm text-white uppercase tracking-wider">{plan.name}</h4>
                    <span className="font-mono text-[9px] text-slate-500 tracking-wider font-semibold uppercase">{plan.id}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className={`px-2 py-0.5 rounded-full font-black text-[8px] uppercase tracking-wider ${plan.is_active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-850 text-slate-400 border border-slate-800'}`}>
                      {plan.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </div>
                </div>

                <div className="flex items-baseline gap-1 mt-1">
                  <span className="text-2xl font-black text-white">₹{plan.price}</span>
                  <span className="text-[10px] text-slate-400 font-bold">/ {plan.duration_days} Days</span>
                </div>

                <div className="flex flex-col gap-2 mt-2">
                  <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Included Features</span>
                  <ul className="flex flex-col gap-1.5">
                    {(plan.features || []).map((feat: string, idx: number) => (
                      <li key={idx} className="text-xs font-semibold text-slate-300 flex items-start gap-1.5">
                        <span className="text-indigo-400 font-black">✓</span>
                        <span className="leading-tight">{feat}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>

              <div className="flex items-center justify-between gap-3 border-t border-slate-800/80 pt-4 mt-6 relative z-10">
                <button
                  onClick={() => handleTogglePlanActive(plan)}
                  className={`px-3 py-1.5 border rounded-lg text-[9px] font-black uppercase tracking-wider transition-all active:scale-95 shrink-0 ${plan.is_active ? 'bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-800' : 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400 hover:bg-emerald-500/20'}`}
                >
                  {plan.is_active ? 'Deactivate' : 'Activate'}
                </button>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => openPlanForm(plan)}
                    className="p-1.5 bg-indigo-500/10 hover:bg-indigo-500/20 text-indigo-400 border border-indigo-500/20 rounded-lg transition-all active:scale-95"
                    title="Edit Plan"
                  >
                    <Edit size={12} />
                  </button>

                  <button
                    onClick={() => {
                      setConfirmConfig({
                        isOpen: true,
                        title: '⚠️ Delete Subscription Plan?',
                        message: `Are you sure you want to permanently delete the plan "${plan.name}"?`,
                        onConfirm: () => handleDeletePlan(plan.id)
                      });
                    }}
                    disabled={plan.id === 'monthly' || plan.id === 'half-yearly' || plan.id === 'yearly'}
                    className="p-1.5 bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 rounded-lg transition-all active:scale-95 disabled:opacity-40"
                    title="Delete Plan"
                  >
                    <Trash2 size={12} />
                  </button>
                </div>
              </div>
            </div>
          ))}

          {dbPlans.length === 0 && (
            <div className="col-span-full bg-slate-900/20 border border-slate-800 border-dashed rounded-3xl p-12 text-center text-slate-500 font-bold text-xs flex flex-col items-center justify-center gap-3">
              <Sparkles size={28} className="text-slate-600" />
              <div>
                <span className="block text-white text-sm mb-1 font-black">No subscription plans found!</span>
                Aap database settings me new plan define karke yahan display kar sakte hain.
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
