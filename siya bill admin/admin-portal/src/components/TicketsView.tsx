import { RefreshCw, MessageSquare, Send, X } from 'lucide-react';

interface TicketReply {
  sender: string;
  senderName?: string;
  timestamp: string | number;
  message: string;
}

interface Ticket {
  id: string;
  category: string;
  description: string;
  status: string;
  priority: string;
  restaurant_code: string;
  app_user_id: string;
  created_at: string;
  updated_at: string;
  replies?: TicketReply[];
}

interface TicketsViewProps {
  tickets: Ticket[];
  selectedTicket: Ticket | null;
  ticketReplyText: string;
  ticketStatusFilter: string;
  ticketPriorityFilter: string;
  ticketsLoading: boolean;
  ticketsErrorMsg: string;
  setSelectedTicket: (ticket: Ticket | null) => void;
  setTicketReplyText: (v: string) => void;
  setTicketStatusFilter: (v: string) => void;
  setTicketPriorityFilter: (v: string) => void;
  handleReplyTicket: (ticketId: string) => void;
  handleUpdateTicketStatus: (ticketId: string, newStatus: string) => void;
  handleUnblockUserFromTicket: (userId: string, ticketId: string) => void;
  fetchAdminData: () => void;
}

export function TicketsView({
  tickets,
  selectedTicket,
  ticketReplyText,
  ticketStatusFilter,
  ticketPriorityFilter,
  ticketsLoading,
  ticketsErrorMsg,
  setSelectedTicket,
  setTicketReplyText,
  setTicketStatusFilter,
  setTicketPriorityFilter,
  handleReplyTicket,
  handleUpdateTicketStatus,
  handleUnblockUserFromTicket,
  fetchAdminData,
}: TicketsViewProps) {
  return (
    <div className="flex flex-col lg:flex-row gap-6 animate-in fade-in duration-200 slide-in-from-bottom-3 h-[calc(100vh-210px)] min-h-[480px]">

      {/* Left Column: Tickets Queue Feed */}
      <div className="w-full lg:w-[380px] bg-slate-900/30 border border-slate-800 rounded-3xl p-5 flex flex-col gap-4 overflow-hidden shrink-0 h-full">
        <div className="flex items-center justify-between border-b border-slate-800 pb-3">
          <div>
            <h3 className="font-extrabold text-sm text-white uppercase tracking-tight">Helpdesk Queue</h3>
            <p className="text-[10px] text-slate-400 font-semibold mt-0.5">Active customer support tickets</p>
          </div>
          <button
            onClick={() => fetchAdminData()}
            className="p-1.5 bg-slate-800 hover:bg-slate-750 border border-slate-700/50 rounded-lg text-slate-300 active:scale-95 transition-all"
            title="Refresh Tickets"
          >
            <RefreshCw size={12} className={ticketsLoading ? 'animate-spin' : ''} />
          </button>
        </div>

        {/* Filters Row */}
        <div className="grid grid-cols-2 gap-2">
          <div className="flex flex-col gap-1">
            <span className="text-[8px] font-black text-slate-500 uppercase tracking-widest">Filter Status</span>
            <select
              value={ticketStatusFilter}
              onChange={(e) => setTicketStatusFilter(e.target.value)}
              className="bg-slate-950 border border-slate-800 rounded-lg text-[10px] text-slate-300 font-black p-1.5 focus:outline-none cursor-pointer"
            >
              <option value="all">All Statuses</option>
              <option value="open">Open</option>
              <option value="in-progress">In Progress</option>
              <option value="resolved">Resolved</option>
            </select>
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[8px] font-black text-slate-500 uppercase tracking-widest">Filter Priority</span>
            <select
              value={ticketPriorityFilter}
              onChange={(e) => setTicketPriorityFilter(e.target.value)}
              className="bg-slate-950 border border-slate-800 rounded-lg text-[10px] text-slate-300 font-black p-1.5 focus:outline-none cursor-pointer"
            >
              <option value="all">All Priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>
        </div>

        {/* Tickets list container */}
        <div className="flex-1 overflow-y-auto pr-1 flex flex-col gap-2.5 scrollbar-thin">
          {ticketsLoading && tickets.length === 0 ? (
            <div className="flex items-center justify-center py-12 text-slate-650 font-bold text-[11px]">
              <RefreshCw size={14} className="animate-spin mr-1.5" /> Loading Tickets...
            </div>
          ) : ticketsErrorMsg ? (
            <div className="p-3.5 bg-red-950/20 border border-red-900/40 text-red-400 rounded-xl text-[10px] font-bold">
              {ticketsErrorMsg}
            </div>
          ) : (() => {
            const filtered = tickets.filter(t => {
              if (ticketStatusFilter !== 'all' && t.status !== ticketStatusFilter) return false;
              if (ticketPriorityFilter !== 'all' && t.priority !== ticketPriorityFilter) return false;
              return true;
            });

            if (filtered.length === 0) {
              return (
                <div className="text-center py-16 text-slate-600 font-bold text-[10.5px]">
                  No support tickets match active filters.
                </div>
              );
            }

            return filtered.map((ticket) => {
              const isSelected = selectedTicket && selectedTicket.id === ticket.id;

              return (
                <div
                  key={ticket.id}
                  onClick={() => {
                    setSelectedTicket(ticket);
                    setTicketReplyText('');
                  }}
                  className={`p-3.5 rounded-2xl border transition-all cursor-pointer text-left relative overflow-hidden group ${
                    isSelected
                      ? 'bg-indigo-950/20 border-indigo-500/40'
                      : 'bg-slate-900/20 border-slate-800 hover:border-slate-700/60'
                  }`}
                >
                  <div className="absolute top-0 right-0 w-1 h-full bg-indigo-500 opacity-0 group-hover:opacity-100 transition-opacity"></div>
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-[10px] font-black text-slate-200 uppercase tracking-wide truncate max-w-[150px]">
                      {ticket.category}
                    </span>
                    <div className="flex items-center gap-1.5 shrink-0">
                      <span className={`px-1.5 py-0.5 rounded text-[7.5px] font-black uppercase tracking-wider ${
                        ticket.priority === 'high' ? 'bg-red-500/10 text-red-400 border border-red-500/20' :
                        ticket.priority === 'medium' ? 'bg-orange-500/10 text-orange-400 border border-orange-500/20' :
                        'bg-slate-850 text-slate-400 border border-slate-800'
                      }`}>
                        {ticket.priority}
                      </span>
                      <span className={`px-1.5 py-0.5 rounded text-[7.5px] font-black uppercase tracking-wider ${
                        ticket.status === 'open' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' :
                        ticket.status === 'in-progress' ? 'bg-orange-500/10 text-orange-400 border border-orange-500/20' :
                        'bg-slate-850 text-slate-500 border border-slate-800'
                      }`}>
                        {ticket.status}
                      </span>
                    </div>
                  </div>

                  <p className="text-[11px] font-semibold text-slate-300 mt-1.5 line-clamp-1 truncate max-w-[320px]">
                    {ticket.description}
                  </p>

                  <div className="flex items-center justify-between mt-2.5 pt-2 border-t border-slate-800/40 text-[9px] text-slate-505 font-bold">
                    <span>Code: {ticket.restaurant_code}</span>
                    <span>{new Date(ticket.updated_at || ticket.created_at).toLocaleDateString()}</span>
                  </div>
                </div>
              );
            });
          })()}
        </div>
      </div>

      {/* Right Column: Ticket Conversation Thread Panel */}
      <div className="flex-1 bg-slate-900/30 border border-slate-800 rounded-3xl flex flex-col overflow-hidden h-full">
        {selectedTicket ? (
          <div className="flex flex-col h-full overflow-hidden">
            {/* Active Ticket Header details */}
            <div className="px-6 py-4 border-b border-slate-800/80 bg-slate-900/20 flex flex-col sm:flex-row sm:items-center justify-between gap-4 shrink-0">
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-[10px] bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 px-2 py-0.5 rounded-full font-black uppercase tracking-wider">
                    {selectedTicket.category}
                  </span>
                  <span className="text-[10px] text-slate-405 font-mono tracking-widest font-bold uppercase">
                    ID: {selectedTicket.id.substring(0, 8).toUpperCase()}
                  </span>
                </div>
                <h4 className="text-sm font-black text-white mt-1 uppercase tracking-tight">
                  Restaurant Code: {selectedTicket.restaurant_code}
                </h4>
              </div>

              {/* Ticket Action updates */}
              <div className="flex items-center gap-2">
                {selectedTicket.category === 'unblock' && selectedTicket.status !== 'resolved' && (
                  <button
                    onClick={() => handleUnblockUserFromTicket(selectedTicket.app_user_id, selectedTicket.id)}
                    className="px-3 py-1.5 bg-red-650 hover:bg-red-750 text-white rounded-lg text-[9.5px] font-black uppercase tracking-wider transition-all active:scale-95 flex items-center gap-1 shadow-md"
                  >
                    🔓 Unblock User
                  </button>
                )}
                {selectedTicket.status !== 'resolved' ? (
                  <button
                    onClick={() => handleUpdateTicketStatus(selectedTicket.id, 'resolved')}
                    className="px-3 py-1.5 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/20 rounded-lg text-[9.5px] font-black uppercase tracking-wider transition-all active:scale-95"
                  >
                    Mark Resolved
                  </button>
                ) : (
                  <button
                    onClick={() => handleUpdateTicketStatus(selectedTicket.id, 'open')}
                    className="px-3 py-1.5 bg-indigo-500/10 hover:bg-indigo-500/20 text-indigo-400 border border-indigo-500/20 rounded-lg text-[9.5px] font-black uppercase tracking-wider transition-all active:scale-95"
                  >
                    Reopen Ticket
                  </button>
                )}
                <button
                  onClick={() => setSelectedTicket(null)}
                  className="p-1.5 bg-slate-800 hover:bg-slate-750 rounded-lg text-slate-400 transition-colors"
                  title="Close panel"
                >
                  <X size={14} />
                </button>
              </div>
            </div>

            {/* Chat dialog thread area */}
            <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-4 scrollbar-thin">
              {/* Customer Initial Issue Card */}
              <div className="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl flex flex-col gap-2 relative">
                <div className="flex items-center justify-between text-[10px] font-bold text-slate-400">
                  <span>CLIENT COMPLAINT / PROBLEM</span>
                  <span>{new Date(selectedTicket.created_at).toLocaleString()}</span>
                </div>
                <p className="text-xs font-semibold text-slate-200 leading-relaxed break-words whitespace-pre-wrap">
                  {selectedTicket.description}
                </p>
              </div>

              {/* Conversation thread loop */}
              {(selectedTicket.replies || []).map((reply: TicketReply, index: number) => {
                const isAdmin = reply.sender === 'admin';
                return (
                  <div
                    key={index}
                    className={`flex flex-col gap-1 max-w-[75%] ${isAdmin ? 'self-end items-end' : 'self-start items-start'}`}
                  >
                    <div className="flex items-center gap-1.5 text-[8.5px] font-black text-slate-500 uppercase tracking-widest">
                      <span>{reply.senderName || (isAdmin ? 'Admin' : 'Client')}</span>
                      <span>•</span>
                      <span>{new Date(reply.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>

                    <div className={`p-3 rounded-2xl text-xs font-semibold leading-relaxed break-words ${
                      isAdmin
                        ? 'bg-gradient-to-br from-indigo-500 to-indigo-600 text-white rounded-tr-none shadow-md shadow-indigo-500/5'
                        : 'bg-slate-800/60 text-slate-200 border border-slate-750 rounded-tl-none'
                    }`}>
                      {reply.message}
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Chat reply submission footer */}
            <form
              onSubmit={(e) => {
                e.preventDefault();
                handleReplyTicket(selectedTicket.id);
              }}
              className="p-4 border-t border-slate-800/80 bg-slate-900/20 flex gap-3 items-end shrink-0"
            >
              <div className="flex-1 relative">
                <textarea
                  rows={2}
                  value={ticketReplyText}
                  onChange={(e) => setTicketReplyText(e.target.value)}
                  placeholder="Type your official helpdesk reply message..."
                  className="w-full p-3 bg-slate-950 border border-slate-800 focus:border-indigo-500 focus:outline-none rounded-xl text-xs font-bold text-white placeholder-slate-700 font-sans resize-none"
                />
              </div>
              <button
                type="submit"
                disabled={!ticketReplyText.trim() || ticketsLoading}
                className="p-3.5 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-indigo-500/10 active:scale-95 transition-all disabled:opacity-40 shrink-0"
                title="Send Reply"
              >
                <Send size={15} />
              </button>
            </form>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center flex-1 text-center p-8 text-slate-500 font-bold text-xs gap-3">
            <MessageSquare size={32} className="text-slate-650" />
            <div>
              <span className="block text-slate-400 font-black text-sm mb-1">Select a Support Ticket</span>
              Helpdesk queue list me se kisi active ticket par click karein conversation dekhne aur reply karne ke liye.
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
