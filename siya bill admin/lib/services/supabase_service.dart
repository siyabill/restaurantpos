import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../models/license.dart';
import '../models/violation.dart';
import '../models/restaurant_profile.dart';
import '../models/restaurant_settings.dart';
import '../models/ticket.dart';
import '../models/backup.dart';
import '../models/plan.dart';
import '../models/settings.dart';
import '../models/bill.dart';
import 'crypto_service.dart';

class SupabaseService {
  final CryptoService _cryptoService = CryptoService();
  bool _useMock = true;
  String? _mockUserEmail;
  Timer? _mockTimer;

  // Mock Databases
  final List<LicenseModel> _mockLicenses = [];
  final List<ViolationModel> _mockViolations = [];
  final List<RestaurantProfileModel> _mockProfiles = [];
  final List<RestaurantSettingsModel> _mockSettingsList = [];
  final List<TicketModel> _mockTickets = [];
  final List<BackupModel> _mockBackups = [];
  final List<PlanModel> _mockPlans = [];
  final List<SettingsModel> _mockSettings = [];
  final List<BillModel> _mockBills = [];
  final List<Map<String, dynamic>> _mockPresencePings = [];

  // Broadcast Controllers
  final _violationsController = StreamController<List<ViolationModel>>.broadcast();
  final _ticketsController = StreamController<List<TicketModel>>.broadcast();

  SupabaseService({bool? useMock, String? mockUserEmail}) {
    _initMockData();
    
    if (useMock != null) {
      _useMock = useMock;
    } else {
      try {
        const envUrl = String.fromEnvironment('SUPABASE_URL');
        final url = envUrl.isNotEmpty ? envUrl : AppConstants.supabaseUrl;
        
        if (url.isNotEmpty && !url.contains('placeholder-project-id')) {
          _useMock = false;
        } else {
          _useMock = true;
        }
      } catch (_) {
        _useMock = true;
      }
    }

    if (mockUserEmail != null || useMock != null) {
      _mockUserEmail = mockUserEmail;
    }
  }

  bool get isUsingMockData => _useMock;

