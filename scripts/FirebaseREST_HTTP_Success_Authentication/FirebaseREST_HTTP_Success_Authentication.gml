			
#macro FirebaseREST_MiddleCallbackTAG "_YYFirebaseCallback"
function FirebaseREST_HTTP_Success_Authentication()
{
	switch(event)
	{
		default:
			RESTFirebase_asyncCall_Authentication()
		break
		
		///////////////////////////////////////////////AUTH
		case "FirebaseAuthentication_RefreshUserData" + FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangeEmail"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangePassword"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangeDisplayName"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangePhotoURL"+FirebaseREST_MiddleCallbackTAG:
			without_userdata = true
		case "RESTFirebaseAuthentication_RequestIDToken"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignInWithCustomToken"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignUp_Email"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_Email"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_Anonymously"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_OAuth"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignInWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_LinkWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_LinkWithEmailPassword"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_LinkWithOAuthCredential"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_UpdateProfile"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_GameCenter"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ReauthenticateWithCustomToken"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ReauthenticateWithEmail"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ReauthenticateWithOAuth"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ReauthenticateWithPhoneNumber"+FirebaseREST_MiddleCallbackTAG:
		
			var map = json_decode(async_load[?"result"])
			if(ds_map_exists(map,"id_token"))//if(event == "RESTFirebaseAuthentication_RequestIDToken"+FirebaseREST_MiddleCallbackTAG)
			{
				//Due is a bit different than to others...
				//https://firebase.google.com/docs/reference/rest/auth#section-refresh-token
				map[?"expiresIn"] = map[?"expires_in"]
				//map[?""] = map[?"token_type"]
				map[?"refreshToken"] = map[?"refresh_token"]
				map[?"idToken"] = map[?"id_token"]
				map[?"localId"] = map[?"user_id"]
				//map[?""] = map[?"project_id"]
			}
			
			if(ds_map_exists(map,"idToken") and ds_map_exists(map,"expiresIn"))
			{
				if(variable_global_exists("YYFirebaseIdToken"))
					YYFirebaseIdToken = map[?"idToken"]
				Obj_FirebaseREST_Authentication.alarm[0] = real(map[?"expiresIn"])*room_speed*Obj_FirebaseREST_Authentication.expiresK
				ds_map_secure_save(map,Firebase_REST_FILE)
				
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
			
			Firebase_Listerner_refreshTokenOnPath()
		
		//This cases only need refresh the users data
		case "FirebaseAuthentication_UnlinkProvider"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ConfirmEmailVerification"+FirebaseREST_MiddleCallbackTAG:
			
			//Middle callback, update the user info
			event = string_replace(event,FirebaseREST_MiddleCallbackTAG,"")
			var listener = RESTFirebaseAuthentication_GetUserData()
			listener.event_ = event
			if(variable_instance_exists(id,"without_userdata"))
				listener.without_userdata = without_userdata
			
			listener.identifiquer = identifiquer
			
		break
		
		case "RESTFirebaseAuthentication_GetUserData":
			YYFirebaseUserData = async_load[?"result"]
			
			var map = ds_map_secure_load(Firebase_REST_FILE)
			map[?"UserData"] = YYFirebaseUserData
			ds_map_secure_save(map,Firebase_REST_FILE)
			ds_map_destroy(map)
			
			event = id.event_
			if(variable_instance_exists(id,"without_userdata"))
				RESTFirebase_asyncCall_Authentication()
			else
				RESTFirebase_asyncCall_Authentication(async_load[?"result"])
		break
		
		case "FirebaseAuthentication_RecaptchaParams":
		case "FirebaseAuthentication_SendVerificationCode":
		case "FirebaseAuthentication_Fetch_Providers":
		case "FirebaseAuthentication_SendPasswordResetEmail":
		case "FirebaseAuthentication_VerifyPasswordResetCode":
		case "FirebaseAuthentication_ConfirmPasswordReset":
		case "FirebaseAuthentication_SendEmailVerification":
			RESTFirebase_asyncCall_Authentication(async_load[?"result"])
		break;
		
		case "FirebaseAuthentication_DeleteAccount":
			FirebaseAuthentication_SignOut()
			RESTFirebase_asyncCall_Authentication()
		break
	}
}
