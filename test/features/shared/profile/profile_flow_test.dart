import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/shared/profile/data/datasources/profile_remote_datasource.dart';
import 'package:lms/features/shared/profile/data/models/profile_model.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';
import 'package:lms/features/shared/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_preferences_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:lms/features/shared/profile/presentation/cubit/profile_cubit.dart';

/// Real `GET /profile/me` payload captured from the live API (2026-10-06).
const _liveLearnerPayload = {
  'id': '50f833b1-82bd-400a-8d3f-bfe10940fa81',
  'createdAt': '2026-10-06T09:00:09.988Z',
  'updatedAt': '2026-10-06T14:26:31.249Z',
  'deletedAt': null,
  'email': 'oo@oo.com',
  'mobileNumber': '+201023684409',
  'isMobileVerified': false,
  'firstName': 'abdallah',
  'lastName': 'yasser',
  'role': 'learner',
  'isEmailVerified': true,
  'isActive': true,
  'profileImageUrl': null,
  'preferences': {'lang': 'ar', 'mode': 'light'},
  'universityId': '23029ebe-8fa3-4bc3-b506-3a9ab8348a0e',
  'faculty': 'Faculty of Medicine',
  'department': 'Pediatrics',
  'year': 'Second Year',
  'storageQuotaBytes': '5368709120',
};

const _liveInstructorPayload = {
  'id': 'bc53d92e-ae43-4bc5-a964-fdfda45f7778',
  'createdAt': '2026-10-06T14:29:03.639Z',
  'updatedAt': '2026-10-06T14:30:21.724Z',
  'deletedAt': null,
  'email': 'uu@uu.com',
  'mobileNumber': '+201023675509',
  'isMobileVerified': false,
  'firstName': 'uu',
  'lastName': 'uu',
  'role': 'instructor',
  'isEmailVerified': true,
  'isActive': true,
  'profileImageUrl':
      'https://res.cloudinary.com/yeptkouk/image/upload/v1791297021/avatars/abc/def.jpg',
  'preferences': {'lang': 'ar', 'mode': 'light'},
  'universityId': '99c8267b-1771-43dc-b116-813887d5d730',
  'faculty': 'Faculty of Engineering',
  'department': 'Computer & Communication Engineering',
  'year': 'First Year',
  'storageQuotaBytes': '5368709120',
};

class _StubApiClient extends ApiClient {
  _StubApiClient({this.patchResponse});

  final Map<String, dynamic>? patchResponse;
  String? lastPatchPath;
  dynamic lastPatchData;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    return const {};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    lastPatchPath = path;
    lastPatchData = data;
    return patchResponse ?? const {};
  }
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({ProfileEntity? profile})
      : profile = profile ??
            const ProfileEntity(
              id: 'p1',
              email: 'a@b.com',
              firstName: 'A',
              lastName: 'B',
            );

  ProfileEntity profile;
  Failure? updateFailure;
  Failure? preferencesFailure;
  Failure? avatarFailure;
  Map<String, dynamic>? lastUpdate;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async => Right(profile);

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? universityId,
    String? faculty,
    String? department,
    String? year,
  }) async {
    lastUpdate = {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'universityId': universityId,
      'faculty': faculty,
      'department': department,
      'year': year,
    };
    if (updateFailure case final failure?) return Left(failure);
    profile = profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      universityId: universityId,
      faculty: faculty,
      department: department,
      year: year,
    );
    return Right(profile);
  }

  @override
  Future<Either<Failure, void>> updatePreferences({
    String? lang,
    String? mode,
  }) async {
    if (preferencesFailure case final failure?) return Left(failure);
    profile = profile.copyWith(lang: lang, mode: mode);
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    if (avatarFailure case final failure?) return Left(failure);
    return Right('https://cdn.example.com/$filePath.jpg');
  }
}

ProfileCubit _cubit(ProfileRepository repo) => ProfileCubit(
      getProfileUseCase: GetProfileUseCase(repo),
      updateProfileUseCase: UpdateProfileUseCase(repo),
      updatePreferencesUseCase: UpdatePreferencesUseCase(repo),
      uploadAvatarUseCase: UploadAvatarUseCase(repo),
    );

