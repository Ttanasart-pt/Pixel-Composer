
//from a map i need a result like this using the keys
//"?updateMask.fieldPaths=key1&updateMask.fieldPaths=key2"
function FriebaseREST_Firestore_urlUpdateMask(json)
{
	var map = json_decode(json)
	if(!ds_exists(map,ds_type_map))
		return ""
	
	var str = ""
	if(ds_map_size(map))
	{
		var key = ds_map_find_first(map)
		while(!is_undefined(key))
		{
			if(key == ds_map_find_first(map))
				str = "?updateMask.fieldPaths=" + key
			else
				str += "&updateMask.fieldPaths=" + key
			key = ds_map_find_next(map,key)
		}
	}
	ds_map_destroy(map)
	return str
}
