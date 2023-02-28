function Node_Rigid_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	inputs[| 0] = nodeValue("Render dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	data_length = 1;
	input_fix_len = ds_list_size(inputs);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _dim = inputs[| 0].getValue();
		var _outSurf = outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var objNode = inputs[| i].getValue();
			if(!is_array(objNode)) objNode = [ objNode ];
			
			for( var j = 0; j < array_length(objNode); j++ ) {
				if(!variable_struct_exists(objNode[j], "object")) continue;
				var obj = objNode[j].object;
				
				if(!is_array(obj)) obj = [ obj ];
				
				for( var k = 0; k < array_length(obj); k++ ) {
					var _o = obj[k];
					if(_o == noone || !instance_exists(_o)) continue;
					if(is_undefined(_o.phy_active)) continue;
					
					var ixs = max(0, _o.image_xscale);
					var iys = max(0, _o.image_yscale);
					var xs = max(0, _o.xscale);
					var ys = max(0, _o.yscale);
					
					var xx = lerp(_o.phy_com_x, _o.phy_position_x, xs);
					var yy = lerp(_o.phy_com_y, _o.phy_position_y, ys);
					
					draw_surface_ext_safe(_o.surface, xx, yy, ixs * xs, iys * ys, _o.image_angle, _o.image_blend, _o.image_alpha);
				}
			}
		}
		
		if(TESTING && keyboard_check(ord("D"))) {
			var flag = phy_debug_render_shapes | phy_debug_render_coms;
			draw_set_color(c_white);
			physics_world_draw_debug(flag);
		}
		
		surface_reset_target();
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}