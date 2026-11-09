function Node_3D_Render_UV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Render UV";
	
	////- =Mesh
	newInput( 0, nodeValue_D3Mesh("Mesh"));
	
	////- =UV
	newInput( 2, nodeValue_EScroll( "Material", 0, [] ));
	newInput( 1, nodeValue_Dimension());
	// 3
	
	newOutput( 0, nodeValue_Output( "UV Map", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 
		[ "Mesh", false ],  0, 
		[ "UV",   false ],  2,  1, 
	];
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData( 0);
		
		var _mid  = getInputData( 2);
		var _dim  = getInputData( 1);
		
		if(!is(_mesh, __3dInstance)) return;
		
		var _vert = _mesh.vertex;
		var sw = _dim[0];
		var sh = _dim[1];
		
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(16);
		
		var vts = array_safe_get(_vert, _mid, undefined);
		if(vts == undefined) return;
		
		for( var j = 0, m = array_length(vts); j < m; j += 3 ) {
			var vt0 = vts[j+0];
			var vt1 = vts[j+1];
			var vt2 = vts[j+2];
			
			var u0 = _x + vt0.u * sw * _s;
			var v0 = _y + vt0.v * sh * _s;
			
			var u1 = _x + vt1.u * sw * _s;
			var v1 = _y + vt1.v * sh * _s;
			
			var u2 = _x + vt2.u * sw * _s;
			var v2 = _y + vt2.v * sh * _s;
			
			draw_line(u0, v0, u1, v1);
			draw_line(u1, v1, u2, v2);
			draw_line(u0, v0, u2, v2);
			
			draw_circle(u0, v0, ui(3), false);
			draw_circle(u1, v1, ui(3), false);
			draw_circle(u2, v2, ui(3), false);
			
		}
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _mesh = _data[ 0];
			
			var _mid  = _data[ 2];
			var _dim  = _data[ 1];
		#endregion
		
		if(!is(_mesh, __3dInstance)) {
			inputs[2].setChoices([]);
			return _output;
		}
		
		var mat = array_create_ext(array_length(_mesh.vertex), function(i) /*=>*/ {return string(i)});
		inputs[2].setChoices(mat);
		
		_output = surface_verify(_output, _dim[0], _dim[1]);
		
		var vbs  = _mesh.VB;
		
		var mats = _mesh.materials;
		var mind = _mesh.material_index;
		var vb = array_safe_get(vbs, _mid, undefined);
		
		if(vb == undefined) return _output;
		
		surface_set_shader(_output, sh_d3d_render_uv);
			var _mat  = array_safe_get_fast(mats, mind == undefined? _mid : mind[_mid], noone);
			var _uMat = is(_mat, __d3dMaterial);
			
			shader_set_i("mat_flip", _mesh.texture_flip);
			var _tex = _uMat? _mat.getTexture() : -1;
			
			vertex_submit(vb, _mesh.render_type, _tex);
		surface_reset_shader();
		
		return _output;
	}
	
}