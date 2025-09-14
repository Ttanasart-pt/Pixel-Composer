// YYFirebaseAuthentication.m

${YYIos_FirebaseAuthentication_Skip_Start}

#import "YYFirebaseAuthentication.h"
#import "FirebaseUtils.h"

@interface YYFirebaseAuthentication ()

@property (nonatomic, strong, nullable) FIRIDTokenDidChangeListenerHandle idTokenListenerHandle;

- (void)handleAuthResultWithAuthResult:(FIRAuthDataResult *)authResult error:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId;
- (void)handleTaskResultWithError:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId;
- (void)handleUserNotSignedInWithEventType:(NSString *)eventType asyncId:(long)asyncId;
- (void)handleError:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId;
- (void)handleErrorWithMessage:(NSString *)message eventType:(NSString *)eventType asyncId:(long)asyncId;
- (FIRAuthCredential *)getAuthCredentialFromProvider:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider;
- (NSString *)getUserDataFromFirebaseUser:(FIRUser *)user;
- (void)putIfNotNullInDictionary:(NSMutableDictionary *)dictionary key:(NSString *)key value:(id)value;
- (NSString *)randomNonce:(NSInteger)length;

@end

@implementation YYFirebaseAuthentication

#pragma mark - General API

- (NSString *)SDKFirebaseAuthentication_GetUserData {
    FIRUser *user = [FIRAuth auth].currentUser;
    return [self getUserDataFromFirebaseUser:user];
}

