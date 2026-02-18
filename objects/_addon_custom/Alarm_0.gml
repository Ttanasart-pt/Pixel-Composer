/// @description 
#region deserialize
	if(!struct_has(PROJECT.addons, name)) exit;
	var _mp = json_try_parse(PROJECT.addons[$ name], noone);
	if(_mp == noone) exit;
	
	try { lua_call(thread, "deserialize", _mp); }
	catch(e) exception_print(e);
#endregion