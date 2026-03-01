function Node_Fast3D_Cylinder(_x, _y, _group = noone) : Node_Fast3D(_x, _y, _group) constructor {
	name = "Fast Cylinder";
	
	fast_i = array_length(inputs);
	
	////- =Geometry
	newInput( fast_i+2, nodeValue_Int(  "Side",    8 ));
	newInput( fast_i+3, nodeValue_Bool( "Caps", true ));
	
	////- =Texturing
	newInput( fast_i+0, nodeValue_Palette( "Colors", [ ca_white ] ));
	newInput( fast_i+1, nodeValue_Surface( "Texture"     ));
	newInput( fast_i+4, nodeValue_Float( "Side Scale", 2 ));
	newInput( fast_i+5, nodeValue_Bool(  "Smooth",     0 ));
	// fast_i+6
	
	input_display_list = [
		FAST3D_PRE
		[ "Geometry",  false ], fast_i+2, fast_i+3, 
		[ "Texturing", false ], fast_i+0, fast_i+1, fast_i+4, fast_i+5, 
		FAST3D_REN
	];
	
	////- Model
	
	d3dObject = new __3dCylinder(); 
	
	////- Nodes
	
	static submitObject = function(_data) {
		#region data
			var _side = _data[fast_i+2];
			var _caps = _data[fast_i+3];
			
			var _col  = _data[fast_i+0];
			var _tex  = _data[fast_i+1];
			
			var _sideSca = _data[fast_i+4];
			var _smt     = _data[fast_i+5];
		#endregion
			
		var _clen = array_length(_col);
		var _ttex = is_surface(_tex)? surface_get_texture(_tex) : -1;
		
		d3dObject.checkParameter({ 
			sides : _side, 
			caps  : _caps,
			
			uvScale_side: _sideSca, 
			smooth: _smt, 
		});
		
		var VB = d3dObject.VB;
		
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			if(VB[i] == noone) continue;
			
			shader_set_c("color", _col[i % _clen]);
			vertex_submit(VB[i], pr_trianglelist, _ttex);
		}
		
	}
	
}