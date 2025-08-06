function armature_autocomplete_server(prompt, _, node) {
	var res = [];
	
	var armature = node.bone_array;
	var pr_list  = ds_priority_create();
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	for( var i = 0, n = array_length(armature); i < n; i++ ) {
		var bone = armature[i];
		var name = bone.name;
		
		var match = string_partial_match(string_lower(name), string_lower(prompt));
		if(match == -9999) continue;
		
		if(bone.IKlength) ds_priority_add(pr_list, [[THEME.bone, 2], name, "IK Handle", name], match);
		else              ds_priority_add(pr_list, [[THEME.bone, 1], name, "Bone",      name], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	ds_priority_destroy(pr_list);
	
	return res;
}