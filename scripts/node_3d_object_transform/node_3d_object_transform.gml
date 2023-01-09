function Node_3D_Transform(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Transform";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 2].getValue(); });
	
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
	
	inputs[| 11] = nodeValue(11, "3D object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3object, noone)
		.setVisible(true, true);
		
	inputs[| 12] = nodeValue(12, "Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ]);
		
	inputs[| 13] = nodeValue(13, "Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
	
	input_display_list = [ 0, 11,
		["Object transform",	false], 1, 2, 3,
		["Camera",				false], 12, 13, 4, 5,
		["Light",				 true], 6, 7, 8, 9, 10,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue(2, "Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
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
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		if(is_array(sv)) {
			for( var i = 0; i < array_length(sv); i++ ) {
				var _sv = sv[i];
				_sv(i);
			}
		} else
			sv();
		_3d_clear_local_transform();
	}
	
	static update = function() {
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

		var _proj = inputs[| 12].getValue();
		var _fov  = inputs[| 13].getValue();
		
		inputs[| 13].setVisible(_proj);
		
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