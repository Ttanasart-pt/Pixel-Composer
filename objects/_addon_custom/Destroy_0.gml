/// @description 
if(!ready) exit;
var runResult = lua_call(thread, "destroy");

array_remove(ANIMATION_PRE,  animationPreStep);
array_remove(ANIMATION_POST, animationPostStep);

var arr = variable_struct_get_names(context_menus);
for( var i = 0, n = array_length(arr); i < n; i++ ) {
	var _call = ds_map_try_get(CONTEXT_MENU_CALLBACK, arr[i], []);
	
	for( var j = array_length(_call) - 1; j >= 0; j-- ) {
		if(_call[j]._addon == self)
			array_delete(_call, j, 1);
	}
}