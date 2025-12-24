function Node_3D_Mesh_Terrain(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Terrain";
	
	object_class = __3dTerrain;
	var i = in_mesh;
	
	////- =Mesh
	newInput(i+3, nodeValue_Int(          "Subdivision",   4 ));
	newInput(i+1, nodeValue_Enum_Button(  "Input type",    0 , [ "Surface", "Array" ] ));
	newInput(i+2, nodeValue_Surface(      "Height map" ));
	newInput(i+4, nodeValue_Float(        "Height array",       []       )).setArrayDepth(2);
	newInput(i+6, nodeValue_Slider_Range( "Front Height Level", [ 0, 1 ] ));
	
	////- =Material
	newInput(i+5, nodeValue_Bool(       "Smooth", false ));
	newInput(i+0, nodeValue_D3Material( "Material", new __d3dMaterial() )).setVisible(true, true);
	// input i=7
	
	input_display_list = [
		__d3d_input_list_transform,
		["Mesh",		false], i+3, i+1, i+2, i+4, i+6, 
		["Material",	false], i+5, i+0, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _mat = _data[in_mesh + 0];
		var _inT = _data[in_mesh + 1];
		var _sub = _data[in_mesh + 3];
		var _his = _data[in_mesh + 2];
		var _hia = _data[in_mesh + 4];
		var _smt = _data[in_mesh + 5];
		var _lvl = _data[in_mesh + 6];
		
		inputs[in_mesh + 2].setVisible(_inT == 0, _inT == 0);
		inputs[in_mesh + 4].setVisible(_inT == 1, _inT == 1);
		
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
	}
	
	static getPreviewValues = function() { return getInputSingle(in_mesh + 0); }
}