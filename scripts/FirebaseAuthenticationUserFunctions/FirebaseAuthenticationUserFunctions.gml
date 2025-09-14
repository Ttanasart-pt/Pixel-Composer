
#macro FirebaseAuthentication_endpoint "https://identitytoolkit.googleapis.com/v1/accounts:"
#macro FirebaseAuthentication_Library_useSDK ((extension_get_option_value("YYFirebaseAuthentication","mode") == "SDKs When Available" and (os_type == os_android or os_type == os_ios or os_browser != browser_not_a_browser)) or extension_get_option_value("YYFirebaseAuthentication","mode") == "SDKs Only")

//Exchange custom token for an ID and refresh token
function FirebaseAuthentication_SignInWithCustomToken(token)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignInWithCustomToken(token);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignInWithCustomToken"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithCustomToken?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true","token",token)
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

function RESTFirebaseAuthentication_RequestIDToken_FromCache()
{
	if(FirebaseAuthentication_Library_useSDK)
		return noone;//NO SDK SIMILAR
	
	FirebaseAuthentication_controllerVerification()
	if(file_exists(Firebase_REST_FILE))
	{
		var map = ds_map_secure_load(Firebase_REST_FILE)
		var refreshToken = map[?"refreshToken"]
		
		if(ds_map_exists(map,"UserData"))
			YYFirebaseUserData = map[?"UserData"] 
		
		ds_map_destroy(map)
		return RESTFirebaseAuthentication_RequestIDToken(refreshToken)
	}
	else
	{
		return noone
	}
}

//Exchange a refresh token for an ID token
function RESTFirebaseAuthentication_RequestIDToken(refresh_token)
{
	if(FirebaseAuthentication_Library_useSDK)
		return noone;//NO SDK SIMILAR
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"RESTFirebaseAuthentication_RequestIDToken"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		"https://securetoken.googleapis.com/v1/token?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),// THIS IS DIFFERENT!!!!
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/x-www-form-urlencoded"),
		"grant_type=refresh_token&refresh_token="+refresh_token
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Sign up with email / password
function FirebaseAuthentication_SignUp_Email(email,password)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignUp_Email(email,password);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignUp_Email"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signUp?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true","email",email,"password",password)
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Sign in with email / password
function FirebaseAuthentication_SignIn_Email(email,password)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignIn_Email(email,password);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignIn_Email"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithPassword?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true","email",email,"password",password)
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Sign in anonymously
function FirebaseAuthentication_SignIn_Anonymously()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignIn_Anonymously();
	
	FirebaseAuthentication_controllerVerification()
	if(file_exists(Firebase_REST_FILE))//try login in the same account
	{
		listener = RESTFirebaseAuthentication_RequestIDToken_FromCache()
		listener.event = "FirebaseAuthentication_SignIn_Anonymously"+FirebaseREST_MiddleCallbackTAG
	}
	else
	{
		var what = extension_get_option_value("YYFirebaseAuthentication","WebAPIKey")
		var listener = FirebaseREST_asyncFunction_Authentication(
			"FirebaseAuthentication_SignIn_Anonymously"+FirebaseREST_MiddleCallbackTAG,
			Obj_FirebaseREST_Listener_Once_Authentication,
			FirebaseAuthentication_endpoint + "signUp?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
			"POST",
			FirebaseREST_KeyValue("Content-Type","application/json"),
			FirebaseREST_KeyValue("returnSecureToken","true"));
		listener.dropListenerFromArgs = true
		Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
		return listener;
	}
}

//Sign In With GameCenter
//https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signInWithGameCenter?hl=es
function FirebaseAuthentication_SignIn_GameCenter(bundle_id,playerId,publicKeyUrl,signature,salt,timestamp,idToken,displayName)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignIn_GameCenter();
	
	FirebaseAuthentication_controllerVerification()
	show_debug_message("signature: " + signature)
	show_debug_message("salt: " + salt)
	//signature = base64_decode(signature)
	//salt = base64_decode(salt)
	//show_debug_message("signatureDE: " + signature)
	//show_debug_message("saltDE: " + salt)
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignIn_GameCenter"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithGameCenter?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		 FirebaseREST_KeyValue("Content-Type","application/json","x-ios-bundle-identifier",bundle_id),
		 FirebaseREST_KeyValue("playerId",playerId,"publicKeyUrl",publicKeyUrl,"signature",signature,"salt",salt,"timestamp",timestamp,/*"idToken",idToken,*/"displayName",displayName));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Sign in with OAuth credential
