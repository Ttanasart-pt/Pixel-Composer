function Node_pSystem_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setCacheAuto();
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Surface
	newInput( 3, nodeValue_Surface( "Surfaces" ));
	
	newInput( 4, nodeValue_EScroll(  "Surface Array", 0, [ "Random", "Order", "Animation", "Scale" ]));
	newInput( 5, nodeValue_Range(    "Animation Speed",      [1,1], { linked : true } ));
	newInput( 6, nodeValue_Bool(     "Stretch Animation",    false                    ));
	newInput( 7, nodeValue_EButton(  "On Animation End",     ANIM_END_ACTION.loop     )).setChoices([ "Loop", "Ping pong", "Destroy" ]);
	
	// 4
	
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
		[ "Texture",   false ], 3, dynaDraw_parameter, __inspc(ui(6), true), 4, 5, 6, 7, 
	];
	
	////- Nodes
	
	array_push(attributeEditors, "Cache" );
	array_push(attributeEditors, Node_Attribute("Cache Data", function() /*=>*/ {return attributes.cache}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("cache")})}));
	
	custom_parameter_names       = [];
	custom_parameter_curves_view = {};
	custom_parameter_map         = {};
	attributes.parameter_curves  = {};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region render check
			var _update = true;
			
			if(!is(inline_context, Node_pSystem_Inline)) _update = false;
			if(inline_context.prerendering)              _update = false;
			if(!IS_PLAYING)                              _update = false;
			
			if(!_update) return;
		#endregion
		
		#region data
			var _dim   = getDimension();
			var _sw    = _dim[0];
			var _sh    = _dim[1];
			
			var _seed  = getInputData( 2);
			
			var _parts = getInputData( 0);
			if(!is(_parts, pSystem_Particles)) return;
			
			var _masks = getInputData( 1), use_mask = _masks != noone;
			
			var _surf  = getInputData( 3);
			var _arrT  = getInputData( 4);
			var _anSp  = getInputData( 5);
			var _anSt  = getInputData( 6);
			var _oend  = getInputData( 7);
			
			var _outSurf = outputs[0].getValue();
			var _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			outputs[0].setValue(_outSurf);
			
			if(use_mask) buffer_to_start(_masks);
			
			inputs[5].setVisible(_arrT == 2);
			inputs[6].setVisible(_arrT == 2);
			inputs[7].setVisible(_arrT == 2 && !_anSt);
		#endregion
		
		var _surf_use = 0;
		var _surf_w   = 1;
		var _surf_h   = 1;
		var _surf_len = 1;
		
		if(is(_surf, dynaDraw)) {
			_surf_use = 3;
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
			
		} else if(is_array(_surf) && !array_empty(_surf)) {
			_surf_use = 2;
			_surf_len = array_length(_surf);
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
				var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
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
				var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
				    rat = clamp(rat, 0, 1);
				
				random_set_seed(_seed + _spwnId);
				
				switch(_surf_use) {
					case 0 : 
						_draw_x = round(_draw_x);
						_draw_y = round(_draw_y);
						
						draw_set_color_alpha(_cc, _draw_a);
						draw_ellipse(_draw_x - _draw_sx, _draw_y - _draw_sy, 
						             _draw_x + _draw_sx, _draw_y + _draw_sy, false);
						break;
						
					case 1 : 
						__p = point_rotate_origin(-_surf_w/2 * _draw_sx, -_surf_h/2 * _draw_sy, _draw_rot, __p);
						var _surf_x = _draw_x + __p[0];
						var _surf_y = _draw_y + __p[1];
						
						draw_surface_ext(_surf, _surf_x, _surf_y, _draw_sx, _draw_sy, _draw_rot, _cc, _draw_a);
						break;
						
					case 2 : 
						var _surfI  = 0;
						
						switch(_arrT) {
							case 0 : _surfI = irandom(_surf_len - 1); break; // Random
							case 1 : _surfI = _spwnId % _surf_len;    break; // Order
							case 2 :                                         // Animation
								if(_anSt) _surfI = rat * (_surf_len - 1);
								else {
									var _animSpeed = random_range(_anSp[0], _anSp[1]);
									var _aFrame    = floor(_lif * _animSpeed);
									
									switch(_oend) {
										case 0 : _surfI = _aFrame % _surf_len; break; // Loop
										case 1 :                                      // Pingpong
											_surfI = _aFrame % (_surf_len * 2 - 1); 
											_surfI = _surfI >= _surf_len? (_surf_len * 2 - 1) - _surfI : _surfI;
											break;
											
										case 2 : 
											_surfI = _aFrame; 
											if(_surfI >= _surf_len) {
												_surfI = 0;
												_act   = false;
											}
											break; // Hide
									}
								}
								break;
								
							case 3 : _surfI = abs(_draw_sx) % _surf_len; break; // Scale
						}
						
						var _surfA  = _surf[_surfI];
						if(!_act || !is_surface(_surfA)) break;
						
					    _surf_w = surface_get_width(_surfA);
					    _surf_h = surface_get_height(_surfA);
						
						__p = point_rotate_origin(-_surf_w/2 * _draw_sx, -_surf_h/2 * _draw_sy, _draw_rot, __p);
						var _surf_x = _draw_x + __p[0];
						var _surf_y = _draw_y + __p[1];
						
						draw_surface_ext(_surfA, _surf_x, _surf_y, _draw_sx, _draw_sy, _draw_rot, _cc, _draw_a);
						break;
					
					case 3 : 
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
	}
	
	static reset = function() {
		for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
			var _n = custom_parameter_names[i];
			if(struct_exists(attributes.parameter_curves, _n))
				custom_parameter_map[$ _n] = new curveMap(attributes.parameter_curves[$ _n], TOTAL_FRAMES);
		}
		
	}
}