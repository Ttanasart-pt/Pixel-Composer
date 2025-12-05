function Node_pSystem_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	use_cache = CACHE_USE.auto;
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Texture
	newInput(3, nodeValue_Surface( "Surfaces" ));
	// 
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	dynaDraw_parameter = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_empty(custom_parameter_names)) return 0;
		
		var _hh =  0;
		
		for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
			var _n = custom_parameter_names[i];
			
			var _wig = custom_parameter_curves_view[$ _n];
			var _dat = attributes.parameter_curves[$ _n];
			if(_wig == undefined || _dat == undefined) continue;
			
			var _txt = string_title(_n) + " Over Lifespan";
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x, _y, _txt);
			
			var _th = string_height(_txt) + ui(8);
			_y  += _th;
			_hh += _th;
			
			_wig.setFocusHover(_focus, _hover);
			var _hg = _wig.drawParam(new widgetParam(_x, _y, _w, 0, _dat, {}, _m, dynaDraw_parameter.rx, dynaDraw_parameter.ry).setFont(f_p2));
			
			_y  += _hg + ui(8);
			_hh += _hg + ui(8);
		}
		
		_hh -= ui(8);
		return _hh;
	});
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Texture",   false ], 3, dynaDraw_parameter, 
	];
	
	////- Nodes
	
	attributes.cache = true;
	array_push(attributeEditors,   "Cache" );
	array_push(attributeEditors, [ "Cache Data", function() /*=>*/ {return attributes.cache}, new checkBox(function() /*=>*/ {return toggleAttribute("cache")}) ]);
	
	custom_parameter_names = undefined;
	
	custom_parameter_names       = [];
	custom_parameter_curves_view = {};
	custom_parameter_map         = {};
	attributes.parameter_curves  = {};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		use_cache = attributes.cache? CACHE_USE.auto : CACHE_USE.none;
		if(use_cache) {
			var surf = getCacheFrame(_frame);
			if(is_surface(surf)) {
				outputs[0].setValue(surf);
				return;
			}
		}
		
		var _dim   = getDimension();
		var _sw    = _dim[0];
		var _sh    = _dim[1];
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		var _surf = getInputData(3);
		
		var _surf_use = 0;
		var _surf_w   = 1;
		var _surf_h   = 1;
		
		if(is(_surf, dynaDraw)) {
			_surf_use = 2;
			_surf_w   = _surf.getWidth();
			_surf_h   = _surf.getHeight();
			
			custom_parameter_names = _surf.parameters;
			
			for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
				var _n = custom_parameter_names[i];
				if(!struct_exists(attributes.parameter_curves, _n))
					attributes.parameter_curves[$ _n] = CURVE_DEF_11;
					
				if(!struct_exists(custom_parameter_curves_view, _n)) {
					var cbox = new curveBox(noone);
					    cbox.param_name  = _n;
					    cbox.param_curve = attributes.parameter_curves;
					    cbox.node        = self;
					    cbox.onModify    = method(cbox, function(c) /*=>*/ { param_curve[$ param_name] = c; node.triggerRender(); });
					
					custom_parameter_curves_view[$ _n] = cbox;
				}
			}
			
		} else if(is_surface(_surf)) {
			_surf_use = 1;
			_surf_w   = surface_get_width(_surf);
			_surf_h   = surface_get_height(_surf);
		}
		
		var __p = [0,0];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _partAmo  = _parts.maxCursor;
			var _partBuff = _parts.buffer;
			var _off = 0;
			
			repeat(_partAmo) {
				var _start = _off;
				buffer_seek(_partBuff, buffer_seek_start, _start);
				_off += global.pSystem_data_length;
				
				var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
				var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
				if(!_act) continue;
				
				var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
				
				var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
				var _lifMax = buffer_read(    _partBuff,                              buffer_f64  );
				
				var _surf_  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.surf,   buffer_f64 );
				var _cc     = buffer_read(    _partBuff,                              buffer_u32 );
				
				var _dfg      = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _draw_x   = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx), buffer_f64 );
				var _draw_y   = buffer_read(    _partBuff,                                                                      buffer_f64 );
				var _draw_sx  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax), buffer_f64 );
				var _draw_sy  = buffer_read(    _partBuff,                                                                      buffer_f64 );
				var _draw_rot = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.drotx : PSYSTEM_OFF.rotx), buffer_f64 );
				
				var _draw_a = ((_cc & (0xFF << 24)) >> 24) / 255 * _mask;
				var rat     = _lif / (_lifMax - 1);
				
				switch(_surf_use) {
					case 0 : 
						draw_set_color_alpha(_cc, _draw_a);
						draw_ellipse(round(_draw_x - _draw_sx), round(_draw_y - _draw_sy), 
						             round(_draw_x + _draw_sx), round(_draw_y + _draw_sy), false);
						break;
						
					case 1 : 
						__p = point_rotate_origin(-_surf_w/2 * _draw_sx, -_surf_h/2 * _draw_sy, _draw_rot, __p);
						var _surf_x = _draw_x + __p[0];
						var _surf_y = _draw_y + __p[1];
						
						draw_surface_ext(_surf, _surf_x, _surf_y, _draw_sx, _draw_sy, _draw_rot, _cc, _draw_a);
						break;
					
					case 2 : 
						for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
								var _param = custom_parameter_names[i]
								var _parcv = custom_parameter_map[$ _param];
								if(_parcv == undefined) continue;
								
								_surf.params[$ _param] = _parcv.get(rat) * _surf[$ _param];
							}
							
						_surf.draw(_draw_x, _draw_y, _draw_sx, _draw_sy, _draw_rot, _cc, _draw_a);
						break;
					
				}
				
			}
			
			draw_set_alpha(1);
		surface_reset_target();
		
		if(use_cache) cacheCurrentFrame(_outSurf);
	}
	
	static reset = function() {
		for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
			var _n = custom_parameter_names[i];
			if(struct_exists(attributes.parameter_curves, _n))
				custom_parameter_map[$ _n] = new curveMap(attributes.parameter_curves[$ _n], TOTAL_FRAMES);
		}
		
	}
}