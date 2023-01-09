function Node_3D_Cube(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cube";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue(0, "Main texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue(3, "Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Textures per face", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[|  6] = nodeValue( 6, "Textures 0", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	inputs[|  7] = nodeValue( 7, "Textures 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	inputs[|  8] = nodeValue( 8, "Textures 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	inputs[|  9] = nodeValue( 9, "Textures 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	inputs[| 10] = nodeValue(10, "Textures 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	inputs[| 11] = nodeValue(11, "Textures 5", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0).setVisible(false);
	
	inputs[| 12] = nodeValue(12, "Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 13] = nodeValue(13, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 14] = nodeValue(14, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 15] = nodeValue(15, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 16] = nodeValue(16, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 17] = nodeValue(17, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 18] = nodeValue(18, "Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 19] = nodeValue(19, "Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 20] = nodeValue(20, "Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ]);
		
	inputs[| 21] = nodeValue(21, "Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
	
	input_display_list = [1,
		["Object transform",false], 19, 18, 12,
		["Camera",			false], 20, 21, 2, 4, 
		["Texture",			 true],	0, 5, 6, 7, 8, 9, 10, 11,
		["Light",			false], 13, 14, 15, 16, 17,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function(index) { return submit_vertex(index); });
	
	outputs[| 2] = nodeValue(2, "Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 2, 18, 4);
	
	cube_faces = [
		matrix_build(0, 0,  0.5, 0,   0, 0, 1, 1, 1),
		matrix_build(0, 0, -0.5, 0, 180, 0, 1, 1, 1),
		matrix_build(0,  0.5, 0, -90, 0, 0, 1, 1, 1),
		matrix_build(0, -0.5, 0,  90, 0, 0, 1, 1, 1),
		matrix_build( 0.5, 0, 0, 0, -90, 0, 1, 1, 1),
		matrix_build(-0.5, 0, 0, 0,  90, 0, 1, 1, 1),
	]
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(19, index);
		var _lrot = getSingleValue(18, index);
		var _lsca = getSingleValue(12, index);
		var _usetex = getSingleValue(5, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		if(_usetex) {
			for(var i = 0; i < 6; i++) {
				matrix_stack_push(cube_faces[i]);
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane_normal"], pr_trianglelist, surface_get_texture(getSingleValue(6 + i, index)));
				matrix_stack_pop();
			}
		} else {
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(PRIMITIVES[? "cube"], pr_trianglelist, surface_get_texture(getSingleValue(0, index)));
		}
		
		_3d_clear_local_transform();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _inSurf = _data[0];
		var _dim = _data[1];
		var _pos = _data[2];
		//var _rot = _data[3];
		var _sca = _data[4];
		
		var _lpos = _data[19];
		var _lrot = _data[18];
		var _lsca = _data[12];
		
		var _ldir = _data[13];
		var _lhgt = _data[14];
		var _lint = _data[15];
		var _lclr = _data[16];
		var _aclr = _data[17];
		
		var _usetex = _data[5];
		
		var _proj = _data[20];
		var _fov  = _data[21];
		
		inputs[| 21].setVisible(_proj);
		
		for(var i = 6; i <= 11; i++) inputs[| i].setVisible(true, _usetex);
		inputs[| 0].setVisible(true, !_usetex);
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		_3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, _proj, _fov, pass);
		
		if(_usetex) {
			for(var i = 0; i < 6; i++) {
				matrix_stack_push(cube_faces[i]);
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane_normal"], pr_trianglelist, surface_get_texture(_data[6 + i]));
				matrix_stack_pop();
			}
		} else {
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(PRIMITIVES[? "cube"], pr_trianglelist, surface_get_texture(_inSurf));
		}
		
		_3d_post_setup();
		
		return _outSurf;
	}
}