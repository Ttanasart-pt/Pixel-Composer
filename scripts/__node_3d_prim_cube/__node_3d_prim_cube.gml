function __Node_3D_Cube(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cube";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Main texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, USE_DEF);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 3] = nodeValue("Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Textures per face", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[|  6] = nodeValue("Textures 0", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	inputs[|  7] = nodeValue("Textures 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	inputs[|  8] = nodeValue("Textures 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	inputs[|  9] = nodeValue("Textures 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	inputs[| 10] = nodeValue("Textures 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	inputs[| 11] = nodeValue("Textures 5", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone).setVisible(false);
	
	inputs[| 12] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 13] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 14] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	inputs[| 15] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 16] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 17] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 18] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 19] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 20] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 21] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 1 ] });
	
	inputs[| 22] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		
	input_display_list = [
		["Output",			 false], 1, 22, 
		["Object transform", false], 19, 18, 12,
		["Camera",			 false], 20, 21, 2, 4, 
		["Texture",			  true], 0, 5, 6, 7, 8, 9, 10, 11,
		["Light",			 false], 13, 14, 15, 16, 17,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function(index) { return submit_vertex(index); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("3D vertex", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	for( var i = 0; i < 6; i++ ) 
		vertexObjects[i] = PRIMITIVES[? "cube"][i].clone();
	
	_3d_node_init(1, /*Transform*/ 2, 4, 19, 18, 12);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _panel) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function(index = 0) {
		var _lpos = getSingleValue(19, index);
		var _lrot = getSingleValue(18, index);
		var _lsca = getSingleValue(12, index);
		var _usetex = getSingleValue(5, index);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for(var i = 0; i < array_length(vertexObjects); i++) {
			var _surf = _usetex? getSingleValue(6 + i, index) : getSingleValue(0, index);
			vertexObjects[i].submit(_surf);
		}
			
		_3d_clear_local_transform();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return undefined;
		if(_output_index == 3) return vertexObjects;
		
		var _inSurf = _data[0];
		var _dim    = _data[1];
		var _pos    = _data[2];
		var _rot    = _data[3];
		var _sca    = _data[4];
		
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
		var _dimS = _data[22];
		
		inputs[| 21].setVisible(_proj);
		
		for(var i = 6; i <= 11; i++) inputs[| i].setVisible(true, _usetex);
		inputs[| 0].setVisible(true, !_usetex);
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, true, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
		
		for(var i = 0; i < array_length(vertexObjects); i++) {
			var _surf = _usetex? _data[6 + i] : _inSurf;
			vertexObjects[i].submit(_surf);
		}
		
		_3d_post_setup();
		
		return _outSurf;
	}
}