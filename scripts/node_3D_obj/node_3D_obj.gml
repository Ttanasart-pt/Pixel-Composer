function Node_create_3D_Obj_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_3D_Obj(_x, _y);
	node.inputs[| 0].setValue(path);
	node.updateObj();
	node.doUpdate(); 
	return node;	
}

function Node_3D_Obj(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Obj";
	
	uniVertex_lightFor = shader_get_uniform(sh_vertex_pnt_light, "u_LightForward");
	uniLightAmb = shader_get_uniform(sh_vertex_pnt_light, "u_AmbientLight");
	uniLightClr = shader_get_uniform(sh_vertex_pnt_light, "u_LightColor");
	uniLightInt = shader_get_uniform(sh_vertex_pnt_light, "u_LightIntensity");
	uniLightNrm = shader_get_uniform(sh_vertex_pnt_light, "useNormal");
	
	inputs[| 0] = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, [ "*.obj", "" ]);
	
	inputs[| 1] = nodeValue(1, "Generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			updateObj();
			doUpdate(); 
		}, "Generate"] );
	
	inputs[| 2] = nodeValue(2, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 2].getValue(); });
		
	inputs[| 4] = nodeValue(4, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 180 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 6] = nodeValue(6, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 7] = nodeValue(7, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 8] = nodeValue(8, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue(9, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 10] = nodeValue(10, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 11] = nodeValue(11, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 2, 
		["Geometry",	false], 0, 1, 
		["Transform",	false], 3, 4, 5, 11,
		["Light",		false], 6, 7, 8, 9, 10,
		["Textures",	true], 
	];
	input_length = ds_list_size(inputs);
	input_display_len  = array_length(input_display_list);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	function reset_tex() {
		tex_surface = PIXEL_SURFACE;
		surface_set_target(tex_surface);
			draw_clear(c_black);
		surface_reset_target();
	}
	reset_tex();
	
	function createMaterial(m_index) {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, materialNames[m_index] + " texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, tex_surface);
		inputs[| index].setVisible(true);
		
		input_display_list[input_display_len + m_index] = index;
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat = materials[m_index];
		if(file_exists(mat.diff_path)) {
			var sol = Node_create_Image_path(x - (w + 64), matY + m_index * (128 + 32), mat.diff_path);
			sol.name = mat.name + " texture";
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		} else {
			var sol = nodeBuild("Node_Solid", x - (w + 64), matY + m_index * (128 + 32));
			sol.name = mat.name + " texture";
			sol.inputs[| 1].setValue(mat.diff);
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		}
	}
	
	VB = [];
	materialNames = [];
	materialIndex = [];
	materials = [];
	use_normal = true;
	
	static updateObj = function() {
		var _path = inputs[| 0].getValue();
		var _pathMtl = string_copy(_path, 1, string_length(_path) - 4) + ".mtl";
		
		var _v = readObj(_path);
		if(_v != noone) {
			VB = _v[0];
			materialNames = _v[1];
			materialIndex = _v[2];
			use_normal    = _v[3];
		}
		
		if(array_length(materialNames)) 
			materials = readMtl(_pathMtl);
		else {
			materialNames = ["Material"];
			materialIndex = [0];
			materials = [new MTLmaterial("Material")];
		}
		
		do_reset_material = true;
	}
	do_reset_material = false;
	
	#region 3D setup
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_proj_mat(cam, cam_view);
		camera_set_view_mat(cam, cam_proj);
	#endregion
	
	drag_index = -1;
	drag_sv = 0;
	drag_mx = 0;
	drag_my = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		
		var _dim = inputs[| 2].getValue();
		var _pos = inputs[| 3].getValue();
		var _rot = inputs[| 4].getValue();
		var cx = _x + _pos[0] * _s;
		var cy = _y + _pos[1] * _s;
		
		draw_set_color(COLORS.axis[0]);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(COLORS.axis[1]);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(COLORS.axis[2]);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * -6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * 6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var dy  = point_direction(cx, cy, _mx, _my) - point_direction(cx, cy, drag_mx, drag_my);
			_rot[2] = drag_sv + dy;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(active && distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(COLORS.axis[0]);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(active && distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(COLORS.axis[1]);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(active && abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
				draw_set_color(COLORS.axis[2]);
				draw_circle_border(cx, cy, 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 2;
					drag_sv		= _rot[2];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			}
		}
		
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)
	}
	
	static update = function() {
		if(!surface_exists(tex_surface)) reset_tex();
		
		if(do_reset_material) {
			array_resize(input_display_list, input_display_len);
		
			while(ds_list_size(inputs) > input_length)
				ds_list_delete(inputs, input_length);
		
			for(var i = 0; i < array_length(materialNames); i++) 
				createMaterial(i);
			do_reset_material = false;
		}
		
		var _dim  = inputs[| 2].getValue();
		var _pos  = inputs[| 3].getValue();
		var _rot  = inputs[| 4].getValue();
		var _sca  = inputs[| 5].getValue();
		
		var _ldir = inputs[| 6].getValue();
		var _lhgt = inputs[| 7].getValue();
		var _lint = inputs[| 8].getValue();
		var _lclr = inputs[| 9].getValue();
		var _aclr = inputs[| 10].getValue();
		var _lsc  = inputs[| 11].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		outputs[| 0].setValue(_outSurf);
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var TM = matrix_build(_pos[0], _pos[1], 0, _rot[0], _rot[1], _rot[2], _dim[0] * _sca[0], _dim[1] * _sca[1], 1);
		var cam_proj = matrix_build_projection_ortho(_dim[0], _dim[1], 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _dim[0], _dim[1]);
		
		var lightFor = [ -cos(degtorad(_ldir)), -_lhgt, -sin(degtorad(_ldir)) ];
		
		gpu_set_ztestenable(true);
		surface_set_target(_outSurf);
			shader_set(sh_vertex_pnt_light);
			shader_set_uniform_f_array(uniVertex_lightFor, lightFor);
			shader_set_uniform_f_array(uniLightAmb, colorArrayFromReal(_aclr));
			shader_set_uniform_f_array(uniLightClr, colorArrayFromReal(_lclr));
			shader_set_uniform_f(uniLightInt, _lint);
			shader_set_uniform_i(uniLightNrm, use_normal);
			
			camera_apply(cam);
			
			draw_clear_alpha(0, 0);
			matrix_stack_push(TM);
			matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsc[0], _lsc[1], _lsc[2]));
			
			matrix_set(matrix_world, matrix_stack_top());
			for(var i = 0; i < array_length(VB); i++) {
				if(i >= ds_list_size(inputs)) break;
				if(i >= array_length(materialIndex)) continue;
				
				var mIndex = materialIndex[i];
				var tex = inputs[| input_length + mIndex].getValue();
						
				if(!is_surface(tex)) continue;
				vertex_submit(VB[i], pr_trianglelist, surface_get_texture(tex));
			}
			shader_reset();
			
			matrix_stack_pop();
			matrix_stack_pop();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		surface_reset_target();
		
		gpu_set_ztestenable(false);
		camera_apply(0);
	}
}