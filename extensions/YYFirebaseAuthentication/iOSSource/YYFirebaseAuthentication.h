// YYFirebaseAuthentication.h

${YYIos_FirebaseAuthentication_Skip_Start}

#import <Foundation/Foundation.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthInterop/FirebaseAuthInterop-umbrella.h>
#import <FirebaseAuth/FirebaseAuth-Swift.h>


NS_ASSUME_NONNULL_BEGIN

@interface YYFirebaseAuthentication : NSObject

// General API
- (NSString *)SDKFirebaseAuthentication_GetUserData;

- (double)SDKFirebaseAuthentication_SignInWithCustomToken:(NSString *)token;
- (double)SDKFirebaseAuthentication_SignIn_Email:(NSString *)email pass:(NSString *)password;
- (double)SDKFirebaseAuthentication_SignUp_Email:(NSString *)email pass:(NSString *)password;
- (double)SDKFirebaseAuthentication_SignIn_Anonymously;
- (double)SDKFirebaseAuthentication_SendPasswordResetEmail:(NSString *)email;
- (double)SDKFirebaseAuthentication_ChangeEmail:(NSString *)email;
- (double)SDKFirebaseAuthentication_ChangePassword:(NSString *)password;
- (double)SDKFirebaseAuthentication_ChangeDisplayName:(NSString *)name;
- (double)SDKFirebaseAuthentication_ChangePhotoURL:(NSString *)photoURL;
- (double)SDKFirebaseAuthentication_SendEmailVerification;
- (double)SDKFirebaseAuthentication_DeleteAccount;
- (void)SDKFirebaseAuthentication_SignOut;
- (double)SDKFirebaseAuthentication_LinkWithEmailPassword:(NSString *)email pass:(NSString *)password;
- (double)SDKFirebaseAuthentication_SignIn_OAuth:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider extra:(NSString *)_unused;
- (double)SDKFirebaseAuthentication_LinkWithOAuthCredential:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider;
- (double)SDKFirebaseAuthentication_UnlinkProvider:(NSString *)provider;
- (double)SDKFirebaseAuthentication_RefreshUserData;
- (double)SDKFirebaseAuthentication_GetIdToken;
- (double)SDKFirebaseAuthentication_IdTokenListener;
- (void)SDKFirebaseAuthentication_IdTokenListener_Remove;
- (double)SDKFirebaseAuthentication_ReauthenticateWithEmail:(NSString *)email pass:(NSString *)password;

@end

NS_ASSUME_NONNULL_END

${YYIos_FirebaseAuthentication_Skip_End}
