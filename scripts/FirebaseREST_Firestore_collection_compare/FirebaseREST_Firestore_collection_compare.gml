function FirebaseREST_Firestore_collection_compare(json_1,json_2) 
{
	var map_1 = json_decode(json_1)
	if(!ds_exists(map_1,ds_type_map))
		return false

	var map_2 = json_decode(json_2)
	if(!ds_exists(map_2,ds_type_map))
	{
		ds_map_destroy(map_1)
		return false
	}

	if(!ds_map_exists(map_1,"documents") and !ds_map_exists(map_2,"documents"))
	{
		ds_map_destroy(map_1)
		ds_map_destroy(map_2)
		return true//this should be 1
	}

	if(!ds_map_exists(map_1,"documents") or !ds_map_exists(map_2,"documents"))
	{
		ds_map_destroy(map_1)
		ds_map_destroy(map_2)
		return false
	}

	var list_1 = map_1[?"documents"]
	var list_2 = map_2[?"documents"]
	if(ds_list_size(list_1) != ds_list_size(list_2))
	{
		ds_map_destroy(map_1)
		ds_map_destroy(map_2)
		return false
	}

	for(var a = 0 ; a < ds_list_size(list_1) ; a++)
	{
		var map_1 = list_1[|a]
		var map_2 = list_2[|a]
		var json_dec_1 = FirebaseREST_Firestore_jsonDecode(json_encode(map_1))
		var json_dec_2 = FirebaseREST_Firestore_jsonDecode(json_encode(map_2))
		if(!json_compare(json_dec_1,json_dec_2))
		{
			ds_map_destroy(map_1)
			ds_map_destroy(map_2)
			return false
		}
	}

	ds_map_destroy(map_1)
	ds_map_destroy(map_2)

	return true
}
