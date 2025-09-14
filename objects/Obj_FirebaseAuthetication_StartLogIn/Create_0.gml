
if(FirebaseAuthentication_Library_useSDK)
{
	instance_destroy()
	exit
}

var auth_exists = RESTFirebaseAuthentication_RequestIDToken_FromCache()
if(auth_exists)
	show_debug_message("Requesting Start Authentication")
