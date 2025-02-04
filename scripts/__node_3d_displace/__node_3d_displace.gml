function __Node_3D_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Displace";
	batch_output = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	newInput(2, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
	
	newInput(4, nodeValue_Vec2("Render position", self, [ 0.5, 0.5 ]))
		.setUnitRef( function() { return getInputData(0); }, VALUE_UNIT.reference);
	
	newInput(5, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
		
	newInput(6, nodeValue_Rotation("Light direction", self, 0));
		
	newInput(7, nodeValue_Float("Light height", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	newInput(8, nodeValue_Float("Light intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Color("Light color", self, cola(c_white)));
	
	newInput(10, nodeValue_Color("Ambient color", self, cola(c_grey)));
	
	newInput(11, nodeValue("3D vertex", self, CONNECT_TYPE.input, VALUE_TYPE.d3vertex, []))
		.setVisible(true, true);
		
	newInput(12, nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ]))
		.rejectArray();
		
	newInput(13, nodeValue_Float("Field of view", self, 60))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	newInput(14, nodeValue_Bool("Scale view with dimension", self, true));
	
	newInput(15, nodeValue_Surface("Displacement map", self));
	
	newInput(16, nodeValue_Float("Strength", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	input_display_list = [ 11,
		["Output",			 true], 0, 14, 
		["Displace",		false], 15, 16,  
		["Object transform", true], 1, 2, 3,
		["Camera",			 true], 12, 13, 4, 5,
		["Light",			 true], 6, 7, 8, 9, 10,
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); }));
	
	newOutput(2, nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone));
	
	newOutput(3, nodeValue_Output("3D vertex", self, VALUE_TYPE.d3vertex, []));
	
	output_display_list = [
		0, 2, 1, 3, 
	]
	
	attributes.auto_update = true;
	
	array_push(attributeEditors, ["Auto Update", function() { return attributes.auto_update; }, 
		new checkBox(function() { attribute[? "auto_update"] = !attribute[? "auto_update"]; }, false)]);
	
	vertexObjects = [];
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
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
		inputs[13].setVisible(_proj);
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
						var r = _color_get_red(c);
						var g = _color_get_green(c);
						var b = _color_get_blue(c);
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