- (double)SDKFirebaseAuthentication_SignInWithCustomToken:(NSString *)token {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    [[FIRAuth auth] signInWithCustomToken:token completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignInWithCustomToken" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SignIn_Email:(NSString *)email pass:(NSString *)password {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignIn_Email" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SignUp_Email:(NSString *)email pass:(NSString *)password {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignUp_Email" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SignIn_Anonymously {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignIn_Anonymously" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SendPasswordResetEmail:(NSString *)email {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    [[FIRAuth auth] sendPasswordResetWithEmail:email completion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_SendPasswordResetEmail" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_ChangeEmail:(NSString *)email {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ChangeEmail" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser sendEmailVerificationBeforeUpdatingEmail:email completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == FIRAuthErrorCodeRequiresRecentLogin) {
                // Handle re-authentication required
                [self handleErrorWithMessage:@"Re-authentication required. Please re-authenticate and try again." eventType:@"FirebaseAuthentication_ChangeEmail" asyncId:asyncId];
            } else {
                [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_ChangeEmail" asyncId:asyncId];
            }
        } else {
            [self handleTaskResultWithError:nil eventType:@"FirebaseAuthentication_ChangeEmail" asyncId:asyncId];
        }
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_ChangePassword:(NSString *)password {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ChangePassword" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser updatePassword:password completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == FIRAuthErrorCodeRequiresRecentLogin) {
                // Handle re-authentication required
                [self handleErrorWithMessage:@"Re-authentication required. Please re-authenticate and try again." eventType:@"FirebaseAuthentication_ChangePassword" asyncId:asyncId];
            } else {
                [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_ChangePassword" asyncId:asyncId];
            }
        } else {
           [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_ChangePassword" asyncId:asyncId];
        }
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_ChangeDisplayName:(NSString *)name {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ChangeDisplayName" asyncId:asyncId];
        return (double)asyncId;
    }
    FIRUserProfileChangeRequest *changeRequest = [currentUser profileChangeRequest];
    changeRequest.displayName = name;
    [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_ChangeDisplayName" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_ChangePhotoURL:(NSString *)photoURL {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ChangePhotoURL" asyncId:asyncId];
        return (double)asyncId;
    }
    FIRUserProfileChangeRequest *changeRequest = [currentUser profileChangeRequest];
    changeRequest.photoURL = [NSURL URLWithString:photoURL];
    [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_ChangePhotoURL" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SendEmailVerification {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_SendEmailVerification" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_SendEmailVerification" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_DeleteAccount {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_DeleteAccount" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser deleteWithCompletion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_DeleteAccount" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (void)SDKFirebaseAuthentication_SignOut {
    NSError *error = nil;
    BOOL signOutSuccess = [[FIRAuth auth] signOut:&error];
    if (!signOutSuccess) {
        NSLog(@"Error signing out: %@", error.localizedDescription);
    }
}

- (double)SDKFirebaseAuthentication_LinkWithEmailPassword:(NSString *)email pass:(NSString *)password {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_LinkWithEmailPassword" asyncId:asyncId];
        return (double)asyncId;
    }
    FIRAuthCredential *credential = [FIREmailAuthProvider credentialWithEmail:email password:password];
    [currentUser linkWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_LinkWithEmailPassword" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_SignIn_OAuth:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider extra:(NSString *)_unused {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRAuthCredential *authCredential = [self getAuthCredentialFromProvider:token kind:tokenKind provider:provider];
    if (authCredential == nil) {
        [self handleErrorWithMessage:@"Invalid provider or token kind" eventType:@"FirebaseAuthentication_SignIn_OAuth" asyncId:asyncId];
        return (double)asyncId;
    }
    [[FIRAuth auth] signInWithCredential:authCredential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignIn_OAuth" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_LinkWithOAuthCredential:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_LinkWithOAuthCredential" asyncId:asyncId];
        return (double)asyncId;
    }
    FIRAuthCredential *authCredential = [self getAuthCredentialFromProvider:token kind:tokenKind provider:provider];
    if (authCredential == nil) {
        [self handleErrorWithMessage:@"Invalid provider or token kind" eventType:@"FirebaseAuthentication_LinkWithOAuthCredential" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser linkWithCredential:authCredential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_LinkWithOAuthCredential" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_UnlinkProvider:(NSString *)provider {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_UnlinkProvider" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser unlinkFromProvider:provider completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            [self handleError:error eventType:@"FirebaseAuthentication_UnlinkProvider" asyncId:asyncId];
        } else {
            NSString *userData = [self getUserDataFromFirebaseUser:user];
            NSDictionary *data = @{
                @"listener": @(asyncId),
                @"status": @(200),
                @"value": userData
            };
            [FirebaseUtils sendSocialAsyncEvent:@"FirebaseAuthentication_UnlinkProvider" data:data];
        }
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_RefreshUserData {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_RefreshUserData" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser reloadWithCompletion:^(NSError * _Nullable error) {
        [self handleTaskResultWithError:error eventType:@"FirebaseAuthentication_RefreshUserData" asyncId:asyncId];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_GetIdToken {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_GetIdToken" asyncId:asyncId];
        return (double)asyncId;
    }
    [currentUser getIDTokenForcingRefresh:YES completion:^(NSString * _Nullable token, NSError * _Nullable error) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"listener"] = @(asyncId);
        if (error) {
            data[@"status"] = @(400);
            data[@"errorMessage"] = error.localizedDescription ?: @"Unknown error";
        } else {
            data[@"status"] = @(200);
            data[@"value"] = token ?: @"";
        }
        [FirebaseUtils sendSocialAsyncEvent:@"FirebaseAuthentication_GetIdToken" data:data];
    }];
    return (double)asyncId;
}

- (double)SDKFirebaseAuthentication_IdTokenListener {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    if (self.idTokenListenerHandle != nil) {
        NSDictionary *data = @{
            @"listener": @(asyncId),
            @"status": @(400),
            @"errorMessage": @"Already registered"
        };
        [FirebaseUtils sendSocialAsyncEvent:@"FirebaseAuthentication_IdTokenListener" data:data];
        return (double)asyncId;
    }
    self.idTokenListenerHandle = [[FIRAuth auth] addIDTokenDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user == nil) {
            NSDictionary *data = @{
                @"listener": @(asyncId),
                @"status": @(200),
                @"value": @""
            };
            [FirebaseUtils sendSocialAsyncEvent:@"FirebaseAuthentication_IdTokenListener" data:data];
            return;
        }
        [user getIDTokenForcingRefresh:NO completion:^(NSString * _Nullable token, NSError * _Nullable error) {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            data[@"listener"] = @(asyncId);
            if (error) {
                data[@"status"] = @(400);
                data[@"errorMessage"] = error.localizedDescription ?: @"Unknown error";
            } else {
                data[@"status"] = @(200);
                data[@"value"] = token ?: @"";
            }
            [FirebaseUtils sendSocialAsyncEvent:@"FirebaseAuthentication_IdTokenListener" data:data];
        }];
    }];
    return (double)asyncId;
}

- (void)SDKFirebaseAuthentication_IdTokenListener_Remove {
    if (self.idTokenListenerHandle != nil) {
        [[FIRAuth auth] removeIDTokenDidChangeListener:self.idTokenListenerHandle];
        self.idTokenListenerHandle = nil;
    }
}

- (double)SDKFirebaseAuthentication_ReauthenticateWithEmail:(NSString *)email pass:(NSString *)password {
    long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ReauthenticateWithEmail" asyncId:asyncId];
        return (double)asyncId;
    }
    FIRAuthCredential *credential = [FIREmailAuthProvider credentialWithEmail:email password:password];
    [currentUser reauthenticateWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_ReauthenticateWithEmail" asyncId:asyncId];
    }];
    return (double)asyncId;
}


