
function FirebaseREST_Firestore_collection_decode(event,data)
{
	var map_return = ds_map_create()
	
	var map = json_decode(data)
	if(ds_map_exists(map,"documents"))
	{
		var list = map[?"documents"]
		for(var a = 0 ; a < ds_list_size(list) ; a++)
		{
			var map_ = list[|a]
			var path = map_[?"name"]//This path looks like this: "projects/yoyoplayservices-13954376/databases/(default)/documents/Collection/0bpoyR0Jn0bWq8bWWh3c"
			var key = FirebaseFirestore_Path_GetName(path,0)
			
			var value = FirebaseREST_Firestore_jsonDecode(json_encode(map_))
			ds_map_add(map_return,key,value)
		}
	}
	ds_map_destroy(map)
	
	var json = json_encode(map_return)
	ds_map_destroy(map_return)
	
	return json
}
