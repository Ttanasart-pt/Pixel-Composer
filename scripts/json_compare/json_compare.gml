function json_compare(json1,json2) 
{
	var ok = false
	if(!firstTime)
	{
		var map_json1 = json_decode(json1)
		var map_json2 = json_decode(json2)
	
		ok = ds_map_size(map_json1) != ds_map_size(map_json2)
			
		if(!ok)
		{
			var key = ds_map_find_first(map_json2)
			while(!is_undefined(key))
			{
				if(!ds_map_exists(map_json1,key))
				{
					ok = true
					break
				}
				if(map_json1[?key] != map_json2[?key])
				{
					ok = true
					break
				}
				key = ds_map_find_next(map_json2,key)
			}
		}
		ds_map_destroy(map_json2)
		ds_map_destroy(map_json1)
	}

	return !ok
}
