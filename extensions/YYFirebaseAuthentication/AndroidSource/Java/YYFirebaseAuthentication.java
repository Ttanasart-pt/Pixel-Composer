package ${YYAndroidPackageName};

import ${YYAndroidPackageName}.R;
import ${YYAndroidPackageName}.FirebaseUtils;

import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserInfo;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.PlayGamesAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.OAuthProvider;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import android.net.Uri;

import androidx.annotation.NonNull;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.Map;
import java.util.HashMap;

public class YYFirebaseAuthentication extends RunnerSocial {

    private FirebaseAuth authentication;
    private FirebaseAuth.IdTokenListener idTokenListener = null;

    public YYFirebaseAuthentication() {
        // Initialize the cached instance
        FirebaseUtils.getInstance().registerInitFunction(()-> {
            authentication = FirebaseAuth.getInstance();
        }, 10);
    }

    // <editor-fold desc="General API">

    public String SDKFirebaseAuthentication_GetUserData() {
        FirebaseUser user = authentication.getCurrentUser();
        return getUserDataFromFirebaseUser(user);
    }

    public double SDKFirebaseAuthentication_SignInWithCustomToken(String token) {
        final long asyncId = getNextAsyncId();

        authentication.signInWithCustomToken(token)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_SignInWithCustomToken", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SignIn_Email(String email, String password) {
        final long asyncId = getNextAsyncId();

        authentication.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_SignIn_Email", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SignUp_Email(String email, String password) {
        final long asyncId = getNextAsyncId();

        authentication.createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_SignUp_Email", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SignIn_Anonymously() {
        final long asyncId = getNextAsyncId();

        authentication.signInAnonymously()
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_SignIn_Anonymously", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SendPasswordResetEmail(String email) {
        final long asyncId = getNextAsyncId();

        authentication.sendPasswordResetEmail(email)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_SendPasswordResetEmail", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_ChangeEmail(String email) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_ChangeEmail", asyncId);
            return (double) asyncId;
        }

        currentUser.updateEmail(email)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_ChangeEmail", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_ChangePassword(String password) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_ChangePassword", asyncId);
            return (double) asyncId;
        }

        currentUser.updatePassword(password)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_ChangePassword", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_ChangeDisplayName(String name) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_ChangeDisplayName", asyncId);
            return (double) asyncId;
        }

        UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
            .setDisplayName(name)
            .build();

        currentUser.updateProfile(profileUpdates)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_ChangeDisplayName", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_ChangePhotoURL(String photoURL) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_ChangePhotoURL", asyncId);
            return (double) asyncId;
        }

        UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
            .setPhotoUri(Uri.parse(photoURL))
            .build();

        currentUser.updateProfile(profileUpdates)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_ChangePhotoURL", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SendEmailVerification() {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_SendEmailVerification", asyncId);
            return (double) asyncId;
        }

        currentUser.sendEmailVerification()
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_SendEmailVerification", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_DeleteAccount() {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_DeleteAccount", asyncId);
            return (double) asyncId;
        }

        currentUser.delete()
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_DeleteAccount", asyncId);
                }
            });
        return (double) asyncId;
    }

    public void SDKFirebaseAuthentication_SignOut() {
        authentication.signOut();
    }

    public double SDKFirebaseAuthentication_LinkWithEmailPassword(String email, String password) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_LinkWithEmailPassword", asyncId);
            return (double) asyncId;
        }

        AuthCredential credential = EmailAuthProvider.getCredential(email, password);
        currentUser.linkWithCredential(credential)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_LinkWithEmailPassword", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_SignIn_OAuth(String token, String tokenKind, String provider, String __) {
        final long asyncId = getNextAsyncId();

        AuthCredential authCredential = getAuthCredentialFromProvider(token, tokenKind, provider);
        authentication.signInWithCredential(authCredential)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_SignIn_OAuth", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_LinkWithOAuthCredential(String token, String tokenKind, String provider) {
        final long asyncId = getNextAsyncId();

        AuthCredential authCredential = getAuthCredentialFromProvider(token, tokenKind, provider);

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_LinkWithOAuthCredential", asyncId);
            return (double) asyncId;
        }

        currentUser.linkWithCredential(authCredential)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_LinkWithOAuthCredential", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_UnlinkProvider(String provider) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_UnlinkProvider", asyncId);
            return (double) asyncId;
        }

        currentUser.unlink(provider)
            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    handleAuthResult(task, "FirebaseAuthentication_UnlinkProvider", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_RefreshUserData() {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_RefreshUserData", asyncId);
            return (double) asyncId;
        }

        currentUser.reload()
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_RefreshUserData", asyncId);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_GetIdToken() {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_GetIdToken", asyncId);
            return (double) asyncId;
        }

        currentUser.getIdToken(true)
            .addOnCompleteListener(new OnCompleteListener<GetTokenResult>() {
                @Override
                public void onComplete(@NonNull Task<GetTokenResult> task) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("listener", asyncId);
                    if (task.isSuccessful()) {
                        String idToken = task.getResult().getToken();
                        data.put("status", 200);
                        data.put("value", idToken != null ? idToken : "");
                    } else {
                        data.put("status", 400);
                        if (task.getException() != null) {
                            data.put("errorMessage", task.getException().getMessage());
                        } else {
                            data.put("errorMessage", "Unknown error");
                        }
                    }
                    FirebaseUtils.sendSocialAsyncEvent("FirebaseAuthentication_GetIdToken", data);
                }
            });
        return (double) asyncId;
    }

    public double SDKFirebaseAuthentication_IdTokenListener() {
        final long asyncId = getNextAsyncId();

        if (idTokenListener != null) {
            Map<String, Object> data = new HashMap<>();
            data.put("listener", asyncId);
            data.put("status", 400);
            data.put("errorMessage", "Already registered");
            FirebaseUtils.sendSocialAsyncEvent("FirebaseAuthentication_IdTokenListener", data);
        }
        else {
            idTokenListener = new FirebaseAuth.IdTokenListener() {
                @Override
                public void onIdTokenChanged(@NonNull FirebaseAuth firebaseAuth) {
                    FirebaseUser mUser = firebaseAuth.getCurrentUser();
                    if (mUser == null) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("listener", asyncId);
                        data.put("status", 200);
                        data.put("value", "");
                        FirebaseUtils.sendSocialAsyncEvent("FirebaseAuthentication_IdTokenListener", data);
                        return;
                    }

                    mUser.getIdToken(false).addOnCompleteListener(new OnCompleteListener<GetTokenResult>() {
                        public void onComplete(@NonNull Task<GetTokenResult> task) {
                            Map<String, Object> data = new HashMap<>();
                            data.put("listener", asyncId);
                            if (task.isSuccessful()) {
                                String idToken = task.getResult().getToken();
                                data.put("status", 200);
                                data.put("value", idToken != null ? idToken : "");
                            } else {
                                data.put("status", 400);
                                if (task.getException() != null) {
                                    data.put("errorMessage", task.getException().getMessage());
                                } else {
                                    data.put("errorMessage", "Unknown error");
                                }
                            }
                            FirebaseUtils.sendSocialAsyncEvent("FirebaseAuthentication_IdTokenListener", data);
                        }
                    });
                }
            };
            authentication.addIdTokenListener(idTokenListener);
        }

        return (double) asyncId;
    }

    public void SDKFirebaseAuthentication_IdTokenListener_Remove() {
        if (idTokenListener != null) {
            authentication.removeIdTokenListener(idTokenListener);
            idTokenListener = null;
        }
    }

    public double SDKFirebaseAuthentication_ReauthenticateWithEmail(String email, String password) {
        final long asyncId = getNextAsyncId();

        FirebaseUser currentUser = authentication.getCurrentUser();
        if (currentUser == null) {
            handleUserNotSignedIn("FirebaseAuthentication_ReauthenticateWithEmail", asyncId);
            return (double) asyncId;
        }

        AuthCredential credential = EmailAuthProvider.getCredential(email, password);
        currentUser.reauthenticate(credential)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    handleTaskResult(task, "FirebaseAuthentication_ReauthenticateWithEmail", asyncId);
                }
            });
        return (double) asyncId;
    }

    // </editor-fold>

    // <editor-fold desc="Helper Methods">

    private long getNextAsyncId() {
        return FirebaseUtils.getInstance().getNextAsyncId();
    }

    private AuthCredential getAuthCredentialFromProvider(final String token, final String tokenKind, final String provider) {
        AuthCredential authCredential = null;
        switch (provider) {
            case "facebook.com":
                authCredential = FacebookAuthProvider.getCredential(token);
                break;
            case "google.com":
                if ("id_token".equals(tokenKind))
                    authCredential = GoogleAuthProvider.getCredential(token, null);
                else if ("access_token".equals(tokenKind))
                    authCredential = GoogleAuthProvider.getCredential(null, token);
                break;
            case "playgames.google.com":
                authCredential = PlayGamesAuthProvider.getCredential(token);
                break;
            default:
                // Handle other providers if needed
                break;
        }
        return authCredential;
    }

    private String getUserDataFromFirebaseUser(FirebaseUser user) {
        if (user == null) {
            return "{}";
        }

        try {
            JSONObject userJson = new JSONObject();

            // Basic user info
            putIfNotNull(userJson, "displayName", user.getDisplayName());
            putIfNotNull(userJson, "email", user.getEmail());
            userJson.put("localId", user.getUid());
            userJson.put("emailVerified", user.isEmailVerified());
            putIfNotNull(userJson, "phoneNumber", user.getPhoneNumber());
            if (user.getPhotoUrl() != null) {
                userJson.put("photoUrl", user.getPhotoUrl().toString());
            }
            if (user.getMetadata() != null) {
                userJson.put("lastLoginAt", user.getMetadata().getLastSignInTimestamp());
                userJson.put("createdAt", user.getMetadata().getCreationTimestamp());
            }

            // Provider data
            JSONArray providerArray = new JSONArray();
            for (UserInfo userInfo : user.getProviderData()) {
                if ("firebase".equals(userInfo.getProviderId())) {
                    continue;
                }

                JSONObject providerObj = new JSONObject();
                putIfNotNull(providerObj, "displayName", userInfo.getDisplayName());
                putIfNotNull(providerObj, "email", userInfo.getEmail());
                putIfNotNull(providerObj, "phoneNumber", userInfo.getPhoneNumber());
                if (userInfo.getPhotoUrl() != null) {
                    providerObj.put("photoUrl", userInfo.getPhotoUrl().toString());
                }
                putIfNotNull(providerObj, "providerId", userInfo.getProviderId());
                putIfNotNull(providerObj, "rawId", userInfo.getUid());
                putIfNotNull(providerObj, "federatedId", userInfo.getUid());

                providerArray.put(providerObj);
            }
            userJson.put("providerUserInfo", providerArray);

            // Wrap in root object
            JSONObject root = new JSONObject();
            root.put("kind", "identitytoolkit#GetAccountInfoResponse");
            JSONArray usersArray = new JSONArray();
            usersArray.put(userJson);
            root.put("users", usersArray);

            return root.toString();
        } catch (JSONException e) {
            e.printStackTrace();
            return "{}";
        }
    }

    private void putIfNotNull(JSONObject jsonObject, String key, Object value) throws JSONException {
        if (value != null) {
            jsonObject.put(key, value);
        }
    }

    private void handleAuthResult(Task<AuthResult> task, final String eventType, final long asyncId) {
        if (task.isSuccessful()) {
            // Offload complex code to a background thread (getUserDataFromFirebaseUser)
            FirebaseUtils.getInstance().submitAsyncTask(() -> {
                Map<String, Object> data = new HashMap<>();
                data.put("listener", asyncId);
                data.put("status", 200);
                FirebaseUser user = task.getResult().getUser();
                String userData = getUserDataFromFirebaseUser(user);
                data.put("value", userData);
                FirebaseUtils.sendSocialAsyncEvent(eventType, data);
            });
        } else {
            Map<String, Object> data = new HashMap<>();
            data.put("listener", asyncId);
            data.put("status", 400);
            if (task.getException() != null) {
                data.put("errorMessage", task.getException().getMessage());
            } else {
                data.put("errorMessage", "Unknown error");
            }
            FirebaseUtils.sendSocialAsyncEvent(eventType, data);
        }
    }

    private void handleTaskResult(Task<Void> task, String eventType, long asyncId) {
        Map<String, Object> data = new HashMap<>();
        data.put("listener", asyncId);
        if (task.isSuccessful()) {
            data.put("status", 200);
        } else {
            data.put("status", 400);
            if (task.getException() != null) {
                data.put("errorMessage", task.getException().getMessage());
            } else {
                data.put("errorMessage", "Unknown error");
            }
        }
        FirebaseUtils.sendSocialAsyncEvent(eventType, data);
    }

    private void handleUserNotSignedIn(String eventType, long asyncId) {
        Map<String, Object> data = new HashMap<>();
        data.put("listener", asyncId);
        data.put("status", 400);
        data.put("errorMessage", "No user is currently signed in.");
        FirebaseUtils.sendSocialAsyncEvent(eventType, data);
    }

    // </editor-fold>
}
