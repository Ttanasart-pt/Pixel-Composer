function Node_Fast3D_Sphere(_x, _y, _group = noone) : Node_Fast3D(_x, _y, _group) constructor {
	name = "Fast Sphere";
	
	fast_i = array_length(inputs);
	
	////- =Geometry
	newInput( fast_i+2, nodeValue_IVec2(  "Side", [16,8] ));
	
	////- =Texturing
	newInput( fast_i+0, nodeValue_Palette( "Colors", [ ca_white ] ));
	newInput( fast_i+1, nodeValue_Surface( "Texture"     ));
	newInput( fast_i+3, nodeValue_Float( "Side Scale", 2 ));
	newInput( fast_i+4, nodeValue_Bool(  "Smooth",     0 ));
	// fast_i+5
	
	input_display_list = [
		FAST3D_PRE
		[ "Geometry",  false ], fast_i+2, 
		[ "Texturing", false ], fast_i+0, fast_i+1, fast_i+3, fast_i+4, 
		FAST3D_REN
	];
	
	////- Model
	
	d3dObject = new __3dUVSphere(); 
	
	////- Nodes
	
	static submitObject = function(_data) {
		#region data
			var _side = _data[fast_i+2];
			
			var _col  = _data[fast_i+0];
			var _tex  = _data[fast_i+1];
			
			var _sca  = _data[fast_i+3];
			var _smt  = _data[fast_i+4];
		#endregion
			
		var _clen = array_length(_col);
		var _ttex = is_surface(_tex)? surface_get_texture(_tex) : -1;
		
		d3dObject.checkParameter({ 
			hori  : _side[0], 
			vert  : _side[1], 
			uvsca : _sca, 
			
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