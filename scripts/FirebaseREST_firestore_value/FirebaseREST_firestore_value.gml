function FirebaseREST_firestore_value(value) 
{
	// https://firebase.google.com/docs/firestore/reference/rest/v1/Value

	var map = ds_map_create()
	if(is_real(value))
		ds_map_add(map,"doubleValue",value)
	else
		ds_map_add(map,"stringValue",value)

	return map
}
