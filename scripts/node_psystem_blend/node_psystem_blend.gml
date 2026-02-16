function Node_pSystem_Blend(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Blend";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_blend);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Alpha
	newInput(10, nodeValue_Bool(   "Alpha", false ));
	newInput(11, nodeValue_Curve(  "Alpha by Lifespan", CURVE_DEF_11      ));
	
	////- =Solid
	newInput(12, nodeValue_Bool(        "Blend Color", false ));
	newInput(14, nodeValue_Enum_Scroll( "Blend Mode",  0, [ "Mix", "Multiply", "Add", "Screen" ] )).setInternalName("blend_mode_solid");
	newInput(13, nodeValue_Color(       "Color",       ca_white )).setInternalName("blend_solid_color");
	
	////- =Lifespan
	newInput( 8, nodeValue_Bool(        "Blend by Lifespan", false ));
	newInput( 3, nodeValue_Enum_Scroll( "Blend Mode", 0, [ "Mix", "Multiply", "Add", "Screen" ] )).setInternalName("blend_mode_lifespan");
	newInput( 4, nodeValue_Gradient(    "Color by Lifespan", gra_white  ));
	
	////- =Index
	newInput( 9, nodeValue_Bool(        "Blend by Index", false ));
	newInput( 7, nodeValue_Enum_Scroll( "Blend Mode", 0, [ "Mix", "Multiply", "Add", "Screen" ] )).setInternalName("blend_mode_index");
	newInput( 5, nodeValue_Palette(     "Color by Index",    [ca_white] )).setCurvable(6, CURVE_DEF_11, "Over Lifespan");
	// 15
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false     ], 0, 1, 
		[ "Alpha",     false, 10 ], 11, 
		[ "Solid",     false, 12 ], 14, 13, 
		[ "Lifespan",  false,  8 ], 3, 4, 
		[ "Index",     false,  9 ], 7, 5, 6, 
	];
	
	////- Nodes
	
	curve_palt = undefined;
	curve_alph = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static reset = function() {
		curve_palt = new curveMap(getInputData( 6));
		curve_alph = new curveMap(getInputData(11));
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		
		var _alph_use  = getInputData(10), _alph_curved = curve_alph != undefined;
		
		var _sold_use  = getInputData(12);
		var _sold_mode = getInputData(14);
		var _sold      = getInputData(13);
		
		var _grad_use  = getInputData( 8);
		var _grad_mode = getInputData( 3);
		var _grad      = getInputData( 4);
		
		var _palt_use  = getInputData( 9);
		var _palt_mode = getInputData( 7);
		var _palt      = getInputData( 5), _palt_curved = inputs[5].attributes.curved && curve_palt != undefined;
		
		var _sold_r = color_get_red(_sold);
		var _sold_g = color_get_green(_sold);
		var _sold_b = color_get_blue(_sold);
		
		_grad.cache();
		var _palt_len = array_length(_palt);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
			var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
			var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
			var _bldsA  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsa,  buffer_u8  );
			
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			random_set_seed(_seed + _spwnId);
			
			if(_alph_use && _alph_curved) {
				var _bldA = _bldsA * curve_alph.get(rat);
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blna, buffer_u8, round(_bldA) );
			}
			
			if(_sold_use) {
				switch(_sold_mode) {
					case 0 : 
						_bldR = lerp(_bldR, _sold_r, _mask);
						_bldG = lerp(_bldG, _sold_g, _mask);
						_bldB = lerp(_bldB, _sold_b, _mask);
						break;
					
					case 1 : 
						_bldR = lerp(_bldR, _bldR * _sold_r / 255, _mask);
						_bldG = lerp(_bldG, _bldG * _sold_g / 255, _mask);
						_bldB = lerp(_bldB, _bldB * _sold_b / 255, _mask);
						break;
						
					case 2 : 
						_bldR += _sold_r * _mask;
						_bldG += _sold_g * _mask;
						_bldB += _sold_b * _mask;
						break;
					
					case 3 : 
						_bldR = lerp(_bldR, 255 * (1 - (1 - _bldR / 255) * (1 - _sold_r / 255)), _mask);
						_bldG = lerp(_bldG, 255 * (1 - (1 - _bldG / 255) * (1 - _sold_g / 255)), _mask);
						_bldB = lerp(_bldB, 255 * (1 - (1 - _bldB / 255) * (1 - _sold_b / 255)), _mask);
						break;
					
				}
			}
			
			if(_grad_use) {
				var _gc = _grad.evalFast(rat);
				
				switch(_grad_mode) {
					case 0 : 
						_bldR = lerp(_bldR, color_get_red(_gc),   _mask);
						_bldG = lerp(_bldG, color_get_green(_gc), _mask);
						_bldB = lerp(_bldB, color_get_blue(_gc),  _mask);
						break;
					
					case 1 : 
						_bldR = lerp(_bldR, _bldR * _color_get_red(_gc),   _mask);
						_bldG = lerp(_bldG, _bldG * _color_get_green(_gc), _mask);
						_bldB = lerp(_bldB, _bldB * _color_get_blue(_gc),  _mask);
						break;
						
					case 2 : 
						_bldR += color_get_red(_gc)   * _mask;
						_bldG += color_get_green(_gc) * _mask;
						_bldB += color_get_blue(_gc)  * _mask;
						break;
					
					case 3 : 
						_bldR = lerp(_bldR, 255 * (1 - (1 - _bldR / 255) * (1 - _color_get_red(_gc))),   _mask);
						_bldG = lerp(_bldG, 255 * (1 - (1 - _bldG / 255) * (1 - _color_get_green(_gc))), _mask);
						_bldB = lerp(_bldB, 255 * (1 - (1 - _bldB / 255) * (1 - _color_get_blue(_gc))),  _mask);
						break;
					
				}
			}
			
			if(_palt_use) {
				var _palt_mod = (_palt_curved? curve_palt.get(rat) : 1) * _mask;
				var _pc = _palt[_spwnId % _palt_len];
					
				switch(_palt_mode) {
					case 0 : 
						_bldR = lerp(_bldR, color_get_red(_pc),   _palt_mod);
						_bldG = lerp(_bldG, color_get_green(_pc), _palt_mod);
						_bldB = lerp(_bldB, color_get_blue(_pc),  _palt_mod);
						break;
					
					case 1 : 
						_bldR = lerp(_bldR, _bldR * color_get_red(_pc),   _palt_mod);
						_bldG = lerp(_bldG, _bldG * color_get_green(_pc), _palt_mod);
						_bldB = lerp(_bldB, _bldB * color_get_blue(_pc),  _palt_mod);
						break;
					
					case 2 : 
						_bldR += color_get_red(_pc)   * _palt_mod;
						_bldG += color_get_green(_pc) * _palt_mod;
						_bldB += color_get_blue(_pc)  * _palt_mod;
						break;
					
					case 3 : 
						_bldR = lerp(_bldR, 255 * (1 - (1 - _bldR / 255) * (1 - _color_get_red(_pc))),   _palt_mod);
						_bldG = lerp(_bldG, 255 * (1 - (1 - _bldG / 255) * (1 - _color_get_green(_pc))), _palt_mod);
						_bldB = lerp(_bldB, 255 * (1 - (1 - _bldB / 255) * (1 - _color_get_blue(_pc))),  _palt_mod);
						break;
					
				}
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnr, buffer_u8, round(_bldR) );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blng, buffer_u8, round(_bldG) );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnb, buffer_u8, round(_bldB) );
		}
		
	}
}