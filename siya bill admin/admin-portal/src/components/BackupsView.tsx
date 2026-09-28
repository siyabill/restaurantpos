import React from 'react';
import { Database, Clock, Download, Upload } from 'lucide-react';
import { BackupRecord } from './types';

interface BackupsViewProps {
  backupRecords: BackupRecord[];
  backupsLoading: boolean;
  handleTriggerBackup: () => void;
  handleRestoreBackup: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export function BackupsView({
  backupRecords,
  backupsLoading,
  handleTriggerBackup,
  handleRestoreBackup,
}: BackupsViewProps) {
  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3">

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Glassmorphic backup execution panel */}
        <div className="bg-gradient-to-br from-slate-900 via-indigo-950/20 to-pink-950/15 border border-slate-800 rounded-3xl p-6 relative overflow-hidden flex flex-col justify-between gap-6">
          <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-64 h-64 bg-indigo-500/5 rounded-full blur-3xl"></div>

          <div className="flex items-start gap-4 relative z-10">
            <div className="p-4 bg-indigo-500/10 text-indigo-400 rounded-2xl border border-indigo-500/20 shrink-0">
              <Database size={28} className="animate-pulse" />
            </div>
            <div>
              <h3 className="font-extrabold text-base text-white uppercase tracking-tight">Manual Backup Snapshot</h3>
              <p className="text-xs text-slate-350 font-medium mt-1 leading-relaxed">
                Ecosystem data tables (licenses, custom plans, support tickets, and global configuration records) ka secure, consolidated backup compile karke direct local download chalu karein. Snapshot JSON packages are fully serialized.
              </p>
            </div>
          </div>

          <button
            onClick={handleTriggerBackup}
            disabled={backupsLoading}
            className="w-full sm:w-auto self-end px-6 py-3.5 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-xs uppercase tracking-wider shadow-lg shadow-indigo-500/20 active:scale-95 transition-all disabled:opacity-50 flex items-center justify-center gap-2 shrink-0 relative z-10 animate-pulse hover:animate-none"
          >
            <Download size={14} className={backupsLoading ? 'animate-bounce' : ''} />
            {backupsLoading ? 'Compiling Tables...' : 'Trigger Backup Snapshot'}
          </button>
        </div>

        {/* Glassmorphic restore execution panel */}
        <div className="bg-gradient-to-br from-slate-900 via-pink-950/15 to-indigo-950/20 border border-slate-800 rounded-3xl p-6 relative overflow-hidden flex flex-col justify-between gap-6">
          <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-64 h-64 bg-pink-500/5 rounded-full blur-3xl"></div>

          <div className="flex items-start gap-4 relative z-10">
            <div className="p-4 bg-pink-500/10 text-pink-400 rounded-2xl border border-pink-500/20 shrink-0">
              <Upload size={28} className="animate-pulse" />
            </div>
            <div>
              <h3 className="font-extrabold text-base text-white uppercase tracking-tight">Restore Backup Snapshot</h3>
              <p className="text-xs text-slate-350 font-medium mt-1 leading-relaxed">
                Apne pehle se download kiye huye valid backup JSON snapshot package ko upload karein. Yeh database tables ko upsert karega, jisse plans, licenses, support tickets aur settings refresh ho jayengi.
              </p>
            </div>
          </div>

          <div className="flex items-center justify-end relative z-10">
            <label className="w-full sm:w-auto px-6 py-3.5 bg-gradient-to-r from-pink-500 to-indigo-500 hover:from-pink-600 hover:to-indigo-600 text-white font-black rounded-xl text-xs uppercase tracking-wider shadow-lg shadow-pink-500/20 active:scale-95 transition-all disabled:opacity-50 flex items-center justify-center gap-2 cursor-pointer shrink-0">
              <Upload size={14} />
              {backupsLoading ? 'Restoring System...' : 'Upload & Restore Snapshot'}
              <input
                type="file"
                accept=".json"
                onChange={handleRestoreBackup}
                disabled={backupsLoading}
                className="hidden"
              />
            </label>
          </div>
        </div>
      </div>

      {/* Backups log history list */}
      <div className="bg-slate-900/30 border border-slate-800 rounded-3xl p-6 flex flex-col gap-4">
        <h3 className="font-extrabold text-sm text-white uppercase tracking-tight flex items-center gap-2 border-b border-slate-800 pb-3">
          <Clock className="text-indigo-400" size={16} />
          Administrative Backup History
        </h3>

        <div className="overflow-x-auto min-h-[220px] scrollbar-thin">
          <table className="w-full text-left text-xs font-semibold">
            <thead>
              <tr className="border-b border-slate-800 text-slate-500 font-black uppercase tracking-wider text-[9px] pb-2">
                <th className="py-2.5">Backup ID</th>
                <th>Created Timestamp</th>
                <th>Package Size</th>
                <th>Serialized Records Count</th>
                <th className="text-right pr-2">Backup Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/40 text-slate-300">
              {backupRecords.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-slate-500 font-bold">
                    No backup snapshots logged in ecosystem yet! Click button above to initialize.
                  </td>
                </tr>
              ) : (
                backupRecords.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-900/20 transition-colors">
                    <td className="py-3 font-mono text-[10px] font-black text-slate-400 tracking-wider">
                      {log.id}
                    </td>
                    <td className="text-slate-300">
                      {new Date(log.timestamp).toLocaleString()}
                    </td>
                    <td className="font-mono text-[10.5px]">
                      {(log.sizeBytes / 1024).toFixed(2)} KB
                    </td>
                    <td className="text-slate-400 py-3">
                      {log.totalRecords ? (
                        <span className="font-bold text-indigo-400 bg-indigo-500/5 border border-indigo-500/10 px-2 py-0.5 rounded-md font-mono text-[10px]">
                          {log.totalRecords} Database Records
                        </span>
                      ) : (
                        `${log.licensesCount || 0} Lic • ${log.plansCount || 0} Plans • ${log.ticketsCount || 0} Tickets`
                      )}
                    </td>
                    <td className="text-right pr-2">
                      {log.id.startsWith('RS-') ? (
                        <span className="px-2.5 py-0.5 text-[8px] font-black uppercase tracking-wider bg-purple-500/10 text-purple-400 border border-purple-500/20 rounded-full">
                          Restored Successfully
                        </span>
                      ) : (
                        <span className="px-2.5 py-0.5 text-[8px] font-black uppercase tracking-wider bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full">
                          Downloaded & Saved
                        </span>
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
