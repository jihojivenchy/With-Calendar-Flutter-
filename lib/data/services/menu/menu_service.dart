import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class MenuService with BaseFirestoreMixin {
  ///
  /// 프로필 조회
  ///
  Future<Profile> fetchProfile() async {
    final data = await fetchDocumentData(
      FirestoreConstants.usersCollection,
      documentID: getUserUID,
    );

    return Profile.fromJson(data);
  }

  ///
  /// 프로필 수정
  ///
  Future<void> updateProfile(Profile profile) async {
    await update(
      FirestoreConstants.usersCollection,
      documentID: profile.id,
      data: profile.toJson(),
    );
  }
}
