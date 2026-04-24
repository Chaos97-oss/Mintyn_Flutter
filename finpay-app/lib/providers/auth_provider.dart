import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    this.title = 'UX/UI Designer',
    this.profilePhotoPath,
  });

  final String name;
  final String email;
  final String title;
  final String? profilePhotoPath;

  AppUser copyWith({
    String? name,
    String? email,
    String? title,
    String? profilePhotoPath,
    bool clearPhoto = false,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      title: title ?? this.title,
      profilePhotoPath: clearPhoto ? null : (profilePhotoPath ?? this.profilePhotoPath),
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      if (s.length >= 2) return s.substring(0, 2).toUpperCase();
      return s.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _restore();
  }

  static const _kLoggedIn = 'auth_logged_in';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_name';
  static const _kTitle = 'auth_title';
  static const _kPhoto = 'auth_profile_photo_path';

  AppUser? _user;
  bool _isLoggedIn = false;
  bool _ready = false;

  bool get isReady => _ready;
  bool get isLoggedIn => _isLoggedIn;
  AppUser? get user => _user;

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    _isLoggedIn = p.getBool(_kLoggedIn) ?? false;
    if (_isLoggedIn) {
      final email = p.getString(_kEmail) ?? 'tayyabsohailabd@gmail.com';
      final name = p.getString(_kName) ?? 'Tayyab Sohail';
      final title = p.getString(_kTitle) ?? 'UX/UI Designer';
      final photo = p.getString(_kPhoto);
      _user = AppUser(name: name, email: email, title: title, profilePhotoPath: photo);
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password, String? name}) async {
    final p = await SharedPreferences.getInstance();
    final resolvedName = name ?? 'Tayyab Sohail';
    _user = AppUser(name: resolvedName, email: email, title: 'UX/UI Designer', profilePhotoPath: p.getString(_kPhoto));
    _isLoggedIn = true;
    await p.setBool(_kLoggedIn, true);
    await p.setString(_kEmail, email);
    await p.setString(_kName, resolvedName);
    await p.setString(_kTitle, _user!.title);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? title,
    String? profilePhotoPath,
    bool clearPhoto = false,
  }) async {
    if (_user == null) return;
    final p = await SharedPreferences.getInstance();
    final next = _user!.copyWith(
      name: name,
      email: email,
      title: title,
      profilePhotoPath: profilePhotoPath,
      clearPhoto: clearPhoto,
    );
    _user = next;
    await p.setString(_kName, next.name);
    await p.setString(_kEmail, next.email);
    await p.setString(_kTitle, next.title);
    if (clearPhoto || profilePhotoPath != null) {
      if (clearPhoto) {
        await p.remove(_kPhoto);
      } else if (profilePhotoPath != null) {
        await p.setString(_kPhoto, profilePhotoPath);
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _user = null;
    await p.setBool(_kLoggedIn, false);
    await p.remove(_kEmail);
    await p.remove(_kName);
    await p.remove(_kTitle);
    await p.remove(_kPhoto);
    notifyListeners();
  }
}
