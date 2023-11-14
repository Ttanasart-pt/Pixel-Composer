function FirebaseREST_firestore_value_json(value) 
{
	// https://firebase.google.com/docs/firestore/reference/rest/v1/Value

	var map = ds_map_create()
	//if(is_real(value))
	//	ds_map_add(map,"doubleValue",value)
	//else
	//	ds_map_add(map,"stringValue",value)

	ds_map_add(map,"value",value)

	var json = json_encode(map)
	ds_map_destroy(map)

	return json
}
