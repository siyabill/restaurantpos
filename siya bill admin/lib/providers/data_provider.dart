import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';
import '../models/license.dart';
import '../models/violation.dart';
import '../models/restaurant_profile.dart';
import '../models/restaurant_settings.dart';
import '../models/ticket.dart';
import '../models/backup.dart';
import '../models/plan.dart';
import '../models/bill.dart';

// --- Outlets Directory Provider ---
class OutletsNotifier extends StateNotifier<AsyncValue<List<RestaurantProfileModel>>> {
  final Ref _ref;

  OutletsNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(supabaseServiceProvider).fetchOutlets();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> extendTrial({
    required String outletId,
    required String appUserId,
    required int days,
    required double currentExpiry,
  }) async {
    try {
      await _ref.read(supabaseServiceProvider).extendSubscription(
        outletId: outletId,
        appUserId: appUserId,
        daysCount: days,
        currentExpiry: currentExpiry,
      );
      await refresh();
    } catch (e) {
      // Keep state but notify views
      rethrow;
    }
  }

  Future<void> suspend({required String outletId, required String appUserId}) async {
    try {
      await _ref.read(supabaseServiceProvider).suspendOutlet(outletId: outletId, appUserId: appUserId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeTier({
    required String outletId,
    required String appUserId,
    required String status,
    required String planName,
    required double expiry,
  }) async {
    try {
      await _ref.read(supabaseServiceProvider).changeSubscriptionTier(
        outletId: outletId,
        appUserId: appUserId,
        tierStatus: status,
        planName: planName,
        expiryTimestamp: expiry,
      );
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

final outletsProvider = StateNotifierProvider<OutletsNotifier, AsyncValue<List<RestaurantProfileModel>>>((ref) {
  return OutletsNotifier(ref);
});

// --- Active Violations Stream Provider ---
final violationsStreamProvider = StreamProvider<List<ViolationModel>>((ref) {
  return ref.read(supabaseServiceProvider).streamViolations();
});

// --- Support Tickets Chat Stream Provider ---
final ticketsStreamProvider = StreamProvider<List<TicketModel>>((ref) {
  return ref.read(supabaseServiceProvider).streamTickets();
});

// --- Licenses Manager State Provider ---
class LicensesNotifier extends StateNotifier<AsyncValue<List<LicenseModel>>> {
  final Ref _ref;

  LicensesNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(supabaseServiceProvider).fetchLicenses();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateNewLicense({
    required String planType,
    required String restaurantCode,
    required int expiryDays,
  }) async {
    try {
      final currentList = state.value ?? [];
      state = const AsyncValue.loading();
      final newLic = await _ref.read(supabaseServiceProvider).createLicense(
        planType: planType,
        restaurantCode: restaurantCode,
        expiryDays: expiryDays,
      );
      state = AsyncValue.data([newLic, ...currentList]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> revoke({required String licenseId, String? claimedByUserId}) async {
    try {
      await _ref.read(supabaseServiceProvider).revokeLicense(licenseId, claimedByUserId);
      await refresh();
      // Also refresh outlets to sync cascade downgrade
      _ref.read(outletsProvider.notifier).refresh();
    } catch (e) {
      rethrow;
    }
  }
}

final licensesProvider = StateNotifierProvider<LicensesNotifier, AsyncValue<List<LicenseModel>>>((ref) {
  return LicensesNotifier(ref);
});

// --- Dynamic Pricing Plans CRUD Provider ---
class PlansNotifier extends StateNotifier<AsyncValue<List<PlanModel>>> {
  final Ref _ref;

  PlansNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(supabaseServiceProvider).fetchPlans();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleActive(String planId, bool active) async {
    try {
      await _ref.read(supabaseServiceProvider).togglePlanStatus(planId, active);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> savePlan(PlanModel plan) async {
    try {
      await _ref.read(supabaseServiceProvider).upsertPlan(plan);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePlan(String planId) async {
    try {
      await _ref.read(supabaseServiceProvider).deletePlan(planId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

final plansProvider = StateNotifierProvider<PlansNotifier, AsyncValue<List<PlanModel>>>((ref) {
  return PlansNotifier(ref);
});

// --- Global Announcement Provider ---
final announcementProvider = FutureProvider<String?>((ref) async {
  return ref.read(supabaseServiceProvider).fetchActiveAnnouncement();
});

// --- Presence Audit Count ---
final livePresenceCountProvider = FutureProvider<int>((ref) async {
  return ref.read(supabaseServiceProvider).fetchLivePresenceCount();
});

// --- Sequence Override Settings Provider ---
class SequenceSettingsNotifier extends StateNotifier<AsyncValue<List<RestaurantSettingsModel>>> {
  final Ref _ref;

  SequenceSettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(supabaseServiceProvider).fetchSequenceSettings();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSequence(String appUserId, int newSequence) async {
    try {
      await _ref.read(supabaseServiceProvider).overrideBillSequence(
        targetAppUserId: appUserId,
        newSeqNum: newSequence,
      );
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

final sequenceSettingsProvider = StateNotifierProvider<SequenceSettingsNotifier, AsyncValue<List<RestaurantSettingsModel>>>((ref) {
  return SequenceSettingsNotifier(ref);
});

// --- Ecosystem Bills Provider (for financial analytics calculations) ---
final billsProvider = FutureProvider<List<BillModel>>((ref) async {
  return ref.read(supabaseServiceProvider).fetchAllBills();
});

// --- Analytics Period State ---
final analyticsPeriodProvider = StateProvider<String>((ref) => 'Last 30 Days');

// --- Database Backups State Provider ---
class BackupsNotifier extends StateNotifier<AsyncValue<List<BackupModel>>> {
  final Ref _ref;

  BackupsNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(supabaseServiceProvider).fetchBackups();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> triggerNewSnapshot() async {
    try {
      final currentList = state.value ?? [];
      state = const AsyncValue.loading();
      await _ref.read(supabaseServiceProvider).compileDatabaseBackup();
      final list = await _ref.read(supabaseServiceProvider).fetchBackups();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> restoreSnapshot(Map<String, dynamic> jsonPayload) async {
    try {
      state = const AsyncValue.loading();
      await _ref.read(supabaseServiceProvider).executeCascadingRestoration(jsonPayload);
      await refresh();
      // Force refresh data modules after restoration
      _ref.read(outletsProvider.notifier).refresh();
      _ref.read(licensesProvider.notifier).refresh();
      _ref.read(plansProvider.notifier).refresh();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final backupsProvider = StateNotifierProvider<BackupsNotifier, AsyncValue<List<BackupModel>>>((ref) {
  return BackupsNotifier(ref);
});

