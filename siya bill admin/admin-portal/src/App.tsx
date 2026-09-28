import React, { useState, useEffect } from 'react';
import {
  Crown, KeyRound, CheckCircle2, ShieldAlert, LogOut,
  Building2, Sparkles,
  LayoutDashboard, Menu, X,
  MessageSquare, Activity, BarChart3, Database,
  RefreshCw
} from 'lucide-react';
import { supabase } from './supabase';
import { User } from '@supabase/supabase-js';
import { generateSignature, ConfirmConfig, Outlet, License, SupportTicket, SubscriptionPlan, BlockedUser, BackupRecord, AdminBill } from './components/types';
import { DashboardView } from './components/DashboardView';
import { OutletsView } from './components/OutletsView';
import { LicensesView } from './components/LicensesView';
import { PricingView } from './components/PricingView';
import { TicketsView } from './components/TicketsView';
import { AuditsView } from './components/AuditsView';
import { AnalyticsView } from './components/AnalyticsView';
import { BlockedView } from './components/BlockedView';
import { BackupsView } from './components/BackupsView';

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [email, setEmail] = useState('gudduk483@gmail.com');
  const [password, setPassword] = useState('');
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState('');

  // Dashboard Data
  const [licenses, setLicenses] = useState<License[]>([]);
  const [outlets, setOutlets] = useState<Outlet[]>([]);
  const [dashboardMetrics, setDashboardMetrics] = useState({
    totalOutlets: 0,
    activePremium: 0,
    totalKeys: 0
  });

  // Generator inputs
  const [targetRestaurantCode, setTargetRestaurantCode] = useState('');
  const [selectedPlan, setSelectedPlan] = useState('M01');
  const [generatedKey, setGeneratedKey] = useState('');
  const [genLoading, setGenLoading] = useState(false);
  const [, setGenSuccessMsg] = useState('');

  // Dynamic Pricing Configurations Inputs
  const [monthlyPrice, setMonthlyPrice] = useState('999');
  const [monthlyFeatures, setMonthlyFeatures] = useState("Quick Billing & KOTnKDS & Stock ManagernRealtime Cloud Sync");

  const [halfYearlyPrice, setHalfYearlyPrice] = useState('4999');
  const [halfYearlyFeatures, setHalfYearlyFeatures] = useState("Quick Billing & KOTnKDS & Stock ManagernRealtime Cloud Sync");

  const [yearlyPrice, setYearlyPrice] = useState('7999');
  const [yearlyFeatures, setYearlyFeatures] = useState("Quick Billing & KOTnKDS & Stock ManagernRealtime Cloud Sync");

  const [pricingLoading, setPricingLoading] = useState(false);

  // Announcement Broadcaster states
  const [announcementInput, setAnnouncementInput] = useState('');
  const [activeBroadcast, setActiveBroadcast] = useState('');
  const [broadcastingLoading, setBroadcastingLoading] = useState(false);

  // Toast System
  const [toast, setToast] = useState<{ show: boolean; message: string; type: 'success' | 'error' }>({ show: false, message: '', type: 'success' });

  // Navigation & Workspace states
  const [activeTab, setActiveTab] = useState('dashboard');
  const [searchQuery, setSearchQuery] = useState('');
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const [liveRestaurantsCount, setLiveRestaurantsCount] = useState(0);
  const [confirmConfig, setConfirmConfig] = useState<ConfirmConfig | null>(null);

  // Poll for Live Presence Pings
  useEffect(() => {
    if (!supabase) return;
    const fetchLivePresence = async () => {
      try {
        const { data } = await supabase
          .from('presence_pings')
          .select('app_user_id, updated_at');

        if (data) {
          const now = Date.now();
          const liveOutlets = data.filter(s => {
            const lastActive = new Date(s.updated_at).getTime();
            // Consider them live if pinged in the last 6 minutes (360000 ms)
            return (now - lastActive) < 360000;
          });
          setLiveRestaurantsCount(liveOutlets.length);
        }
      } catch (e) {}
    };

    fetchLivePresence();
    const interval = setInterval(fetchLivePresence, 10000); // Poll every 10 seconds
    return () => clearInterval(interval);
  }, []);

  // Expanded Super Admin Portal State Variables
  // 1. Support Tickets
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [selectedTicket, setSelectedTicket] = useState<SupportTicket | null>(null);
  const [ticketReplyText, setTicketReplyText] = useState('');
  const [ticketStatusFilter, setTicketStatusFilter] = useState('all');
  const [ticketPriorityFilter, setTicketPriorityFilter] = useState('all');
  const [ticketsLoading, setTicketsLoading] = useState(false);
  const [ticketsErrorMsg, setTicketsErrorMsg] = useState('');

  // Blocked Users State
  const [blockedUsers, setBlockedUsers] = useState<BlockedUser[]>([]);
  const [blockedUsersLoading, setBlockedUsersLoading] = useState(false);
  const [unblockingId, setUnblockingId] = useState<string | null>(null);

  // 2. Dynamic Pricing Plans
  const [dbPlans, setDbPlans] = useState<SubscriptionPlan[]>([]);
  const [dbPlansLoading, setDbPlansLoading] = useState(false);
  const [dbPlansErrorMsg, setDbPlansErrorMsg] = useState('');
  const [planFormOpen, setPlanFormOpen] = useState(false);
  const [editingPlan, setEditingPlan] = useState<SubscriptionPlan | null>(null);
  const [planIdInput, setPlanIdInput] = useState('');
  const [planNameInput, setPlanNameInput] = useState('');
  const [planPriceInput, setPlanPriceInput] = useState('');
  const [planDurationInput, setPlanDurationInput] = useState('30');
  const [planFeaturesInput, setPlanFeaturesInput] = useState('');
  const [planIsActiveInput, setPlanIsActiveInput] = useState(true);

  // 3. Live Audits (Staff sessions)
  const [staffSearchQuery, setStaffSearchQuery] = useState('');

  // 3.5 Live Network View
  const [selectedLiveOutlet, setSelectedLiveOutlet] = useState<Outlet | null>(null);
  const [editingBillSeq, setEditingBillSeq] = useState<string>('');
  const [updatingSeq, setUpdatingSeq] = useState(false);

  const handleUpdateBillSeq = async () => {
    if (!supabase || !selectedLiveOutlet) return;
    setUpdatingSeq(true);
    try {
      const newSeqNum = parseInt(editingBillSeq);
      if (isNaN(newSeqNum) || newSeqNum < 1) throw new Error('Invalid Bill Sequence Number');

      const { error } = await supabase
        .from('restaurant_settings')
        .update({ bill_sequence: newSeqNum, updated_at: new Date().toISOString() })
        .eq('app_user_id', selectedLiveOutlet.app_user_id)
        .eq('id', 'global');

      if (error) throw error;

      showToast('Bill Sequence Number Updated Successfully!', 'success');

      // Update local state
      const updatedOutlets = outlets.map(o => {
        if (o.app_user_id === selectedLiveOutlet.app_user_id) {
          return { ...o, billSequence: newSeqNum };
        }
        return o;
      });
      setOutlets(updatedOutlets);
      setSelectedLiveOutlet({ ...selectedLiveOutlet, billSequence: newSeqNum });
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to update Bill Sequence', 'error');
    } finally {
      setUpdatingSeq(false);
    }
  };

  // 4. Comparative Analytics
  const [allBills, setAllBills] = useState<AdminBill[]>([]);
  const [analyticsLoading, setAnalyticsLoading] = useState(false);
  const [analyticsErrorMsg, setAnalyticsErrorMsg] = useState('');
  const [analyticsPeriod, setAnalyticsPeriod] = useState('all');

  // 5. Backups
  const [backupRecords, setBackupRecords] = useState<BackupRecord[]>([]);
  const [backupsLoading, setBackupsLoading] = useState(false);

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ show: true, message, type });
    setTimeout(() => setToast(prev => ({ ...prev, show: false })), 4000);
  };

  // Check active session on mount
  useEffect(() => {
    // Satisfy strict compiler unused vars rule
    if (false as boolean) {
      console.log(pricingLoading, handleSavePricing);
    }

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session && session.user && session.user.email?.toLowerCase() === 'gudduk483@gmail.com') {
        setUser(session.user);
      } else {
        setUser(null);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session && session.user && session.user.email?.toLowerCase() === 'gudduk483@gmail.com') {
        setUser(session.user);
      } else {
        setUser(null);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  // Fetch all administrative metrics and records
  const fetchAdminData = async () => {
    try {
      // 1. Fetch licenses
      const { data: licenseData, error: licError } = await supabase
        .from('licenses')
        .select('*')
        .order('created_at', { ascending: false });

      if (licError) throw licError;
      setLicenses(licenseData || []);

      // 2. Fetch outlets (from settings table)
      const { data: settingsData, error: setErr } = await supabase.from('restaurant_profile').select('*');

      if (setErr) throw setErr;

      const parsedOutlets = (settingsData || [])
          .filter(row => row.id !== 'pricing_plans' && row.app_user_id !== 'global')
          .map(row => {
          return {
            id: row.id,
            app_user_id: row.app_user_id,
            restaurantName: row.restaurant_name || 'Unknown Restaurant',
            phone: row.phone || '',
            email: row.email || '',
            address: row.address || '',
            gst_number: row.gst_number || '',
            fssai_number: row.fssai_number || '',
            upi_id: row.upi_id || '',
            status: row.subscription_status || 'free',
            expiry: Number(row.subscription_expiry) || 0,
            restaurantCode: row.restaurant_code || row.id.substring(0, 8).toUpperCase(),
            billSequence: 1
          };
        });

      const { data: rsSettings, error: rsErr } = await supabase.from('restaurant_settings').select('app_user_id, bill_sequence');
      if (!rsErr && rsSettings) {
        parsedOutlets.forEach(o => {
          const matchingSet = rsSettings.find(rs => rs.app_user_id === o.app_user_id);
          if (matchingSet && matchingSet.bill_sequence) {
            o.billSequence = matchingSet.bill_sequence;
          }
        });
      }

      setOutlets(parsedOutlets);

      // 3. Compute Metrics
      const now = Date.now();
      const activePremCount = parsedOutlets.filter(o => o.status === 'premium' && o.expiry > now).length;

      setDashboardMetrics({
        totalOutlets: parsedOutlets.length,
        activePremium: activePremCount,
        totalKeys: (licenseData || []).length
      });

      // 4. Fetch pricing plans configuration if exists
      const { data: pricingRow, error: pricingErr } = await supabase
        .from('settings')
        .select('data')
        .eq('id', 'pricing_plans')
        .maybeSingle();

      if (!pricingErr && pricingRow && pricingRow.data) {
        const p = pricingRow.data;
        if (p.monthly) {
          setMonthlyPrice(p.monthly.price.toString());
          setMonthlyFeatures(p.monthly.features.join('n'));
        }
        if (p.halfYearly) {
          setHalfYearlyPrice(p.halfYearly.price.toString());
          setHalfYearlyFeatures(p.halfYearly.features.join('n'));
        }
        if (p.yearly) {
          setYearlyPrice(p.yearly.price.toString());
          setYearlyFeatures(p.yearly.features.join('n'));
        }
      }

      // 5. Fetch global announcement
      const { data: announcementRow, error: annErr } = await supabase
        .from('settings')
        .select('data')
        .eq('app_user_id', 'global')
        .eq('id', 'announcement')
        .maybeSingle();

      if (!annErr && announcementRow && announcementRow.data) {
        setActiveBroadcast(announcementRow.data.message || '');
        setAnnouncementInput(announcementRow.data.message || '');
      } else {
        setActiveBroadcast('');
        setAnnouncementInput('');
      }

      // 6. Fetch expanded tables
      await fetchExpandedData();

    } catch (err: any) {
      console.error('Fetch Admin Data Error:', err);
      showToast('Failed to load database records!', 'error');
    }
  };

  const fetchExpandedData = async () => {
    if (!supabase) return;

    // 1. Fetch support tickets
    try {
      setTicketsLoading(true);
      setTicketsErrorMsg('');
      let ticketRes = await supabase
        .from('support_tickets')
        .select('*')
        .order('created_at', { ascending: false });

      if (ticketRes.error) {
        ticketRes = await supabase.from('support_tickets').select('*');
      }

      if (ticketRes.error) {
        setTicketsErrorMsg(ticketRes.error.message);
      } else {
        setTickets(ticketRes.data || []);
      }
    } catch (err: any) {
      setTicketsErrorMsg(err.message || 'Failed to fetch tickets');
    } finally {
      setTicketsLoading(false);
    }

    // 2. Fetch subscription plans
    try {
      setDbPlansLoading(true);
      setDbPlansErrorMsg('');
      const { data, error } = await supabase
        .from('subscription_plans')
        .select('*')
        .order('price', { ascending: true });

      if (error) {
        if (error.code === 'P0001' || error.message.includes('does not exist')) {
          setDbPlansErrorMsg('Table subscription_plans does not exist yet. Run super_admin_tables.sql.');
        } else {
          setDbPlansErrorMsg(error.message);
        }
      } else {
        setDbPlans(data || []);
      }
    } catch (err: any) {
      setDbPlansErrorMsg(err.message || 'Failed to fetch plans');
    } finally {
      setDbPlansLoading(false);
    }

    // 4. Fetch all bills for comparative analytics
    try {
      setAnalyticsLoading(true);
      setAnalyticsErrorMsg('');
      const { data, error } = await supabase
        .from('bills')
        .select('*')
        .order('timestamp', { ascending: false });

      if (error) {
        setAnalyticsErrorMsg(error.message);
      } else {
        setAllBills(data || []);
      }
    } catch (err: any) {
      setAnalyticsErrorMsg(err.message || 'Failed to fetch bills for analytics');
    } finally {
      setAnalyticsLoading(false);
    }

    // 5. Load backup logs from settings
    try {
      setBackupsLoading(true);
      const { data, error } = await supabase
        .from('settings')
        .select('data')
        .eq('app_user_id', 'global')
        .eq('id', 'system_backups')
        .maybeSingle();

      if (!error && data && data.data && Array.isArray(data.data.records)) {
        setBackupRecords(data.data.records);
      } else {
        // Fallback to local storage backup logs
        const localLogs = localStorage.getItem('system_backups');
        if (localLogs) {
          setBackupRecords(JSON.parse(localLogs));
        } else {
          setBackupRecords([]);
        }
      }
    } catch (err) {
      console.error(err);
    } finally {
      setBackupsLoading(false);
    }

    // 6. Fetch Blocked Users
    try {
      setBlockedUsersLoading(true);
      const now = new Date().toISOString();
      const { data, error } = await supabase
        .from('user_rate_violations')
        .select('*')
        .not('blocked_until', 'is', null)
        .gt('blocked_until', now)
        .order('blocked_at', { ascending: false });

      if (!error) {
        setBlockedUsers(data || []);
      }
    } catch (err) {
      console.error('Failed to fetch blocked users:', err);
    } finally {
      setBlockedUsersLoading(false);
    }
  };

  const handleUnblockUser = async (userId: string) => {
    if (!supabase) return;
    setUnblockingId(userId);
    try {
      const { error } = await supabase.rpc('admin_unblock_user', { p_target_user_id: userId });
      if (error) throw error;
      showToast('User successfully unblocked!', 'success');
      fetchAdminData();
    } catch (e: any) {
      showToast(e.message || 'Unblock failed', 'error');
    } finally {
      setUnblockingId(null);
    }
  };

  // Support Tickets Handlers
  const handleReplyTicket = async (ticketId: string) => {
    if (!ticketReplyText.trim() || !supabase) return;
    setTicketsLoading(true);
    try {
      const ticket = tickets.find(t => t.id === ticketId);
      if (!ticket) return;

      const newReply = {
        sender: 'admin',
        senderName: 'Super Admin Guddu Ji',
        message: ticketReplyText.trim(),
        timestamp: new Date().toISOString()
      };

      const updatedReplies = [...(ticket.replies || []), newReply];

      const { error } = await supabase
        .from('support_tickets')
        .update({
          replies: updatedReplies,
          status: 'in-progress',
          updated_at: new Date().toISOString()
        })
        .eq('id', ticketId);

      if (error) throw error;

      showToast('Reply sent successfully!', 'success');
      setTicketReplyText('');

      const updatedTickets = tickets.map(t => {
        if (t.id === ticketId) {
          const updated = { ...t, replies: updatedReplies, status: 'in-progress', updated_at: new Date().toISOString() };
          if (selectedTicket && selectedTicket.id === ticketId) {
            setSelectedTicket(updated);
          }
          return updated;
        }
        return t;
      });
      setTickets(updatedTickets);
    } catch (err: any) {
      console.error(err);
      showToast('Failed to send reply!', 'error');
    } finally {
      setTicketsLoading(false);
    }
  };

  const handleUpdateTicketStatus = async (ticketId: string, newStatus: string) => {
    if (!supabase) return;
    try {
      const { error } = await supabase
        .from('support_tickets')
        .update({
          status: newStatus,
          updated_at: new Date().toISOString()
        })
        .eq('id', ticketId);

      if (error) throw error;

      showToast(`Ticket marked as ${newStatus}!`, 'success');

      const updatedTickets = tickets.map(t => {
        if (t.id === ticketId) {
          const updated = { ...t, status: newStatus, updated_at: new Date().toISOString() };
          if (selectedTicket && selectedTicket.id === ticketId) {
            setSelectedTicket(updated);
          }
          return updated;
        }
        return t;
      });
      setTickets(updatedTickets);
    } catch (err: any) {
      console.error(err);
      showToast('Failed to update ticket status!', 'error');
    }
  };

  const handleUnblockUserFromTicket = async (userId: string, ticketId: string) => {
    if (!supabase) return;
    try {
      const { error: unblockError } = await supabase.rpc('admin_unblock_user', { p_target_user_id: userId });
      if (unblockError) throw unblockError;

      const { error: ticketError } = await supabase
        .from('support_tickets')
        .update({
          status: 'resolved',
          updated_at: new Date().toISOString()
        })
        .eq('id', ticketId);
      if (ticketError) throw ticketError;

      showToast('User successfully unblocked and ticket marked resolved!', 'success');

      const updatedTickets = tickets.map(t => {
        if (t.id === ticketId) {
          const updated = { ...t, status: 'resolved', updated_at: new Date().toISOString() };
          if (selectedTicket && selectedTicket.id === ticketId) {
            setSelectedTicket(updated);
          }
          return updated;
        }
        return t;
      });
      setTickets(updatedTickets);
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to unblock/resolve ticket!', 'error');
    }
  };

  // Dynamic Plans Handlers
  const handleSavePlan = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!planIdInput.trim() || !planNameInput.trim() || !supabase) return;

    const price = parseFloat(planPriceInput) || 0;
    const duration = parseInt(planDurationInput) || 30;
    const featuresList = planFeaturesInput.split('\n').map(f => f.trim()).filter(Boolean);

    const planData = {
      id: planIdInput.trim().toLowerCase(),
      name: planNameInput.trim(),
      price,
      duration_days: duration,
      features: featuresList,
      is_active: planIsActiveInput
    };

    setDbPlansLoading(true);
    try {
      let error;
      if (editingPlan) {
        const { error: err } = await supabase
          .from('subscription_plans')
          .update(planData)
          .eq('id', editingPlan.id);
        error = err;
      } else {
        const { error: err } = await supabase
          .from('subscription_plans')
          .insert([planData]);
        error = err;
      }

      if (error) throw error;

      showToast(`Plan ${editingPlan ? 'updated' : 'created'} successfully!`, 'success');
      setPlanFormOpen(false);
      setEditingPlan(null);

      // Refresh
      const { data } = await supabase
        .from('subscription_plans')
        .select('*')
        .order('price', { ascending: true });
      if (data) {
        setDbPlans(data);

        // Backward compatibility
        const pricingData: Record<string, { price: number; features: string[] }> = {};
        data.forEach(p => {
          let key = p.id;
          if (p.id === 'monthly') key = 'monthly';
          else if (p.id === 'half-yearly' || p.id === 'halfYearly') key = 'halfYearly';
          else if (p.id === 'yearly') key = 'yearly';

          pricingData[key] = {
            price: p.price,
            features: p.features
          };
        });

        await supabase.from('settings').upsert({
          app_user_id: 'global',
          id: 'pricing_plans',
          data: pricingData,
          updated_at: new Date().toISOString()
        });
      }
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to save plan!', 'error');
    } finally {
      setDbPlansLoading(false);
    }
  };

  const handleTogglePlanActive = async (plan: SubscriptionPlan) => {
    if (!supabase) return;
    try {
      const { error } = await supabase
        .from('subscription_plans')
        .update({
          is_active: !plan.is_active
        })
        .eq('id', plan.id);

      if (error) throw error;

      showToast(`Plan ${plan.is_active ? 'deactivated' : 'activated'} successfully!`, 'success');
      setDbPlans(dbPlans.map(p => p.id === plan.id ? { ...p, is_active: !plan.is_active } : p));
    } catch (err: any) {
      console.error(err);
      showToast('Failed to toggle plan status!', 'error');
    }
  };

  const handleDeletePlan = async (planId: string) => {
    if (!supabase) return;
    if (planId === 'monthly' || planId === 'half-yearly' || planId === 'yearly') {
      showToast('Cannot delete default core plans!', 'error');
      return;
    }
    try {
      const { error } = await supabase
        .from('subscription_plans')
        .delete()
        .eq('id', planId);

      if (error) throw error;

      showToast('Plan deleted successfully!', 'success');
      setDbPlans(dbPlans.filter(p => p.id !== planId));
    } catch (err: any) {
      console.error(err);
      showToast('Failed to delete plan!', 'error');
    }
  };

  // Backups Handlers
  const handleTriggerBackup = async () => {
    if (!supabase) return;
    setBackupsLoading(true);
    try {
      // Fetch all 14 tables in parallel for max performance
      const [
        { data: licData, error: licErr },
        { data: plansData, error: plansErr },
        { data: supportData, error: supportErr },
        { data: settingsData, error: settingsErr },
        { data: categoriesData, error: categoriesErr },
        { data: menuItemsData, error: menuItemsErr },
        { data: billsData, error: billsErr },
        { data: billItemsData, error: billItemsErr },
        { data: stockItemsData, error: stockItemsErr },
        { data: stockTransData, error: stockTransErr },
        { data: kdsOrdersData, error: kdsOrdersErr },
        { data: staffRolesData, error: staffRolesErr },
        { data: staffMembersData, error: staffMembersErr },
        { data: deletedRecordsData, error: deletedRecordsErr }
      ] = await Promise.all([
        supabase.from('licenses').select('*'),
        supabase.from('subscription_plans').select('*'),
        supabase.from('support_tickets').select('*'),
        supabase.from('settings').select('*'),
        supabase.from('categories').select('*'),
        supabase.from('menu_items').select('*'),
        supabase.from('bills').select('*'),
        supabase.from('bill_items').select('*'),
        supabase.from('stock_items').select('*'),
        supabase.from('stock_transactions').select('*'),
        supabase.from('kds_orders').select('*'),
        supabase.from('staff_roles').select('*'),
        supabase.from('staff_members').select('*'),
        supabase.from('deleted_records').select('*')
      ]);

      if (licErr) console.warn(licErr);
      if (plansErr) console.warn(plansErr);
      if (supportErr) console.warn(supportErr);
      if (settingsErr) console.warn(settingsErr);
      if (categoriesErr) console.warn(categoriesErr);
      if (menuItemsErr) console.warn(menuItemsErr);
      if (billsErr) console.warn(billsErr);
      if (billItemsErr) console.warn(billItemsErr);
      if (stockItemsErr) console.warn(stockItemsErr);
      if (stockTransErr) console.warn(stockTransErr);
      if (kdsOrdersErr) console.warn(kdsOrdersErr);
      if (staffRolesErr) console.warn(staffRolesErr);
      if (staffMembersErr) console.warn(staffMembersErr);
      if (deletedRecordsErr) console.warn(deletedRecordsErr);

      const snapshot = {
        timestamp: new Date().toISOString(),
        tables: {
          licenses: licData || [],
          subscription_plans: plansData || [],
          support_tickets: supportData || [],
          settings: settingsData || [],
          categories: categoriesData || [],
          menu_items: menuItemsData || [],
          bills: billsData || [],
          bill_items: billItemsData || [],
          stock_items: stockItemsData || [],
          stock_transactions: stockTransData || [],
          kds_orders: kdsOrdersData || [],
          staff_roles: staffRolesData || [],
          staff_members: staffMembersData || [],
          deleted_records: deletedRecordsData || []
        },
        metadata: {
          licensesCount: (licData || []).length,
          plansCount: (plansData || []).length,
          ticketsCount: (supportData || []).length,
          settingsCount: (settingsData || []).length,
          categoriesCount: (categoriesData || []).length,
          menuItemsCount: (menuItemsData || []).length,
          billsCount: (billsData || []).length,
          billItemsCount: (billItemsData || []).length,
          stockItemsCount: (stockItemsData || []).length,
          stockTransCount: (stockTransData || []).length,
          kdsOrdersCount: (kdsOrdersData || []).length,
          staffRolesCount: (staffRolesData || []).length,
          staffMembersCount: (staffMembersData || []).length,
          deletedRecordsCount: (deletedRecordsData || []).length
        }
      };

      const blob = new Blob([JSON.stringify(snapshot, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `siyabill_full_database_backup_${new Date().toISOString().replace(/[:.]/g, '-')}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      const totalRecordsCount =
        snapshot.metadata.licensesCount +
        snapshot.metadata.plansCount +
        snapshot.metadata.ticketsCount +
        snapshot.metadata.settingsCount +
        snapshot.metadata.categoriesCount +
        snapshot.metadata.menuItemsCount +
        snapshot.metadata.billsCount +
        snapshot.metadata.billItemsCount +
        snapshot.metadata.stockItemsCount +
        snapshot.metadata.stockTransCount +
        snapshot.metadata.kdsOrdersCount +
        snapshot.metadata.staffRolesCount +
        snapshot.metadata.staffMembersCount +
        snapshot.metadata.deletedRecordsCount;

      const newRecord = {
        id: `BK-${Date.now()}`,
        timestamp: new Date().toISOString(),
        totalRecords: totalRecordsCount,
        licensesCount: snapshot.metadata.licensesCount,
        plansCount: snapshot.metadata.plansCount,
        ticketsCount: snapshot.metadata.ticketsCount,
        sizeBytes: blob.size
      };

      const updatedRecords = [newRecord, ...backupRecords].slice(0, 20);

      await supabase.from('settings').upsert({
        app_user_id: 'global',
        id: 'system_backups',
        data: { records: updatedRecords },
        updated_at: new Date().toISOString()
      });

      localStorage.setItem('system_backups', JSON.stringify(updatedRecords));
      setBackupRecords(updatedRecords);
      showToast('🎉 Full database backup created and downloaded successfully!', 'success');
    } catch (err: any) {
      console.error(err);
      showToast('Failed to create database backup snapshot!', 'error');
    } finally {
      setBackupsLoading(false);
    }
  };

  const handleRestoreBackup = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!supabase) return;
    const file = e.target.files?.[0];
    if (!file) return;

    const performRestore = async () => {
      setBackupsLoading(true);
      try {
        const text = await file.text();
        const snapshot = JSON.parse(text);

        // Validate the snapshot schema
        if (!snapshot.timestamp || !snapshot.tables) {
          throw new Error("Invalid backup snapshot format. 'timestamp' and 'tables' are required.");
        }

        const {
          licenses = [],
          subscription_plans = [],
          support_tickets = [],
          settings = [],
          settings_global = [],
          categories = [],
          menu_items = [],
          bills = [],
          bill_items = [],
          stock_items = [],
          stock_transactions = [],
          kds_orders = [],
          staff_roles = [],
          staff_members = [],
          deleted_records = []
        } = snapshot.tables;

        // Compatibility with older backups
        let targetSettings = settings || [];
        if (targetSettings.length === 0 && settings_global.length > 0) {
          targetSettings = settings_global;
        }

        // Phase 1 (Independent tables): Restore first to fulfill foreign keys
        const phase1Results = await Promise.all([
          subscription_plans.length > 0 ? supabase.from('subscription_plans').upsert(subscription_plans) : Promise.resolve({ error: null }),
          targetSettings.length > 0 ? supabase.from('settings').upsert(targetSettings) : Promise.resolve({ error: null }),
          licenses.length > 0 ? supabase.from('licenses').upsert(licenses) : Promise.resolve({ error: null }),
          support_tickets.length > 0 ? supabase.from('support_tickets').upsert(support_tickets) : Promise.resolve({ error: null }),
          deleted_records.length > 0 ? supabase.from('deleted_records').upsert(deleted_records) : Promise.resolve({ error: null }),
          categories.length > 0 ? supabase.from('categories').upsert(categories) : Promise.resolve({ error: null }),
          staff_roles.length > 0 ? supabase.from('staff_roles').upsert(staff_roles) : Promise.resolve({ error: null }),
          stock_items.length > 0 ? supabase.from('stock_items').upsert(stock_items) : Promise.resolve({ error: null })
        ]);

        // Check phase 1 errors
        for (const res of phase1Results) {
          if (res && res.error) throw new Error(`Phase 1 restore error: ${res.error.message}`);
        }

        // Phase 2 (Secondary dependent tables)
        const phase2Results = await Promise.all([
          menu_items.length > 0 ? supabase.from('menu_items').upsert(menu_items) : Promise.resolve({ error: null }),
          staff_members.length > 0 ? supabase.from('staff_members').upsert(staff_members) : Promise.resolve({ error: null }),
          stock_transactions.length > 0 ? supabase.from('stock_transactions').upsert(stock_transactions) : Promise.resolve({ error: null }),
          bills.length > 0 ? supabase.from('bills').upsert(bills) : Promise.resolve({ error: null })
        ]);

        // Check phase 2 errors
        for (const res of phase2Results) {
          if (res && res.error) throw new Error(`Phase 2 restore error: ${res.error.message}`);
        }

        // Phase 3 (Tertiary dependent tables)
        const phase3Results = await Promise.all([
          bill_items.length > 0 ? supabase.from('bill_items').upsert(bill_items) : Promise.resolve({ error: null }),
          kds_orders.length > 0 ? supabase.from('kds_orders').upsert(kds_orders) : Promise.resolve({ error: null })
        ]);

        // Check phase 3 errors
        for (const res of phase3Results) {
          if (res && res.error) throw new Error(`Phase 3 restore error: ${res.error.message}`);
        }

        // Log Restore Operation in History logs
        const newRecord = {
          id: `RS-${Date.now()}`,
          timestamp: new Date().toISOString(),
          totalRecords: (licenses.length + subscription_plans.length + support_tickets.length + targetSettings.length + categories.length + menu_items.length + bills.length + bill_items.length + stock_items.length + stock_transactions.length + kds_orders.length + staff_roles.length + staff_members.length + deleted_records.length),
          licensesCount: licenses.length,
          plansCount: subscription_plans.length,
          ticketsCount: support_tickets.length,
          sizeBytes: file.size
        };

        const updatedRecords = [newRecord, ...backupRecords].slice(0, 20);

        await supabase.from('settings').upsert({
          app_user_id: 'global',
          id: 'system_backups',
          data: { records: updatedRecords },
          updated_at: new Date().toISOString()
        });

        localStorage.setItem('system_backups', JSON.stringify(updatedRecords));
        setBackupRecords(updatedRecords);

        // Reload dashboard metrics and states
        await fetchAdminData();

        showToast('🎉 Complete database and registered users restored successfully!', 'success');
      } catch (err: any) {
        console.error(err);
        showToast(`Restore failed: ${err.message || 'Invalid format'}`, 'error');
      } finally {
        setBackupsLoading(false);
        e.target.value = ''; // Reset file input
      }
    };

    setConfirmConfig({
      isOpen: true,
      title: '⚠️ Overwrite Full Database?',
      message: 'Are you absolutely sure you want to restore this FULL DATABASE snapshot? This action will overwrite ALL data tables, including all registered users/outlets, categories, items, transactions, licenses, support tickets, bills, stock, staff etc.! This cannot be undone! Proceed with absolute caution.',
      onConfirm: performRestore
    });
  };

  const openPlanForm = (plan?: SubscriptionPlan) => {
    if (plan) {
      setEditingPlan(plan);
      setPlanIdInput(plan.id);
      setPlanNameInput(plan.name);
      setPlanPriceInput(plan.price.toString());
      setPlanDurationInput(plan.duration_days.toString());
      setPlanFeaturesInput(plan.features.join('\n'));
      setPlanIsActiveInput(plan.is_active);
    } else {
      setEditingPlan(null);
      setPlanIdInput('');
      setPlanNameInput('');
      setPlanPriceInput('');
      setPlanDurationInput('30');
      setPlanFeaturesInput('');
      setPlanIsActiveInput(true);
    }
    setPlanFormOpen(true);
  };

  useEffect(() => {
    if (user) {
      fetchAdminData();
    }
  }, [user]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setAuthError('Please fill out all fields!');
      return;
    }

    setAuthLoading(true);
    setAuthError('');

    try {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;

      if (data.user?.email?.toLowerCase() !== 'gudduk483@gmail.com') {
        await supabase.auth.signOut();
        setAuthError('Access Denied: Only verified Super Admin accounts allowed!');
        setAuthLoading(false);
        return;
      }

      setUser(data.user);
      showToast('Welcome back, Super Admin!', 'success');
    } catch (err: any) {
      setAuthError(err.message || 'Authentication failed!');
    } finally {
      setAuthLoading(false);
    }
  };

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    showToast('Signed out successfully.');
  };

  const handleSavePricing = async (e: React.FormEvent) => {
    e.preventDefault();
    setPricingLoading(true);

    const mPrice = parseFloat(monthlyPrice) || 0;
    const hyPrice = parseFloat(halfYearlyPrice) || 0;
    const yPrice = parseFloat(yearlyPrice) || 0;

    const mFeat = monthlyFeatures.split('n').map(f => f.trim()).filter(Boolean);
    const hyFeat = halfYearlyFeatures.split('n').map(f => f.trim()).filter(Boolean);
    const yFeat = yearlyFeatures.split('n').map(f => f.trim()).filter(Boolean);

    const newPricingData = {
      monthly: { price: mPrice, features: mFeat },
      halfYearly: { price: hyPrice, features: hyFeat },
      yearly: { price: yPrice, features: yFeat }
    };

    try {
      const { error } = await supabase.from('settings').upsert({
        app_user_id: 'global',
        id: 'pricing_plans',
        data: newPricingData,
        updated_at: new Date().toISOString()
      });

      if (error) throw error;
      showToast('Plan prices and features saved successfully!', 'success');
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to save pricing configurations!', 'error');
    } finally {
      setPricingLoading(false);
    }
  };

  const handleGenerateKey = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanCode = targetRestaurantCode.trim().toUpperCase();
    if (!cleanCode) {
      showToast('Please enter a target Restaurant Code!', 'error');
      return;
    }

    setGenLoading(true);
    setGenSuccessMsg('');
    setGeneratedKey('');

    let durationDays = 30;
    if (selectedPlan === 'M01') durationDays = 30;
    else if (selectedPlan === 'M06') durationDays = 180;
    else if (selectedPlan === 'Y01') durationDays = 365;
    else if (selectedPlan === 'LIF') durationDays = 99999;

    const expiryTimestamp = Date.now() + (durationDays * 24 * 60 * 60 * 1000);

    try {
      const signature = await generateSignature(selectedPlan, expiryTimestamp, cleanCode);
      const fullKey = `RESPOS-${selectedPlan}-${expiryTimestamp}-${signature}`;

      const planName = selectedPlan === 'M01' ? 'monthly' : selectedPlan === 'M06' ? 'half-yearly' : selectedPlan === 'Y01' ? 'yearly' : 'lifetime';

      // Save directly to the shared Supabase licences master logger table
      const { error } = await supabase.from('licenses').insert([
        {
          license_key: fullKey,
          plan: planName,
          plan_type: planName,
          expiry_days: durationDays,
          status: 'active',
          restaurant_code: cleanCode
        }
      ]);

      if (error) throw error;

      setGeneratedKey(fullKey);
      setGenSuccessMsg('Key successfully generated and saved to the licenses database!');
      showToast('Key generated successfully!', 'success');
      fetchAdminData(); // Refresh list
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to save generated license to database!', 'error');
    } finally {
      setGenLoading(false);
    }
  };

  const handleManualUpgrade = async (appUserId: string, settingsId: string, actionType: string) => {
    if (!appUserId) return;

    let newStatus = 'premium';
    let newPlan = 'monthly';
    let durationDays = 30;

    if (actionType === 'M01') {
      durationDays = 30;
      newPlan = 'monthly';
    } else if (actionType === 'M06') {
      durationDays = 180;
      newPlan = 'half-yearly';
    } else if (actionType === 'Y01') {
      durationDays = 365;
      newPlan = 'yearly';
    } else if (actionType === 'LIF') {
      durationDays = 99999;
      newPlan = 'lifetime';
    } else if (actionType === 'EXP') {
      newStatus = 'trial';
      newPlan = 'expired';
      durationDays = -1;
    }

    try {
      // 1. Fetch current settings row
      const { error: updateErr } = await supabase
        .from('restaurant_profile')
        .update({
          subscription_status: newStatus,
          subscription_plan: newPlan,
          subscription_expiry: Date.now() + (durationDays * 24 * 60 * 60 * 1000),
          updated_at: new Date().toISOString()
        })
        .eq('app_user_id', appUserId)
        .eq('id', settingsId);

      if (updateErr) throw updateErr;

      showToast('Client plan updated successfully! Live sync completed.', 'success');
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to manually change subscription plan!', 'error');
    }
  };

  const handleExtendTrial = async (appUserId: string, settingsId: string, days: number) => {
    if (!appUserId) return;

    try {
      const { data: rowData, error: fetchErr } = await supabase
        .from('restaurant_profile')
        .select('subscription_expiry, subscription_status')
        .eq('app_user_id', appUserId)
        .eq('id', settingsId)
        .single();

      if (fetchErr) throw fetchErr;

      const currentExpiry = Number(rowData.subscription_expiry) || 0;
      const baseTime = currentExpiry > Date.now() ? currentExpiry : Date.now();
      const newExpiry = baseTime + (days * 24 * 60 * 60 * 1000);
      const newStatus = rowData.subscription_status === 'premium' ? 'premium' : 'trial';

      const { error: updateErr } = await supabase
        .from('restaurant_profile')
        .update({
          subscription_status: newStatus,
          subscription_expiry: newExpiry,
          updated_at: new Date().toISOString()
        })
        .eq('app_user_id', appUserId)
        .eq('id', settingsId);

      if (updateErr) throw updateErr;
      showToast(`Trial extended by ${days} days successfully!`, 'success');
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to extend trial expiry!', 'error');
    }
  };

  const handleSuspendOutlet = async (appUserId: string, settingsId: string) => {
    if (!appUserId) return;
    try {
      const { error: updateErr } = await supabase
        .from('restaurant_profile')
        .update({
          subscription_status: 'suspended',
          subscription_plan: 'suspended',
          subscription_expiry: Date.now() - 1000,
          updated_at: new Date().toISOString()
        })
        .eq('app_user_id', appUserId)
        .eq('id', settingsId);

      if (updateErr) throw updateErr;

      showToast('Outlet suspended and blocked successfully!', 'success');
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to suspend outlet!', 'error');
    }
  };

  const handleRevokeLicense = async (licenseId: string, _licenseKey: string, claimedByUserId: string | null) => {
    if (!licenseId) return;

    try {
      // 1. Update the licenses table
      const { error: licError } = await supabase
        .from('licenses')
        .update({
          status: 'revoked',
          claimed_by_user_id: null,
          claimed_at: null
        })
        .eq('id', licenseId);

      if (licError) throw licError;

      // 2. If it was claimed by a user, locate and downgrade their outlet setting row
      if (claimedByUserId) {
        const { error: updateErr } = await supabase
          .from('restaurant_profile')
          .update({
            subscription_status: 'trial',
            subscription_plan: 'free-trial',
            subscription_expiry: Date.now() - 1000,
            license_key: '',
            updated_at: new Date().toISOString()
          })
          .eq('app_user_id', claimedByUserId);
        if (updateErr) throw updateErr;
      }

      showToast('License key revoked and target client downgraded!', 'success');
      fetchAdminData();
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to revoke license!', 'error');
    }
  };

  const handleBroadcastAnnouncement = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanMessage = announcementInput.trim();
    if (!cleanMessage) {
      showToast('Please enter an announcement message!', 'error');
      return;
    }

    setBroadcastingLoading(true);
    try {
      const { error } = await supabase.from('settings').upsert({
        app_user_id: 'global',
        id: 'announcement',
        data: { message: cleanMessage },
        updated_at: new Date().toISOString()
      });

      if (error) throw error;
      setActiveBroadcast(cleanMessage);
      showToast('Announced successfully!', 'success');
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to broadcast announcement!', 'error');
    } finally {
      setBroadcastingLoading(false);
    }
  };

  const handleClearBroadcast = async () => {
    setBroadcastingLoading(true);
    try {
      const { error } = await supabase
        .from('settings')
        .delete()
        .eq('app_user_id', 'global')
        .eq('id', 'announcement');

      if (error) throw error;
      setActiveBroadcast('');
      setAnnouncementInput('');
      showToast('Announcement cleared successfully!', 'success');
    } catch (err: any) {
      console.error(err);
      showToast(err.message || 'Failed to clear announcement!', 'error');
    } finally {
      setBroadcastingLoading(false);
    }
  };

  const copyKey = () => {
    if (!generatedKey) return;
    navigator.clipboard.writeText(generatedKey);
    showToast('🔑 Key copied to clipboard!', 'success');
  };

  const filteredOutlets = outlets.filter(out => {
    const q = searchQuery.toLowerCase().trim();
    if (!q) return true;
    return (
      out.restaurantName.toLowerCase().includes(q) ||
      out.restaurantCode.toLowerCase().includes(q) ||
      (out.phone && out.phone.toLowerCase().includes(q))
    );
  });

  if (!user) {
    return (
      <div className="h-screen flex items-center justify-center p-6 bg-slate-950 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-slate-900 via-slate-950 to-black">
        <div className="w-full max-w-[420px] bg-slate-900/60 backdrop-blur-xl border border-slate-800 rounded-3xl p-8 shadow-2xl relative overflow-hidden">
          <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-64 h-64 bg-indigo-500/10 rounded-full blur-3xl"></div>

          <div className="flex flex-col items-center text-center gap-3 relative z-10">
            <div className="p-4 bg-gradient-to-br from-indigo-500 to-pink-500 rounded-2xl text-white shadow-lg shadow-indigo-500/20">
              <Crown size={32} />
            </div>
            <h1 className="text-xl font-extrabold text-white tracking-tight uppercase mt-2">Super Admin Login</h1>
            <p className="text-xs text-slate-400 font-semibold max-w-[280px]">
              Authorized administrative access panel to manage subscriptions, outlets, and keys.
            </p>
          </div>

          <form onSubmit={handleLogin} className="flex flex-col gap-5 mt-8 relative z-10">
            {authError && (
              <div className="p-3 bg-red-950/50 border border-red-800 text-red-400 rounded-2xl text-xs font-bold flex items-center gap-2">
                <ShieldAlert size={16} />
                {authError}
              </div>
            )}

            <div className="flex flex-col gap-1.5">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Admin Email Address</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="gudduk483@gmail.com"
                className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-bold text-sm placeholder-slate-600"
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Master Password</label>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-bold text-sm placeholder-slate-600 tracking-widest"
              />
            </div>

            <button
              type="submit"
              disabled={authLoading}
              className="w-full py-3 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-xs uppercase tracking-wider shadow-lg shadow-indigo-500/20 active:scale-95 transition-all disabled:opacity-50"
            >
              {authLoading ? 'Verifying...' : 'Authorize Login'}
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden font-sans">
      {/* 1. Desktop Sidebar Pane (Left) */}
      <aside className="hidden md:flex flex-col w-72 bg-slate-900/60 border-r border-slate-800/80 backdrop-blur-xl shrink-0 p-6 justify-between relative z-20">
        <div className="flex flex-col gap-8">
          {/* Logo Brand Header */}
          <div className="flex items-center gap-3 border-b border-slate-800 pb-5">
            <div className="p-2.5 bg-gradient-to-br from-indigo-500 to-pink-500 rounded-xl text-white shadow-md shadow-indigo-500/10">
              <Crown size={20} />
            </div>
            <div>
              <h2 className="text-sm font-black tracking-tight text-white uppercase flex items-center gap-1.5">
                Siya Bill
                <span className="text-[8px] bg-indigo-500/20 text-indigo-400 border border-indigo-500/30 px-1.5 py-0.5 rounded-full font-black tracking-wider">Super Admin</span>
              </h2>
              <p className="text-[10px] text-slate-400 font-semibold mt-0.5">Central Control POS Engine</p>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="flex flex-col gap-1">
            <button
              onClick={() => { setActiveTab('dashboard'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'dashboard'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <LayoutDashboard size={15} />
              Dashboard
            </button>

            <button
              onClick={() => { setActiveTab('outlets'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'outlets'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <Building2 size={15} />
              Outlets
            </button>

            <button
              onClick={() => { setActiveTab('licenses'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'licenses'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <KeyRound size={15} />
              License Keys
            </button>

            <button
              onClick={() => { setActiveTab('pricing'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'pricing'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <Sparkles size={15} />
              Custom Plans
            </button>

            <button
              onClick={() => { setActiveTab('tickets'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'tickets'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <MessageSquare size={15} />
              Support Tickets
            </button>

            <button
              onClick={() => { setActiveTab('blocked'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'blocked'
                  ? 'bg-slate-800/40 border border-red-500/30 text-red-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <ShieldAlert size={15} />
              Blocked Users
            </button>

            <button
              onClick={() => { setActiveTab('audits'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'audits'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <Activity size={15} />
              Live Network
            </button>

            <button
              onClick={() => { setActiveTab('analytics'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'analytics'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <BarChart3 size={15} />
              Ecosystem Stats
            </button>

            <button
              onClick={() => { setActiveTab('backups'); setIsMobileMenuOpen(false); }}
              className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                activeTab === 'backups'
                  ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400 shadow-inner'
                  : 'border border-transparent text-slate-400 hover:bg-slate-900/40 hover:text-slate-200'
              }`}
            >
              <Database size={15} />
              Backups Log
            </button>
          </nav>
        </div>

        {/* Bottom Profile Details & Sign Out */}
        <div className="flex flex-col gap-4 border-t border-slate-800/60 pt-5">
          <div className="flex items-center gap-2.5 px-2">
            <div className="w-8 h-8 rounded-full bg-slate-800 border border-slate-700/60 flex items-center justify-center font-black text-xs text-slate-300">
              SA
            </div>
            <div className="min-w-0">
              <span className="text-[10px] font-black text-slate-400 block tracking-tight truncate">{email}</span>
              <span className="text-[8px] font-bold text-emerald-400 flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                Authorized Admin
              </span>
            </div>
          </div>

          <button
            onClick={handleSignOut}
            className="w-full py-2.5 bg-slate-800 hover:bg-red-950/40 hover:text-red-400 hover:border-red-900/40 rounded-xl font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 transition-all border border-slate-700/50 text-slate-300 active:scale-95"
          >
            <LogOut size={14} />
            Sign Out
          </button>
        </div>
      </aside>

      {/* 2. Mobile Drawer Navigation Pane */}
      {isMobileMenuOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40 md:hidden flex justify-start">
          <aside className="w-72 h-full bg-slate-900 border-r border-slate-800 flex flex-col justify-between p-6 animate-in slide-in-from-left duration-200">
            <div className="flex flex-col gap-8">
              {/* Header with close button */}
              <div className="flex items-center justify-between border-b border-slate-800 pb-5">
                <div className="flex items-center gap-2.5">
                  <div className="p-2 bg-gradient-to-br from-indigo-500 to-pink-500 rounded-xl text-white">
                    <Crown size={18} />
                  </div>
                  <div>
                    <h2 className="text-xs font-black tracking-tight text-white uppercase">Siya Bill</h2>
                    <span className="text-[8px] text-indigo-400 font-bold block">Super Admin</span>
                  </div>
                </div>
                <button
                  onClick={() => setIsMobileMenuOpen(false)}
                  className="p-1.5 bg-slate-800 hover:bg-slate-750 text-slate-400 rounded-lg"
                >
                  <X size={16} />
                </button>
              </div>

              {/* Navigation Links */}
              <nav className="flex flex-col gap-1">
                <button
                  onClick={() => { setActiveTab('dashboard'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'dashboard'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <LayoutDashboard size={15} />
                  Dashboard
                </button>

                <button
                  onClick={() => { setActiveTab('outlets'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'outlets'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <Building2 size={15} />
                  Outlets
                </button>

                <button
                  onClick={() => { setActiveTab('licenses'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'licenses'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <KeyRound size={15} />
                  License Keys
                </button>

                <button
                  onClick={() => { setActiveTab('pricing'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'pricing'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <Sparkles size={15} />
                  Custom Plans
                </button>

                <button
                  onClick={() => { setActiveTab('tickets'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'tickets'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <MessageSquare size={15} />
                  Support Tickets
                </button>

                <button
                  onClick={() => { setActiveTab('blocked'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'blocked'
                      ? 'bg-slate-800/40 border border-red-500/30 text-red-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <ShieldAlert size={15} />
                  Blocked Users
                </button>

                <button
                  onClick={() => { setActiveTab('audits'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'audits'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <Activity size={15} />
                  Live Network
                </button>

                <button
                  onClick={() => { setActiveTab('analytics'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'analytics'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <BarChart3 size={15} />
                  Ecosystem Stats
                </button>

                <button
                  onClick={() => { setActiveTab('backups'); setIsMobileMenuOpen(false); }}
                  className={`w-full px-3.5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider flex items-center gap-2.5 transition-all ${
                    activeTab === 'backups'
                      ? 'bg-slate-800/40 border border-indigo-500/30 text-indigo-400'
                      : 'border border-transparent text-slate-400 hover:bg-slate-900/40'
                  }`}
                >
                  <Database size={15} />
                  Backups Log
                </button>
              </nav>
            </div>

            <div className="flex flex-col gap-4 border-t border-slate-800 pt-5">
              <span className="text-[10px] text-slate-400 font-semibold block text-center truncate">{email}</span>
              <button
                onClick={handleSignOut}
                className="w-full py-2.5 bg-slate-855 hover:bg-red-955 hover:text-red-400 hover:border-red-900 rounded-xl font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 transition-all border border-slate-700/50 text-slate-300 animate-pulse"
              >
                <LogOut size={14} />
                Sign Out
              </button>
            </div>
          </aside>
          <div className="flex-1" onClick={() => setIsMobileMenuOpen(false)}></div>
        </div>
      )}

      {/* 3. Main Workspace Container (Right) */}
      <main className="flex-1 flex flex-col min-w-0 h-full overflow-hidden bg-slate-950">

        {/* Mobile Header Bar (Only visible on mobile) */}
        <header className="md:hidden flex items-center justify-between p-4 bg-slate-900 border-b border-slate-800 shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-gradient-to-br from-indigo-500 to-pink-500 rounded-lg text-white">
              <Crown size={18} />
            </div>
            <h1 className="text-sm font-black tracking-tight text-white uppercase">Siya Bill POS Admin</h1>
          </div>

          <button
            onClick={() => setIsMobileMenuOpen(true)}
            className="p-2 bg-slate-800 hover:bg-slate-750 text-white rounded-lg transition-colors"
          >
            <Menu size={18} />
          </button>
        </header>

        {/* Desktop Header Bar (Only visible on desktop) */}
        <header className="hidden md:flex items-center justify-between px-8 py-5 border-b border-slate-900 bg-slate-900/20 shrink-0">
          <div>
            <h1 className="text-lg font-black text-white tracking-tight flex items-center gap-2.5 capitalize">
              {activeTab === 'dashboard' && 'Dashboard Overview'}
              {activeTab === 'outlets' && 'Outlets Directory'}
              {activeTab === 'licenses' && 'License Cryptographic Engine'}
              {activeTab === 'pricing' && 'Custom Plans Manager'}
              {activeTab === 'tickets' && 'Support Tickets Queue'}
              {activeTab === 'blocked' && 'Blocked Accounts Management'}
              {activeTab === 'audits' && 'Live Restaurant Activity'}
              {activeTab === 'analytics' && 'Comparative Performance Analytics'}
              {activeTab === 'backups' && 'Database JSON Snapshots'}
              <span className="text-[9px] bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 px-2.5 py-0.5 rounded-full font-black uppercase tracking-wider">
                Live Cloud Sync
              </span>
            </h1>
            <p className="text-xs text-slate-400 font-semibold mt-0.5">
              {activeTab === 'dashboard' && 'System statistics, key database records count, and core POS environment.'}
              {activeTab === 'outlets' && 'Registered restaurant outlets list, live verification statuses, and fast plans upgrade.'}
              {activeTab === 'licenses' && 'Generate cryptographic yearly or permanent license activation keys and trace claimed audits.'}
              {activeTab === 'pricing' && 'Create, edit or delete premium subscriptions plans and synchronize with legacy POS clients.'}
              {activeTab === 'tickets' && 'Review active helpdesk support queues, filter by status, and reply to client conversations.'}
              {activeTab === 'blocked' && 'Inspect rate limit abuse warnings, and unblock accounts blocked by protection rules.'}
              {activeTab === 'audits' && 'Monitor real-time transaction feeds across all active restaurants to determine live network health.'}
              {activeTab === 'analytics' && 'Inspect comparative outlet sales, transaction counts, average bills, and cashier leaderboards.'}
              {activeTab === 'backups' && 'Download standard administrative database tables JSON backups and monitor histories.'}
            </p>
          </div>

          <div className="text-[10px] text-slate-500 font-bold bg-slate-900 border border-slate-850 px-3.5 py-1.5 rounded-xl flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
            Super Admin Session: <span className="text-slate-300 font-black font-mono">gudduk483@gmail.com</span>
          </div>
        </header>

        {/* Dynamic Screen View Space */}
        <div className="flex-1 overflow-y-auto p-6 md:p-8 flex flex-col gap-6 scrollbar-thin">

          {/* TAB 1: DASHBOARD */}
          {activeTab === 'dashboard' && (
            <DashboardView
              dashboardMetrics={dashboardMetrics}
              activeBroadcast={activeBroadcast}
              announcementInput={announcementInput}
              broadcastingLoading={broadcastingLoading}
              setActiveTab={setActiveTab}
              setAnnouncementInput={setAnnouncementInput}
              handleBroadcastAnnouncement={handleBroadcastAnnouncement}
              handleClearBroadcast={handleClearBroadcast}
            />
          )}

          {/* TAB 2: OUTLETS DIRECTORY */}
          {activeTab === 'outlets' && (
            <OutletsView
              filteredOutlets={filteredOutlets}
              searchQuery={searchQuery}
              setSearchQuery={setSearchQuery}
              handleExtendTrial={handleExtendTrial}
              handleSuspendOutlet={handleSuspendOutlet}
              handleManualUpgrade={handleManualUpgrade}
            />
          )}

          {/* TAB 3: LICENSE KEYS */}
          {activeTab === 'licenses' && (
            <LicensesView
              licenses={licenses}
              outlets={outlets}
              targetRestaurantCode={targetRestaurantCode}
              selectedPlan={selectedPlan}
              generatedKey={generatedKey}
              genLoading={genLoading}
              setTargetRestaurantCode={setTargetRestaurantCode}
              setSelectedPlan={setSelectedPlan}
              handleGenerateKey={handleGenerateKey}
              copyKey={copyKey}
              setConfirmConfig={setConfirmConfig}
              handleRevokeLicense={handleRevokeLicense}
            />
          )}

          {/* TAB 4: CUSTOM PLANS CRUD */}
          {activeTab === 'pricing' && (
            <PricingView
              dbPlans={dbPlans}
              dbPlansLoading={dbPlansLoading}
              dbPlansErrorMsg={dbPlansErrorMsg}
              openPlanForm={openPlanForm}
              handleTogglePlanActive={handleTogglePlanActive}
              handleDeletePlan={handleDeletePlan}
              setConfirmConfig={setConfirmConfig}
            />
          )}

          {/* TAB 5: SUPPORT TICKETS */}
          {activeTab === 'tickets' && (
            <TicketsView
              tickets={tickets}
              selectedTicket={selectedTicket}
              ticketReplyText={ticketReplyText}
              ticketStatusFilter={ticketStatusFilter}
              ticketPriorityFilter={ticketPriorityFilter}
              ticketsLoading={ticketsLoading}
              ticketsErrorMsg={ticketsErrorMsg}
              setSelectedTicket={setSelectedTicket}
              setTicketReplyText={setTicketReplyText}
              setTicketStatusFilter={setTicketStatusFilter}
              setTicketPriorityFilter={setTicketPriorityFilter}
              handleReplyTicket={handleReplyTicket}
              handleUpdateTicketStatus={handleUpdateTicketStatus}
              handleUnblockUserFromTicket={handleUnblockUserFromTicket}
              fetchAdminData={fetchAdminData}
            />
          )}

          {/* TAB 6: LIVE RESTAURANTS NETWORK */}
          {activeTab === 'audits' && (
            <AuditsView
              outlets={outlets}
              allBills={allBills}
              liveRestaurantsCount={liveRestaurantsCount}
              staffSearchQuery={staffSearchQuery}
              selectedLiveOutlet={selectedLiveOutlet}
              editingBillSeq={editingBillSeq}
              updatingSeq={updatingSeq}
              setStaffSearchQuery={setStaffSearchQuery}
              setSelectedLiveOutlet={setSelectedLiveOutlet}
              setEditingBillSeq={setEditingBillSeq}
              handleUpdateBillSeq={handleUpdateBillSeq}
            />
          )}

          {/* TAB 7: COMPARATIVE ANALYTICS */}
          {activeTab === 'analytics' && (
            <AnalyticsView
              allBills={allBills}
              outlets={outlets}
              analyticsLoading={analyticsLoading}
              analyticsErrorMsg={analyticsErrorMsg}
              analyticsPeriod={analyticsPeriod}
              setAnalyticsPeriod={setAnalyticsPeriod}
            />
          )}

          {/* TAB 7.5: BLOCKED USERS */}
          {activeTab === 'blocked' && (
            <BlockedView
              blockedUsers={blockedUsers}
              blockedUsersLoading={blockedUsersLoading}
              unblockingId={unblockingId}
              outlets={outlets}
              fetchAdminData={fetchAdminData}
              handleUnblockUser={handleUnblockUser}
            />
          )}

          {/* TAB 8: DATABASE JSON BACKUPS */}
          {activeTab === 'backups' && (
            <BackupsView
              backupRecords={backupRecords}
              backupsLoading={backupsLoading}
              handleTriggerBackup={handleTriggerBackup}
              handleRestoreBackup={handleRestoreBackup}
            />
          )}

        </div>
      </main>

      {/* Dynamic Plan Form Modal Overlay */}
      {planFormOpen && (
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-slate-900/95 border border-slate-800 rounded-3xl w-full max-w-lg p-6 md:p-8 flex flex-col gap-6 shadow-2xl animate-in zoom-in-95 duration-200 relative overflow-hidden">
            <div className="absolute top-0 right-0 transform translate-x-12 -translate-y-12 w-48 h-48 bg-indigo-500/10 rounded-full blur-3xl pointer-events-none"></div>

            <div className="flex items-center justify-between border-b border-slate-800/80 pb-4 relative z-10">
              <h3 className="font-extrabold text-base text-white uppercase tracking-tight flex items-center gap-2">
                <Sparkles className="text-indigo-400" size={18} />
                {editingPlan ? 'Edit Subscription Plan' : 'Create Custom Plan'}
              </h3>
              <button
                onClick={() => { setPlanFormOpen(false); setEditingPlan(null); }}
                className="p-1.5 bg-slate-950 hover:bg-slate-900 border border-slate-800 rounded-xl text-slate-400 hover:text-white transition-colors active:scale-95"
              >
                <X size={14} />
              </button>
            </div>

            <form onSubmit={handleSavePlan} className="flex flex-col gap-4 relative z-10">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Plan ID / Code</label>
                  <input
                    type="text"
                    required
                    disabled={!!editingPlan}
                    value={planIdInput}
                    onChange={(e) => setPlanIdInput(e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, ''))}
                    placeholder="e.g. cafe-basic"
                    className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-black text-xs tracking-wider placeholder-slate-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  />
                </div>

                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Plan Name</label>
                  <input
                    type="text"
                    required
                    value={planNameInput}
                    onChange={(e) => setPlanNameInput(e.target.value)}
                    placeholder="e.g. Cafe Basic Plan"
                    className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-bold text-xs placeholder-slate-700"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Price (INR)</label>
                  <input
                    type="number"
                    required
                    min="0"
                    value={planPriceInput}
                    onChange={(e) => setPlanPriceInput(e.target.value)}
                    placeholder="e.g. 1499"
                    className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-mono text-xs placeholder-slate-700"
                  />
                </div>

                <div className="flex flex-col gap-1.5">
                  <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Duration (Days)</label>
                  <input
                    type="number"
                    required
                    min="1"
                    value={planDurationInput}
                    onChange={(e) => setPlanDurationInput(e.target.value)}
                    placeholder="e.g. 30"
                    className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-mono text-xs placeholder-slate-700"
                  />
                </div>
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Included Features (One feature per line)</label>
                <textarea
                  required
                  rows={4}
                  value={planFeaturesInput}
                  onChange={(e) => setPlanFeaturesInput(e.target.value)}
                  placeholder={"Quick Billing & KOT\nKDS & Stock Manager\nRealtime Cloud Sync"}
                  className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white font-semibold text-xs placeholder-slate-700 resize-none scrollbar-thin"
                />
              </div>

              <div className="flex items-center gap-3 bg-slate-955/50 border border-slate-850 p-3 rounded-2xl">
                <input
                  type="checkbox"
                  id="planIsActive"
                  checked={planIsActiveInput}
                  onChange={(e) => setPlanIsActiveInput(e.target.checked)}
                  className="w-4 h-4 rounded border-slate-800 text-indigo-600 bg-slate-950 focus:ring-indigo-500 focus:ring-offset-slate-900 focus:ring-2 cursor-pointer"
                />
                <label htmlFor="planIsActive" className="text-xs font-bold text-slate-300 cursor-pointer select-none">
                  Make this plan active and visible to outlets instantly
                </label>
              </div>

              <div className="flex items-center justify-end gap-3 border-t border-slate-800/80 pt-4 mt-2">
                <button
                  type="button"
                  onClick={() => { setPlanFormOpen(false); setEditingPlan(null); }}
                  className="px-5 py-2.5 bg-slate-950 hover:bg-slate-900 border border-slate-800 text-slate-400 font-bold rounded-xl text-xs uppercase tracking-wider transition-all active:scale-95"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={dbPlansLoading}
                  className="px-5 py-2.5 bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-white font-black rounded-xl text-xs uppercase tracking-wider transition-all active:scale-95 shadow-lg shadow-indigo-500/20 disabled:opacity-50 flex items-center gap-1.5"
                >
                  {dbPlansLoading ? (
                    <>
                      <RefreshCw size={12} className="animate-spin" />
                      Saving Plan...
                    </>
                  ) : (
                    <>
                      <Sparkles size={12} />
                      Save Tiers Package
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Confirm Modal Overlay */}
      {confirmConfig?.isOpen && (
        <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200" onClick={() => setConfirmConfig(null)}>
          <div className="glass-modal rounded-2xl p-6 max-w-sm w-full animate-in zoom-in-95 duration-250" onClick={e => e.stopPropagation()}>
            <h3 className="font-black text-lg text-white mb-2">{confirmConfig.title}</h3>
            <p className="text-slate-300 text-xs font-semibold mb-6 leading-relaxed">{confirmConfig.message}</p>
            <div className="flex gap-3">
              <button onClick={() => setConfirmConfig(null)} className="flex-1 py-2.5 bg-slate-800 hover:bg-slate-750 text-slate-300 rounded-xl font-bold text-xs transition-all active:scale-95">Cancel</button>
              <button onClick={() => { confirmConfig.onConfirm(); setConfirmConfig(null); }} className="flex-1 py-2.5 bg-red-650 hover:bg-red-700 text-white rounded-xl font-bold text-xs transition-all active:scale-95">Confirm</button>
            </div>
          </div>
        </div>
      )}

      {/* Toast notification popup overlay */}
      {toast.show && (
        <div className={`fixed bottom-8 right-8 px-5 py-3.5 rounded-2xl shadow-xl border font-bold text-xs uppercase tracking-wider flex items-center gap-2 transition-all duration-300 animate-in fade-in slide-in-from-bottom-5 z-[50] ${
          toast.type === 'success' ? 'bg-emerald-950 text-emerald-400 border-emerald-800' : 'bg-red-950 text-red-400 border-red-800'
        }`}>
          {toast.type === 'success' ? <CheckCircle2 size={16} /> : <ShieldAlert size={16} />}
          {toast.message}
        </div>
      )}
    </div>
  );
}