-(double) SDKFirebaseAuthentication_SignIn_GameCenter
{
	long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
	[FIRGameCenterAuthProvider getCredentialWithCompletion:^(FIRAuthCredential *credential,NSError *error)
	{
		if (error == nil)
		{
		  [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable) {
			  [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_SignIn_GameCenter" asyncId:asyncId];
		  }];
		}
	}];
	return (double)asyncId;
}

-(double) SDKFirebaseAuthentication_ReauthenticateWithGameCenter
{
	long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
	FIRUser *currentUser = [FIRAuth auth].currentUser;
	if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_ReauthenticateWithGameCenter" asyncId:asyncId];
        return (double)asyncId;
    }
	
	[FIRGameCenterAuthProvider getCredentialWithCompletion:^(FIRAuthCredential *credential,NSError *error)
	{
		if (error == nil)
		{
		  [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable) {
			  [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_ReauthenticateWithGameCenter" asyncId:asyncId];
		  }];
		}
	}];
	return (double)asyncId;
}

-(double) SDKFirebaseAuthentication_LinkWithGameCenter
{
	long asyncId = [[FirebaseUtils sharedInstance] getNextAsyncId];
	FIRUser *currentUser = [FIRAuth auth].currentUser;
	if (currentUser == nil) {
        [self handleUserNotSignedInWithEventType:@"FirebaseAuthentication_LinkWithGameCenter" asyncId:asyncId];
        return (double)asyncId;
    }
	
	[FIRGameCenterAuthProvider getCredentialWithCompletion:^(FIRAuthCredential *credential,NSError *error)
	{
		if (error == nil)
		{
		  [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable) {
			  [self handleAuthResultWithAuthResult:authResult error:error eventType:@"FirebaseAuthentication_LinkWithGameCenter" asyncId:asyncId];
		  }];
		}
	}];
	return (double)asyncId;
}

#pragma mark - Helper Methods

- (void)handleAuthResultWithAuthResult:(FIRAuthDataResult *)authResult error:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId {
    if (error) {
        [self handleError:error eventType:eventType asyncId:asyncId];
    } else {
        [[FirebaseUtils sharedInstance] submitAsyncTask:^{
            NSString *userData = [self getUserDataFromFirebaseUser:authResult.user];
            NSDictionary *data = @{
                @"listener": @(asyncId),
                @"status": @(200),
                @"value": userData
            };
            [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
        }];
    }
}

- (void)handleTaskResultWithError:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"listener"] = @(asyncId);
    if (error) {
        data[@"status"] = @(400);
        data[@"errorMessage"] = error.localizedDescription ?: @"Unknown error";
    } else {
        data[@"status"] = @(200);
    }
    [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
}

