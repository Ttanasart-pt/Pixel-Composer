function Node_3D_Combine(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Combine";
	
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
		
	inputs[| 11] = nodeValue(11, "Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ]);
		
	inputs[| 12] = nodeValue(12, "Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ]);
	
	input_display_list = [ 0, 
		["Object transform",	false], 1, 2, 3,
		["Camera",				false], 11, 12, 4, 5,
		["Light",				false], 6, 7, 8, 9, 10,
		["Objects",				 true], 
	];
	
	data_length = 1;
	input_fix_len = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	outputs[| 1] = nodeValue(1, "3D objects", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue(2, "Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 4, 2, 5);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "3D object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3object, noone )
			.setVisible(true, true);
			
		array_push(input_display_list, index);
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
		
		var _d = [];
		for( var i = 0; i < array_length(input_display_list); i++ ) {
			var ind = input_display_list[i];
			
			if(i < input_display_len || ind < ds_list_size(inputs))
				array_push(_d, input_display_list[i]);
		}
		input_display_list = _d;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = inputs[| 1].getValue();
		var _lrot = inputs[| 2].getValue();
		var _lsca = inputs[| 3].getValue();
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var sv = inputs[| i].getValue();
			
			if(is_array(sv)) {
				for( var j = 0; j < array_length(sv); j++ ) {
					var _sv = sv[j];
					_sv(j);
				}
			} else
				sv();
		}
		
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
		
		var _proj = inputs[| 11].getValue();
		var _fov  = inputs[| 12].getValue();
		
		inputs[| 12].setVisible(_proj);
		
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
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}