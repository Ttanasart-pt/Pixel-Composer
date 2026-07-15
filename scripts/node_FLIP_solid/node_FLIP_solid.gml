function Node_FLIP_Solid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Surface Collider";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	////- =Collider
	newInput( 1, nodeValue_Surface( "Collider"      ));
	newInput( 3, nodeValue_Slider(  "Threshold", .1 ));
	newInput( 2, nodeValue_Int(     "Expands",    0 ));
	// 4
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 
		[ "Collider",  false ],  1,  3,  2, 
	]
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	static getDimension = function() { var d = getInputData(0); return instance_exists(d)? d.getSize() : [ 1, 1 ]; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var domain = getInputData( 0);
			
			var _surf  = getInputData( 1);
			var _thrs  = getInputData( 3);
			var _expn  = getInputData( 2);
		
			if(!instance_exists(domain)) return;
			outputs[0].setValue(domain);
			
			if(!is_surface(_surf)) return;
		#endregion
		
		var ww = domain.cellX;
		var hh = domain.cellY;
		
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, surface_r8unorm);
		temp_surface[1] = surface_verify(temp_surface[1], ww, hh, surface_r8unorm);
		
		surface_set_shader(temp_surface[0], sh_flip_solid_surface_cvt);
			shader_set_f( "threshold", _thrs   );
			
			draw_surface_stretched(_surf, 0, 0, ww, hh);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_flip_solid_surface_expand);
			shader_set_2( "dimension", [ww,hh] );
			shader_set_f( "expands",   _expn   );
			
			draw_surface_stretched(temp_surface[0], 0, 0, ww, hh);
		surface_reset_shader();
		
		var _buff = buffer_create(ww * hh, buffer_fixed, 1);
		buffer_get_surface(_buff, temp_surface[1], 0);
		
		FLIP_setSolid_surface(domain.domain, buffer_get_address(_buff));
		buffer_delete(_buff);
	}
	
	static getPreviewValues = function() /*=>*/ {return temp_surface[1]};
}