function Node_3D_Material(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Material";
	is_3D = NODE_3D.none;
	solid_surf = noone;
	
	////- =Texture
	newInput( 0, nodeValue_Surface( "Texture"              )).setVisible(true, true);
	newInput( 8, nodeValue_Bool(    "Anti Aliasing", false ));
	newInput( 9, nodeValue_Vec2(    "Scale",         [1,1] ));
	newInput(10, nodeValue_Vec2(    "Shift",         [0,0] ));
	
	////- =Properties
	newInput(11, nodeValue_EScroll( "Shader",     0, [ "Phong", "PBR" ] ));
	
	newInput( 1, nodeValue_Slider(  "Diffuse",    1     ));
	newInput( 2, nodeValue_Slider(  "Specular",   0     ));
	newInput( 3, nodeValue_Float(   "Shininess",  1     ));
	newInput( 4, nodeValue_Bool(    "Metal",      false ));
	newInput(15, nodeValue_Slider(  "Reflectance",0     ));
	
	newInput(12, nodeValue_Slider(  "Metalic",    0     )).setMappable(13);
	newInput( 7, nodeValue_Slider(  "Roughness",  1     )).setMappable(14);
	
	////- =Normal
	newInput( 5, nodeValue_Surface( "Normal Map"                    ));
	newInput( 6, nodeValue_Slider(  "Normal Strength", 1, [0,2,.01] ));
	// 16
	
	newOutput(0, nodeValue_Output("Material", VALUE_TYPE.d3Material, noone));
	
	input_display_list = [ 
		[ "Texture",    false ], 0, 8, 9, 10, 
		[ "Properties", false ], 11, /**/ 1, 2, 3, 4, 15, /**/ 12, 13, 7, 14, 
		[ "Normal",     false ], 5, 6,
	];
	
	////- Nodes
	
	temp_surfaces = [noone];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _surf = _data[ 0];
			var _aa   = _data[ 8];
			var _scal = _data[ 9];
			var _shft = _data[10];
			
			var _shad = _data[11];
			var _diff = _data[ 1];
			var _spec = _data[ 2];
			var _shin = _data[ 3];
			var _metl = _data[ 4];
			var _refl = _data[15];
			
			var _mett = _data[12];
			var _roug = _data[ 7];
			
			var _nor  = _data[ 5];
			var _norS = _data[ 6];
			
			inputs[ 1].setVisible(_shad == 0);
			inputs[ 2].setVisible(_shad == 0);
			inputs[ 3].setVisible(_shad == 0);
			inputs[ 4].setVisible(_shad == 0);
			
			inputs[12].setVisible(_shad == 1);
			inputs[ 7].setVisible(_shad == 1);
		#endregion
		
		if(!is_surface(_surf)) {
			solid_surf = surface_verify(solid_surf, 1, 1);
			_surf = solid_surf;
		}
		
		var _mat = new __d3dMaterial(_surf);
		_mat.texScale   = _scal;
		_mat.texShift   = _shft;
		_mat.texFilter  = _aa;
		
		_mat.diffuse    = _diff;
		_mat.specular   = _spec;
		_mat.shine      = _shin;
		_mat.metalic    = _metl;
		_mat.reflective = _refl;
		
		_mat.normal     = _nor;
		_mat.normalStr  = _norS;
		
		#region pbr map
			var _met_map = _data[13];
			var _rog_map = _data[14];
			
			var _prop_w = max(32, surface_get_width_safe(_met_map),  surface_get_width_safe(_rog_map));
			var _prop_h = max(32, surface_get_height_safe(_met_map), surface_get_height_safe(_rog_map));
			
			temp_surfaces[0] = surface_verify(temp_surfaces[0], _prop_w, _prop_h);
			surface_set_target(temp_surfaces[0]);
				draw_clear(c_black);
				BLEND_ADD_ONE
				
				gpu_set_colorwriteenable(1,0,0,1);
				draw_surface_stretched_safe(_met_map, 0, 0, _prop_w, _prop_h);
				
				gpu_set_colorwriteenable(0,1,0,1);
				draw_surface_stretched_safe(_rog_map, 0, 0, _prop_w, _prop_h);
				
				gpu_set_colorwriteenable(1,1,1,1);
				BLEND_NORMAL
			surface_reset_target();
		#endregion
		
		_mat.pbr_metalic_map    = inputs[12].attributes.mapped;
		_mat.pbr_roughness_map  = inputs[ 7].attributes.mapped;
		_mat.pbr_metalic        = _mat.pbr_metalic_map?   _mett : [_mett,_mett]; 
		_mat.pbr_roughness      = _mat.pbr_roughness_map? _roug : [_roug,_roug]; 
		_mat.pbr_properties_map = temp_surfaces[0];
	
		return _mat;
	}
	
	static getPreviewValues       = function() /*=>*/ {return inputs[0].getValue()};
	static getGraphPreviewSurface = function() /*=>*/ {return getInputSingle(0)};
}