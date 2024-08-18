function __Node_3D_Cube(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Cube";
	batch_output = false;
	dimension_index = 1;
	
	newInput(0, nodeValue_Surface("Main texture", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	inputs[2] = nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ])
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(3, nodeValue_Vec3("Render rotation", self, [ 0, 0, 0 ]));
	
	newInput(4, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
	
	newInput(5, nodeValue_Bool("Textures per face", self, false));
	
	newInput( 6, nodeValue_Surface("Textures 0", self).setVisible(false));
	newInput( 7, nodeValue_Surface("Textures 1", self).setVisible(false));
	newInput( 8, nodeValue_Surface("Textures 2", self).setVisible(false));
	newInput( 9, nodeValue_Surface("Textures 3", self).setVisible(false));
	newInput(10, nodeValue_Surface("Textures 4", self).setVisible(false));
	newInput(11, nodeValue_Surface("Textures 5", self).setVisible(false));
	
	newInput(12, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
		
	newInput(13, nodeValue_Rotation("Light direction", self, 0));
		
	inputs[14] = nodeValue_Float("Light height", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	inputs[15] = nodeValue_Float("Light intensity", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(16, nodeValue_Color("Light color", self, c_white));
	
	newInput(17, nodeValue_Color("Ambient color", self, c_grey));
	
	newInput(18, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
		
	newInput(19, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	inputs[20] = nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[21] = nodeValue_Float("Field of view", self, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	inputs[22] = nodeValue_Bool("Scale view with dimension", self, true)
		
	input_display_list = [
		["Output",			 false], 1, 22, 
		["Object transform", false], 19, 18, 12,
		["Camera",			 false], 20, 21, 2, 4, 
		["Texture",			  true], 0, 5, 6, 7, 8, 9, 10, 11,
		["Light",			 false], 13, 14, 15, 16, 17,
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[1] = nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function(index) { return submit_vertex(index); });
	
	outputs[2] = nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone);
	
	outputs[3] = nodeValue_Output("3D vertex", self, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3
	]
	
	for( var i = 0; i < 6; i++ ) 
		vertexObjects[i] = PRIMITIVES[? "cube"][i].clone();
	
	_3d_node_init(1, /*Transform*/ 2, 4, 19, 18, 12);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _panel) {
		PROCESSOR_OVERLAY_CHECK
		
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
		
		inputs[21].setVisible(_proj);
		
		for(var i = 6; i <= 11; i++) inputs[i].setVisible(true, _usetex);
		inputs[0].setVisible(true, !_usetex);
		
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