function FirebaseAuthentication_SignIn_OAuth(token, token_kind, provider, requestUri = "", extra_params = "")
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignIn_OAuth(token,token_kind,provider,requestUri)
		
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignIn_OAuth"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithIdp?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true",
								"returnIdpCredential","true",
								"requestUri",requestUri,
								"postBody",$"{token_kind}={token}&providerId={provider}{extra_params}",
								)
							);
							
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Fetch providers for email	
/*function FirebaseAuthentication_Fetch_Providers(email,continueUri)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SomeFutureFunction;
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_Fetch_Providers",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "createAuthUri?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("identifier",email,"continueUri",continueUri),
		
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}
*/

//Send password reset email
function FirebaseAuthentication_SendPasswordResetEmail(email)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SendPasswordResetEmail(email);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SendPasswordResetEmail",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "sendOobCode?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("requestType","PASSWORD_RESET","email",email));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Verify password reset code// Not contain id_token, Maybe can be useful even in SDKs, already tested in REST API
/*function FirebaseAuthentication_VerifyPasswordResetCode(oobCode)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SomeFutureFunction;
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_VerifyPasswordResetCode",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "resetPassword?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("oobCode",oobCode),
		
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Confirm password reset
function FirebaseAuthentication_ConfirmPasswordReset(oobCode,newPassword)// Not contain id_token, Maybe can be useful even in SDKs, already tested in REST API
{
	if(FirebaseAuthentication_Library_useSDK)
		return SomeFutureFunction;
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_ConfirmPasswordReset",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "resetPassword?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("oobCode",oobCode,"newPassword",newPassword),
		
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}*/

//Change email
function FirebaseAuthentication_ChangeEmail(email)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ChangeEmail(email);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_ChangeEmail"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true","idToken",RESTFirebaseAuthentication_GetIdToken(),"email",email));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Change password
function FirebaseAuthentication_ChangePassword(password)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ChangePassword(password);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_ChangePassword"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("returnSecureToken","true","idToken",RESTFirebaseAuthentication_GetIdToken(),"password",password));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Update profile
function FirebaseAuthentication_ChangeDisplayName(name)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ChangeDisplayName(name);
		
	var ins = RESTFirebaseAuthentication_UpdateProfile_Builder(name,"",false,false)
	ins.event = "FirebaseAuthentication_ChangeDisplayName"+FirebaseREST_MiddleCallbackTAG;
}

function FirebaseAuthentication_ChangePhotoURL(photo)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ChangePhotoURL(photo);
		
	var ins = RESTFirebaseAuthentication_UpdateProfile_Builder("",photo,false,false)
	ins.event = "FirebaseAuthentication_ChangePhotoURL"+FirebaseREST_MiddleCallbackTAG;
}

function RESTFirebaseAuthentication_UpdateProfile_Builder(displayName,photoUrl,deleteDisplayName,deletePhotoUrl)
{
	FirebaseAuthentication_controllerVerification()
	var map = json_decode(FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken(),"returnSecureToken","true"))
	
	if(displayName != "")
		map[?"displayName"] = displayName
	if(photoUrl != "")
		map[?"photoUrl"] = photoUrl
	
	var list = ds_list_create()
	if(deleteDisplayName == "")
		ds_list_add(list,"DISPLAY_NAME")
	if(deletePhotoUrl  == "")
		ds_list_add(list,"PHOTO_URL")
	ds_map_add_list(map,"deleteAttribute",list)
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_UpdateProfile"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		json_encode(map))
	ds_map_destroy(map)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Get user data
