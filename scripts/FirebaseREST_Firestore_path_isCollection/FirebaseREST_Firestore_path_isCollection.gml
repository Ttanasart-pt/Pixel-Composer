function FirebaseREST_Firestore_path_isCollection(path) 
{
	var list = FirebaseFirestore_Path_ToList(path)
	var count = ds_list_size(list)
	ds_list_destroy(list)
	
	return count mod 2
}
