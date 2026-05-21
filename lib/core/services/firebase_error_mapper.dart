import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/generated/app_localizations.dart';

class FirebaseErrorMapper {
  static String map(AppLocalizations l10n, Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return l10n.firebaseErrorInvalidEmail;
        case 'user-not-found':
          return l10n.firebaseErrorUserNotFound;
        case 'wrong-password':
        case 'invalid-credential':
          return l10n.firebaseErrorWrongCredential;
        case 'email-already-in-use':
          return l10n.firebaseErrorEmailInUse;
        case 'weak-password':
          return l10n.firebaseErrorWeakPassword;
        case 'requires-recent-login':
          return l10n.firebaseErrorRequiresRecentLogin;
        case 'too-many-requests':
          return l10n.firebaseErrorTooManyRequests;
        case 'invalid-argument':
          return l10n.feedbackValidationMin10;
        case 'network-request-failed':
          return l10n.firebaseErrorNetwork;
        default:
          return error.message ?? l10n.firebaseErrorAuthGeneric;
      }
    }
    if (error is FirebaseException) {
      if (error.code == 'unavailable') {
        return l10n.firebaseErrorUnavailable;
      }
      return error.message ?? l10n.firebaseErrorGeneric;
    }
    return l10n.firebaseErrorUnknown;
  }
}
