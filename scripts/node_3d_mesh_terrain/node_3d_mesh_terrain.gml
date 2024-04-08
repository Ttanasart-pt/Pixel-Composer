function Node_3D_Mesh_Terrain(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Terrain";
	
	object_class = __3dTerrain;
	
	inputs[| in_mesh + 0] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Surface", "Array" ]);
	
	inputs[| in_mesh + 2] = nodeValue("Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 3] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 );
	
	inputs[| in_mesh + 4] = nodeValue("Height array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setArrayDepth(2);
	
	input_display_list = [
		__d3d_input_list_mesh, 
		__d3d_input_list_transform,
		["Terrain",		false], in_mesh + 3, in_mesh + 1, in_mesh + 2, in_mesh + 4, 
		["Material",	false], in_mesh + 0, 
	]
	
	static step = function() { #region
		var _inT = getInputData(in_mesh + 1);
		
		inputs[| in_mesh + 2].setVisible(_inT == 0, _inT == 0);
		inputs[| in_mesh + 4].setVisible(_inT == 1, _inT == 1);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat = _data[in_mesh + 0];
		var _inT = _data[in_mesh + 1];
		var _sub = _data[in_mesh + 3];
		var _his = _data[in_mesh + 2];
		var _hia = _data[in_mesh + 4];
		
		var _h = array_create((_sub + 1) * (_sub + 1));
		var object = getObject(_array_index);
		
		if(_inT == 0 && is_surface(_his)) {
			var _ind = 0;
			var _pxw = surface_get_width(_his)  / (_sub + 1);
			var _pxh = surface_get_height(_his) / (_sub + 1);
			
			for( var i = 0; i < _sub + 1; i++ ) 
			for( var j = 0; j < _sub + 1; j++ ) {
				var cc = surface_getpixel(_his, j * _pxw, i * _pxh);
				_h[_ind] = colorBrightness(cc);
				_ind++;
			}
		} else if(_inT == 1 && !array_empty(_hia)) {
			if(is_array(_hia[0])) _hia = array_spread(_hia);
			
			array_copy(_h, 0, _hia, 0, min(array_length(_h), array_length(_hia)));
		}
		
		if(IS_FIRST_FRAME) object.initModel();
		
		object.checkParameter({ subdivision: _sub });
		object.updateHeight(_h);
		object.materials   = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}