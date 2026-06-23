// lib/features/settings/profile_screen.dart
// Law Briefly — Profile Screen
// iOS 18 Liquid Glass | Apple-Style Grouped Form | Production-Ready

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — USER PROFILE MODEL (ISAR-ready)
// ─────────────────────────────────────────────

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String college;
  final String course;
  final String semester;
  final String city;
  final String state;
  final DateTime? createdAt;    // Future: sync
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.college,
    required this.course,
    required this.semester,
    required this.city,
    required this.state,
    this.createdAt,
    this.updatedAt,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String get courseAndSemester {
    if (course.isEmpty && semester.isEmpty) return 'Law Student';
    if (course.isEmpty) return semester;
    if (semester.isEmpty) return course;
    return '$course · $semester';
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? mobileNumber,
    String? college,
    String? course,
    String? semester,
    String? city,
    String? state,
    DateTime? updatedAt,
  }) =>
      UserProfile(
        id:           id,
        fullName:     fullName     ?? this.fullName,
        email:        email        ?? this.email,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        college:      college      ?? this.college,
        course:       course       ?? this.course,
        semester:     semester     ?? this.semester,
        city:         city         ?? this.city,
        state:        state        ?? this.state,
        createdAt:    createdAt,
        updatedAt:    updatedAt    ?? this.updatedAt,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id:           json['id']             as String,
        fullName:     json['full_name']      as String,
        email:        json['email']          as String,
        mobileNumber: json['mobile_number']  as String,
        college:      json['college']        as String,
        course:       json['course']         as String,
        semester:     json['semester']       as String,
        city:         json['city']           as String,
        state:        json['state']          as String,
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'full_name':     fullName,
        'email':         email,
        'mobile_number': mobileNumber,
        'college':       college,
        'course':        course,
        'semester':      semester,
        'city':          city,
        'state':         state,
      };
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA
// ─────────────────────────────────────────────

abstract final class MockProfileData {
  static const UserProfile profile = UserProfile(
    id:           'user_001',
    fullName:     'Arjun Sharma',
    email:        'arjun.sharma@gmail.com',
    mobileNumber: '+91 98765 43210',
    college:      'National Law School of India University',
    course:       'BALLB (Hons.)',
    semester:     '3rd Semester',
    city:         'Bengaluru',
    state:        'Karnataka',
  );
}

// ─────────────────────────────────────────────
// MARK: — PICKER OPTIONS
// ─────────────────────────────────────────────

abstract final class _PickerOptions {
  static const List<String> courses = [
    'BALLB (Hons.)', 'BALLB', 'BA LLB', 'BBA LLB',
    'BCom LLB', 'BSc LLB', 'LLB (3-Year)', 'LLM',
    'LLD', 'PhD (Law)', 'Diploma in Law', 'Other',
  ];

  static const List<String> semesters = [
    '1st Semester', '2nd Semester', '3rd Semester', '4th Semester',
    '5th Semester', '6th Semester', '7th Semester', '8th Semester',
    '9th Semester', '10th Semester',
  ];

  static const List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Jammu & Kashmir', 'Ladakh',
    'Chandigarh', 'Puducherry', 'Other',
  ];
}

