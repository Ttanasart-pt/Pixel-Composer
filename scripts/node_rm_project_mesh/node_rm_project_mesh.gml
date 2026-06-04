function Node_RM_Project_Mesh(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "RM Project";
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Top"    )).setDrawGroup(0);
	newInput( 1, nodeValue_Surface( "Front"  )).setDrawGroup(0);
	newInput( 2, nodeValue_Surface( "Right"  )).setDrawGroup(0);
	
		////- =/Back side
	newInput( 3, nodeValue_Surface( "Bottom" )).setDrawGroup(1).setVisible(true, false);
	newInput( 4, nodeValue_Surface( "Back"   )).setDrawGroup(1).setVisible(true, false);
	newInput( 5, nodeValue_Surface( "Left"   )).setDrawGroup(1).setVisible(true, false);
	// 6
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	input_display_list = [ 
		[ "Surfaces",       false ],  0, 1, 2,
			[ "/Back side", false ],  3, 4, 5, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone ];
	object       = new __3dRmVoxel();
	voxeldata    = undefined;
	
	static drawOverlay3D = function(active, _mx, _my, _params) {}
	
	static update = function() {
		#region data
			var _sTop  = getInputData( 0); if(!is_surface(_sTop)) return;
			var _sFrn  = getInputData( 1); if(!is_surface(_sFrn)) return;
			var _sSid  = getInputData( 2); if(!is_surface(_sSid)) return;
			
			var _sTopb = getInputData( 3);
			var _sFrnb = getInputData( 4);
			var _sSidb = getInputData( 5);
			
		#endregion
	
		var _dim = surface_get_dimension(_sTop);
		var _res = max(_dim[0], _dim[1]);
		var s = ceil(sqrt(_res * _res * _res));
		
		temp_surface[0] = surface_verify(temp_surface[0], s, s, surface_r8unorm);
		voxeldata = buffer_create(_res * _res * _res, buffer_grow, 1);
		buffer_to_start(voxeldata);
		
		surface_set_shader(temp_surface[0], sh_rm_project_mesh);
			
		surface_reset_shader();
		
		var _bTop = buffer_from_surface(_sTop);
		var _bFrn = buffer_from_surface(_sFrn);
		var _bSid = buffer_from_surface(_sSid);
		
		for( var i = 0; i < _res; i++ )
		for( var j = 0; j < _res; j++ )
		for( var k = 0; k < _res; k++ ) {
			var idT = i * _res + j;
			var idF = j * _res + k;
			var idS = k * _res + i;
			
			var smT = buffer_read_at()
		}
		
		buffer_delete(_bTop);
		buffer_delete(_bFrn);
		buffer_delete(_bSid);
		
		object.voxelRes  = _res;
		object.voxelData = voxeldata;
		object.materials = [
			new __d3dMaterial(_sTop),
			new __d3dMaterial(_sFrn),
			new __d3dMaterial(_sSid),
		];
		object.initModel();
		
		outputs[0].setValue(object);
	}
	
	////- 3D
	
	static getPreviewObject        = function() /*=>*/ {return outputs[0].getValue()};
	static getPreviewValues        = function() /*=>*/ {return outputs[0].getValue()};
	static getPreviewObjects       = function() /*=>*/ {return [ getPreviewObject() ]};
	static getPreviewObjectOutline = function() /*=>*/ {return getPreviewObjects()};
	
} 
