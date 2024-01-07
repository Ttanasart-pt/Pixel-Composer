function Node_FLIP_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Merge threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.75)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Vaporize", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 3] = nodeValue("Particle expansion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	
	inputs[| 4] = nodeValue("Draw obstracles", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 5] = nodeValue("Fluid particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 6] = nodeValue("Render type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Particle", "Line" ] );
	
	inputs[| 7] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 8] = nodeValue("Additive", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	input_display_list = [ 0, 5, 
		["Rendering", false], 6, 3, 4, 9, 
		["Effect",    false], 2, 
		["Post Processing", false], 8, 7, 1, 
	];
	
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	seed = irandom_range(100000, 999999);
	temp_surface = [ noone ];
	
	array_push(attributeEditors, "FLIP Solver");
	
	attributes.update = true;
	array_push(attributeEditors, ["Update domain", function() { return attributes.update; }, 
		new checkBox(function() { 
			attributes.update = !attributes.update;
			triggerRender();
		})]);
			
	static step = function() {
		var _typ = getInputData(6);
		var _thr = getInputData(7);
		
		inputs[| 1].setVisible(_typ == 0 && _thr);
		inputs[| 3].setVisible(_typ == 0);
		inputs[| 5].setVisible(_typ == 0, _typ == 0);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		if(domain.domain == noone)   return;
		
		if(attributes.update && IS_PLAYING) domain.step();
		
		var _bln = getInputData(1);
		var _vap = getInputData(2);
		var _exp = getInputData(3);
		var _obs = getInputData(4);
		var _spr = getInputData(5);
		var _typ = getInputData(6);
		var _thr = getInputData(7);
		var _add = getInputData(8);
		var _alp = getInputData(9);
		
		var _outSurf = outputs[| 0].getValue();
		var _padd    = domain.particleSize;
		var _ww = domain.width  - _padd * 2;
		var _hh = domain.height - _padd * 2;
				  
		_outSurf        = surface_verify(_outSurf,        _ww, _hh);
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh);
		
		outputs[| 0].setValue(_outSurf);		
		
		var _x, _y, _px, _py, _r, _l, _a;
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
		
		random_set_seed(seed);
		
		surface_set_shader(temp_surface[0], _useSpr? noone : sh_FLIP_draw_droplet);
			if(_add) BLEND_ADD
			else     BLEND_ALPHA_MULP
			
			if(_typ == 0) {
				for( var i = 0; i < _mx; i++ ) {
					_x = domain.particlePos[i * 2 + 0];
					_y = domain.particlePos[i * 2 + 1];
					_l = domain.particleLife[i];
				
					if(_x == 0 && _y == 0) continue;
				
					_x -= _padd;
					_y -= _padd;
					_r  = 1;
					_a  = random_range(_alp[0], _alp[1]);
				
					if(_vap) {
						_r = (_vap - _l) / _vap;
						if(_r * _rad < 0.5) continue;
					}
					
					if(_useSpr) {
						if(is_array(_spr)) draw_surface_ext(_spr[i % array_length(_spr)], _x - _sprw * _r, _y - _sprh * _r, _r, _r, 0, c_white, _a * _r);
						else               draw_surface_ext(_spr, _x - _sprw * _r, _y - _sprh * _r, _r, _r, 0, c_white, _a * _r);
					} else {
						draw_set_alpha(_a * _r);
						draw_circle_color(_x, _y, _rad, c_white, c_black, false);
						draw_set_alpha(1);
					}
				}
			} else if(_typ == 1) {
				for( var i = 0; i < _mx; i++ ) {
					_x  = domain.particlePos[i * 2 + 0];
					_y  = domain.particlePos[i * 2 + 1];
					_px = domain.particleHist[i * 2 + 0];
					_py = domain.particleHist[i * 2 + 1];
					
					_l  = domain.particleLife[i];
					
					if(_x == 0  && _y == 0)  continue;
					if(_px == 0 && _py == 0) continue;
					
					if(_vap) {
						if(_l >= _vap) continue;
						_r = (_vap - _l) / _vap;
						
						_px = _x + (_px - _x) * _r;
						_py = _y + (_py - _y) * _r;
					}
					
					_x  -= _padd;
					_y  -= _padd;
					_px -= _padd;
					_py -= _padd;
					
					draw_set_color(c_white);
					draw_line(_px, _py, _x, _y);
				}
			}
			
			BLEND_NORMAL
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			if(_thr) {
				shader_set(sh_FLIP_render_threshold);
					shader_set_f("threshold", 1 - _bln);
					draw_surface(temp_surface[0], 0, 0);
				shader_reset();
			} else 
				draw_surface(temp_surface[0], 0, 0);
			
			if(_obs)
			for( var i = 0, n = array_length(domain.obstracles); i < n; i++ )
				domain.obstracles[i].draw();
		surface_reset_target();
	}
	
}