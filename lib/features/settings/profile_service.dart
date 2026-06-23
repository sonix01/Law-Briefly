import 'dart:async';
import 'package:flutter/foundation.dart';
import 'profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel?> fetch(String userId);
  Future<ProfileModel>  upsert(ProfileModel profile);
  Future<void>          delete(String userId);
  Stream<ProfileModel?> watch(String userId);
}

class _InMemoryProfileRepository implements ProfileRepository {
  final Map<String, ProfileModel> _store = {};
  final StreamController<ProfileModel?> _ctrl =
      StreamController<ProfileModel?>.broadcast();

  @override
  Future<ProfileModel?> fetch(String userId) async {
    await Future.delayed(Duration.zero);
    return _store[userId];
  }

  @override
  Future<ProfileModel> upsert(ProfileModel profile) async {
    await Future.delayed(Duration.zero);
    _store[profile.id] = profile;
    _ctrl.add(profile);
    return profile;
  }

  @override
  Future<void> delete(String userId) async {
    await Future.delayed(Duration.zero);
    _store.remove(userId);
    _ctrl.add(null);
  }

  @override
  Stream<ProfileModel?> watch(String userId) =>
      _ctrl.stream.where((_) => _store.containsKey(userId) || _ == null);

  void dispose() => _ctrl.close();
}

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _currentUserId = 'current_user';

  ProfileRepository _repo = _InMemoryProfileRepository();

  // ── GET PROFILE ─────────────────────────────────

  Future<ProfileModel?> getProfile() async {
    try {
      return await _repo.fetch(_currentUserId);
    } catch (e) {
      debugPrint('[ProfileService] getProfile error: $e');
      return null;
    }
  }

  Stream<ProfileModel?> watchProfile() => _repo.watch(_currentUserId);

  // ── SAVE PROFILE ────────────────────────────────

  Future<ProfileModel> saveProfile(ProfileModel profile) async {
    final toSave = profile.copyWith(
      id:        _currentUserId,
      updatedAt: DateTime.now(),
    );
    try {
      final saved = await _repo.upsert(toSave);
      debugPrint('[ProfileService] Saved: ${saved.fullName}');
      return saved;
    } catch (e) {
      debugPrint('[ProfileService] saveProfile error: $e');
      rethrow;
    }
  }

  // ── UPDATE PROFILE ───────────────────────────────

  Future<ProfileModel?> updateProfile({
    String? fullName,
    String? email,
    String? mobileNumber,
    String? college,
    String? course,
    String? semester,
    String? city,
    String? state,
  }) async {
    final existing = await getProfile();
    final base     = existing ?? ProfileModel.empty();

    final updated = base.copyWith(
      fullName:     fullName,
      email:        email,
      mobileNumber: mobileNumber,
      college:      college,
      course:       course,
      semester:     semester,
      city:         city,
      state:        state,
      updatedAt:    DateTime.now(),
    );

    return saveProfile(updated);
  }

  // ── DELETE PROFILE ───────────────────────────────

  Future<void> deleteProfile() async {
    try {
      await _repo.delete(_currentUserId);
      debugPrint('[ProfileService] Profile deleted.');
    } catch (e) {
      debugPrint('[ProfileService] deleteProfile error: $e');
      rethrow;
    }
  }

  // ── SEED (for first launch) ──────────────────────

  Future<ProfileModel> seedDefaultProfile() async {
    final defaultProfile = ProfileModel(
      id:           _currentUserId,
      fullName:     'Arjun Sharma',
      email:        'arjun.sharma@example.com',
      mobileNumber: '+91 98765 43210',
      college:      'National Law School of India University',
      course:       'BALLB (Hons.)',
      semester:     '3rd Semester',
      city:         'Bengaluru',
      state:        'Karnataka',
      createdAt:    DateTime.now(),
    );
    return saveProfile(defaultProfile);
  }

  void setRepository(ProfileRepository repository) => _repo = repository;
}