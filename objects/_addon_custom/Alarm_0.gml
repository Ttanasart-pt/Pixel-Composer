/// @description 
#region deserialize
	if(!struct_has(LOAD_ADDON, name)) exit;
	var _mp = json_parse(LOAD_ADDON[$ name]);
				
	lua_call(thread, "deserialize", _mp);
#endregion