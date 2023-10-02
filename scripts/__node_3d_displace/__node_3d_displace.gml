function __Node_3D_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Displace";
	
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
		.setUnitRef( function() { return getInputData(0); }, VALUE_UNIT.reference);
	
	inputs[| 5] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 6] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 7] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	inputs[| 8] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 10] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 11] = nodeValue("3D vertex", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3vertex, [])
		.setVisible(true, true);
		
	inputs[| 12] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 13] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 1 ] });
	
	inputs[| 14] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 15] = nodeValue("Displacement map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 16] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	input_display_list = [ 11,
		["Output",			 true], 0, 14, 
		["Displace",		false], 15, 16,  
		["Object transform", true], 1, 2, 3,
		["Camera",			 true], 12, 13, 4, 5,
		["Light",			 true], 6, 7, 8, 9, 10,
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 3] = nodeValue("3D vertex", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3vertex, []);
	
	output_display_list = [
		0, 2, 1, 3, 
	]
	
	attributes.auto_update = true;
	
	array_push(attributeEditors, ["Auto Update", function() { return attributes.auto_update; }, 
		new checkBox(function() { 
			attribute[? "auto_update"] = !attribute[? "auto_update"]; 
		}, false)]);
	
	vertexObjects = [];
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for( var i = 0, n = array_length(vertexObjects); i < n; i++ )
			vertexObjects[i].submit();
		
		_3d_clear_local_transform();
	}
	
	static step = function() {
		var _proj = getInputData(12);
		inputs[| 13].setVisible(_proj);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return undefined;
		if(_output_index == 3) return vertexObjects;
		
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
		
		var _dspTex = _data[15];
		var _dspStr = _data[16];
		
		if(_output_index == 0 && attributes.auto_update) {
			var _vert = _data[11];
			
			for( var i = 0, n = array_length(vertexObjects); i < n; i++ )
				vertexObjects[i].destroy();
			vertexObjects = [];
			
			for( var i = 0, n = array_length(_vert); i < n; i++ ) {
				var v = _vert[i].clone(false);
				
				for( var j = 0; j < array_length(v.faces); j++ ) {
					var face = v.faces[j];
					
					var _posI = face[0];
					var _norI = face[1];
					var _texI = face[2];
					
					var str = 1;
					
					if(is_surface(_dspTex)) {
						var c = surface_getpixel(_dspTex, v.textures[_texI][0] * surface_get_width_safe(_dspTex), v.textures[_texI][1] * surface_get_height_safe(_dspTex));
						var r = color_get_red(c) / 255;
						var g = color_get_green(c) / 255;
						var b = color_get_blue(c) / 255;
						str   = 0.2126 * r + 0.7152 * g + 0.0722 * b;
					}
					
					v.positions[@ _posI][@ 0] += v.normals[_norI][0] * str * _dspStr;
					v.positions[@ _posI][@ 1] += v.normals[_norI][1] * str * _dspStr;
					v.positions[@ _posI][@ 2] += v.normals[_norI][2] * str * _dspStr;
				}
				
				v.createBuffer();
				vertexObjects[i] = v;
			}
		}
		
		var pass = "diff";
		switch(_output_index) {
			case 0 : pass = "diff" break;
			case 2 : pass = "norm" break;
		}
		
		var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, true, _dimS );
		var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
		var _cam	   = new __3d_camera(_proj, _fov);
			
		_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
			for( var i = 0, n = array_length(vertexObjects); i < n; i++ )
				vertexObjects[i].submit();
		_3d_post_setup();
		
		return _outSurf;
	}
}