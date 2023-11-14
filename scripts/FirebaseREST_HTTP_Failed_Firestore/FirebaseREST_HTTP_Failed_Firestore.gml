function FirebaseREST_HTTP_Failed_Firestore()
{
	var map_error = json_decode(async_load[?"result"])
	if(ds_exists(map_error,ds_type_map))
	{
		var map = map_error
		if(ds_map_exists(map,"default"))//Some times this is a list....
		{
			if(map[?"default"] = "")
				errorMessage = ""
			else
			{
				var list = map[?"default"]
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
	
	FirebaseREST_asyncCall_Firestore()
	
	/*
	switch(event)
	{
		default:
			FirebaseREST_asyncCall_Firestore()
		break
		
	    case "FirebaseFirestore_Collection_Read":
		case "FirebaseFirestore_Collection_Listener":
		case "FirebaseFirestore_Collection_Query":
		case "FirebaseFirestore_Document_Read":
		case "FirebaseFirestore_Document_Listener":
	        FirebaseREST_asyncCall_Firestore(undefined)
	    break
	}
	*/
	
}