void main() {
  group('ProfileModel — live payload parsing', () {
    test('parses learner profile with nested preferences and new fields',
        () {
      final profile = ProfileModel.fromJson(_liveLearnerPayload);

      expect(profile.id, '50f833b1-82bd-400a-8d3f-bfe10940fa81');
      expect(profile.email, 'oo@oo.com');
      expect(profile.firstName, 'abdallah');
      expect(profile.lastName, 'yasser');
      expect(profile.role.value, 'learner');
      expect(profile.isEmailVerified, isTrue);
      expect(profile.isMobileVerified, isFalse);
      expect(profile.isActive, isTrue);
      expect(profile.mobileNumber, '+201023684409');
      expect(profile.universityId, '23029ebe-8fa3-4bc3-b506-3a9ab8348a0e');
      expect(profile.faculty, 'Faculty of Medicine');
      expect(profile.department, 'Pediatrics');
      expect(profile.year, 'Second Year');
      expect(profile.avatarUrl, isNull);

      // preferences are nested in the payload.
      expect(profile.lang, 'ar');
      expect(profile.mode, 'light');

      // camelCase timestamps.
      expect(profile.createdAt, isNotNull);
      expect(profile.createdAt!.year, 2026);
      expect(profile.updatedAt, isNotNull);

      // storageQuotaBytes arrives as a numeric string.
      expect(profile.storageQuotaBytes, 5368709120);
      expect(profile.storageQuotaLabel, '5 GB');
    });

    test('parses instructor profile with cloudinary avatar', () {
      final profile = ProfileModel.fromJson(_liveInstructorPayload);

      expect(profile.role.value, 'instructor');
      expect(profile.isEmailVerified, isTrue);
      expect(profile.avatarUrl, startsWith('https://res.cloudinary.com/'));
      expect(profile.lang, 'ar');
      expect(profile.department, 'Computer & Communication Engineering');
      expect(profile.storageQuotaLabel, '5 GB');
    });

    test('copyWith keeps unspecified fields', () {
      final base = ProfileModel.fromJson(_liveLearnerPayload).toEntity();

      final updated = base.copyWith(lang: 'en', mode: 'dark');

      expect(updated.lang, 'en');
      expect(updated.mode, 'dark');
      expect(updated.firstName, base.firstName);
      expect(updated.mobileNumber, base.mobileNumber);
      expect(updated.faculty, base.faculty);
      expect(updated.storageQuotaBytes, base.storageQuotaBytes);
      expect(updated.isEmailVerified, isTrue);
    });
  });

  group('ProfileRemoteDataSource.updateProfile', () {
    test('sends all editable fields to PATCH /profile/me', () async {
      final client = _StubApiClient(
        patchResponse: {'id': 'p1', 'email': 'a@b.com'},
      );
      final ds = ProfileRemoteDataSourceImpl(apiClient: client);

      await ds.updateProfile(
        firstName: 'New',
        lastName: 'Name',
        mobileNumber: '+201111111111',
        universityId: 'uni-1',
        faculty: 'Engineering',
        department: 'CS',
        year: 'Third Year',
      );

      expect(client.lastPatchPath, '/profile/me');
      expect(client.lastPatchData, {
        'firstName': 'New',
        'lastName': 'Name',
        'mobileNumber': '+201111111111',
        'universityId': 'uni-1',
        'faculty': 'Engineering',
        'department': 'CS',
        'year': 'Third Year',
      });
    });

    test('omits null fields from PATCH body', () async {
      final client = _StubApiClient(
        patchResponse: {'id': 'p1', 'email': 'a@b.com'},
      );
      final ds = ProfileRemoteDataSourceImpl(apiClient: client);

      await ds.updateProfile(firstName: 'A', lastName: 'B');

      expect(client.lastPatchData, {'firstName': 'A', 'lastName': 'B'});
    });
  });

  group('ProfileCubit', () {
    const base = ProfileEntity(
      id: 'p1',
      email: 'a@b.com',
      firstName: 'A',
      lastName: 'B',
      lang: 'en',
      mode: 'light',
    );

    Future<List<ProfileState>> capture(
      ProfileCubit cubit,
      Future<void> Function(ProfileCubit) action,
    ) async {
      final states = <ProfileState>[];
      final sub = cubit.stream.listen(states.add);
      await action(cubit);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      return states;
    }

    test('updatePreferences: optimistic update then success notice', () async {
      final cubit = _cubit(_FakeProfileRepository(profile: base));

      final states = await capture(cubit, (c) async {
        await c.getProfile();
        await c.updatePreferences(lang: 'ar');
      });

      expect(states[0], const ProfileLoading());
      expect(states[1], const ProfileLoaded(base));
      expect(
        states[2],
        isA<ProfileLoaded>()
            .having((s) => s.profile.lang, 'lang', 'ar')
            .having((s) => s.saving, 'saving', true),
      );
      expect(
        states[3],
        isA<ProfileLoaded>()
            .having((s) => s.profile.lang, 'lang', 'ar')
            .having((s) => s.saving, 'saving', false)
            .having((s) => s.notice, 'notice', 'Preferences saved')
            .having((s) => s.noticeIsError, 'noticeIsError', false),
      );
    });

    test('updatePreferences failure keeps profile and flags error notice',
        () async {
      final repo = _FakeProfileRepository(profile: base)
        ..preferencesFailure = const ServerFailure(
          message: 'prefs failed',
          statusCode: 500,
        );
      final cubit = _cubit(repo);

      await capture(cubit, (c) async {
        await c.getProfile();
        await c.updatePreferences(mode: 'dark');
      });

      final loaded = cubit.state;
      expect(loaded, isA<ProfileLoaded>());
      loaded as ProfileLoaded;
      expect(loaded.profile.mode, 'light'); // reverted
      expect(loaded.saving, isFalse);
      expect(loaded.noticeIsError, isTrue);
      expect(loaded.notice, 'prefs failed');
    });

    test('updateProfile success emits saved fields with success notice',
        () async {
      final cubit = _cubit(_FakeProfileRepository(profile: base));

      await capture(cubit, (c) async {
        await c.getProfile();
        await c.updateProfile(
          firstName: 'Renamed',
          lastName: 'User',
          faculty: 'Medicine',
        );
      });

      final loaded = cubit.state;
      expect(loaded, isA<ProfileLoaded>());
      loaded as ProfileLoaded;
      expect(loaded.profile.firstName, 'Renamed');
      expect(loaded.profile.lastName, 'User');
      expect(loaded.profile.faculty, 'Medicine');
      expect(loaded.saving, isFalse);
      expect(loaded.notice, 'Profile updated');
      expect(loaded.noticeIsError, isFalse);
    });

    test('uploadAvatar success updates avatar url with notice', () async {
      final cubit = _cubit(_FakeProfileRepository(profile: base));

      await capture(cubit, (c) async {
        await c.getProfile();
        await c.uploadAvatar('/tmp/pic.png');
      });

      final loaded = cubit.state as ProfileLoaded;
      expect(
        loaded.profile.avatarUrl,
        'https://cdn.example.com//tmp/pic.png.jpg',
      );
      expect(loaded.notice, 'Profile photo updated');
    });
  });
}
