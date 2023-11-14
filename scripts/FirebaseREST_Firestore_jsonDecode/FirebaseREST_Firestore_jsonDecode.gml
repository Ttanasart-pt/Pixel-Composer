
//TODO? yyundefined aparently do the work correctly, Check Obj_FirebaseREST_Listener_On_firestore_document -> HTTP Event
function FirebaseREST_Firestore_jsonDecode(json_data)
{
	//fields -> Key -> stringValue,integerValue,doubleValue -> value

	if(is_undefined(json_data) or json_data == "")
		return json_stringify({yyundefined1:"yyundefined1"})

	var map = ds_map_create()

	var map_data = json_decode(json_data)

	if(!ds_exists(map_data,ds_type_map))
	{
		ds_map_destroy(map)
		return json_stringify({yyundefined2:"yyundefined2"})
	}

	if(ds_map_exists(map_data,"error"))
	{
		var map_error = map_data[?"error"]
		if(map_error[?"code"] == 404)
		{
			ds_map_destroy(map_data)
			ds_map_destroy(map)
			return json_stringify({yyundefined3:"yyundefined3"})
		}
	}
	
	if(!ds_map_exists(map_data,"fields"))
	{
		ds_map_destroy(map)
		ds_map_destroy(map_data)
		return json_stringify({yyundefined4:"yyundefined4"})
	}

	var map_fields = map_data[?"fields"]

	var key = ds_map_find_first(map_fields)
	while(!is_undefined(key))
	{
		var map_value = map_fields[?key]
		var value = map_value[?ds_map_find_first(map_value)]
		ds_map_add(map,key,value)
		key = ds_map_find_next(map_fields,key)
	}

	ds_map_destroy(map_data)

	var json = json_encode(map)
	ds_map_destroy(map)

	return(json)
}
