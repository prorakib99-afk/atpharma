import 'package:equatable/equatable.dart';

import '../../../../../core/constants/api_constants.dart';

final class ProfileData extends Equatable {
  const ProfileData({
    required this.name,
    required this.status,
    required this.roleLine,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.department,
    required this.memberSince,
    this.avatarUrl,
    this.isGuest = false,
  });

  factory ProfileData.fromSession(
    Map<String, dynamic>? user, {
    required bool isGuest,
  }) {
    final Map<String, dynamic> values = user ?? const <String, dynamic>{};
    final String guestNumber = _value(values, <String>[
      'guestNumber',
      'guest_number',
      'name',
    ]);
    final String name = isGuest
        ? (guestNumber.isEmpty ? 'Guest' : guestNumber)
        : _value(values, <String>[
            'name',
            'fullName',
            'full_name',
          ], fallback: 'User');
    final String role = _value(values, <String>[
      'role',
      'roleName',
    ], fallback: isGuest ? 'Guest User' : 'Customer');
    final String department = _value(values, <String>[
      'department',
      'departmentName',
    ]);
    final String avatar = _value(values, <String>[
      'profileImageUrl',
      'profile_image_url',
      'profileImage',
      'avatarUrl',
      'avatar',
      'imageUrl',
      'image',
    ]);

    return ProfileData(
      name: name,
      status: _value(values, <String>[
        'status',
        'accountStatus',
      ], fallback: 'Active'),
      roleLine: department.isEmpty ? role : '$role · $department',
      email: isGuest
          ? 'Guest account'
          : _value(values, <String>['email'], fallback: 'Not available'),
      phone: _value(values, <String>[
        'phone',
        'phoneNumber',
        'mobile',
      ], fallback: 'Not available'),
      accountType: _value(values, <String>[
        'accountType',
        'account_type',
      ], fallback: isGuest ? 'Guest' : 'Customer'),
      department: department.isEmpty ? 'Not assigned' : department,
      memberSince: _formatDate(
        _value(values, <String>['createdAt', 'created_at', 'memberSince']),
      ),
      avatarUrl: avatar.isEmpty ? null : ApiConstants.resolveMediaUrl(avatar),
      isGuest: isGuest,
    );
  }

  final String name;
  final String status;
  final String roleLine;
  final String email;
  final String phone;
  final String accountType;
  final String department;
  final String memberSince;
  final String? avatarUrl;
  final bool isGuest;

  @override
  List<Object?> get props => <Object?>[
    name,
    status,
    roleLine,
    email,
    phone,
    accountType,
    department,
    memberSince,
    avatarUrl,
    isGuest,
  ];

  static String _value(
    Map<String, dynamic> values,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final String key in keys) {
      final dynamic value = values[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static String _formatDate(String value) {
    if (value.isEmpty) return 'Not available';
    final DateTime? date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';
  }

  static String _month(int month) => const <String>[
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month];
}

enum ProfileStatus { initial, loading, success }

final class ProfileState extends Equatable {
  const ProfileState({this.status = ProfileStatus.initial, this.profile});

  final ProfileStatus status;
  final ProfileData? profile;

  ProfileState copyWith({ProfileStatus? status, ProfileData? profile}) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, profile];
}
