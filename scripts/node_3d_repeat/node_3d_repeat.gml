function Node_3D_Repeat(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Repeat";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 0].getValue(); });
	
	inputs[| 5] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 6] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 7] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 8] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 10] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
		
	inputs[| 11] = nodeValue("3D object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3object, noone)
		.setVisible(true, true);
	
	inputs[| 12] = nodeValue("Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Amount of copies to be generated.");
	
	inputs[| 13] = nodeValue("Repeat position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 14] = nodeValue("Repeat rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 15] = nodeValue("Repeat scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 16] = nodeValue("Repeat pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Linear", "Circular" ])
		.rejectArray();
	
	inputs[| 17] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "x", "y", "z" ]);
	
	inputs[| 18] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 19] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 360 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 20] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 21] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
	
	input_display_list = [ 0, 11,
		["Object transform", true], 1, 2, 3,
		["Camera",			 true], 20, 21, 4, 5,
		["Light",			 true], 6, 7, 8, 9, 10,
		["Repeat",			false], 12, 16, 13, 14, 15, 17, 18, 19
	];
	
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D objects", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 4, 2, 5);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = inputs[| 1].getValue();
		var _lrot = inputs[| 2].getValue();
		var _lsca = inputs[| 3].getValue();
		
		var sv = inputs[| 11].getValue();
		if(sv == noone) return;
		
		var _samo = inputs[| 12].getValue();
		var _patt = inputs[| 16].getValue();
		
		var _srot = inputs[| 14].getValue();
		var _ssca = inputs[| 15].getValue();
		
		var _spos = inputs[| 13].getValue();
		
		var _raxs = inputs[| 17].getValue();
		var _rrad = inputs[| 18].getValue();
		var _rrot = inputs[| 19].getValue();
		
		_3d_local_transform(_lpos, _lrot, _lsca);
			for( var i = 0; i < _samo; i++ ) {
				if(_patt == 0) {
					matrix_stack_push(matrix_build(	_spos[0] * i, _spos[1] * i, _spos[2] * i, 
													_srot[0] * i, _srot[1] * i, _srot[2] * i, 
													power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
				} else if(_patt == 1) {
					var angle = _rrot[0] + i * (_rrot[1] - _rrot[0]) / _samo;
					var ldx = lengthdir_x(_rrad, angle);
					var ldy = lengthdir_y(_rrad, angle);
					
					switch(_raxs) {
						case 0 :
							matrix_stack_push(matrix_build(	0, ldx, ldy, 
															_srot[0] * i, _srot[1] * i, _srot[2] * i, 
															power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
							break;
						case 1 :
							matrix_stack_push(matrix_build(	ldy, 0, ldx, 
															_srot[0] * i, _srot[1] * i, _srot[2] * i, 
															power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
							break;
						case 2 :
							matrix_stack_push(matrix_build(	ldx, ldy, 0, 
															_srot[0] * i, _srot[1] * i, _srot[2] * i, 
															power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
							break;
					}
				}
				
				matrix_set(matrix_world, matrix_stack_top());
				
				if(is_array(sv)) {
					var index = i % array_length(sv);
					var _sv = sv[index];
					_sv(index);
				} else
					sv();
				
				matrix_stack_pop();
			}
		_3d_clear_local_transform();
	}
	
	static step = function() {
		var _proj = inputs[| 20].getValue();
		var _patt = inputs[| 16].getValue();
		
		inputs[| 13].setVisible(_patt == 0);
		
		inputs[| 17].setVisible(_patt == 1);
		inputs[| 18].setVisible(_patt == 1);
		inputs[| 19].setVisible(_patt == 1);
		inputs[| 21].setVisible(_proj);
	}
	
	function update(frame = ANIMATOR.current_frame) {
		var _dim  = inputs[| 0].getValue();
		var _lpos = inputs[| 1].getValue();
		var _lrot = inputs[| 2].getValue();
		var _lsca = inputs[| 3].getValue();
		
		var _pos  = inputs[| 4].getValue();
		var _sca  = inputs[| 5].getValue();
		
		var _ldir = inputs[|  6].getValue();
		var _lhgt = inputs[|  7].getValue();
		var _lint = inputs[|  8].getValue();
		var _lclr = inputs[|  9].getValue();
		var _aclr = inputs[| 10].getValue();
		
		var _proj = inputs[| 20].getValue();
		var _fov  = inputs[| 21].getValue();
		
		var _patt = inputs[| 16].getValue();
		
		for( var i = 0; i < array_length(output_display_list) - 1; i++ ) {
			var ind = output_display_list[i];
			var _outSurf = outputs[| ind].getValue();
			outputs[| ind].setValue(surface_verify(_outSurf, _dim[0], _dim[1]));
			
			var pass = "diff";
			switch(ind) {
				case 0 : pass = "diff" break;
				case 2 : pass = "norm" break;
			}
		
			_3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, _proj, _fov, pass, false);
				submit_vertex();
			_3d_post_setup();
		}
	}
}