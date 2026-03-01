function Node_Fast3D_Cube(_x, _y, _group = noone) : Node_Fast3D(_x, _y, _group) constructor {
	name = "Fast Cube";
	
	fast_i = array_length(inputs);
	
	////- =Texturing
	newInput( fast_i+0, nodeValue_Palette( "Colors", [ ca_white ] ));
	newInput( fast_i+1, nodeValue_Surface( "Texture" ));
	//
	
	input_display_list = [
		FAST3D_PRE
		[ "Texturing", false ], fast_i+0, fast_i+1, 
		FAST3D_REN
	];
	
	////- Model
	
	d3dObject = new __3dCube(); 
	d3dObject.separate_faces = true;
	d3dObject.initModel();
	
	var v = d3dObject.VB;
	VB = [ v[1], v[3], v[5], v[0], v[2], v[4] ];
	
	////- Nodes
	
	static submitObject = function(_data) {
		#region data
			var _col = _data[fast_i+0];
			var _tex = _data[fast_i+1];
		#endregion
			
		var _clen = array_length(_col);
		var _ttex = is_surface(_tex)? surface_get_texture(_tex) : -1;
		
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			if(VB[i] == noone) continue;
			
			shader_set_c("color", _col[i % _clen]);
			vertex_submit(VB[i], pr_trianglelist, _ttex);
		}
		
	}
	
}