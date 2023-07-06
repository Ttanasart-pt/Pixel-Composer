/// @description 
#region deserialize
	if(!struct_has(PROJECT.addons, name)) exit;
	var _mp = json_parse(PROJECT.addons[$ name]);
				
	lua_call(thread, "deserialize", _mp);
#endregion