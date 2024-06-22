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
		
	inputs[| in_mesh + 5] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_mesh + 6] = nodeValue("Front Height Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [
		__d3d_input_list_transform,
		["Terrain",		false], in_mesh + 3, in_mesh + 1, in_mesh + 2, in_mesh + 4, in_mesh + 5, in_mesh + 6, 
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
		var _smt = _data[in_mesh + 5];
		var _lvl = _data[in_mesh + 6];
		
		var _h     = array_create((_sub + 1) * (_sub + 1));
		var object = getObject(_array_index);
		
		var lv_min = _lvl[0];
		var lv_max = _lvl[1];
		var lv_rng = lv_max - lv_min;
		
		if(_inT == 0 && is_surface(_his)) {
			var _ind = 0;
			var _sw  = surface_get_width(_his);
			var _sh  = surface_get_height(_his);
			
			var _pxw = _sw / (_sub + 1);
			var _pxh = _sh / (_sub + 1);
			var _bf  = buffer_from_surface(_his, false);
			
			for( var i = 0; i < _sub + 1; i++ ) 
			for( var j = 0; j < _sub + 1; j++ ) {
				var ps   = clamp(round(i * _pxh), 0, _sh) * _sw + clamp(round(j * _pxw), 0, _sw);
				buffer_seek(_bf, buffer_seek_start, ps * 4);
				
				var cc   = buffer_read(_bf, buffer_u32);
				_h[_ind] = lv_min + colorBrightness(cc) * lv_rng;
				_ind++;
			}
			
			buffer_delete(_bf);
		} else if(_inT == 1 && !array_empty(_hia)) {
			if(is_array(_hia[0])) _hia = array_spread(_hia);
			
			array_copy(_h, 0, _hia, 0, min(array_length(_h), array_length(_hia)));
		}
		
		object.checkParameter({ subdivision: _sub, smooth: _smt });
		object.updateHeight(_h);
		object.materials   = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}