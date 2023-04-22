#region 
	global.__lua_functions = [
		[ "print", print ], 
		
		[ "draw_sprite",				draw_sprite ], 
		[ "draw_sprite_ext",			draw_sprite_ext ], 
		[ "draw_sprite_stretched",		draw_sprite_stretched ], 
		[ "draw_sprite_stretched_ext",	draw_sprite_stretched_ext ], 
		
		[ "draw_surface",				draw_surface ], 
		[ "draw_surface_ext",			draw_surface_ext ], 
		[ "draw_surface_stretched",		draw_surface_stretched ], 
		[ "draw_surface_stretched_ext",	draw_surface_stretched_ext ], 
		
		[ "draw_set_color",		draw_set_color ], 
		[ "draw_set_alpha",		draw_set_alpha ], 
		
		[ "draw_circle",		draw_circle ], 
		[ "draw_rectangle",		draw_rectangle ], 
		[ "draw_line",			draw_line ], 
		[ "draw_line_width",	draw_line_width ], 
	];
#endregion

function __addon_lua_setup(lua) {
	for( var i = 0; i < array_length(global.__lua_functions); i++ ) {
		var _func = global.__lua_functions[i];
		lua_add_function(lua, _func[0], _func[1]);
	}
}