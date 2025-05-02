function __Node_3D_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Transform";
	batch_output = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	newInput(2, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
	
	newInput(4, nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ]))
		.setUnitRef( function() { return getInputData(2); }, VALUE_UNIT.reference);
	
	newInput(5, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
		
	newInput(6, nodeValue_Rotation("Light direction", self, 0));
		
	newInput(7, nodeValue_Float("Light height", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	newInput(8, nodeValue_Float("Light intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Color("Light color", self, ca_white));
	
	newInput(10, nodeValue_Color("Ambient color", self, cola(c_grey)));
	
	newInput(11, nodeValue("3D object", self, CONNECT_TYPE.input, VALUE_TYPE.d3object, noone))
		.setVisible(true, true);
		
	newInput(12, nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ]))
		.rejectArray();
		
	newInput(13, nodeValue_Float("Field of view", self, 60))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	newInput(14, nodeValue_Bool("Scale view with dimension", self, true))
	
	input_display_list = [ 11,
		["Output",				false], 0, 14, 
		["Object transform",	false], 1, 2, 3,
		["Camera",				false], 12, 13, 4, 5,
		["Light",				 true], 6, 7, 8, 9, 10,
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); }));
	
	newOutput(2, nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone));
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);	
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		var sv = getInputData(11);
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
		var _proj = getInputData(12);
		inputs[13].setVisible(_proj);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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