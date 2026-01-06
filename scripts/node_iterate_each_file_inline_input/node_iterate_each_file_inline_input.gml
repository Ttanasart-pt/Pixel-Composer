function Node_Iterate_Each_File_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_input         = false;
	inline_parent_object = "Node_Iterate_Each_File_Inline";
	manual_ungroupable	 = false;
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Path",    VALUE_TYPE.path,    ""    ));
	
	temp_surface = [ noone ];
	
	static onGetPreviousNodes = function(arr) /*=>*/ { array_push(arr, loop); }
	
	static update = function() {
		if(!is(loop, Node_Iterate_Each_File_Inline)) return;
		
		var val = loop.paths;
		var itr = loop.iterated - 1;
		if(!is_array(val)) return;
		
		var _path = array_safe_get_fast(val, itr)
		var _surf = noone;
		
		if(file_exists_empty(_path) && file_is_graphic(_path)) {
			var _spr = sprite_add_map(_path);
			var _sw  = sprite_get_width(_spr);
			var _sh  = sprite_get_height(_spr);
			
			temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);
			surface_set_shader(temp_surface[0]);
				draw_sprite(_spr, 0, 0, 0);
			surface_reset_shader();
			
			sprite_delete(_spr);
			
			_surf = temp_surface[0];
		}
		
		outputs[0].setValue(_surf);
		outputs[1].setValue(_path);
	}
}