// ─────────────────────────────────────────────
// MARK: — PROFILE SCREEN
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const ProfileScreen({super.key, this.onSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  // ── Data ──────────────────────────────────────
  late UserProfile _originalProfile;

  // ── Controllers ───────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _collegeController;
  late final TextEditingController _cityController;

  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _mobileFocus;
  late final FocusNode _collegeFocus;
  late final FocusNode _cityFocus;

  // ── Picker state ──────────────────────────────
  String _selectedCourse   = '';
  String _selectedSemester = '';
  String _selectedState    = '';

  // ── UI state ──────────────────────────────────
  bool _hasChanges     = false;
  bool _isSaving       = false;
  bool _nameFocused    = false;
  bool _emailFocused   = false;
  bool _mobileFocused  = false;
  bool _collegeFocused = false;
  bool _cityFocused    = false;

  // ── Animations ────────────────────────────────
  late AnimationController _entranceController;
  late AnimationController _saveController;
  late Animation<double>   _avatarFade;
  late Animation<Offset>   _avatarSlide;
  late Animation<double>   _formFade;
  late Animation<Offset>   _formSlide;
  late Animation<double>   _buttonsFade;
  late Animation<double>   _saveScale;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _originalProfile = MockProfileData.profile;
    _initControllers();
    _setupAnimations();
    _startEntrance();
  }

  void _initControllers() {
    final p = _originalProfile;
    _nameController    = TextEditingController(text: p.fullName);
    _emailController   = TextEditingController(text: p.email);
    _mobileController  = TextEditingController(text: p.mobileNumber);
    _collegeController = TextEditingController(text: p.college);
    _cityController    = TextEditingController(text: p.city);

    _selectedCourse   = p.course;
    _selectedSemester = p.semester;
    _selectedState    = p.state;

    _nameFocus    = FocusNode()..addListener(() => setState(() => _nameFocused    = _nameFocus.hasFocus));
    _emailFocus   = FocusNode()..addListener(() => setState(() => _emailFocused   = _emailFocus.hasFocus));
    _mobileFocus  = FocusNode()..addListener(() => setState(() => _mobileFocused  = _mobileFocus.hasFocus));
    _collegeFocus = FocusNode()..addListener(() => setState(() => _collegeFocused = _collegeFocus.hasFocus));
    _cityFocus    = FocusNode()..addListener(() => setState(() => _cityFocused    = _cityFocus.hasFocus));

    for (final c in [
      _nameController, _emailController, _mobileController,
      _collegeController, _cityController,
    ]) {
      c.addListener(_checkChanges);
    }
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _avatarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOut),
      ),
    );
    _avatarSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.65, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _buttonsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.52, 0.90, curve: Curves.easeOut),
      ),
    );

    _saveScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.94).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_saveController);
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _saveController.dispose();
    for (final c in [
      _nameController, _emailController, _mobileController,
      _collegeController, _cityController,
    ]) { c.dispose(); }
    for (final f in [
      _nameFocus, _emailFocus, _mobileFocus, _collegeFocus, _cityFocus,
    ]) { f.dispose(); }
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — CHANGE DETECTION
  // ─────────────────────────────────────────────

  void _checkChanges() {
    final p = _originalProfile;
    final changed = _nameController.text    != p.fullName
        || _emailController.text            != p.email
        || _mobileController.text           != p.mobileNumber
        || _collegeController.text          != p.college
        || _selectedCourse                  != p.course
        || _selectedSemester                != p.semester
        || _cityController.text             != p.city
        || _selectedState                   != p.state;

    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_hasChanges) return;
    HapticFeedback.mediumImpact();

    setState(() => _isSaving = true);
    _saveController.forward(from: 0);

    // Simulate brief save (replace with Isar in production)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final updated = _originalProfile.copyWith(
      fullName:     _nameController.text.trim(),
      email:        _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      college:      _collegeController.text.trim(),
      course:       _selectedCourse,
      semester:     _selectedSemester,
      city:         _cityController.text.trim(),
      state:        _selectedState,
      updatedAt:    DateTime.now(),
    );

    setState(() {
      _originalProfile = updated;
      _hasChanges      = false;
      _isSaving        = false;
    });

    widget.onSaved?.call();
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl,
        ),
      ),
    );
  }

  void _resetChanges() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    final p = _originalProfile;
    setState(() {
      _nameController.text    = p.fullName;
      _emailController.text   = p.email;
      _mobileController.text  = p.mobileNumber;
      _collegeController.text = p.college;
      _cityController.text    = p.city;
      _selectedCourse         = p.course;
      _selectedSemester       = p.semester;
      _selectedState          = p.state;
      _hasChanges             = false;
    });
  }

  // ── Picker sheets ─────────────────────────────

  void _showCoursePicker(bool dark) {
    FocusScope.of(context).unfocus();
    GlassBottomSheet.show(
      context,
      initialChildSize: 0.55,
      maxChildSize: 0.75,
      child: _PickerSheet(
        title: 'Select Course',
        options: _PickerOptions.courses,
        selectedValue: _selectedCourse,
        isDark: dark,
        onSelected: (v) {
          Navigator.pop(context);
          setState(() => _selectedCourse = v);
          _checkChanges();
        },
      ),
    );
  }

  void _showSemesterPicker(bool dark) {
    FocusScope.of(context).unfocus();
    GlassBottomSheet.show(
      context,
      initialChildSize: 0.60,
      maxChildSize: 0.78,
      child: _PickerSheet(
        title: 'Select Semester',
        options: _PickerOptions.semesters,
        selectedValue: _selectedSemester,
        isDark: dark,
        onSelected: (v) {
          Navigator.pop(context);
          setState(() => _selectedSemester = v);
          _checkChanges();
        },
      ),
    );
  }

  void _showStatePicker(bool dark) {
    FocusScope.of(context).unfocus();
    GlassBottomSheet.show(
      context,
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      child: _PickerSheet(
        title: 'Select State',
        options: _PickerOptions.states,
        selectedValue: _selectedState,
        isDark: dark,
        onSelected: (v) {
          Navigator.pop(context);
          setState(() => _selectedState = v);
          _checkChanges();
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _ProfileBackground(isDark: dark),

          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.base,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.max,
              ),
              child: Column(
                children: [
                  // ── Unsaved changes banner ──────
                  AnimatedSwitcher(
                    duration: AppAnimation.standard,
                    child: _hasChanges
                        ? _UnsavedChangesBanner(isDark: dark)
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Avatar + header ─────────────
                  FadeTransition(
                    opacity: _avatarFade,
                    child: SlideTransition(
                      position: _avatarSlide,
                      child: _ProfileHeader(
                        profile: _originalProfile,
                        isDark: dark,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Form ────────────────────────
                  FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: _formSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            // Personal
                            _ProfileSection(
                              label: 'PERSONAL INFORMATION',
                              isDark: dark,
                              fields: [
                                _ProfileTextField(
                                  label: 'Full Name',
                                  hint: 'Enter your full name',
                                  controller: _nameController,
                                  focusNode: _nameFocus,
                                  isFocused: _nameFocused,
                                  isDark: dark,
                                  icon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _emailFocus.requestFocus(),
                                  capitalization: TextCapitalization.words,
                                ),
                                _ProfileTextField(
                                  label: 'Email Address',
                                  hint: 'your@email.com',
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  isFocused: _emailFocused,
                                  isDark: dark,
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _mobileFocus.requestFocus(),
                                ),
                                _ProfileTextField(
                                  label: 'Mobile Number',
                                  hint: '+91 XXXXX XXXXX',
                                  controller: _mobileController,
                                  focusNode: _mobileFocus,
                                  isFocused: _mobileFocused,
                                  isDark: dark,
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _collegeFocus.requestFocus(),
                                  isLast: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Academic
                            _ProfileSection(
                              label: 'ACADEMIC INFORMATION',
                              isDark: dark,
                              fields: [
                                _ProfileTextField(
                                  label: 'Law College',
                                  hint: 'Enter your college name',
                                  controller: _collegeController,
                                  focusNode: _collegeFocus,
                                  isFocused: _collegeFocused,
                                  isDark: dark,
                                  icon: Icons.school_outlined,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                  capitalization: TextCapitalization.words,
                                ),
                                _ProfilePickerField(
                                  label: 'Course',
                                  value: _selectedCourse,
                                  hint: 'Select your course',
                                  icon: Icons.menu_book_outlined,
                                  isDark: dark,
                                  onTap: () => _showCoursePicker(dark),
                                ),
                                _ProfilePickerField(
                                  label: 'Semester',
                                  value: _selectedSemester,
                                  hint: 'Select semester',
                                  icon: Icons.calendar_today_outlined,
                                  isDark: dark,
                                  isLast: true,
                                  onTap: () => _showSemesterPicker(dark),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // Location
                            _ProfileSection(
                              label: 'LOCATION',
                              isDark: dark,
                              fields: [
                                _ProfileTextField(
                                  label: 'City',
                                  hint: 'Enter your city',
                                  controller: _cityController,
                                  focusNode: _cityFocus,
                                  isFocused: _cityFocused,
                                  isDark: dark,
                                  icon: Icons.location_city_outlined,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                  capitalization: TextCapitalization.words,
                                ),
                                _ProfilePickerField(
                                  label: 'State',
                                  value: _selectedState,
                                  hint: 'Select your state',
                                  icon: Icons.map_outlined,
                                  isDark: dark,
                                  isLast: true,
                                  onTap: () => _showStatePicker(dark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Buttons ─────────────────────
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _saveScale,
                            child: _SaveButton(
                              hasChanges: _hasChanges,
                              isLoading: _isSaving,
                              isDark: dark,
                              onTap: _saveProfile,
                            ),
                          ),
                          if (_hasChanges) ...[
                            const SizedBox(height: AppSpacing.base),
                            _ResetButton(isDark: dark, onTap: _resetChanges),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark) => GlassAppBar(
        title: 'Profile',
        leading: _GlassBackButton(isDark: dark),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.30),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Unsaved',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — UNSAVED CHANGES BANNER
// ─────────────────────────────────────────────

class _UnsavedChangesBanner extends StatelessWidget {
  final bool isDark;
  const _UnsavedChangesBanner({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: AppColors.warning.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'You have unsaved changes',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — PROFILE HEADER
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isDark;

  const _ProfileHeader({required this.profile, required this.isDark});

  static const List<List<Color>> _gradients = [
    [Color(0xFF1C4ED8), Color(0xFF7C3AED)],
    [Color(0xFF059669), Color(0xFF1C4ED8)],
    [Color(0xFF7C3AED), Color(0xFFE11D48)],
    [Color(0xFFF59E0B), Color(0xFFE11D48)],
    [Color(0xFF059669), Color(0xFF0891B2)],
  ];

  List<Color> _gradient(String name) {
    final seed = name.isEmpty ? 0 : name.codeUnitAt(0) % _gradients.length;
    return _gradients[seed];
  }

  @override
  Widget build(BuildContext context) {
    final grad = _gradient(profile.fullName);

    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: grad,
                ),
                boxShadow: [
                  BoxShadow(
                    color: grad[0].withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            // Edit overlay
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_outlined, size: 13,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.base),

        // Name
        Text(
          profile.fullName.isEmpty ? 'Your Name' : profile.fullName,
          style: AppTypography.displaySmall.copyWith(
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 5),

        // Course info
        Text(
          profile.courseAndSemester,
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
            fontFamily: 'Georgia',
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 5),

        // College (truncated)
        if (profile.college.isNotEmpty)
          Text(
            profile.college,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTertiaryText
                  : AppColors.lightTertiaryText,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — PROFILE SECTION
// ─────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final String label;
  final bool isDark;
  final List<Widget> fields;

  const _ProfileSection({
    required this.label,
    required this.isDark,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.base, bottom: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Glass card
          ClipRRect(
            borderRadius: AppRadius.card,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x991C1C1E)
                      : const Color(0xCCFFFFFF),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x33FFFFFF),
                    width: 0.5,
                  ),
                  boxShadow: isDark
                      ? AppShadows.darkGlass
                      : AppShadows.lightGlass,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < fields.length; i++) ...[
                      fields[i],
                      if (i < fields.length - 1)
                        Divider(
                          height: 0.5,
                          thickness: 0.5,
                          indent: AppSpacing.base + 24 + AppSpacing.md,
                          endIndent: 0,
                          color: isDark
                              ? AppColors.darkSeparator
                              : AppColors.lightSeparator,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — PROFILE TEXT FIELD
// ─────────────────────────────────────────────

class _ProfileTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isDark;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization capitalization;
  final bool isLast;

  const _ProfileTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.isDark,
    required this.icon,
    this.keyboardType    = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.capitalization  = TextCapitalization.none,
    this.isLast          = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.accentLight : AppColors.accent;
    final iconColor   = isFocused
        ? accentColor
        : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.base,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AnimatedContainer(
              duration: AppAnimation.standard,
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Label + field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: AppAnimation.standard,
                  style: AppTypography.caption.copyWith(
                    color: isFocused
                        ? accentColor
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                    fontSize: 11,
                    fontWeight: isFocused ? FontWeight.w600 : FontWeight.w400,
                  ),
                  child: Text(label),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller:       controller,
                  focusNode:        focusNode,
                  keyboardType:     keyboardType,
                  textInputAction:  textInputAction,
                  textCapitalization: capitalization,
                  onSubmitted:      onSubmitted,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: null,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                    height: 1.35,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.bodySmall.copyWith(
                      fontFamily: null,
                      color: isDark
                          ? AppColors.darkTertiaryText
                          : AppColors.lightTertiaryText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — PROFILE PICKER FIELD
// ─────────────────────────────────────────────

class _ProfilePickerField extends StatefulWidget {
  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool isLast;
  final VoidCallback onTap;

  const _ProfilePickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.isLast = false,
    required this.onTap,
  });

  @override
  State<_ProfilePickerField> createState() => _ProfilePickerFieldState();
}

class _ProfilePickerFieldState extends State<_ProfilePickerField> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value.isNotEmpty;
    final textColor = hasValue
        ? (widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
        : (widget.isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText);
    final iconColor =
        widget.isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onTap(); HapticFeedback.lightImpact(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? (widget.isDark ? const Color(0x0DFFFFFF) : const Color(0x06000000))
            : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.base,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 18, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.caption.copyWith(
                      color: iconColor, fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasValue ? widget.value : widget.hint,
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: null,
                      color: textColor,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded, size: 18,
              color: widget.isDark
                  ? AppColors.darkTertiaryText
                  : AppColors.lightTertiaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — PICKER SHEET
// ─────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final bool isDark;
  final ValueChanged<String> onSelected;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.accentLight : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        ...options.map((opt) {
          final isSelected = opt == selectedValue;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(opt),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      opt,
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: null,
                        color: isSelected
                            ? accentColor
                            : (isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_rounded, size: 18, color: accentColor),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — SAVE BUTTON
// ─────────────────────────────────────────────

class _SaveButton extends StatefulWidget {
  final bool hasChanges;
  final bool isLoading;
  final bool isDark;
  final AsyncCallback onTap;

  const _SaveButton({
    required this.hasChanges,
    required this.isLoading,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            widget.onTap();
          },
          onTapCancel: () => _press.reverse(),
          child: AnimatedContainer(
            duration: AppAnimation.standard,
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: widget.hasChanges
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accentLight, AppColors.accent],
                    )
                  : null,
              color: widget.hasChanges ? null : (widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x14000000)),
              borderRadius: AppRadius.button,
              boxShadow: widget.hasChanges
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.hasChanges ? 'Save Profile' : 'No Changes',
                      style: AppTypography.labelLarge.copyWith(
                        color: widget.hasChanges
                            ? Colors.white
                            : (widget.isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — RESET BUTTON
// ─────────────────────────────────────────────

class _ResetButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _ResetButton({required this.isDark, required this.onTap});

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          opacity: _pressed ? 0.55 : 1.0,
          child: SizedBox(
            width: double.infinity, height: 48,
            child: Center(
              child: Text(
                'Reset Changes',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS BACK BUTTON
// ─────────────────────────────────────────────

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34, height: 34,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded, size: 15,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — BACKGROUND
// ─────────────────────────────────────────────

class _ProfileBackground extends StatelessWidget {
  final bool isDark;
  const _ProfileBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212), const Color(0xFF0C0D14)]
                : [const Color(0xFFF8F5FF), const Color(0xFFFFFFFF), const Color(0xFFF5F8FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accent.withOpacity(isDark ? 0.07 : 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),
      );
}