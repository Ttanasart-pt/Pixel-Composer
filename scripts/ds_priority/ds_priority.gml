function ds_priority_to_list(priority, asc = true) {
	var l = ds_list_create();
	var amo = ds_priority_size(priority);
	
	repeat(amo) {
		if(asc)
			ds_list_add(l, ds_priority_delete_min(priority));
		else
			ds_list_add(l, ds_priority_delete_max(priority));
	}
	
	return l;
}