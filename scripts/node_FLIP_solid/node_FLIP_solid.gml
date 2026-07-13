function Node_FLIP_Solid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Surface Collider";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	////- =Collider
	newInput( 1, nodeValue_Surface( "Collider" ));
	// 2
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 
		[ "Collider",  false ], 1, 
	]
	
	////- Node
	
	temp_surface = [ noone ];
	
	static getDimension = function() { var d = getInputData(0); return instance_exists(d)? d.getSize() : [ 1, 1 ]; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var domain = getInputData(0);
			var _surf  = getInputData(1);
		
			if(!instance_exists(domain)) return;
			outputs[0].setValue(domain);
			
			if(!is_surface(_surf)) return;
		#endregion
		
		var ww = domain.cellX;
		var hh = domain.cellY;
		
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, surface_r8unorm);
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			draw_surface_stretched(_surf, 0, 0, ww, hh);
		surface_reset_target();
		
		var _buff = buffer_create(ww * hh, buffer_fixed, 1);
		buffer_get_surface(_buff, temp_surface[0], 0);
		
		FLIP_setSolid_surface(domain.domain, buffer_get_address(_buff));
		buffer_delete(_buff);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}