function RESTFirebaseAuthentication_GetUserData()
{
	//if(FirebaseAuthentication_Library_useSDK)
	//	return noone;//NO SDK SIMILAR
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"RESTFirebaseAuthentication_GetUserData",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "lookup?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken()));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Link with email/password
function FirebaseAuthentication_LinkWithEmailPassword(email,password)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_LinkWithEmailPassword(email,password);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_LinkWithEmailPassword"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken(),"returnSecureToken","true","email",email,"password",password));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Link with OAuth credential
function FirebaseAuthentication_LinkWithOAuthCredential(token,token_kind,provider,requestUri = "", extra_params= "")
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_LinkWithOAuthCredential(token,token_kind,provider,requestUri);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_LinkWithOAuthCredential" + FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithIdp?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken(),"returnSecureToken","true","returnIdpCredential","true","requestUri",requestUri,"postBody",token_kind+"="+token+"&providerId="+provider+extra_params));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Unlink provider
function FirebaseAuthentication_UnlinkProvider(provider)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_UnlinkProvider(provider);
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_UnlinkProvider"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken(),"deleteProvider",provider));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

//Send email verification
function FirebaseAuthentication_SendEmailVerification()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SendEmailVerification();
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SendEmailVerification",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "sendOobCode?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken(),"requestType","VERIFY_EMAIL"));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

/*
//Confirm email verification // Not contain id_token, Maybe can be useful even in SDKs, already tested in REST API
function FirebaseAuthentication_ConfirmEmailVerification(oobCode)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SomeFutureFunction;
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_ConfirmEmailVerification"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "update?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("oobCode",oobCode),
		
		)
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}
*/

//Delete account
function FirebaseAuthentication_DeleteAccount()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_DeleteAccount();
	
	FirebaseAuthentication_controllerVerification()
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_DeleteAccount",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "delete?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("idToken",RESTFirebaseAuthentication_GetIdToken()));
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

function FirebaseAuthentication_RefreshUserData()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_RefreshUserData()
		
	listener = RESTFirebaseAuthentication_RequestIDToken_FromCache()
	listener.event = "FirebaseAuthentication_RefreshUserData" + FirebaseREST_MiddleCallbackTAG
	return listener
}

function FirebaseAuthentication_SignOut()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignOut();
	
	FirebaseAuthentication_controllerVerification()
	if(variable_global_exists("YYFirebaseUserData"))
		YYFirebaseUserData = "{}"
	if(variable_global_exists("YYFirebaseIdToken"))
		YYFirebaseIdToken = ""
	Obj_FirebaseREST_Authentication.alarm[0] = -1
	if(file_exists(Firebase_REST_FILE))
		file_delete(Firebase_REST_FILE)
		
	if(Listener_IdToken)
	{
		var map = ds_map_create()
		map[?"type"] = "FirebaseAuthentication_IdTokenListener"
		map[?"listener"] = Listener_IdToken
		map[?"status"] = 200
		map[?"value"] = YYFirebaseIdToken
		event_perform_async(ev_async_social,map)
	}
}

function FirebaseAuthentication_GetIdToken()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_GetIdToken()
	
	//This is a callback in SDK so let make simulation
	var listener = irandom_range(100000,900000)
	var map = ds_map_create()
	map[?"type"] = "FirebaseAuthentication_GetIdToken"
	map[?"listener"] = listener
	if(variable_global_exists("YYFirebaseIdToken"))
	{
		map[?"status"] = 200
		map[?"value"] = YYFirebaseIdToken
	}
	else
		map[?"status"] = 400
	event_perform_async(ev_async_social,map)
	
	return listener
}

//////////////////Sync functions:

#macro FirebaseAuthentication_args2array var array = [] for(var a = 0 ; a < argument_count ; a ++) array_push(array,argument_count)


function RESTFirebaseAuthentication_GetIdToken()
{
	if(FirebaseAuthentication_Library_useSDK)
		return "";
	
	if(variable_global_exists("YYFirebaseIdToken"))
		return YYFirebaseIdToken
	else
		return ""
}

function FirebaseAuthentication_GetUserData_raw()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_GetUserData();
	
	if(variable_global_exists("YYFirebaseUserData"))
		return YYFirebaseUserData
	else
		return "{}"
}

//function FirebaseAuthentication_GetUsersCount()
//{
//	if(FirebaseAuthentication_Library_useSDK)
//		return 1;
	
