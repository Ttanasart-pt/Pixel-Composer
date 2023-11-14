function FirebaseREST_firestore_fieldReference(orderBy_field) 
{
	// https://firebase.google.com/docs/firestore/reference/rest/v1/StructuredQuery#fieldreference
	
	var map_order_field = ds_map_create()
	ds_map_add(map_order_field,"fieldPath",orderBy_field)
	
	return map_order_field
}
