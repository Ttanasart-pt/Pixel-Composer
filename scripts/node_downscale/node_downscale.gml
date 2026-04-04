function Node_Downscale(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Downscale";
	dimension_index = -1;
	manage_atlas    = false;
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface("Surface In" ));
	
	////- =Scale
	newInput( 2, nodeValue_EButton( "Mode",      0, [ "Mix", "Max", "Min" ] ));
	newInput( 1, nodeValue_Float(   "Downscale", 1 ));
	newInput( 4, nodeValue_Bool(    "Multiply Alpha", false ));
	// inputs 5
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  3, 
		[ "Surfaces", true ],  0,  
		[ "Scale",	 false ],  2,  1,  4, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var surf  = _data[0]; 
			var malp  = _data[4]; 
			
			var mode  = _data[2];
			var scale = _data[1];
			
			var cDep  = attrDepth();
		#endregion
		
		var isAtlas = is(surf, SurfaceAtlas);
		if(isAtlas && !is(_outSurf, SurfaceAtlas)) 
			_outSurf = surf.clone(true);
		
		var sw = surface_get_width_safe(  surf );
		var sh = surface_get_height_safe( surf );
		
		var ww = max(1, ceil(sw / scale));
		var hh = max(1, ceil(sh / scale));
		
		_outSurf = surface_verify(_outSurf, ww, hh, cDep);
		
		surface_set_shader(_outSurf, sh_downscale);
			shader_set_interpolation(surf);
			shader_set_i( "sampleMode", getAttribute("oversample"));
			
			shader_set_2("baseDimension", [ww,hh] );
			shader_set_2("surfDimension", [sw,sh] );
			shader_set_f("scale",          scale  );
			shader_set_i("mode",           mode   );
			shader_set_i("multiplyAlpha",  malp   );
			
			draw_surface_stretched_safe(surf, 0, 0, ww, hh);
		surface_reset_shader();
		
		draw_transforms[_array_index] = [ 0, 0, 1 / scale, 1 / scale, 0];
		
		return _outSurf;
	}
}