//	var count = 0
//	var map = json_decode(FirebaseAuthentication_GetUserData_raw())
//	if(ds_map_exists(map,"users"))
//	{
//		var list = map[?"users"]
//		count = ds_list_size(list)
//	}
//	ds_map_destroy(map)
	
//	return count
//}

function FirebaseAuthentication_Get(key,argument_array)
{
	var json = "{}"
	if(FirebaseAuthentication_Library_useSDK)
		json = SDKFirebaseAuthentication_GetUserData();
	else 
		json = FirebaseAuthentication_GetUserData_raw()
	
	var value = undefined
	var map = json_decode(json)
	if(ds_map_exists(map,"users"))
	{
		var ind = 0
		if(array_length(argument_array))
			ind = argument_array[0]
		
		var list = map[?"users"]
		value = list[|ind][?key]
	}
	ds_map_destroy(map)
	
	return value
}

//string	The uid of the current user.
function FirebaseAuthentication_GetLocalId()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("localId",array)
	if(is_undefined(value))
		return ""
	return value
}

//string	The email of the account.
function FirebaseAuthentication_GetEmail()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("email",array)
	if(is_undefined(value))
		return ""
	return value
}

//boolean	Whether or not the account's email has been verified.
function FirebaseAuthentication_GetEmailVerified()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("emailVerified",array)
	if(is_undefined(value))
		return ""
	return value
}

//string	The display name for the account.
function FirebaseAuthentication_GetDisplayName()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("displayName",array)
	if(is_undefined(value))
		return ""
	return value
}

function FirebaseAuthentication_GetProviderUserInfo()
{
	FirebaseAuthentication_args2array
	var return_array = []
	var map = json_decode(FirebaseAuthentication_GetUserData_raw())
	if(ds_map_exists(map,"users"))
	{
		var ind = 0
		if(array_length(array))
			ind = argument[0]
		
		var list = map[?"users"]
		var user_map = list[|ind]
		
		if(ds_map_exists(user_map,"providerUserInfo"))
		{
			var list_providers = user_map[?"providerUserInfo"]
			for(var a = 0 ; a < ds_list_size(list_providers) ; a++)
				array_push(return_array,json_parse(json_encode(list_providers[|a])))
		}
	}
	ds_map_destroy(map)
	return return_array
}

//string	The photo Url for the account.
function FirebaseAuthentication_GetPhotoUrl()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("photoUrl",array)
	if(is_undefined(value))
		return ""
	return value
}
/*
//string	Hash version of password.
function FirebaseAuthentication_GetPasswordHash()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("passwordHash",array)
	if(is_undefined(value))
		return ""
	return value
}


//double	The timestamp, in milliseconds, that the account password was last changed.
function FirebaseAuthentication_GetPasswordUpdatedAt()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("passwordUpdatedAt",array)
	if(is_undefined(value))
		return noone
	return value
}

//string	The timestamp, in seconds, which marks a boundary, before which Firebase ID token are considered revoked.
function FirebaseAuthentication_GetValidSince()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("validSince",array)
	if(is_undefined(value))
		return noone
	return real(value)
}

//boolean	Whether the account is disabled or not.
function FirebaseAuthentication_GetDisabled()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("disabled",array)
	if(is_undefined(value))
		return false
	return value
}

//real(string)	The timestamp, in milliseconds, that the account last logged in at.
function FirebaseAuthentication_GetLastLoginAt()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("lastLoginAt",array)
	if(is_undefined(value))
		return noone
	return real(value)
}

//real(string)	The timestamp, in milliseconds, that the account was created at.
function FirebaseAuthentication_GetCreatedAt()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("createdAt",array)
	if(is_undefined(value))
		return noone
	return real(value)
}

//boolean	Whether the account is authenticated by the developer.
function FirebaseAuthentication_GetCustomAuth()
{
	FirebaseAuthentication_args2array
	var value = FirebaseAuthentication_Get("customAuth",array)
	if(is_undefined(value))
		return false
	return value
}
*/
//Same than FirebaseAuthentication_GetLocalId() but with a better name :)
function FirebaseAuthentication_GetUID()
{
	if(argument_count)
		return FirebaseAuthentication_GetLocalId(argument[0])
	return FirebaseAuthentication_GetLocalId()
}

