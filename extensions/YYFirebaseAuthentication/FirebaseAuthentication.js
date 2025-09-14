// Global namespace for Firebase Authentication
// Merge the new methods and properties into the existing FirebaseAuthenticationExt object
window.FirebaseAuthenticationExt = Object.assign(window.FirebaseAuthenticationExt || {}, {
    // Variable to store the ID token listener
    idTokenListener: null,

    /**
     * Helper function to check if Firebase Authentication is initialized.
     * Logs an error if not ready.
     * @return {boolean} `true` if `module` is ready, `false` otherwise.
     */
    isAuthInitialized: function() {
		const context = window.FirebaseAuthenticationExt;
        if (!context.instance || !context.module) {
            console.warn("Firebase Authentication is not initialized. Please ensure Firebase is correctly configured.");
            return false;
        }
        return true;
    },

    /**
     * Sends an authentication event with the specified parameters.
     * @param {string} eventType - The type of event.
     * @param {number} asyncId - The unique async ID.
     * @param {number} status - The HTTP status code representing the result.
     * @param {object|null} additionalData - Additional data to include in the event.
     */
    sendAuthEvent: function(eventType, asyncId, status, additionalData) {
        const { sendSocialAsyncEvent } = window.FirebaseSetup;

        // Initialize a new data object
        const data = {
            listener: asyncId,
            status: status,
        };

        if (additionalData !== null && additionalData !== undefined) {
            // Merge additionalData into data
            Object.assign(data, additionalData);
        }

        sendSocialAsyncEvent(eventType, data);
    },

    /**
     * Generates a JSON representation of the FirebaseUser.
     * @param {object|null} user - The FirebaseUser object.
     * @return {string} JSON string of user data.
     */
    getUserDataFromFirebaseUser: function(user) {
        if (user === null) {
            return "{}";
        }

        try {
            const userObj = {};

            // Basic user info
            if (user.displayName !== null) userObj.displayName = user.displayName;
            if (user.email !== null) userObj.email = user.email;
            userObj.localId = user.uid;
            userObj.emailVerified = user.emailVerified;
            if (user.phoneNumber !== null) userObj.phoneNumber = user.phoneNumber;
            if (user.photoURL !== null) userObj.photoUrl = user.photoURL;
            if (user.metadata) {
                userObj.lastLoginAt = user.metadata.lastSignInTime;
                userObj.createdAt = user.metadata.creationTime;
            }

            // Provider data
            const providerArray = [];
            user.providerData.forEach(userInfo => {
                if (userInfo.providerId === "firebase") {
                    return;
                }
                const providerObj = {};
                if (userInfo.displayName !== null) providerObj.displayName = userInfo.displayName;
                if (userInfo.email !== null) providerObj.email = userInfo.email;
                if (userInfo.phoneNumber !== null) providerObj.phoneNumber = userInfo.phoneNumber;
                if (userInfo.photoURL !== null) providerObj.photoUrl = userInfo.photoURL;
                if (userInfo.providerId !== null) providerObj.providerId = userInfo.providerId;
                if (userInfo.uid !== null) {
                    providerObj.rawId = userInfo.uid;
                    providerObj.federatedId = userInfo.uid;
                }
                providerArray.push(providerObj);
            });
            userObj.providerUserInfo = providerArray;

            // Wrap in root object
            const root = {
                kind: "identitytoolkit#GetAccountInfoResponse",
                users: [userObj]
            };

            return JSON.stringify(root);
        } catch (e) {
            console.error("Error serializing user data:", e);
            return "{}";
        }
    },

    /**
     * Retrieves an AuthCredential based on the provider, token, and token kind.
     * @param {string} token - The token.
     * @param {string} tokenKind - The kind of token (e.g., "id_token" or "access_token").
     * @param {string} provider - The provider ID (e.g., "google.com").
     * @return {object|null} The AuthCredential object or null if not found.
     */
    getAuthCredentialFromProvider: function(token, tokenKind, provider) {
        let authCredential = null;
        switch (provider) {
            case "facebook.com":
                authCredential = firebase.auth.FacebookAuthProvider.credential(token);
                break;
            case "google.com":
                if (tokenKind === "id_token") {
                    authCredential = firebase.auth.GoogleAuthProvider.credential(token, null);
                } else if (tokenKind === "access_token") {
                    authCredential = firebase.auth.GoogleAuthProvider.credential(null, token);
                }
                break;
            case "apple.com":
                authCredential = firebase.auth.OAuthProvider("apple.com").credential({
                    idToken: token,
                });
                break;
            // Add other providers as needed
            default:
                console.warn("Unsupported provider:", provider);
                break;
        }
        return authCredential;
    },

    /**
     * Handles authentication results and sends appropriate events.
     * @param {Promise} promise - The promise returned by the Firebase Auth method.
     * @param {string} eventType - The type of event.
     * @param {number} asyncId - The unique async ID.
     */
    handleAuthResult: function(promise, eventType, asyncId) {
        const { getUserDataFromFirebaseUser, sendAuthEvent } = window.FirebaseAuthenticationExt;

        promise.then(userCredential => {
            if (userCredential.user === null) {
                sendAuthEvent(eventType, asyncId, 400, null);
            } else {
                // Offload heavy computation to an async task if necessary
                FirebaseSetup.submitAsyncTask(() => {
                    const userData = getUserDataFromFirebaseUser(userCredential.user);
                    sendAuthEvent(eventType, asyncId, 200, { value: userData });
                });
            }
        }).catch(error => {
            sendAuthEvent(eventType, asyncId, 400, { errorMessage: error.message });
        });
    },

    /**
     * Handles task results and sends appropriate events.
     * @param {Promise} promise - The promise returned by the Firebase Auth method.
     * @param {string} eventType - The type of event.
     * @param {number} asyncId - The unique async ID.
     */
    handleTaskResult: function(promise, eventType, asyncId) {
        const { sendAuthEvent } = window.FirebaseAuthenticationExt;

        promise.then(() => {
            sendAuthEvent(eventType, asyncId, 200, null);
        }).catch(error => {
            sendAuthEvent(eventType, asyncId, 400, { errorMessage: error.message });
        });
    },

    /**
     * Handles cases where the user is not signed in.
     * @param {string} eventType - The type of event.
     * @param {number} asyncId - The unique async ID.
     */
    handleUserNotSignedIn: function(eventType, asyncId) {
        const { sendAuthEvent } = window.FirebaseAuthenticationExt;
        sendAuthEvent(eventType, asyncId, 400, { errorMessage: "No user is currently signed in." });
    },
});

