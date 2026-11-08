function Node_3D_Mesh_Terrain(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Terrain";
	
	object_class = __3dTerrain;
	var i = in_mesh;
	
	////- =Mesh
	newInput(i+3, nodeValue_Int(          "Subdivision",   4 ));
	newInput(i+1, nodeValue_EButton(  "Input type",    0 , [ "Surface", "Array" ] ));
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
	];
	
	////- Node
	
	temp_surface = [noone];
	height_arr   = [];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _sub = _data[in_mesh + 3];
			var _inT = _data[in_mesh + 1];
			var _his = _data[in_mesh + 2];
			var _hia = _data[in_mesh + 4];
			var _lvl = _data[in_mesh + 6];
			
			var _smt = _data[in_mesh + 5];
			var _mat = _data[in_mesh + 0];
			
			inputs[in_mesh + 2].setVisible(_inT == 0, _inT == 0);
			inputs[in_mesh + 4].setVisible(_inT == 1, _inT == 1);
		#endregion
		
		var _sub1  = _sub + 1;
		var _h = array_safe_get(height_arr, _array_index, []); 
		    _h = array_verify(_h, _sub1 * _sub1);
		height_arr[_array_index] = _h;
		
		var object = getObject(_array_index);
		
		var lv_min = _lvl[0];
		var lv_max = _lvl[1];
		var lv_rng = lv_max - lv_min;
		
		if(_inT == 0 && is_surface(_his)) {
			var _sw  = surface_get_width(_his);
			var _sh  = surface_get_height(_his);
			var _fmt = surface_get_format(_his);
			
			temp_surface[0] = surface_verify(temp_surface[0], _sub1, _sub1, surface_r16float);
			
			surface_set_shader(temp_surface[0], sh_d3d_terrain_greyscale);
				shader_set_f( "lv_min", lv_min )
				shader_set_f( "lv_rng", lv_rng )
				
				gpu_set_tex_filter(true);
				draw_surface_stretched(_his, 0, 0, _sub1, _sub1);
				gpu_set_tex_filter(false);
			surface_reset_shader();
			
			var _pxw = _sw / _sub1;
			var _pxh = _sh / _sub1;
			var _bf  = buffer_from_surface(temp_surface[0], false);
			buffer_to_start(_bf);
			
			var _ind = 0;
			repeat( _sub1 * _sub1 )  {
				_h[_ind] = buffer_read(_bf, buffer_f16);
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
	
}