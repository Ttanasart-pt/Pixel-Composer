function Node_FLIP_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	use_cache = CACHE_USE.auto;
	
	inline_output      = false;
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain( "Domain" )).setVisible(true, true);
	newInput( 5, nodeValue_Surface( "Fluid particle" ));
	
	////- =Rendering
	newInput( 6, nodeValue_Enum_Scroll(  "Render type",  0, __enum_array_gen(["Particle", "Line"], s_node_flip_render_type) ));
	newInput(10, nodeValue_Int(          "Segments",            1     ));
	newInput( 3, nodeValue_Float(        "Particle expansion",  20    ));
	newInput( 4, nodeValue_Bool(         "Draw obstracles",     true  ));
	newInput( 9, nodeValue_Slider_Range( "Alpha",               [1,1] ));
	
	////- =Effect
	newInput(11, nodeValue_Gradient( "Color Over Velocity", new gradientObject(ca_white)));
	newInput(12, nodeValue_Range(    "Velocity Map",        [0,10] ));
	newInput( 2, nodeValue_Range(    "Lifespan",            [0, 0], { linked : true } ));
	
	////- =Post Processing
	newInput( 8, nodeValue_Bool(   "Additive",        true ));
	newInput( 7, nodeValue_Bool(   "Threshold",       true ));
	newInput( 1, nodeValue_Slider( "Merge threshold", 0.75 ));
	// input 13
	
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 5, 
		["Rendering", false], 6, 10, 3, 4, 9, 
		["Effect",    false], 11, 12, 2, 
		["Post Processing", false], 8, 7, 1, 
	];
	
	////- Nodes
	
	seed = irandom_range(100000, 999999);
	temp_surface = [ noone ];
	
	array_push(attributeEditors, "FLIP Solver");
	
	attributes.update    = true;
	attributes.debugDraw = false;
	
	array_push(attributeEditors, ["Update domain",        function() /*=>*/ {return attributes.update},    new checkBox(function() /*=>*/ {return toggleAttribute("update", true)})]);
	array_push(attributeEditors, ["Draw Fluid Particles", function() /*=>*/ {return attributes.debugDraw}, new checkBox(function() /*=>*/ {return toggleAttribute("debugDraw")})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		if(domain.domain == noone)   return;
		
		if(attributes.debugDraw) {
			var _m = min(array_length(domain.particlePos) / 2 - 1, domain.numParticles);
		
			draw_set_color(COLORS._main_accent);
			
			for( var i = 0; i < _m; i++ ) {
				var _px = domain.particlePos[i * 2 + 0] - 1;
				var _py = domain.particlePos[i * 2 + 1] - 1;
			
				draw_circle(_x + _px * _s, _y + _py * _s, 1, false);
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		if(domain.domain == noone)   return;
		
		var _bln = getInputData(1);
		var _vap = getInputData(2);
		var _exp = getInputData(3);
		var _obs = getInputData(4);
		var _spr = getInputData(5);
		var _typ = getInputData(6);
		var _thr = getInputData(7);
		var _add = getInputData(8);
		var _alp = getInputData(9);
		var _seg = getInputData(10);
		var _cvl = getInputData(11);
		var _vlr = getInputData(12);
		
		inputs[ 1].setVisible(_typ == 0 && _thr);
		inputs[ 3].setVisible(_typ == 0);
		inputs[ 5].setVisible(_typ == 0, _typ == 0);
		inputs[10].setVisible(_typ == 1);
		
		if(!PROJECT.animator.is_playing && recoverCache()) return;
		if(attributes.update && IS_PLAYING) domain.step();
		
		var _outSurf = outputs[0].getValue();
		var _maxpart = domain.maxParticles;
		var _padd    = domain.particleSize;
		var _ww = domain.width  - _padd * 2;
		var _hh = domain.height - _padd * 2;
				  
		_outSurf        = surface_verify(_outSurf,        _ww, _hh);
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh);
		
		outputs[0].setValue(_outSurf);		
		
		var _x, _y, _px, _py, _r, _l, _a, _v, _sx, _sy;
		var _rad = domain.particleRadius * _exp;
		var _mx  = min(array_length(domain.particlePos) / 2 - 1, domain.numParticles);
		
		var _useSpr = is_surface(_spr);
		var _sprw, _sprh;
		
		if(_useSpr) {
			_sprw = 0.5 * surface_get_width_safe(_spr);
			_sprh = 0.5 * surface_get_height_safe(_spr);
		} else if(is_array(_spr) && array_length(_spr)) {
			_useSpr = is_surface(_spr[0]);
			_sprw = 0.5 * surface_get_width_safe(_spr[0]);
			_sprh = 0.5 * surface_get_height_safe(_spr[0]);
		}
		
		var _useMapRange = array_length(_cvl.keys) > 1;
		var _vMapRange   = _vlr[1] - _vlr[0];
		var _cc = _cvl.keys[0].value;
		
		random_set_seed(seed);
		
		surface_set_shader(temp_surface[0], _useSpr? noone : sh_FLIP_draw_droplet);
			if(_add) BLEND_ADD
			else     BLEND_ALPHA_MULP
			
			if(_typ == 0) {
				for( var i = 0; i < _mx; i++ ) {
					_x  = domain.particlePos[i * 2 + 0];
					_y  = domain.particlePos[i * 2 + 1];
					_sx = domain.particleVel[i * 2 + 0];
					_sy = domain.particleVel[i * 2 + 1];
					_l  = domain.particleLife[i];
				
					if(_x == 0 && _y == 0) continue;
					
					_x -= _padd;
					_y -= _padd;
					_r  = 1;
					_a  = random_range(_alp[0], _alp[1]);
					_v  = irandom_range(_vap[0], _vap[1]);
					
					if(_v) {
						_r = (_v - _l) / _v;
						if(_r * _rad < 0.5) continue;
					}
					
					if(_useMapRange) {
						var _vel  = sqrt(_sx * _sx + _sy * _sy);
						var _vmap = (_vel - _vlr[0]) / _vMapRange;
						    _vmap = power(clamp(_vmap, 0, 1), 5);
						_cc   = _cvl.eval(_vmap);
					}
					
					if(_useSpr) {
						if(is_array(_spr)) draw_surface_ext(_spr[i % array_length(_spr)], _x - _sprw * _r, _y - _sprh * _r, _r, _r, 0, _cc, _a * _r);
						else               draw_surface_ext(_spr, _x - _sprw * _r, _y - _sprh * _r, _r, _r, 0, _cc, _a * _r);
					} else {
						draw_circle_color_alpha(_x, _y, _rad, _cc, _cc, _a * _r, 0);
					}
				}
			} else if(_typ == 1) {
				var _segg = min(_seg, CURRENT_FRAME);
				
				var _ox, _oy, _nx, _ny;
				
				for( var i = 0; i < _mx; i++ ) {
					_l = domain.particleLife[i];
					_v = irandom_range(_vap[0], _vap[1]);
					
					var fstFr = max(0, CURRENT_FRAME - _segg);
					var lstFr = _v? min(CURRENT_FRAME, CURRENT_FRAME - _l + _v)  : CURRENT_FRAME;
					
					if(lstFr <= fstFr) continue;
					
					_ox = lstFr == CURRENT_FRAME? domain.particlePos[i * 2 + 0] : domain.particleHist[(lstFr + 1) * _maxpart * 2 + i * 2 + 0];
					_oy = lstFr == CURRENT_FRAME? domain.particlePos[i * 2 + 1] : domain.particleHist[(lstFr + 1) * _maxpart * 2 + i * 2 + 1];
					
					if(_ox == 0 && _oy == 0) continue;
					
					_ox -= _padd;
					_oy -= _padd;
					
					for( var j = lstFr; j > fstFr; j-- ) {
						_nx = domain.particleHist[j * _maxpart * 2 + i * 2 + 0];
						_ny = domain.particleHist[j * _maxpart * 2 + i * 2 + 1];
						
						if(_nx == 0 && _ny == 0) continue;
						
						if(_useMapRange) {
							var _dx = _ox - _nx;
							var _dy = _oy - _ny;
							var _vel  = sqrt(_dx * _dx + _dy * _dy);
							var _vmap = (_vel - _vlr[0]) / _vMapRange;
							    _vmap = power(clamp(_vmap, 0, 1), 5);
							_cc   = _cvl.eval(_vmap);
						}
						
						_nx -= _padd;
						_ny -= _padd;
						
						draw_set_color(_cc);
						draw_line(_ox, _oy, _nx, _ny);
						
						_ox = _nx;
						_oy = _ny;
					}
				}
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			if(_thr) {
				shader_set(sh_FLIP_render_threshold);
					shader_set_f("threshold", 1 - _bln);
					draw_surface_safe(temp_surface[0]);
				shader_reset();
			} else 
				draw_surface_safe(temp_surface[0]);
			
			if(_obs)
			for( var i = 0, n = array_length(domain.obstracles); i < n; i++ )
				domain.obstracles[i].draw();
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
	
}