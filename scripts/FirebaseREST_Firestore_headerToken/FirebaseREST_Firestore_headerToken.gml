function FirebaseREST_Firestore_headerToken() 
{
	var map = ds_map_create()
	
	if(asset_get_index("RESTFirebaseAuthentication_GetIdToken") != -1)
	if(RESTFirebaseAuthentication_GetIdToken() != "")
		ds_map_add(map,"Authorization","Bearer " + RESTFirebaseAuthentication_GetIdToken())

	ds_map_add(map,"Content-Type", "application/json");

	var json = json_encode(map)
	ds_map_destroy(map)

	return json
}
