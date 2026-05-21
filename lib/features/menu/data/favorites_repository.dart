import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sevimli taomlar: kirgan foydalanuvchi — Firestore, mehmon — SharedPreferences.
class FavoritesRepository {
  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static const _prefsKey = 'favorite_product_ids';

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _localController = StreamController<Set<String>>.broadcast();

  String? get _uid => _auth.currentUser?.uid;

  Stream<Set<String>> watchIds() {
    final uid = _uid;
    if (uid != null) {
      return _db.collection('users').doc(uid).snapshots().map((snap) {
        final raw = snap.data()?['favoriteIds'];
        if (raw is List) {
          return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toSet();
        }
        return <String>{};
      });
    }
    unawaited(_emitLocal());
    return _localController.stream;
  }

  Future<Set<String>> fetchIds() async {
    final uid = _uid;
    if (uid != null) {
      final snap = await _db.collection('users').doc(uid).get();
      final raw = snap.data()?['favoriteIds'];
      if (raw is List) {
        return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toSet();
      }
      return {};
    }
    return _loadLocal();
  }

  Future<Set<String>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).where((id) => id.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _emitLocal() async {
    if (!_localController.isClosed) {
      _localController.add(await _loadLocal());
    }
  }

  Future<void> _saveLocal(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(ids.toList()));
    await _emitLocal();
  }

  Future<void> toggle(String productId) async {
    if (productId.isEmpty) return;
    final uid = _uid;
    if (uid != null) {
      final ref = _db.collection('users').doc(uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data() ?? {};
        final current = <String>{};
        final raw = data['favoriteIds'];
        if (raw is List) {
          current.addAll(raw.map((e) => e.toString()));
        }
        if (current.contains(productId)) {
          current.remove(productId);
        } else {
          current.add(productId);
        }
        tx.set(ref, {'favoriteIds': current.toList()}, SetOptions(merge: true));
      });
      return;
    }
    final local = await _loadLocal();
    if (local.contains(productId)) {
      local.remove(productId);
    } else {
      local.add(productId);
    }
    await _saveLocal(local);
  }
}
