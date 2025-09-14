
/// @pure
function FirebaseREST_KeyValue() 
{
	var map = ds_map_create()

	for(var a = 0 ; a < argument_count ; a += 2)
	    ds_map_add(map,argument[a],argument[a+1])

	var json = json_encode(map)
	ds_map_destroy(map)

	return(json)
}
