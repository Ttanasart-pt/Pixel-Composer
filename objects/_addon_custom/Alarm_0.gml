/// @description 
#region deserialize
	if(!has(PROJECT.addons, name)) exit;
	
	var _mp = json_try_parse(PROJECT.addons[$ name], noone);
	if(!is_struct(_mp)) exit;
	
	try { lua_call(thread, "deserialize", _mp); }
	catch(e) exception_print(e);
	draw_set_alpha(1);
		
#endregion