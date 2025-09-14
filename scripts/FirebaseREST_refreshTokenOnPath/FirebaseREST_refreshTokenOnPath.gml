function Firebase_Listerner_refreshTokenOnPath() 
{
	with(Obj_FirebaseREST_Listener_Authentication)
	{
		var ind = string_pos("?auth=",url)
		if(ind)
			url = string_copy(url,1,ind-1) + "?auth=" + RESTFirebaseAuthentication_GetIdToken()
	}
}
