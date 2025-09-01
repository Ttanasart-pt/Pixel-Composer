function Node_pSystem_Sample_Color(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sample Color";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_sample_color;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Sample
	newInput( 3, nodeValue_Surface(   "Sample Surface"   ));
	newInput( 4, nodeValue_Dimension( "Target Dimension" ));
	newInput( 5, nodeValue_Bool(      "On Spawn", true   ));
	
	////- =Blending
	newInput( 6, nodeValue_Bool(      "Override Color", false ));
	// 7
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Sample",    false ], 3, 4, 5, 
		[ "Blending",  false ], 6, 
	];
	
	////- Nodes
	
	surf_sampler = undefined;
	samp_w = 1;
	samp_h = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _samp = getInputData( 3);
		var _sdim = getInputData( 4);
		var _spwn = getInputData( 5);
		
		var _over = getInputData( 6);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(surf_sampler == undefined || !surf_sampler.active) return;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _life   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			if(_spwn && _life) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
			var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
			var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
			var _bldA   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8  );
			
			random_set_seed(_seed + _spwnId);
			
			var _cc = surf_sampler.getPixel(round(_px / _sdim[0] * samp_w), round(_py / _sdim[1] * samp_h));
			
			if(_over) {
				_bldR  = _color_get_red(_cc);
				_bldG  = _color_get_green(_cc);
				_bldB  = _color_get_blue(_cc);
				_bldA  = _color_get_alpha(_cc);
				
			} else {
				_bldR *= _color_get_red(_cc);
				_bldG *= _color_get_green(_cc);
				_bldB *= _color_get_blue(_cc);
				_bldA *= _color_get_alpha(_cc);
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnr, buffer_u8, round(_bldR) );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blng, buffer_u8, round(_bldG) );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnb, buffer_u8, round(_bldB) );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blna, buffer_u8, round(_bldA) );
		}
		
	}
	
	static reset = function() {
		var _surf = getInputData(3);
		
		if(surf_sampler != undefined) surf_sampler.free();
		surf_sampler = new Surface_sampler(_surf);
		samp_w = surface_get_width_safe(_surf);
		samp_h = surface_get_height_safe(_surf);
	}
}