function Node_Corner_Detect(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Corner Detect";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	newInput( 2, nodeValue_EScroll( "Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
		
	////- =Detection
	newInput( 1, nodeValue_EScroll( "Algorithm",  0, [ "Harris" ] )).setPieMenu();
	newInput( 9, nodeValue_Float(   "Radius",     4 )).setUnitSimple(false);
	newInput(10, nodeValue_Slider(  "k",         .2 ));
	newInput(11, nodeValue_Slider(  "Threshold", .2 ));
	// 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		[ "Surfaces",   true ],  0,  3,  4,  7,  8, 
		[ "Detection", false ],  1,  9, 10, 11, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = array_create(9, noone);
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var surf  = _data[ 0];
			
			var algo  = _data[ 1];
			var radi  = _data[ 9];
			
			var k     = _data[10];
			var thr   = _data[11];
			
			if(!is_surface(surf)) return _outSurf;
		#endregion
		
		var over  = getAttribute("oversample");
		var _dim  = surface_get_dimension(surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_r16float);
		
		var sI   = temp_surface[0];
		var sIx  = temp_surface[1];
		var sIy  = temp_surface[2];
		
		var sIxx = temp_surface[3];
		var sIxy = temp_surface[4];
		var sIyy = temp_surface[5];
		
		var sGxx = temp_surface[6];
		var sGxy = temp_surface[7];
		var sGyy = temp_surface[8];
		
		surface_set_shader(sI, sh_corner_detect_grey);
			shader_set_2( "dimension", _dim );
			
			draw_surface(surf,0,0);
		surface_reset_shader();
		
		//////////////////////////////////////
		
		surface_set_shader(sIx, sh_corner_detect_sobel);
			shader_set_2( "dimension", _dim );
			shader_set_i( "axis",      0    );
			
			draw_surface(sI,0,0);
		surface_reset_shader();
		
		surface_set_shader(sIy, sh_corner_detect_sobel);
			shader_set_2( "dimension", _dim );
			shader_set_i( "axis",      1    );
			
			draw_surface(sI,0,0);
		surface_reset_shader();
		
		//////////////////////////////////////
		
		surface_set_shader(sIxx, sh_corner_detect_multiply);
			shader_set_s( "s0", sIx );
			shader_set_s( "s1", sIx );
			
			draw_empty();
		surface_reset_shader();
		
		surface_set_shader(sIxy, sh_corner_detect_multiply);
			shader_set_s( "s0", sIx );
			shader_set_s( "s1", sIy );
			
			draw_empty();
		surface_reset_shader();
		
		surface_set_shader(sIyy, sh_corner_detect_multiply);
			shader_set_s( "s0", sIy );
			shader_set_s( "s1", sIy );
			
			draw_empty();
		surface_reset_shader();
		
		//////////////////////////////////////
		
		surface_set_shader(sGxx, sh_corner_detect_blur);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    radi );
			
			draw_surface(sIxx,0,0);
		surface_reset_shader();
		
		surface_set_shader(sGxy, sh_corner_detect_blur);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    radi );
			
			draw_surface(sIxy,0,0);
		surface_reset_shader();
		
		surface_set_shader(sGyy, sh_corner_detect_blur);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    radi );
			
			draw_surface(sIyy,0,0);
		surface_reset_shader();
		
		//////////////////////////////////////
		
		surface_set_shader(_outSurf, sh_corner_detect);
			shader_set_2( "dimension", _dim );
			
			shader_set_f( "k",         k    );
			shader_set_f( "thres",     thr  );
			
			shader_set_s( "Ixx",       sGxx );
			shader_set_s( "Ixy",       sGxy );
			shader_set_s( "Iyy",       sGyy );
			
			draw_surface(sI,0,0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(surf, _outSurf, _data[3], _data[4], inputs[3]);
		_outSurf = channel_apply(surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}