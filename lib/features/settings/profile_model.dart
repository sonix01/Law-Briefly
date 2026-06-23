class ProfileModel {
  final String  id;
  final String  fullName;
  final String  email;
  final String  mobileNumber;
  final String  college;
  final String  course;
  final String  semester;
  final String  city;
  final String  state;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
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
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get courseAndSemester {
    if (course.isEmpty && semester.isEmpty) return 'Law Student';
    if (course.isEmpty)   return semester;
    if (semester.isEmpty) return course;
    return '$course · $semester';
  }

  bool get isComplete =>
      fullName.isNotEmpty &&
      email.isNotEmpty    &&
      college.isNotEmpty  &&
      course.isNotEmpty;

  static ProfileModel empty() => ProfileModel(
        id:           'current_user',
        fullName:     '',
        email:        '',
        mobileNumber: '',
        college:      '',
        course:       '',
        semester:     '',
        city:         '',
        state:        '',
        createdAt:    DateTime.now(),
      );

  ProfileModel copyWith({
    String?   id,
    String?   fullName,
    String?   email,
    String?   mobileNumber,
    String?   college,
    String?   course,
    String?   semester,
    String?   city,
    String?   state,
    Object?   createdAt = _sentinel,
    Object?   updatedAt = _sentinel,
  }) =>
      ProfileModel(
        id:           id           ?? this.id,
        fullName:     fullName     ?? this.fullName,
        email:        email        ?? this.email,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        college:      college      ?? this.college,
        course:       course       ?? this.course,
        semester:     semester     ?? this.semester,
        city:         city         ?? this.city,
        state:        state        ?? this.state,
        createdAt:    createdAt    == _sentinel ? this.createdAt : createdAt as DateTime?,
        updatedAt:    updatedAt    == _sentinel ? this.updatedAt : updatedAt as DateTime?,
      );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id:           json['id']            as String,
        fullName:     json['full_name']     as String,
        email:        json['email']         as String,
        mobileNumber: json['mobile_number'] as String,
        college:      json['college']       as String,
        course:       json['course']        as String,
        semester:     json['semester']      as String,
        city:         json['city']          as String,
        state:        json['state']         as String,
        createdAt:    json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt:    json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
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
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  @override
  String toString() =>
      'ProfileModel(id: $id, name: $fullName, college: $college)';
}

const Object _sentinel = Object();