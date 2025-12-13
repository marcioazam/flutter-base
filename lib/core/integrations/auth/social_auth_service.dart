import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Social auth provider type.
enum SocialProvider { google, apple, facebook }

/// Social credential returned after successful authentication.
class SocialCredential {

  const SocialCredential({
    required this.provider,
    required this.token,
    this.email,
    this.name,
    this.photoUrl,
    this.userId,
  });
  final SocialProvider provider;
  final String token;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? userId;

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'token': token,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'userId': userId,
      };
}

/// Abstract social auth service interface.
abstract interface class SocialAuthService {
  /// Signs in with Google.
  Future<Result<SocialCredential>> signInWithGoogle();

  /// Signs in with Apple.
  Future<Result<SocialCredential>> signInWithApple();

  /// Signs in with Facebook.
  Future<Result<SocialCredential>> signInWithFacebook();

  /// Signs out from all providers.
  Future<void> signOut();

  /// Checks if user is signed in with a provider.
  Future<bool> isSignedIn(SocialProvider provider);
}

/// Social auth service implementation.
/// Note: Requires google_sign_in, sign_in_with_apple, flutter_facebook_auth packages.
class SocialAuthServiceImpl implements SocialAuthService {
  // Note: Requires google_sign_in package
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  @override
  Future<Result<SocialCredential>> signInWithGoogle() async {
    try {
      // Placeholder - requires google_sign_in package
      // final account = await _googleSignIn.signIn();
      // if (account == null) {
      //   return Failure(AuthFailure('Google sign in cancelled'));
      // }
      //
      // final auth = await account.authentication;
      // if (auth.idToken == null) {
      //   return Failure(AuthFailure('Failed to get Google ID token'));
      // }
      //
      // return Success(SocialCredential(
      //   provider: SocialProvider.google,
      //   token: auth.idToken!,
      //   email: account.email,
      //   name: account.displayName,
      //   photoUrl: account.photoUrl,
      //   userId: account.id,
      // ));

      return Failure(AuthFailure('Google Sign-In not configured'));
    } catch (e) {
      return Failure(AuthFailure('Google sign in failed: $e'));
    }
  }

  @override
  Future<Result<SocialCredential>> signInWithApple() async {
    try {
      // Placeholder - requires sign_in_with_apple package
      // final credential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      // );
      //
      // if (credential.identityToken == null) {
      //   return Failure(AuthFailure('Failed to get Apple ID token'));
      // }
      //
      // final name = [
      //   credential.givenName,
      //   credential.familyName,
      // ].where((n) => n != null).join(' ').trim();
      //
      // return Success(SocialCredential(
      //   provider: SocialProvider.apple,
      //   token: credential.identityToken!,
      //   email: credential.email,
      //   name: name.isNotEmpty ? name : null,
      //   userId: credential.userIdentifier,
      // ));

      return Failure(AuthFailure('Apple Sign-In not configured'));
    } catch (e) {
      return Failure(AuthFailure('Apple sign in failed: $e'));
    }
  }

  @override
  Future<Result<SocialCredential>> signInWithFacebook() async {
    try {
      // Placeholder - requires flutter_facebook_auth package
      // final result = await FacebookAuth.instance.login(
      //   permissions: ['email', 'public_profile'],
      // );
      //
      // if (result.status == LoginStatus.cancelled) {
      //   return Failure(AuthFailure('Facebook sign in cancelled'));
      // }
      //
      // if (result.status != LoginStatus.success) {
      //   return Failure(AuthFailure(result.message ?? 'Facebook sign in failed'));
      // }
      //
      // final accessToken = result.accessToken;
      // if (accessToken == null) {
      //   return Failure(AuthFailure('Failed to get Facebook access token'));
      // }
      //
      // final userData = await FacebookAuth.instance.getUserData();
      //
      // return Success(SocialCredential(
      //   provider: SocialProvider.facebook,
      //   token: accessToken.tokenString,
      //   email: userData['email'] as String?,
      //   name: userData['name'] as String?,
      //   photoUrl: userData['picture']?['data']?['url'] as String?,
      //   userId: userData['id'] as String?,
      // ));

      return Failure(AuthFailure('Facebook Sign-In not configured'));
    } catch (e) {
      return Failure(AuthFailure('Facebook sign in failed: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    // Placeholder - requires all social auth packages
    // await _googleSignIn.signOut();
    // await FacebookAuth.instance.logOut();
  }

  @override
  Future<bool> isSignedIn(SocialProvider provider) async {
    // Placeholder - requires social auth packages
    // switch (provider) {
    //   case SocialProvider.google:
    //     return await _googleSignIn.isSignedIn();
    //   case SocialProvider.facebook:
    //     final token = await FacebookAuth.instance.accessToken;
    //     return token != null;
    //   case SocialProvider.apple:
    //     return false; // Apple doesn't provide this
    // }
    return false;
  }
}

/// Social auth service factory.
SocialAuthService createSocialAuthService() => SocialAuthServiceImpl();
