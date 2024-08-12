function __Node_3D_Combine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "3D Combine";
	
	inputs[0] = nodeValue_Dimension(self)
		.rejectArray();
	
	inputs[1] = nodeValue_Vec3("Object position", self, [ 0, 0, 0 ])
		.rejectArray();
	
	inputs[2] = nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ])
		.rejectArray();
	
	inputs[3] = nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ])
		.rejectArray();
	
	inputs[4] = nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ])
		.setUnitRef( function() { return getInputData(2); }, VALUE_UNIT.reference)
		.rejectArray();
	
	inputs[5] = nodeValue_Vec2("Render scale", self, [ 1, 1 ])
		.rejectArray();
		
	inputs[6] = nodeValue_Rotation("Light direction", self, 0)
		.rejectArray();
		
	inputs[7] = nodeValue_Float("Light height", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] })
		.rejectArray();
		
	inputs[8] = nodeValue_Float("Light intensity", self, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[9] = nodeValue_Color("Light color", self, c_white)
		.rejectArray();
	
	inputs[10] = nodeValue_Color("Ambient color", self, c_grey)
		.rejectArray();
		
	inputs[11] = nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[12] = nodeValue_Float("Field of view", self, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 0.1 ] })
		.rejectArray();
	
	inputs[13] = nodeValue_Bool("Scale view with dimension", self, true)
	
	input_display_list = [ 
		["Output",				false], 0, 13, 
		["Object transform",	false], 1, 2, 3,
		["Camera",				false], 11, 12, 4, 5,
		["Light",				false], 6, 7, 8, 9, 10,
		["Objects",				 true], 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[1] = nodeValue_Output("3D objects", self, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[2] = nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone);
	
	output_display_list = [ 0, 2, 1 ]
	
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);
	
	static createNewInput = function() {
		var index = array_length(inputs);
		inputs[index] = nodeValue("3D object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3object, noone )
			.setVisible(true, true);
			
		array_push(input_display_list, index);
		
	} setDynamicInput(1, true, VALUE_TYPE.d3object);
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for( var i = input_fix_len; i < array_length(inputs) - 1; i++ ) {
			var sv = getInputData(i);
			
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
	
	static update = function(frame = CURRENT_FRAME) {
		var _dim  = getInputData(0);
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		var _pos  = getInputData(4);
		var _sca  = getInputData(5);
		
		var _ldir = getInputData( 6);
		var _lhgt = getInputData( 7);
		var _lint = getInputData( 8);
		var _lclr = getInputData( 9);
		var _aclr = getInputData(10);
		
		var _proj = getInputData(11);
		var _fov  = getInputData(12);
		var _dimS = getInputData(13);
		
		inputs[12].setVisible(_proj);
		
		for( var i = 0, n = array_length(output_display_list) - 1; i < n; i++ ) {
			var ind = output_display_list[i];
			var _outSurf = outputs[ind].getValue();
			outputs[ind].setValue(surface_verify(_outSurf, _dim[0], _dim[1]));
			
			var pass = "diff";
			switch(ind) {
				case 0 : pass = "diff" break;
				case 2 : pass = "norm" break;
			}
		
			var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, false, _dimS );
			var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
			var _cam	   = new __3d_camera(_proj, _fov);
			
			_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
				submit_vertex();
			_3d_post_setup();
		}
	}
}