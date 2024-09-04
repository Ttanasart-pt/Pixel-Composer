function __Node_3D_Plane(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Plane";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
	
	newInput(4, nodeValue_Enum_Scroll("Output dimension", self, OUTPUT_SCALING.same_as_input, [ "Same as input", "Constant", "Relative to input" ]))
		.rejectArray();
	
	newInput(5, nodeValue_Vec2("Constant dimension", self, DEF_SURF));
	
	newInput(6, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	newInput(7, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
	
	newInput(8, nodeValue_Enum_Button("Projection", self, 0, [ "Orthographic", "Perspective" ]))
		.rejectArray();
		
	newInput(9, nodeValue_Float("Field of view", self, 60))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	newInput(10, nodeValue_Vec2("Texture scale", self, [ 1, 1 ]));
	
	newInput(11, nodeValue_Vec2("Texture shift", self, [ 0, 0 ]));
		
	newInput(12, nodeValue_Int("Subdiviion", self, 1))
		
	newInput(13, nodeValue_Enum_Button("Normal axis", self, 2, [ "X", "Y", "Z" ]));
	
	input_display_list = [0, 
		["Geometry",		  true], 13, 12, 
		["Outputs",			  true], 4, 5, 
		["Object transform", false], 6, 2, 7,
		["Camera",			 false], 8, 9, 1, 3,
		["Texture",			 false], 10, 11,
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); }));
	
	newOutput(2, nodeValue_Output("3D vertex", self, VALUE_TYPE.d3vertex, []));
	
	output_display_list = [
		0, 1, 2
	]
	
	vertexObjects = [ PRIMITIVES[? "plane"].clone() ];
	vertexSide = 1;
	axis = 0;
	
	_3d_node_init(0, /*Transform*/ 1, 3, 6, 2, 7);
	
	static generate_vb = function() {
		for( var i = 0, n = array_length(vertexObjects); i < n; i++ ) 
			vertexObjects[i].destroy();
		vertexObjects = [];
		
		var pln = new VertexObject();
		for(var i = 0; i < vertexSide; i++) 
		for(var j = 0; j < vertexSide; j++) {
			var _x0 = (i + 0) * (1 / vertexSide);
			var _y0 = (j + 0) * (1 / vertexSide);
			var _x1 = (i + 1) * (1 / vertexSide);
			var _y1 = (j + 1) * (1 / vertexSide);
			
			_x0 -= 0.5;
			_x1 -= 0.5;
			_y0 -= 0.5;
			_y1 -= 0.5;
			
			if(axis == 0) {
				pln.addFace( [0, _x1, _y0], [0, 1, 0], [_x1 + .5, _y0 + .5], 
				             [0, _x0, _y0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
				             [0, _x1, _y1], [0, 1, 0], [_x1 + .5, _y1 + .5], );
			
				pln.addFace( [0, _x1, _y1], [0, 1, 0], [_x1 + .5, _y1 + .5], 
						     [0, _x0, _y0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
						     [0, _x0, _y1], [0, 1, 0], [_x0 + .5, _y1 + .5], );	
			} else if(axis == 1) {
				pln.addFace( [_x1, 0, _y0], [0, 1, 0], [_x1 + .5, _y0 + .5], 
				             [_x0, 0, _y0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
				             [_x1, 0, _y1], [0, 1, 0], [_x1 + .5, _y1 + .5], );
								 
				pln.addFace( [_x1, 0, _y1], [0, 1, 0], [_x1 + .5, _y1 + .5], 
						     [_x0, 0, _y0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
						     [_x0, 0, _y1], [0, 1, 0], [_x0 + .5, _y1 + .5], );	
			} else if(axis == 2) {
				pln.addFace( [_x1, _y0, 0], [0, 1, 0], [_x1 + .5, _y0 + .5], 
				             [_x0, _y0, 0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
				             [_x1, _y1, 0], [0, 1, 0], [_x1 + .5, _y1 + .5], );
			
				pln.addFace( [_x1, _y1, 0], [0, 1, 0], [_x1 + .5, _y1 + .5], 
						     [_x0, _y0, 0], [0, 1, 0], [_x0 + .5, _y0 + .5], 
						     [_x0, _y1, 0], [0, 1, 0], [_x0 + .5, _y1 + .5], );	
			} 
		}
		
		pln.createBuffer();
		vertexObjects[0] = pln;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) 
			active = false;
		var _out = outputs[0].getValue();
		if(!is_surface(_out) || !surface_exists(_out)) return;
		
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue( 6, index);
		var _lrot = getSingleValue( 2, index);
		var _lsca = getSingleValue( 7, index);
		
		var _inSurf = getSingleValue(0, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);

		vertexObjects[0].submit(_inSurf);
		
		_3d_clear_local_transform();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 2) return vertexObjects;
		
		if(!is_surface(_data[0])) return _outSurf;
		
		var _out_type = _data[4];
		var _out = _data[5];
		
		var _ww, _hh;
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				inputs[5].setVisible(false);
				_ww  = surface_get_width_safe(_data[0]);
				_hh  = surface_get_height_safe(_data[0]);
				break;
			case OUTPUT_SCALING.constant :	
				inputs[5].setVisible(true);
				_ww  = _out[0];
				_hh  = _out[1];
				break;
			case OUTPUT_SCALING.relative : 
				inputs[5].setVisible(true);
				_ww  = surface_get_width_safe(_data[0]) * _out[0];
				_hh  = surface_get_height_safe(_data[0]) * _out[1];
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
		
		var _vertexSide = max(1, _data[12]);
		var _axis = _data[13];
		
		if(vertexSide != _vertexSide || _axis != axis) {
			vertexSide = _vertexSide;
			axis = _axis;
			generate_vb();
		}
		
		inputs[9].setVisible(_proj);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
			shader = sh_vertex_pt;
			shader_set(shader);
			
			uniUVscale = shader_get_uniform(shader, "UVscale");
			uniUVshift = shader_get_uniform(shader, "UVshift");
			
			shader_set_uniform_f_array_safe(uniUVscale, _uvSca);
			shader_set_uniform_f_array_safe(uniUVshift, _uvShf);
			
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
			
			vertexObjects[0].submit(_data[0]);
			shader_reset();
			
			matrix_stack_clear();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}