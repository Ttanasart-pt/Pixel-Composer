
function FirebaseREST_asyncCall_Firestore()
{
	show_debug_message(json_encode(async_load))
	
	var map = ds_map_create()
	map[?"listener"] = id
	map[?"type"] = event
	map[?"path"] = path
	map[?"status"] = async_load[?"http_status"]
	
	if(!is_undefined(errorMessage))
		map[?"errorMessage"] = errorMessage
	
	if(argument_count)
		map[?"value"] = argument[0]
	event_perform_async(ev_async_social,map)
}
