
function RESTFirebase_asyncCall_Authentication()
{
	var map = ds_map_create()
	map[?"listener"] = identifiquer
	map[?"type"] = event
	map[?"status"] = async_load[?"http_status"]
	
	if(!is_undefined(errorMessage))
		map[?"errorMessage"] = errorMessage
	
	if(argument_count)
		map[?"value"] = argument[0]
	event_perform_async(ev_async_social,map)
	exit
}
