function Node_UV_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "UV Blend";
	
	////- =UVS
	newInput( 0, nodeValue_Surface( "UV bg" )).setCustomData(global.SURFACE_UV_JUNC);
	newInput( 1, nodeValue_Surface( "UV fg" )).setCustomData(global.SURFACE_UV_JUNC);
	
	////- =Blending
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Amount", .5 ));
	// 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "UVs",      false ],  0,  1, 
		[ "Blending", false ],  3,  2, 
	];
	
	outputs[0].setCustomData(global.SURFACE_UV_JUNC);
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var uv0 = _data[ 0];
			var uv1 = _data[ 1];
			
			var msk = _data[ 3], useMask = is_surface(msk);
			var amo = _data[ 2];
		#endregion
		
		surface_set_shader(_outSurf, sh_uv_blend);
			shader_set_s("bg",  uv0);
			shader_set_s("fg",  uv1);
			
			shader_set_i("useMask", useMask);
			shader_set_s("mask",    msk);
			shader_set_f("amo",     amo);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}