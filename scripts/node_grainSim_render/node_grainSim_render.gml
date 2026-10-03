function Node_GrainSim_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	
	parameters.inline_draw_output = true;
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	////- =Domain
	newInput( 0, nodeValue_Struct( "Domain" )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	
	////- =Update
	newInput( 1, nodeValue_Bool( "Update",  true ));
	newInput( 2, nodeValue_Int(  "Iteration", 16 ));
	
	////- =Rendering
	newInput( 4, nodeValue_EScroll( "Channel", 0, [ "Material", "Velocity", "Density" ] ));
	newInput( 3, nodeValue_Bool(    "Anti-Aliasing", false ));
	newInput( 5, nodeValue_Float(   "Magnitude",     .1    ));
	
	////- =Post-Processing
	
		////- =/Alpha Threshold
	newInput( 6, nodeValue_Bool(    "Use Threshold", false ));
	newInput( 7, nodeValue_Slider(  "Threshold",     .5    ));
	// 8
	
	newOutput( 0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [
		[ "Domain",    false    ],  0, 
		[ "Update",    false, 1 ],  2,  
		[ "Rendering", false    ],  4,  3,  5, 
		
		[ "Post Processing", false ], 
			[ "/Alpha Threshold", false, 6 ],  7, 
	];
	
	////- Node
	
	outpBuff = undefined;
	temp_surface = [ noone ];
	
	static getDimension = function() /*=>*/ {
		var _domain = inputs[0].getValue();
		return is(_domain, GrainSim_Domain)? [_domain.size, _domain.size] : PROJ_SURF;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _domain = inputs[ 0].getValue();
			
			var _update = inputs[ 1].getValue();
			var _itr    = inputs[ 2].getValue();
			
			var _chan   = inputs[ 4].getValue();
			var _aa     = inputs[ 3].getValue();
			var _mag    = inputs[ 5].getValue();
			
			var _atUse  = inputs[ 6].getValue();
			var _athr   = inputs[ 7].getValue();
			
			inputs[ 3].setVisible(_chan == 0);
			inputs[ 5].setVisible(_chan >  0);
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		if(IS_PLAYING && _update) grainSim_step(_domain.index, _itr);
		
		var _size   = _domain.size;
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _size, _size);
		outputs[0].setValue(_outSurf);
		
		outpBuff = buffer_verify(outpBuff, _size * _size * 8 * 4, buffer_grow);
		
		// var pcount = grainSim_getParticleCount(_domain.index);
		// print(pcount);
		
		switch(_chan) {
			case 0 :
				if(_aa) grainSim_render_aa( _domain.index, buffer_get_address(outpBuff) );
				else    grainSim_render(    _domain.index, buffer_get_address(outpBuff) );
				break;
				
			case 1 : grainSim_render_grid_velocity( _domain.index, _mag, buffer_get_address(outpBuff) ); break;
			case 2 : grainSim_render_grid_density(  _domain.index, _mag, buffer_get_address(outpBuff) ); break;
		}
		
		buffer_set_surface(outpBuff, _outSurf, 0);
		
		if(_atUse) {
			temp_surface[0] = surface_verify(temp_surface[0], _size, _size);
			
			surface_set_shader(temp_surface[0], sh_grainsim_render_threshold);
				shader_set_f( "threshold", _athr );
				
				draw_surface(_outSurf, 0, 0);
			surface_reset_shader();
			
			surface_set_target(_outSurf);
				DRAW_CLEAR
				BLEND_OVERRIDE
				draw_surface(temp_surface[0], 0, 0);
				BLEND_NORMAL
			surface_reset_target();
		}
		
		outputs[0].setValue(_outSurf);
	}

}