- (void)handleUserNotSignedInWithEventType:(NSString *)eventType asyncId:(long)asyncId {
    NSDictionary *data = @{
        @"listener": @(asyncId),
        @"status": @(400),
        @"errorMessage": @"No user is currently signed in."
    };
    [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
}

- (void)handleError:(NSError *)error eventType:(NSString *)eventType asyncId:(long)asyncId {
    NSDictionary *data = @{
        @"listener": @(asyncId),
        @"status": @(400),
        @"errorMessage": error.localizedDescription ?: @"Unknown error"
    };
    [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
}

- (void)handleErrorWithMessage:(NSString *)message eventType:(NSString *)eventType asyncId:(long)asyncId {
    NSDictionary *data = @{
        @"listener": @(asyncId),
        @"status": @(400),
        @"errorMessage": message ?: @"Unknown error"
    };
    [FirebaseUtils sendSocialAsyncEvent:eventType data:data];
}

- (FIRAuthCredential *)getAuthCredentialFromProvider:(NSString *)token kind:(NSString *)tokenKind provider:(NSString *)provider {
    FIRAuthCredential *authCredential = nil;
    if ([provider isEqualToString:@"facebook.com"]) {
        authCredential = [FIRFacebookAuthProvider credentialWithAccessToken:token];
    } else if ([provider isEqualToString:@"google.com"]) {
        if ([tokenKind isEqualToString:@"id_token"]) {
            authCredential = [FIRGoogleAuthProvider credentialWithIDToken:token accessToken:@""];
        } else if ([tokenKind isEqualToString:@"access_token"]) {
            authCredential = [FIRGoogleAuthProvider credentialWithIDToken:@"" accessToken:token];
        }
    } else if ([provider isEqualToString:@"apple.com"]) {
        NSString *rawNonce = [self randomNonce:32];
        authCredential = [FIROAuthProvider credentialWithProviderID:@"apple.com" IDToken:token rawNonce:rawNonce];
    }
    // Handle other providers if needed
    return authCredential;
}

- (NSString *)getUserDataFromFirebaseUser:(FIRUser *)user {
    if (user == nil) {
        return @"{}";
    }
    NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
    [self putIfNotNullInDictionary:userDict key:@"displayName" value:user.displayName];
    [self putIfNotNullInDictionary:userDict key:@"email" value:user.email];
    userDict[@"localId"] = user.uid ?: @"";
    userDict[@"emailVerified"] = @(user.isEmailVerified);
    [self putIfNotNullInDictionary:userDict key:@"phoneNumber" value:user.phoneNumber];
    if (user.photoURL) {
        userDict[@"photoUrl"] = user.photoURL.absoluteString;
    }
    if (user.metadata) {
        userDict[@"lastLoginAt"] = @([user.metadata.lastSignInDate timeIntervalSince1970]);
        userDict[@"createdAt"] = @([user.metadata.creationDate timeIntervalSince1970]);
    }
    NSMutableArray *providerArray = [NSMutableArray array];
    for (id<FIRUserInfo> userInfo in user.providerData) {
        if ([userInfo.providerID isEqualToString:@"firebase"]) {
            continue;
        }
        NSMutableDictionary *providerDict = [NSMutableDictionary dictionary];
        [self putIfNotNullInDictionary:providerDict key:@"displayName" value:userInfo.displayName];
        [self putIfNotNullInDictionary:providerDict key:@"email" value:userInfo.email];
        [self putIfNotNullInDictionary:providerDict key:@"phoneNumber" value:userInfo.phoneNumber];
        if (userInfo.photoURL) {
            providerDict[@"photoUrl"] = userInfo.photoURL.absoluteString;
        }
        [self putIfNotNullInDictionary:providerDict key:@"providerId" value:userInfo.providerID];
        if (userInfo.uid) {
            providerDict[@"rawId"] = userInfo.uid;
            providerDict[@"federatedId"] = userInfo.uid;
        }
        [providerArray addObject:providerDict];
    }
    userDict[@"providerUserInfo"] = providerArray;
    NSDictionary *root = @{
        @"kind": @"identitytoolkit#GetAccountInfoResponse",
        @"users": @[userDict]
    };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:root options:0 error:&error];
    if (error) {
        NSLog(@"Error serializing user data: %@", error.localizedDescription);
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)putIfNotNullInDictionary:(NSMutableDictionary *)dictionary key:(NSString *)key value:(id)value {
    if (value != nil) {
        dictionary[key] = value;
    }
}

- (NSString *)randomNonce:(NSInteger)length {
    NSAssert(length > 0, @"Expected nonce to have positive length");
    NSString *charset = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        uint32_t randomIndex = arc4random_uniform((uint32_t)charset.length);
        unichar character = [charset characterAtIndex:randomIndex];
        [result appendFormat:@"%C", character];
    }
    return result;
}

@end

${YYIos_FirebaseAuthentication_Skip_End}