// Constants
const FIREBASE_AUTH_SUCCESS = 0.0;
const FIREBASE_AUTH_ERROR_NOT_INITIALIZED = -1.0;

// Public API Functions

function SDKFirebaseAuthentication_GetUserData() {
    const { instance, isAuthInitialized, getUserDataFromFirebaseUser } = window.FirebaseAuthenticationExt;

    if (!isAuthInitialized()) {
        return "{}";
    }

    const user = instance.currentUser;
    return getUserDataFromFirebaseUser(user);
}

function SDKFirebaseAuthentication_SignInWithCustomToken(token) {
    const { module, instance, isAuthInitialized, handleAuthResult } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const promise = module.signInWithCustomToken(instance, token);
    handleAuthResult(promise, "FirebaseAuthentication_SignInWithCustomToken", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SignIn_Email(email, password) {
    const { module, instance, isAuthInitialized, handleAuthResult } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const promise = module.signInWithEmailAndPassword(instance, email, password);
    handleAuthResult(promise, "FirebaseAuthentication_SignIn_Email", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SignUp_Email(email, password) {
    const { module, instance, isAuthInitialized, handleAuthResult } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const promise = module.createUserWithEmailAndPassword(instance, email, password);
    handleAuthResult(promise, "FirebaseAuthentication_SignUp_Email", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SignIn_Anonymously() {
    const { module, instance, isAuthInitialized, handleAuthResult } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const promise = module.signInAnonymously(instance);
    handleAuthResult(promise, "FirebaseAuthentication_SignIn_Anonymously", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SendPasswordResetEmail(email) {
    const { module, instance, isAuthInitialized, handleTaskResult } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const promise = module.sendPasswordResetEmail(instance, email);
    handleTaskResult(promise, "FirebaseAuthentication_SendPasswordResetEmail", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_ChangeEmail(email) {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_ChangeEmail", asyncId);
        return asyncId;
    }

    const promise = module.updateEmail(user, email);
    handleTaskResult(promise, "FirebaseAuthentication_ChangeEmail", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_ChangePassword(password) {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_ChangePassword", asyncId);
        return asyncId;
    }

    const promise = module.updatePassword(user, password);
    handleTaskResult(promise, "FirebaseAuthentication_ChangePassword", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_ChangeDisplayName(name) {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_ChangeDisplayName", asyncId);
        return asyncId;
    }

    const promise = module.updateProfile(user, { displayName: name });
    handleTaskResult(promise, "FirebaseAuthentication_ChangeDisplayName", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_ChangePhotoURL(photoURL) {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_ChangePhotoURL", asyncId);
        return asyncId;
    }

    const promise = module.updateProfile(user, { photoURL: photoURL });
    handleTaskResult(promise, "FirebaseAuthentication_ChangePhotoURL", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SendEmailVerification() {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_SendEmailVerification", asyncId);
        return asyncId;
    }

    const promise = module.sendEmailVerification(user);
    handleTaskResult(promise, "FirebaseAuthentication_SendEmailVerification", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_DeleteAccount() {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_DeleteAccount", asyncId);
        return asyncId;
    }

    const promise = module.deleteUser(user);
    handleTaskResult(promise, "FirebaseAuthentication_DeleteAccount", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SignOut() {
    const { module, instance, isAuthInitialized } = window.FirebaseAuthenticationExt;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    module.signOut(instance);
}

function SDKFirebaseAuthentication_LinkWithEmailPassword(email, password) {
    const { module, instance, isAuthInitialized, handleAuthResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_LinkWithEmailPassword", asyncId);
        return asyncId;
    }

    const credential = firebase.auth.EmailAuthProvider.credential(email, password);
    const promise = module.linkWithCredential(user, credential);
    handleAuthResult(promise, "FirebaseAuthentication_LinkWithEmailPassword", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_SignIn_OAuth(token, tokenKind, provider, extra) {
    const { module, instance, isAuthInitialized, handleAuthResult, getAuthCredentialFromProvider, sendAuthEvent } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    const credential = getAuthCredentialFromProvider(token, tokenKind, provider);

    if (credential === null) {
        // Unsupported provider or invalid token
        sendAuthEvent("FirebaseAuthentication_SignIn_OAuth", asyncId, 400, { errorMessage: "Invalid provider or token kind" });
        return asyncId;
    }

    const promise = module.signInWithCredential(instance, credential);
    handleAuthResult(promise, "FirebaseAuthentication_SignIn_OAuth", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_LinkWithOAuthCredential(token, tokenKind, provider) {
    const { module, instance, isAuthInitialized, handleAuthResult, getAuthCredentialFromProvider, handleUserNotSignedIn, sendAuthEvent } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_LinkWithOAuthCredential", asyncId);
        return asyncId;
    }

    const credential = getAuthCredentialFromProvider(token, tokenKind, provider);

    if (credential === null) {
        // Unsupported provider or invalid token
        sendAuthEvent("FirebaseAuthentication_LinkWithOAuthCredential", asyncId, 400, { errorMessage: "Invalid provider or token kind" });
        return asyncId;
    }

    const promise = module.linkWithCredential(user, credential);
    handleAuthResult(promise, "FirebaseAuthentication_LinkWithOAuthCredential", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_UnlinkProvider(provider) {
    const { module, instance, isAuthInitialized, handleUserNotSignedIn, sendAuthEvent, getUserDataFromFirebaseUser } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId, submitAsyncTask } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_UnlinkProvider", asyncId);
        return asyncId;
    }

    const promise = module.unlink(user, provider);

    promise.then(result => {
        // Offload heavy computation to an async task if necessary
        submitAsyncTask(() => {
            const userData = getUserDataFromFirebaseUser(result);
            sendAuthEvent("FirebaseAuthentication_UnlinkProvider", asyncId, 200, { value: userData });
        });
    }).catch(error => {
        sendAuthEvent("FirebaseAuthentication_UnlinkProvider", asyncId, 400, { errorMessage: error.message });
    });

    return asyncId;
}

function SDKFirebaseAuthentication_RefreshUserData() {
    const { module, instance, isAuthInitialized, handleTaskResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_RefreshUserData", asyncId);
        return asyncId;
    }

    const promise = module.reload(user);
    handleTaskResult(promise, "FirebaseAuthentication_RefreshUserData", asyncId);

    return asyncId;
}

function SDKFirebaseAuthentication_GetIdToken() {
    const { module, instance, isAuthInitialized, sendAuthEvent, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_GetIdToken", asyncId);
        return asyncId;
    }

    module.getIdToken(user, true)
        .then(token => {
            sendAuthEvent("FirebaseAuthentication_GetIdToken", asyncId, 200, { value: token });
        })
        .catch(error => {
            sendAuthEvent("FirebaseAuthentication_GetIdToken", asyncId, 400, { errorMessage: error.message });
        });

    return asyncId;
}

function SDKFirebaseAuthentication_IdTokenListener() {
    const { module, instance, isAuthInitialized, sendAuthEvent } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

    if (window.FirebaseAuthenticationExt.idTokenListener !== null) {
        sendAuthEvent("FirebaseAuthentication_IdTokenListener", asyncId, 400, { errorMessage: "Already registered" });
        return asyncId;
    }

    window.FirebaseAuthenticationExt.idTokenListener = module.onIdTokenChanged(instance, function(user) {
        if (!user) {
            sendAuthEvent("FirebaseAuthentication_IdTokenListener", asyncId, 200, { value: "" });
            return;
        }

        user.getIdToken(false).then(token => {
            sendAuthEvent("FirebaseAuthentication_IdTokenListener", asyncId, 200, { value: token });
        }).catch(error => {
            sendAuthEvent("FirebaseAuthentication_IdTokenListener", asyncId, 400, { errorMessage: error.message });
        });
    });

    return asyncId;
}

function SDKFirebaseAuthentication_IdTokenListener_Remove() {
    if (window.FirebaseAuthenticationExt.idTokenListener !== null) {
        window.FirebaseAuthenticationExt.idTokenListener();
        window.FirebaseAuthenticationExt.idTokenListener = null;
    }
}

function SDKFirebaseAuthentication_ReauthenticateWithEmail(email, password) {
    const { module, instance, isAuthInitialized, handleAuthResult, handleUserNotSignedIn } = window.FirebaseAuthenticationExt;
    const { getNextAsyncId } = window.FirebaseSetup;

    if (!isAuthInitialized()) {
        return FIREBASE_AUTH_ERROR_NOT_INITIALIZED;
    }

    const asyncId = getNextAsyncId();

	const user = instance.currentUser
    if (user === null) {
        handleUserNotSignedIn("FirebaseAuthentication_ReauthenticateWithEmail", asyncId);
        return asyncId;
    }

    const credential = firebase.auth.EmailAuthProvider.credential(email, password);
    const promise = module.reauthenticateWithCredential(user, credential);
    handleAuthResult(promise, "FirebaseAuthentication_ReauthenticateWithEmail", asyncId);

    return asyncId;
}
