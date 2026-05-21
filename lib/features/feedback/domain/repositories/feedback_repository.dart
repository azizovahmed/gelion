import '../entities/feedback_entry.dart';

abstract class FeedbackRepository {
  /// Firestore `users/{uid}` da `isAdmin: true` yoki `role: "admin"`.
  Future<bool> isCurrentUserAdmin();

  Future<void> submitFeedback({
    required String message,
    required int rating,
  });

  Stream<List<FeedbackEntry>> watchFeedbacks();

  Future<void> deleteFeedback(String id);

  Future<void> setFeedbackRead(String id, {required bool read});
}
