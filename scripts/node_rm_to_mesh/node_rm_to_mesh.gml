function Node_RM_to_Mesh(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "RM to Mesh";
	is_3D = NODE_3D.polygon;
	setDrawIcon();
	setDimension(96, 48);
	
	// dialogPanelCall(new Panel_CubeMarch_Guide());
	
	////- Object
	newInput( 0, nodeValue_SDF( "SDF Object" )).setVisible(true, true);
	
	////- Voxel
	newInput( 1, nodeValue_Vec3(    "Midpoint", [0,0,0] ));
	newInput( 2, nodeValue_Vec3(    "Span",     [1,1,1] ));
	newInput( 3, nodeValue_Float(   "Resolution", 8     ));
	
	////- Material
	newInput( 4, nodeValue_D3Material( "Material" ));
	// 5
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	input_display_list = [
		[ "Object",   false ],  0, 
		[ "Voxel",    false ],  1,  2,  3, 
		[ "Material", false ],  4, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	object       = new __3dRmCubeMarch();
	voxeldata    = undefined;
	
	static drawOverlay3D = function(active, _mx, _my, _params) {}
	
	static update = function() {
		#region data
			var _shp  = getInputData( 0);
			
			var _mid  = getInputData( 1);
			var _spa  = getInputData( 2);
			var _res  = getInputData( 3);
			
			var _mat  = getInputData( 4);
			
			if(!is(_shp, RM_Object)) return;
			_shp.flatten();
		#endregion
		
		var s = ceil(sqrt(_res * _res * _res));
		temp_surface[0] = surface_verify(temp_surface[0], s, s, surface_r8unorm);
		voxeldata = buffer_create(_res * _res * _res, buffer_grow, 1);
		
		surface_set_shader(temp_surface[0], sh_rm_to_voxel_cross);
			shader_set_3( "middle",     _mid  );
			shader_set_3( "span",       _spa  );
			
			shader_set_f( "resolution", _res  );
			shader_set_f( "texelSize",  s     );
			_shp.apply();
			
			draw_empty();
		surface_reset_shader();
		buffer_get_surface(voxeldata, temp_surface[0], 0);
		
		object.voxelRes  = _res;
		object.voxelData = voxeldata;
		object.materials = [_mat];
		object.initModel();
		
		outputs[0].setValue(object);
	}
	
	////- 3D
	
	static getPreviewObject        = function() /*=>*/ {return outputs[0].getValue()};
	static getPreviewValues        = function() /*=>*/ {return outputs[0].getValue()};
	static getPreviewObjects       = function() /*=>*/ {return [ getPreviewObject() ]};
	static getPreviewObjectOutline = function() /*=>*/ {return getPreviewObjects()};
	
}