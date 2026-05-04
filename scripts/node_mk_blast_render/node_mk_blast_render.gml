function Node_MK_Blast_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	parameters.inline_draw_output = true;
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	
	newOutput( 0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 
		[ "Blast",   false ], 0,  
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone ];
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim = getDimension();
			
			var _layers = getInputData(0);
		#endregion
		
		var _outSurf = surface_verify(outputs[0].getValue(), _dim[0], _dim[1]);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_rgba16float);
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			
			for( var i = 0, n = array_length(_layers); i < n; i++ )
				_layers[i].draw(temp_surface[0]);
			
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			shader_set(sh_mk_blast_remove_black);
				draw_surface(temp_surface[1], 0, 0);
			shader_reset();
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
	}
}