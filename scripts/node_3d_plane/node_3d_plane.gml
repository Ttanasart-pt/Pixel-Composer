function Node_3D_Plane(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Plane";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 2] = nodeValue(2, "Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, OUTPUT_SCALING.same_as_input)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Same as input", "Constant", "Relative to input" ]);
	
	inputs[| 5] = nodeValue(5, "Constant dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue(6, "Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue(7, "Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue(8, "Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ]);
		
	inputs[| 9] = nodeValue(9, "Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
	
	inputs[| 10] = nodeValue(10, "Texture scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 11] = nodeValue(11, "Texture shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	input_display_list = [0, 
		["Outputs",			  true], 4, 5, 
		["Object transform", false], 6, 2, 7,
		["Camera",			 false], 8, 9, 1, 3,
		["Texture",			 false], 10, 11,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	output_display_list = [
		0, 1
	]
	
	_3d_node_init(0, /*Transform*/ 1, 2, 3);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) 
			active = false;
		var _out = outputs[| 0].getValue();
		if(!is_surface(_out) || !surface_exists(_out)) return;
		
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny,, false);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue( 6, index);
		var _lrot = getSingleValue( 2, index);
		var _lsca = getSingleValue( 7, index);
		
		var _inSurf = getSingleValue(0, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(_inSurf));
		
		_3d_clear_local_transform();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(!is_surface(_data[0])) return _outSurf;
		
		var _out_type = _data[4];
		var _out = _data[5];
		
		var _ww, _hh;
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				inputs[| 5].setVisible(false);
				_ww  = surface_get_width(_data[0]);
				_hh  = surface_get_height(_data[0]);
				break;
			case OUTPUT_SCALING.constant :	
				inputs[| 5].setVisible(true);
				_ww  = _out[0];
				_hh  = _out[1];
				break;
			case OUTPUT_SCALING.relative : 
				inputs[| 5].setVisible(true);
				_ww  = surface_get_width(_data[0]) * _out[0];
				_hh  = surface_get_height(_data[0]) * _out[1];
				break;
		}
		
		if(_ww <= 0 || _hh <= 0) return;
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		
		var _pos = _data[1];
		var _sca = _data[3];
		
		var _lpos = _data[6];
		var _lrot = _data[2];
		var _lsca = _data[7];
		
		var _proj = _data[8];
		var _fov  = _data[9];
		
		var _uvSca = _data[10];
		var _uvShf = _data[11];
		
		inputs[| 9].setVisible(_proj);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
			shader = sh_vertex_pt;
			shader_set(shader);
			
			uniUVscale = shader_get_uniform(shader, "UVscale");
			uniUVshift = shader_get_uniform(shader, "UVshift");
			
			shader_set_uniform_f_array(uniUVscale, _uvSca);
			shader_set_uniform_f_array(uniUVshift, _uvShf);
			
			var cam_view, cam_proj;
			if(_proj == CAMERA_PROJ.ortho) {
				cam_view = matrix_build_lookat(0, 0, 128, 0, 0, 0, 0, 1, 0);
				cam_proj = matrix_build_projection_ortho(_ww, _hh, 0.1, 256);
			} else {
				var dist = _ww / 2 * dtan(90 - _fov);
				cam_view = matrix_build_lookat(0, 0, 1 + dist, 0, 0, 0, 0, 1, 0);
				cam_proj = matrix_build_projection_perspective(_ww, _hh, dist, dist + 128);
			}
			
			var cam = camera_get_active();
			camera_set_view_size(cam, _ww, _hh);
			camera_set_view_mat(cam, cam_view);
			camera_set_proj_mat(cam, cam_proj);
			camera_apply(cam);
		
			if(_proj == CAMERA_PROJ.ortho) 
				matrix_stack_push(matrix_build(_ww / 2 - _pos[0], _pos[1] - _hh / 2, 0, 0, 0, 0, _ww * _sca[0], -_hh * _sca[1], 1));
			else 
				matrix_stack_push(matrix_build(_ww / 2 - _pos[0], _pos[1] - _hh / 2, 0, 0, 0, 0, _ww * _sca[0], -_hh * _sca[1], 1));
			
			matrix_stack_push(matrix_build(_lpos[0], _lpos[1], _lpos[2], 0, 0, 0, 1, 1, 1));
			matrix_stack_push(matrix_build(0, 0, 0, _lrot[0], _lrot[1], _lrot[2], 1, 1, 1));
			matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsca[0], _lsca[1], _lsca[2]));
			matrix_set(matrix_world, matrix_stack_top());
			
			vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(_data[0]));
			shader_reset();
			
			matrix_stack_clear();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}