////////////////////// Phone Functions


//https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signInWithPhoneNumber
function FirebaseAuthentication_RecaptchaParams()
{
	//Used on SDK too
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_RecaptchaParams",
		Obj_FirebaseREST_Listener_Once_Authentication,
		"https://identitytoolkit.googleapis.com/v1/recaptchaParams?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"GET",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		"");
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}


//https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/sendVerificationCode
function FirebaseAuthentication_SendVerificationCode(phoneNumber,recaptchaToken)
{
	//Used on SDK too 
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SendVerificationCode",
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "sendVerificationCode?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("phoneNumber",phoneNumber,"recaptchaToken",recaptchaToken))
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}


//https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signInWithPhoneNumber
function FirebaseAuthentication_SignInWithPhoneNumber(phoneNumber,code,sessionInfo)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_SignInWithPhoneNumber(phoneNumber,code,sessionInfo);
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_SignInWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithPhoneNumber?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("phoneNumber",phoneNumber,"code",code,"sessionInfo",sessionInfo))
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

function FirebaseAuthentication_LinkWithPhoneNumber(phoneNumber,code,sessionInfo)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_LinkWithPhoneNumber(phoneNumber,code,sessionInfo)
	
	var listener = FirebaseREST_asyncFunction_Authentication(
		"FirebaseAuthentication_LinkWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG,
		Obj_FirebaseREST_Listener_Once_Authentication,
		FirebaseAuthentication_endpoint + "signInWithPhoneNumber?key=" + extension_get_option_value("YYFirebaseAuthentication","WebAPIKey"),
		"POST",
		FirebaseREST_KeyValue("Content-Type","application/json"),
		FirebaseREST_KeyValue("phoneNumber",phoneNumber,"code",code,"sessionInfo",sessionInfo,"idToken",RESTFirebaseAuthentication_GetIdToken()))
	listener.dropListenerFromArgs = true
	Firebase_Listener_SetErrorCountLimit_Authentication(listener,0)
	return listener;
}

function FirebaseAuthentication_ReauthenticateWithEmail(email,password)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ReauthenticateWithEmail(email,password)
	
	var listener = SDKFirebaseAuthentication_SignIn_OAuth(email,password)
	listener.event = "FirebaseAuthentication_ReauthenticateWithEmail"+FirebaseREST_MiddleCallbackTAG
	return listener
}

function FirebaseAuthentication_ReauthenticateWithOAuth(token,token_kind,provider,requestUri = "", extra_params = "")
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ReauthenticateWithOAuth(token,token_kind,provider,requestUri)
	
	var listener = FirebaseAuthentication_SignIn_OAuth(token,token_kind,provider,requestUri,extra_params)
	listener.event = "FirebaseAuthentication_ReauthenticateWithOAuth"+FirebaseREST_MiddleCallbackTAG
	return listener
}

function FirebaseAuthentication_ReauthenticateWithPhoneNumber(phoneNumber,code,sessionInfo)
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_ReauthenticateWithPhoneNumber(phoneNumber,code,sessionInfo)
	
	var listener = FirebaseAuthentication_SignInWithPhoneNumber(phoneNumber,code,sessionInfo)
	listener.event = "FirebaseAuthentication_ReauthenticateWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG
	return listener
}

globalvar Listener_IdToken;
Listener_IdToken = false
function FirebaseAuthentication_IdTokenListener()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_IdTokenListener()
	
	Listener_IdToken = true
	
	var map = ds_map_create()
	map[?"type"] = "FirebaseAuthentication_IdTokenListener"
	map[?"listener"] = Listener_IdToken
	map[?"status"] = 200
	map[?"value"] = YYFirebaseIdToken
	event_perform_async(ev_async_social,map)
	
	return Listener_IdToken
}

function FirebaseAuthentication_IdTokenListener_Remove()
{
	if(FirebaseAuthentication_Library_useSDK)
		return SDKFirebaseAuthentication_IdTokenListener_Remove()
	
	Listener_IdToken = false
}
