function Node_3D_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Transform";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 2].getValue(); }, VALUE_UNIT.reference);
	
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
		
	inputs[| 12] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 13] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 1, 90, 1 ]);
	
	inputs[| 14] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	input_display_list = [ 11,
		["Output",				false], 0, 14, 
		["Object transform",	false], 1, 2, 3,
		["Camera",				false], 12, 13, 4, 5,
		["Light",				 true], 6, 7, 8, 9, 10,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);	
	
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
			for( var i = 0, n = array_length(sv); i < n; i++ )
				sv[i](i);
		} else
			sv();
		_3d_clear_local_transform();
	}
	
	static step = function() {
		var _proj = inputs[| 12].getValue();
		inputs[| 13].setVisible(_proj);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return undefined;
		
		var _dim  = _data[0];
		var _lpos = _data[1];
		var _lrot = _data[2];
		var _lsca = _data[3];
		
		var _pos  = _data[4];
		var _sca  = _data[5];
		
		var _ldir = _data[ 6];
		var _lhgt = _data[ 7];
		var _lint = _data[ 8];
		var _lclr = _data[ 9];
		var _aclr = _data[10];

		var _proj = _data[12];
		var _fov  = _data[13];
		var _dimS = _data[14];
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, false, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
			submit_vertex();
		_3d_post_setup();
		
		return _outSurf;
	}
}