function Node_FLIP_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spawner";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Spawn Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Circle", s_node_shape_circle, 0), new scrollItem("Rectangle", s_node_shape_rectangle, 0), "Surface" ]);
	
	inputs[| 2] = nodeValue("Spawn Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.25 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(); }, VALUE_UNIT.reference);
	
	inputs[| 3] = nodeValue("Spawn Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Splash" ]);
	
	inputs[| 4] = nodeValue("Spawn Frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 );
	
	inputs[| 5] = nodeValue("Spawn Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8 );
	
	inputs[| 6] = nodeValue("Spawn Velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 7] = nodeValue("Spawn Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 8] = nodeValue("Spawn Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2 )	
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 9] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 9].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 10] = nodeValue("Spawn Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 45, 135, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
		
	inputs[| 11] = nodeValue("Inherit Velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )	
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 12] = nodeValue("Spawn Duration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| 13] = nodeValue("Spawn Szie", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 9, 
		["Spawner",	false], 1, 7, 8, 13, 2, 3, 4, 12, 5, 
		["Physics", false], 10, 6, 11, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	spawn_amo     = 0;
	prev_position = [ 0, 0 ];
	toReset       = true;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _shp   = getInputData(1);
		var _posit = getInputData(2);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		if(_shp == 0) {
			var _rad   = getInputData(8);
			
			draw_set_color(COLORS._main_accent);
			draw_circle(_px, _py, _rad * _s, true);
			
		} else if(_shp == 1) {
			var _siz   = getInputData(13);
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(_px - _siz[0] * _s, _py - _siz[1] * _s, _px + _siz[0] * _s, _py + _siz[1] * _s, true);
			
		} else if(_shp == 2) {
			var _surf  = getInputData(7);
			if(!is_surface(_surf)) return;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			draw_surface_ext(_surf, _px - _sw * _s / 2, _py - _sh * _s / 2, _s, _s, 0, c_white, 0.5);
		}
		
		if(inputs[| 2].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
		
	} #endregion
	
	static getDimension = function() { 
		var domain = getInputData(0);
		if(!instance_exists(domain)) return [ 1, 1 ];
		
		return [ domain.width, domain.height ];
	}
	
	static step = function() { #region
		var _shp = getInputData(1);
		var _typ = getInputData(3);
		
		inputs[|  4].setVisible(_typ == 1);
		inputs[| 12].setVisible(_typ == 1);
		
		inputs[|  7].setVisible(_shp == 2, _shp == 2);
		inputs[|  8].setVisible(_shp == 0);
		inputs[| 13].setVisible(_shp == 1);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _shape = getInputData(1);
		var _posit = getInputData(2);
		var _type  = getInputData(3);
		var _fra   = getInputData(4);
		var _amo   = getInputData(5);
		var _surf  = getInputData(7);
		var _rad   = getInputData(8);
		var _seed  = getInputData(9);
		
		var _vel   = getInputData( 6);
		var _dirr  = getInputData(10);
		var _ivel  = getInputData(11);
		var _sdur  = getInputData(12);
		var _siz   = getInputData(13);
		
		if(IS_FIRST_FRAME || toReset) spawn_amo = 0;
		toReset = false;
		
		_amo = min(_amo, domain.maxParticles - domain.numParticles);
		spawn_amo += _amo;
		
		if(spawn_amo < 1) return;
		if(_type == 1  && (frame < _fra || frame >= _fra + _sdur)) return;
		if(_shape == 2 && !is_surface(_surf)) return;
		
		var _samo  = floor(spawn_amo);
		spawn_amo -= _samo;
		
		var _points = [];
		
		if(_shape == 2) {
			var _sw = surface_get_width(_surf);
			var _sh = surface_get_height(_surf);
			
			_points = get_points_from_dist(_surf, _samo, _seed + ceil(_amo) * frame);
			_points = array_filter(_points, function(a) { return is_array(a); });
			_samo   = array_length(_points);
			
			if(_samo == 0) return;
		}
		
		domain.numParticles += _samo;
		
		var _buffP = buffer_create(_samo * 2 * 8, buffer_fixed, 8);
		var _buffV = buffer_create(_samo * 2 * 8, buffer_fixed, 8);
		
		buffer_seek(_buffP, buffer_seek_start, 0);
		buffer_seek(_buffV, buffer_seek_start, 0);
		
		random_set_seed(_seed + (ceil(_amo) + 10) * frame);
		var ind = 0;
		
		repeat(_samo) {
			var _x = _posit[0];
			var _y = _posit[1];
			
			if(_shape == 0) {
				var _dir = random(360);
				var _dis = sqrt(random(1)) * _rad;
				
				_x = _posit[0] + lengthdir_x(_dis, _dir);
				_y = _posit[1] + lengthdir_y(_dis, _dir);
				
			} else if(_shape == 1) {
				_x = _posit[0] + random_range(-_siz[0], _siz[0]);
				_y = _posit[1] + random_range(-_siz[1], _siz[1]);
				
			} else if(_shape == 2) {
				_x = _posit[0] - _sw / 2 + _points[ind][0] * _sw;
				_y = _posit[1] - _sh / 2 + _points[ind][1] * _sh;
			}
			
			buffer_write(_buffP, buffer_f64, clamp(_x, 0, domain.width));
			buffer_write(_buffP, buffer_f64, clamp(_y, 0, domain.height));
			
			var _vdis = random_range(_vel[0], _vel[1]);
			var _vdir = angle_random_eval(_dirr);
			
			var _vx = lengthdir_x(_vdis, _vdir) + (frame? (_posit[0] - prev_position[0]) * _ivel : 0);
			var _vy = lengthdir_y(_vdis, _vdir) + (frame? (_posit[1] - prev_position[1]) * _ivel : 0);
			
			buffer_write(_buffV, buffer_f64, _vx);
			buffer_write(_buffV, buffer_f64, _vy);
			
			ind++;
		}
		
		FLIP_spawnParticles(domain.domain, buffer_get_address(_buffP), buffer_get_address(_buffV), _samo);
		
		buffer_delete(_buffP);
		buffer_delete(_buffV);
		
		prev_position[0] = _posit[0];
		prev_position[1] = _posit[1];
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_add_fluid, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}