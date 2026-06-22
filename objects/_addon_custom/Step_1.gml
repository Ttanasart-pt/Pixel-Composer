/// @description 
if(!ready) exit;
try { var runResult = lua_call(thread, "step"); }
catch(e) exception_print(e);
draw_set_alpha(1);
