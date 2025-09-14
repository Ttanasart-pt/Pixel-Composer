function FirebaseREST_HTTP_Failed_Authentication()
{
	
	event = string_replace(event,FirebaseREST_MiddleCallbackTAG,"")
	
	var map_error = json_decode(async_load[?"result"])
	if(ds_exists(map_error,ds_type_map))
	{
		var map = map_error
		if(ds_map_exists(map,"default"))//Some times this is a list....
		{
			var list = map[?"default"]
			if(!is_real(list))
				errorMessage = "Firebase Error: Expecting ds_list index"
			else
			{
				if(ds_exists(list,ds_type_list))
				if(ds_list_size(list))
					map = list[|0]
					
				if(ds_map_exists(map,"error"))
				if(ds_map_exists(map[?"error"],"message"))
					errorMessage = map[?"error"][?"message"]
			}
		}
		else
		if(ds_map_exists(map,"error"))
		if(is_string(map[?"error"]))
			errorMessage = map[?"error"]
		else
		if(ds_exists(map[?"error"],ds_type_map))
		if(ds_map_exists(map[?"error"],"message"))
			errorMessage = map[?"error"][?"message"]
		
		ds_map_destroy(map_error)
	}
	
	if(!is_undefined(errorMessage))
	if(errorMessage == "USER_NOT_FOUND")
		FirebaseAuthentication_SignOut()
	
	RESTFirebase_asyncCall_Authentication()
	
	/*
	switch(event)
	{
		default:
			RESTFirebase_asyncCall_Authentication()
		break
		
		case "RESTFirebaseAuthentication_RequestIDToken"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignInWithCustomToken"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignUp_Email"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_Email"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_Anonymously"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_OAuth"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_LinkWithEmailPassword"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_LinkWithOAuthCredential"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangeEmail"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ChangePassword"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_UpdateProfile"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_UnlinkProvider"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_ConfirmEmailVerification"+FirebaseREST_MiddleCallbackTAG:
		case "FirebaseAuthentication_SignIn_GameCenter"+FirebaseREST_MiddleCallbackTAG:
			event = string_replace(event,FirebaseREST_MiddleCallbackTAG,"")
		case "FirebaseAuthentication_SignInWithCustomToken":
		case "RESTFirebaseAuthentication_RequestIDToken":
		case "FirebaseAuthentication_SignUp_Email":
		case "FirebaseAuthentication_SignIn_Email":
		case "FirebaseAuthentication_SignIn_Anonymously":
		case "FirebaseAuthentication_SignIn_OAuth":
		case "FirebaseAuthentication_Fetch_Providers":
		case "FirebaseAuthentication_SendPasswordResetEmail":
		case "FirebaseAuthentication_VerifyPasswordResetCode":
		case "FirebaseAuthentication_ConfirmPasswordReset":
		case "FirebaseAuthentication_ChangeEmail":
		case "FirebaseAuthentication_ChangePassword":
		case "FirebaseAuthentication_UpdateProfile":
		case "RESTFirebaseAuthentication_GetUserData":
		case "FirebaseAuthentication_LinkWithEmailPassword":
		case "FirebaseAuthentication_LinkWithOAuthCredential":
		case "FirebaseAuthentication_UnlinkProvider":
		case "FirebaseAuthentication_SendEmailVerification":
		case "FirebaseAuthentication_ConfirmEmailVerification":
		case "FirebaseAuthentication_SignIn_GameCenter":
		case "FirebaseAuthentication_DeleteAccount":
		case "FirebaseAuthentication_RecaptchaParams":
		case "FirebaseAuthentication_SendVerificationCode":
		case "FirebaseAuthentication_SignInWithPhoneNumber":
		case "FirebaseAuthentication_LinkWithPhoneNumber":
			RESTFirebase_asyncCall_Authentication(undefined)
		break;
	}
	*/
}
