
//Dont do tasks if you arent authenticated and you are going to be authenticated
if(asset_get_index("Obj_FirebaseREST_Listener_Authentication") != -1)
{
	var SELF = id
	with(Obj_FirebaseREST_Listener_Authentication)
	if(string_count("Auth",event))
	{
		SELF.alarm[0] = 10
		//show_debug_message("WAITING FOR AUTHENTICATION")
		exit
	}
}

var header_map = json_decode(header_json)

request = http_request(url,method_,header_map,body)

ds_map_destroy(header_map)