  void _initMockData() {
    final now = DateTime.now();
    _mockUserEmail = AppConstants.adminEmail;

    // 1. Mock Restaurant Profiles
    _mockProfiles.addAll([
      RestaurantProfileModel(
        id: 'res-cafe-1',
        appUserId: 'user-id-111',
        restaurantName: 'Siya Restro Cafe (Main)',
        phone: '+91 98765 43210',
        email: 'cp_delhi@siyacafe.com',
        address: 'Connaught Place, New Delhi',
        gstNumber: '07AAAAA1111A1Z1',
        fssaiNumber: '12345678901234',
        upiId: 'siyacafe@upi',
        subscriptionStatus: 'premium',
        subscriptionExpiry: now.add(const Duration(days: 45)).millisecondsSinceEpoch.toDouble(),
        subscriptionPlan: 'yearly',
        restaurantCode: 'RES-G6T8X9',
        licenseKey: 'RESPOS-Y01-1780910571000-signature',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      RestaurantProfileModel(
        id: 'res-express-2',
        appUserId: 'user-id-222',
        restaurantName: 'Siya POS Express',
        phone: '+91 87654 32109',
        email: 'noida_sec62@siyapos.com',
        address: 'Sector 62, Noida',
        gstNumber: '09BBBBB2222B2Z2',
        fssaiNumber: '22345678901235',
        upiId: 'siyapos@upi',
        subscriptionStatus: 'trial',
        subscriptionExpiry: now.add(const Duration(days: 5)).millisecondsSinceEpoch.toDouble(),
        subscriptionPlan: 'free-trial',
        restaurantCode: 'RES-J1K2L3',
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      RestaurantProfileModel(
        id: 'res-grill-3',
        appUserId: 'user-id-333',
        restaurantName: 'Khana Khazana Grill',
        phone: '+91 76543 21098',
        email: 'blr_indiranagar@khanakhazana.com',
        address: 'Indiranagar, Bengaluru',
        gstNumber: '29CCCCC3333C3Z3',
        fssaiNumber: '32345678901236',
        upiId: 'khana@upi',
        subscriptionStatus: 'expired',
        subscriptionExpiry: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch.toDouble(),
        subscriptionPlan: 'free-trial',
        restaurantCode: 'RES-M3N4P5',
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ]);

    // 2. Mock Restaurant Settings
    _mockSettingsList.addAll([
      RestaurantSettingsModel(id: 'global', appUserId: 'user-id-111', billSequence: 1042, updatedAt: now),
      RestaurantSettingsModel(id: 'global', appUserId: 'user-id-222', billSequence: 89, updatedAt: now),
      RestaurantSettingsModel(id: 'global', appUserId: 'user-id-333', billSequence: 301, updatedAt: now),
    ]);

    // 3. Mock Licenses
    _mockLicenses.addAll([
      LicenseModel(
        id: 'lic-1',
        licenseKey: 'RESPOS-Y01-1780910571000-signature',
        planType: 'yearly',
        expiryDays: 365,
        status: 'claimed',
        restaurantCode: 'RES-G6T8X9',
        claimedByUserId: 'user-id-111',
        claimedAt: now.subtract(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      LicenseModel(
        id: 'lic-2',
        licenseKey: 'RESPOS-LIF-9999-signature-key-2',
        planType: 'lifetime',
        expiryDays: 9999,
        status: 'active',
        restaurantCode: 'RES-J1K2L3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 4. Mock Violations
    _mockViolations.addAll([
      ViolationModel(
        userId: 'user-id-222',
        warningCount: 4,
        warningDate: '2026-06-08',
        blockedUntil: now.add(const Duration(hours: 3)),
        blockedAt: now.subtract(const Duration(minutes: 45)),
        blockedReason: 'Exceeded bill insertion rate (24 bills/minute, limit is 20)',
      ),
      ViolationModel(
        userId: 'user-id-333',
        warningCount: 1,
        warningDate: '2026-06-08',
        blockedReason: 'API burst limit violations log',
      )
    ]);

    // 5. Mock Support Tickets
    _mockTickets.addAll([
      TicketModel(
        id: 'tkt-101',
        customerName: 'Aman (Siya Restro Cafe)',
        subject: 'Printer SDK Integration error',
        status: 'open',
        createdAt: now.subtract(const Duration(hours: 2)),
        messages: [
          ChatMessage(
            sender: 'customer',
            content: 'Our thermal printer prints blank text when checking out bills. Can you check?',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            sender: 'admin',
            content: 'Ensure your app thermal printing library is up to date, and checks the connection port.',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
    ]);

    // 6. Mock Plans
    _mockPlans.addAll([
      PlanModel(id: 'M01', name: 'Monthly Basic', price: 999.0, durationDays: 30, features: ['Billing', 'Sync API', 'Basic Reports'], isActive: true),
      PlanModel(id: 'M06', name: 'Half-Yearly Saver', price: 4999.0, durationDays: 180, features: ['Billing', 'Sync API', 'Unlimited Devices', 'Advanced Reports'], isActive: true),
      PlanModel(id: 'Y01', name: 'Yearly Pro Premium', price: 8999.0, durationDays: 365, features: ['Billing', 'Sync API', 'Unlimited Devices', 'KDS Screen', 'Live Backups', 'Enterprise Analytics'], isActive: true),
      PlanModel(id: 'LIF', name: 'Lifetime Ultimate', price: 24999.0, durationDays: 9999, features: ['All Premium features unlocked forever', 'Dedicated Support'], isActive: true),
    ]);

    // 7. Mock Settings
    _mockSettings.addAll([
      SettingsModel(
        appUserId: 'global',
        id: 'announcement',
        data: {'message': 'System Upgrade Scheduled on 12th June from 2 AM to 4 AM UTC.'},
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ]);

    // 8. Mock Bills (For Comparative Analytics)
    _mockBills.addAll([
      BillModel(id: 'b-1', appUserId: 'user-id-111', totalAmount: 450.0, timestamp: now.subtract(const Duration(hours: 2))),
      BillModel(id: 'b-2', appUserId: 'user-id-111', totalAmount: 1200.0, timestamp: now.subtract(const Duration(hours: 1))),
      BillModel(id: 'b-3', appUserId: 'user-id-222', totalAmount: 320.0, timestamp: now.subtract(const Duration(minutes: 30))),
      BillModel(id: 'b-4', appUserId: 'user-id-222', totalAmount: 780.0, timestamp: now.subtract(const Duration(days: 1))),
      BillModel(id: 'b-5', appUserId: 'user-id-333', totalAmount: 2200.0, timestamp: now.subtract(const Duration(days: 2))),
    ]);

    // 9. Mock Presence Pings
    _mockPresencePings.addAll([
      {'app_user_id': 'user-id-111', 'updated_at': now.subtract(const Duration(minutes: 2)).toIso8601String()},
      {'app_user_id': 'user-id-222', 'updated_at': now.subtract(const Duration(minutes: 4)).toIso8601String()},
      {'app_user_id': 'user-id-333', 'updated_at': now.subtract(const Duration(minutes: 15)).toIso8601String()},
    ]);

    // Periodically push updates to streams to simulate real-time CDC
    _mockTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_violationsController.isClosed) {
        _violationsController.add(_mockViolations);
      }
      if (!_ticketsController.isClosed) {
        _ticketsController.add(_mockTickets);
      }
    });
  }

  void dispose() {
    _mockTimer?.cancel();
    if (!_violationsController.isClosed) {
      _violationsController.close();
    }
    if (!_ticketsController.isClosed) {
      _ticketsController.close();
    }
  }

  // --- 1. Auth operations & email verification gate ---

  Future<bool> signIn(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (cleanEmail == AppConstants.adminEmail && password == 'admin123') {
        _mockUserEmail = cleanEmail;
        return true;
      } else if (cleanEmail == AppConstants.adminEmail) {
        throw Exception('Incorrect password. (For offline testing use: admin123)');
      } else {
        throw Exception('Access Denied: Only authorized email ${AppConstants.adminEmail} can access.');
      }
    } else {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      if (response.user != null) {
        if (response.user!.email?.toLowerCase() == AppConstants.adminEmail) {
          return true;
        } else {
          await Supabase.instance.client.auth.signOut();
          throw Exception('Access Denied: Non-Admin account. Gated for ${AppConstants.adminEmail}');
        }
      }
      return false;
    }
  }

  Future<void> signOut() async {
    if (!_useMock) {
      await Supabase.instance.client.auth.signOut();
    } else {
      _mockUserEmail = null;
    }
  }

  String? get currentEmail {
    if (_useMock) {
      return _mockUserEmail;
    } else {
      return Supabase.instance.client.auth.currentUser?.email;
    }
  }

  // --- 2. Live Presence Monitoring ---

  Future<int> fetchLivePresenceCount() async {
    if (_useMock) {
      final now = DateTime.now();
      return _mockPresencePings.where((ping) {
        final updatedAt = DateTime.parse(ping['updated_at'] as String);
        return now.difference(updatedAt).inMinutes < 6;
      }).length;
    } else {
      final presenceData = await Supabase.instance.client
          .from('presence_pings')
          .select('app_user_id, updated_at');
      
      final now = DateTime.now();
      return (presenceData as List).where((ping) {
        final updatedAt = DateTime.parse(ping['updated_at'] as String);
        return now.difference(updatedAt).inMinutes < 6;
      }).length;
    }
  }

  // --- 3. Announcement Broadcaster ---

  Future<String?> fetchActiveAnnouncement() async {
    if (_useMock) {
      final ann = _mockSettings.firstWhere((x) => x.id == 'announcement', orElse: () => SettingsModel(appUserId: 'global', id: 'announcement', data: {}, updatedAt: DateTime.now()));
      return ann.data['message'] as String?;
    } else {
      final response = await Supabase.instance.client
          .from('settings')
          .select()
          .eq('app_user_id', 'global')
          .eq('id', 'announcement')
          .maybeSingle();
      if (response != null) {
        final settings = SettingsModel.fromJson(response);
        return settings.data['message'] as String?;
      }
      return null;
    }
  }

  Future<void> broadcastAnnouncement(String message) async {
    if (_useMock) {
      final index = _mockSettings.indexWhere((x) => x.id == 'announcement');
      final newAnn = SettingsModel(
        appUserId: 'global',
        id: 'announcement',
        data: {'message': message},
        updatedAt: DateTime.now(),
      );
      if (index != -1) {
        _mockSettings[index] = newAnn;
      } else {
        _mockSettings.add(newAnn);
      }
    } else {
      await Supabase.instance.client.from('settings').upsert({
        'app_user_id': 'global',
        'id': 'announcement',
        'data': {'message': message},
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<void> clearAnnouncement() async {
    if (_useMock) {
      _mockSettings.removeWhere((x) => x.id == 'announcement');
    } else {
      await Supabase.instance.client
          .from('settings')
          .delete()
          .eq('app_user_id', 'global')
          .eq('id', 'announcement');
    }
  }

  // --- 4. Outlets Directory Management ---

  Future<List<RestaurantProfileModel>> fetchOutlets() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockProfiles;
    } else {
      final response = await Supabase.instance.client
          .from('restaurant_profile')
          .select('*')
          .not('id', 'eq', 'pricing_plans')
          .order('restaurant_name');
      return (response as List).map((x) => RestaurantProfileModel.fromJson(x)).toList();
    }
  }

  Future<void> extendSubscription({
    required String outletId,
    required String appUserId,
    required int daysCount,
    required double currentExpiry,
  }) async {
    final baseTime = currentExpiry > DateTime.now().millisecondsSinceEpoch
        ? currentExpiry
        : DateTime.now().millisecondsSinceEpoch.toDouble();
    final newExpiry = baseTime + (daysCount * 24 * 60 * 60 * 1000);

    if (_useMock) {
      final index = _mockProfiles.indexWhere((x) => x.id == outletId);
      if (index != -1) {
        final cur = _mockProfiles[index];
        _mockProfiles[index] = RestaurantProfileModel(
          id: cur.id,
          appUserId: cur.appUserId,
          restaurantName: cur.restaurantName,
          phone: cur.phone,
          email: cur.email,
          address: cur.address,
          gstNumber: cur.gstNumber,
          fssaiNumber: cur.fssaiNumber,
          upiId: cur.upiId,
          subscriptionStatus: cur.subscriptionStatus == 'premium' ? 'premium' : 'trial',
          subscriptionExpiry: newExpiry,
          subscriptionPlan: cur.subscriptionPlan,
          restaurantCode: cur.restaurantCode,
          licenseKey: cur.licenseKey,
          updatedAt: DateTime.now(),
        );
      }
    } else {
      final status = await Supabase.instance.client
          .from('restaurant_profile')
          .select('subscription_status')
          .eq('id', outletId)
          .single();
      final currentStatus = status['subscription_status'] as String? ?? 'trial';

      await Supabase.instance.client.from('restaurant_profile').update({
        'subscription_status': currentStatus == 'premium' ? 'premium' : 'trial',
        'subscription_expiry': newExpiry.toInt(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('app_user_id', appUserId).eq('id', outletId);
    }
  }

  Future<void> suspendOutlet({required String outletId, required String appUserId}) async {
    if (_useMock) {
      final index = _mockProfiles.indexWhere((x) => x.id == outletId);
      if (index != -1) {
        final cur = _mockProfiles[index];
        _mockProfiles[index] = RestaurantProfileModel(
          id: cur.id,
          appUserId: cur.appUserId,
          restaurantName: cur.restaurantName,
          phone: cur.phone,
          email: cur.email,
          address: cur.address,
          gstNumber: cur.gstNumber,
          fssaiNumber: cur.fssaiNumber,
          upiId: cur.upiId,
          subscriptionStatus: 'suspended',
          subscriptionExpiry: (DateTime.now().millisecondsSinceEpoch - 1000).toDouble(),
          subscriptionPlan: 'suspended',
          restaurantCode: cur.restaurantCode,
          licenseKey: cur.licenseKey,
          updatedAt: DateTime.now(),
        );
      }
    } else {
      await Supabase.instance.client.from('restaurant_profile').update({
        'subscription_status': 'suspended',
        'subscription_plan': 'suspended',
        'subscription_expiry': DateTime.now().millisecondsSinceEpoch - 1000,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('app_user_id', appUserId).eq('id', outletId);
    }
  }

  Future<void> changeSubscriptionTier({
    required String outletId,
    required String appUserId,
    required String tierStatus,
    required String planName,
    required double expiryTimestamp,
  }) async {
    if (_useMock) {
      final index = _mockProfiles.indexWhere((x) => x.id == outletId);
      if (index != -1) {
        final cur = _mockProfiles[index];
        _mockProfiles[index] = RestaurantProfileModel(
          id: cur.id,
          appUserId: cur.appUserId,
          restaurantName: cur.restaurantName,
          phone: cur.phone,
          email: cur.email,
          address: cur.address,
          gstNumber: cur.gstNumber,
          fssaiNumber: cur.fssaiNumber,
          upiId: cur.upiId,
          subscriptionStatus: tierStatus,
          subscriptionExpiry: expiryTimestamp,
          subscriptionPlan: planName,
          restaurantCode: cur.restaurantCode,
          licenseKey: cur.licenseKey,
          updatedAt: DateTime.now(),
        );
      }
    } else {
      await Supabase.instance.client.from('restaurant_profile').update({
        'subscription_status': tierStatus,
        'subscription_plan': planName,
        'subscription_expiry': expiryTimestamp.toInt(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('app_user_id', appUserId).eq('id', outletId);
    }
  }

  // --- 5. Licenses Engine & Revoke Cascades ---

  Future<List<LicenseModel>> fetchLicenses() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockLicenses;
    } else {
      final response = await Supabase.instance.client
          .from('licenses')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((x) => LicenseModel.fromJson(x)).toList();
    }
  }

  Future<LicenseModel> createLicense({
    required String planType,
    required String restaurantCode,
    required int expiryDays,
  }) async {
    final planCode = planType == 'lifetime'
        ? 'LIF'
        : planType == 'yearly'
            ? 'Y01'
            : planType == 'half-yearly'
                ? 'M06'
                : 'M01';
    final expiryTimestamp = DateTime.now().add(Duration(days: expiryDays)).millisecondsSinceEpoch;

    String signatureKey = '';

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      signatureKey = await _cryptoService.signLicenseLocally(
        planCode: planCode,
        expiry: expiryTimestamp,
        restaurantCode: restaurantCode,
      );
    } else {
      try {
        final response = await Supabase.instance.client.functions.invoke(
          'sign-license',
          body: {
            'planCode': planCode,
            'expiry': expiryTimestamp,
            'restaurantCode': restaurantCode,
          },
        );
        signatureKey = response.data['signature'] as String;
      } catch (e) {
        // Cryptographic P-256 local signature fallback
        signatureKey = await _cryptoService.signLicenseLocally(
          planCode: planCode,
          expiry: expiryTimestamp,
          restaurantCode: restaurantCode,
        );
      }
    }

    final keySignature = 'RESPOS-$planCode-$expiryTimestamp-$signatureKey';

    final newLicense = LicenseModel(
      id: _useMock ? 'lic-${DateTime.now().millisecondsSinceEpoch}' : '',
      licenseKey: keySignature,
      planType: planType,
      expiryDays: expiryDays,
      status: 'active',
      restaurantCode: restaurantCode,
      createdAt: DateTime.now(),
    );

    if (_useMock) {
      _mockLicenses.insert(0, newLicense);
      return newLicense;
    } else {
      final response = await Supabase.instance.client
          .from('licenses')
          .insert(newLicense.toJson())
          .select()
          .single();
      return LicenseModel.fromJson(response);
    }
  }

  Future<void> revokeLicense(String licenseId, String? claimedByUserId) async {
    if (_useMock) {
      final idx = _mockLicenses.indexWhere((x) => x.id == licenseId);
      if (idx != -1) {
        final l = _mockLicenses[idx];
        _mockLicenses[idx] = LicenseModel(
          id: l.id,
          licenseKey: l.licenseKey,
          planType: l.planType,
          expiryDays: l.expiryDays,
          status: 'revoked',
          restaurantCode: l.restaurantCode,
          claimedByUserId: null,
          claimedAt: null,
          createdAt: l.createdAt,
        );
      }
      
      // Cascade downgrade to target claiming profile
      if (claimedByUserId != null) {
        final profileIdx = _mockProfiles.indexWhere((x) => x.appUserId == claimedByUserId);
        if (profileIdx != -1) {
          final cur = _mockProfiles[profileIdx];
          _mockProfiles[profileIdx] = RestaurantProfileModel(
            id: cur.id,
            appUserId: cur.appUserId,
            restaurantName: cur.restaurantName,
            phone: cur.phone,
            email: cur.email,
            address: cur.address,
            gstNumber: cur.gstNumber,
            fssaiNumber: cur.fssaiNumber,
            upiId: cur.upiId,
            subscriptionStatus: 'trial',
            subscriptionExpiry: (DateTime.now().millisecondsSinceEpoch - 1000).toDouble(),
            subscriptionPlan: 'free-trial',
            restaurantCode: cur.restaurantCode,
            licenseKey: '',
            updatedAt: DateTime.now(),
          );
        }
      }
    } else {
      // 1. Update license state to revoked
      await Supabase.instance.client.from('licenses').update({
        'status': 'revoked',
        'claimed_by_user_id': null,
        'claimed_at': null,
      }).eq('id', licenseId);

      // 2. Cascade downgrade to POS restaurant client
      if (claimedByUserId != null) {
        await Supabase.instance.client.from('restaurant_profile').update({
          'subscription_status': 'trial',
          'subscription_plan': 'free-trial',
          'subscription_expiry': DateTime.now().millisecondsSinceEpoch - 1000,
          'license_key': '',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('app_user_id', claimedByUserId);
      }
    }
  }

  // --- 6. Plans CRUD Manager ---

  Future<List<PlanModel>> fetchPlans() async {
    if (_useMock) {
      return _mockPlans;
    } else {
      final response = await Supabase.instance.client
          .from('subscription_plans')
          .select('*')
          .order('price', ascending: true);
      return (response as List).map((x) => PlanModel.fromJson(x)).toList();
    }
  }

  Future<void> togglePlanStatus(String planId, bool newStatus) async {
    if (_useMock) {
      final idx = _mockPlans.indexWhere((x) => x.id == planId);
      if (idx != -1) {
        final p = _mockPlans[idx];
        _mockPlans[idx] = PlanModel(
          id: p.id,
          name: p.name,
          price: p.price,
          durationDays: p.durationDays,
          features: p.features,
          isActive: newStatus,
        );
      }
      await _syncLegacyPlansMock();
    } else {
      await Supabase.instance.client.from('subscription_plans').update({
        'is_active': newStatus,
      }).eq('id', planId);
      await syncLegacyPlans();
    }
  }

  Future<void> upsertPlan(PlanModel plan) async {
    if (_useMock) {
      final idx = _mockPlans.indexWhere((x) => x.id == plan.id);
      if (idx != -1) {
        _mockPlans[idx] = plan;
      } else {
        _mockPlans.add(plan);
      }
      await _syncLegacyPlansMock();
    } else {
      await Supabase.instance.client.from('subscription_plans').upsert(plan.toJson());
      await syncLegacyPlans();
    }
  }

  Future<void> deletePlan(String planId) async {
    if (_useMock) {
      _mockPlans.removeWhere((x) => x.id == planId);
      await _syncLegacyPlansMock();
    } else {
      await Supabase.instance.client.from('subscription_plans').delete().eq('id', planId);
      await syncLegacyPlans();
    }
  }

  Future<void> _syncLegacyPlansMock() async {
    final activePlans = _mockPlans.where((p) => p.isActive);
    final Map<String, dynamic> pricingMap = {};
    for (var p in activePlans) {
      pricingMap[p.id] = {
        'name': p.name,
        'price': p.price,
        'days': p.durationDays,
        'features': p.features,
      };
    }
    
    final index = _mockSettings.indexWhere((x) => x.id == 'pricing_plans');
    final newSettings = SettingsModel(
      appUserId: 'global',
      id: 'pricing_plans',
      data: pricingMap,
      updatedAt: DateTime.now(),
    );
    
    if (index != -1) {
      _mockSettings[index] = newSettings;
    } else {
      _mockSettings.add(newSettings);
    }
  }

  Future<void> syncLegacyPlans() async {
    final plansList = await fetchPlans();
    final activePlans = plansList.where((p) => p.isActive);
    
    final Map<String, dynamic> pricingMap = {};
    for (var p in activePlans) {
      pricingMap[p.id] = {
        'name': p.name,
        'price': p.price,
        'days': p.durationDays,
        'features': p.features,
      };
    }

    await Supabase.instance.client.from('settings').upsert({
      'app_user_id': 'global',
      'id': 'pricing_plans',
      'data': pricingMap,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // --- 7. Support Ticket Chats Array appenders ---

  Stream<List<TicketModel>> streamTickets() {
    if (_useMock) {
      return _ticketsController.stream;
    } else {
      final controller = StreamController<List<TicketModel>>();
      
      Future<void> fetchAndAdd() async {
        try {
          final response = await Supabase.instance.client
              .from('support_tickets')
              .select('*')
              .order('updated_at', ascending: false);
          final list = (response as List).map((x) => TicketModel.fromJson(x)).toList();
          if (!controller.isClosed) {
            controller.add(list);
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      }

      fetchAndAdd();

      final timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        fetchAndAdd();
      });

      controller.onCancel = () {
        timer.cancel();
        controller.close();
      };

      return controller.stream;
    }
  }

  Future<void> updateTicketStatus(String ticketId, String targetStatus) async {
    if (_useMock) {
      final index = _mockTickets.indexWhere((x) => x.id == ticketId);
      if (index != -1) {
        final t = _mockTickets[index];
        _mockTickets[index] = TicketModel(
          id: t.id,
          customerName: t.customerName,
          subject: t.subject,
          status: targetStatus,
          createdAt: t.createdAt,
          messages: t.messages,
        );
        _ticketsController.add(_mockTickets);
      }
    } else {
      await Supabase.instance.client.from('support_tickets').update({
        'status': targetStatus,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', ticketId);
    }
  }

  Future<void> sendChatMessage(String ticketId, String messageContent) async {
    final newMessage = ChatMessage(
      sender: 'admin',
      content: messageContent,
      timestamp: DateTime.now(),
    );

    if (_useMock) {
      final index = _mockTickets.indexWhere((x) => x.id == ticketId);
      if (index != -1) {
        final ticket = _mockTickets[index];
        ticket.messages.add(newMessage);
        _ticketsController.add(_mockTickets);

        Future.delayed(const Duration(seconds: 3), () {
          final reply = ChatMessage(
            sender: 'customer',
            content: 'Noted. Checking on our end.',
            timestamp: DateTime.now(),
          );
          ticket.messages.add(reply);
          _ticketsController.add(_mockTickets);
        });
      }
    } else {
      // Fetch ticket JSONB replies array
      final response = await Supabase.instance.client
          .from('support_tickets')
          .select('replies')
          .eq('id', ticketId)
          .single();
      
      final currentList = (response['replies'] as List? ?? []);
      currentList.add(newMessage.toJson());

      await Supabase.instance.client.from('support_tickets').update({
        'replies': currentList,
        'status': 'in-progress',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', ticketId);
    }
  }

  Future<void> quickUnblockAndResolve({required String ticketId, required String targetUserId}) async {
    await unblockUser(targetUserId);
    await updateTicketStatus(ticketId, 'resolved');
  }

  // --- 8. Accounts block monitor RPC triggers ---

  Stream<List<ViolationModel>> streamViolations() {
    if (_useMock) {
      return _violationsController.stream;
    } else {
      final controller = StreamController<List<ViolationModel>>();
      
      Future<void> fetchAndAdd() async {
        try {
          final response = await Supabase.instance.client
              .from('user_rate_violations')
              .select('*')
              .order('blocked_at', ascending: false);
          final list = (response as List).map((x) => ViolationModel.fromJson(x)).toList();
          if (!controller.isClosed) {
            controller.add(list);
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      }

      fetchAndAdd();

      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        fetchAndAdd();
      });

      controller.onCancel = () {
        timer.cancel();
        controller.close();
      };

      return controller.stream;
    }
  }

  Future<void> unblockUser(String userId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final idx = _mockViolations.indexWhere((x) => x.userId == userId);
      if (idx != -1) {
        final v = _mockViolations[idx];
        _mockViolations[idx] = ViolationModel(
          userId: v.userId,
          warningCount: 0,
          warningDate: v.warningDate,
          blockedUntil: null,
          blockedAt: null,
          blockedReason: null,
        );
      }
      _violationsController.add(_mockViolations);
    } else {
      await Supabase.instance.client.rpc('admin_unblock_user', params: {
        'p_target_user_id': userId,
      });
    }
  }

  // --- 9. Sequence Override Audits ---

  Future<List<RestaurantSettingsModel>> fetchSequenceSettings() async {
    if (_useMock) {
      return _mockSettingsList;
    } else {
      final response = await Supabase.instance.client
          .from('restaurant_settings')
          .select('id, app_user_id, bill_sequence, updated_at');
      return (response as List).map((x) => RestaurantSettingsModel.fromJson(x)).toList();
    }
  }

  Future<void> overrideBillSequence({required String targetAppUserId, required int newSeqNum}) async {
    if (_useMock) {
      final idx = _mockSettingsList.indexWhere((x) => x.appUserId == targetAppUserId);
      if (idx != -1) {
        final cur = _mockSettingsList[idx];
        _mockSettingsList[idx] = RestaurantSettingsModel(
          id: cur.id,
          appUserId: cur.appUserId,
          billSequence: newSeqNum,
          updatedAt: DateTime.now(),
        );
      }
    } else {
      await Supabase.instance.client
          .from('restaurant_settings')
          .update({
            'bill_sequence': newSeqNum,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('app_user_id', targetAppUserId)
          .eq('id', 'global');
    }
  }

  // --- 10. Financial Analytics Calculations ---

  Future<List<BillModel>> fetchAllBills() async {
    if (_useMock) {
      return _mockBills;
    } else {
      final response = await Supabase.instance.client
          .from('bills')
          .select('id, app_user_id, total, timestamp')
          .order('timestamp', ascending: false);
      return (response as List).map((x) => BillModel.fromJson(x)).toList();
    }
  }

  // --- 11. Database JSON backup and Cascading Restoration sequence Compiler ---

  Future<Map<String, dynamic>> compileDatabaseBackup() async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      
      final Map<String, dynamic> backupData = {
        'licenses': _mockLicenses.map((x) => x.toJson()).toList(),
        'subscription_plans': _mockPlans.map((x) => x.toJson()).toList(),
        'settings': _mockSettings.map((x) => x.toJson()).toList(),
        'restaurant_profile': _mockProfiles.map((x) => x.toJson()).toList(),
        'restaurant_settings': _mockSettingsList.map((x) => x.toJson()).toList(),
        'support_tickets': _mockTickets.map((x) => x.toJson()).toList(),
        'user_rate_violations': _mockViolations.map((x) => x.toJson()).toList(),
        'bills': _mockBills.map((x) => x.toJson()).toList(),
      };
      
      // Update backups list logs
      final fileName = 'manual_siya_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final newBackup = BackupModel(
        name: fileName,
        sizeBytes: jsonEncode(backupData).length,
        createdAt: DateTime.now(),
        path: 'backups/$fileName',
      );
      _mockBackups.insert(0, newBackup);
      return backupData;
    } else {
      // Parallel execution of all 14 tables in production
      final results = await Future.wait([
        Supabase.instance.client.from('licenses').select('*'),
        Supabase.instance.client.from('subscription_plans').select('*'),
        Supabase.instance.client.from('support_tickets').select('*'),
        Supabase.instance.client.from('settings').select('*'),
        Supabase.instance.client.from('restaurant_profile').select('*'),
        Supabase.instance.client.from('restaurant_settings').select('*'),
        Supabase.instance.client.from('user_rate_violations').select('*'),
        Supabase.instance.client.from('bills').select('*'),
        // Add rest of the 14 tables
      ]);

      final Map<String, dynamic> backupPayload = {
        'licenses': results[0],
        'subscription_plans': results[1],
        'support_tickets': results[2],
        'settings': results[3],
        'restaurant_profile': results[4],
        'restaurant_settings': results[5],
        'user_rate_violations': results[6],
        'bills': results[7],
      };

      // Upload JSON file back to Storage Bucket or log it
      final logName = 'siya_db_snapshot_${DateTime.now().millisecondsSinceEpoch}.json';
      try {
        await Supabase.instance.client.storage
            .from('backups')
            .uploadBinary(logName, utf8.encode(jsonEncode(backupPayload)));
      } catch (e) {
        debugPrint('Failed to upload snapshot to Supabase Storage: $e');
      }

      return backupPayload;
    }
  }

  Future<void> executeCascadingRestoration(Map<String, dynamic> backup) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      // Basic format validation
      if (!backup.containsKey('restaurant_profile') || !backup.containsKey('licenses')) {
        throw Exception('Restoration Compiler Error: Missing profile/licenses tables validation metadata.');
      }
      return;
    } else {
      // STRICT 3-Phase Cascading sequential compilation
      // PHASE 1: Independent Tables Configuration (Settings, plans)
      if (backup.containsKey('subscription_plans')) {
        final list = backup['subscription_plans'] as List;
        for (var p in list) {
          await Supabase.instance.client.from('subscription_plans').upsert(p);
        }
      }
      if (backup.containsKey('settings')) {
        final list = backup['settings'] as List;
        for (var s in list) {
          await Supabase.instance.client.from('settings').upsert(s);
        }
      }

      // PHASE 2: Core Store Operations profiles
      if (backup.containsKey('restaurant_profile')) {
        final list = backup['restaurant_profile'] as List;
        for (var p in list) {
          await Supabase.instance.client.from('restaurant_profile').upsert(p);
        }
      }
      if (backup.containsKey('restaurant_settings')) {
        final list = backup['restaurant_settings'] as List;
        for (var s in list) {
          await Supabase.instance.client.from('restaurant_settings').upsert(s);
        }
      }

      // PHASE 3: Line items logs and detailed records
      if (backup.containsKey('licenses')) {
        final list = backup['licenses'] as List;
        for (var l in list) {
          await Supabase.instance.client.from('licenses').upsert(l);
        }
      }
      if (backup.containsKey('support_tickets')) {
        final list = backup['support_tickets'] as List;
        for (var t in list) {
          await Supabase.instance.client.from('support_tickets').upsert(t);
        }
      }
      if (backup.containsKey('user_rate_violations')) {
        final list = backup['user_rate_violations'] as List;
        for (var v in list) {
          await Supabase.instance.client.from('user_rate_violations').upsert(v);
        }
      }
      if (backup.containsKey('bills')) {
        final list = backup['bills'] as List;
        for (var b in list) {
          await Supabase.instance.client.from('bills').upsert(b);
        }
      }
    }
  }

  Future<List<BackupModel>> fetchBackups() async {
    if (_useMock) {
      return _mockBackups;
    } else {
      try {
        final response = await Supabase.instance.client.storage
            .from('backups')
            .list();
        return response.map((f) => BackupModel(
          name: f.name,
          sizeBytes: f.metadata?['size'] as int? ?? 0,
          createdAt: f.createdAt != null ? DateTime.parse(f.createdAt!) : DateTime.now(),
          path: 'backups/${f.name}',
        )).toList();
      } catch (e) {
        debugPrint('Storage Bucket fetch failed: $e');
        return [];
      }
    }
  }
}
