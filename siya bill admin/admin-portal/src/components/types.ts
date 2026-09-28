import { supabase } from '../supabase';

// Cryptographic signature generator invoking the secure server-side Supabase Edge Function
export async function generateSignature(planCode: string, expiry: number, restaurantCode: string): Promise<string> {
  const { data, error } = await supabase.functions.invoke('sign-license', {
    body: { planCode, expiry, restaurantCode }
  });

  if (error) {
    throw new Error(`Edge Function error: ${error.message || 'Failed to sign license'}`);
  }

  if (!data?.signature) {
    throw new Error('Edge Function did not return a valid signature');
  }

  return data.signature;
}

export interface ConfirmConfig {
  isOpen: boolean;
  title: string;
  message: string;
  onConfirm: () => void;
}

export interface Outlet {
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

export interface License {
  id: string;
  license_key: string;
  plan_type: string;
  status: string;
  restaurant_code: string;
  claimed_by_user_id: string | null;
  claimed_at: string | null;
  created_at?: string;
}

export interface TicketReply {
  sender: string;
  senderName?: string;
  timestamp: string | number;
  message: string;
}

export interface SupportTicket {
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

export interface SubscriptionPlan {
  id: string;
  plan_code?: string;
  name: string;
  price: number;
  duration_days: number;
  features: string[];
  is_active: boolean;
}

export interface BlockedUser {
  user_id: string;
  warning_count: number;
  blocked_until: string;
  blocked_at: string;
  blocked_reason: string;
}

export interface BackupRecord {
  id: string;
  timestamp: string;
  totalRecords?: number;
  licensesCount?: number;
  plansCount?: number;
  ticketsCount?: number;
  sizeBytes: number;
}

export interface AdminBill {
  id: string;
  app_user_id: string;
  total: string | number;
  timestamp: string | number;
}
