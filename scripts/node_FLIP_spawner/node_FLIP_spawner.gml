function Node_FLIP_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spawner";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Spawn shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Circle", "Surface" ]);
	
	inputs[| 2] = nodeValue("Spawn position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Stream", "Splash" ]);
	
	inputs[| 4] = nodeValue("Spawn frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 );
	
	inputs[| 5] = nodeValue("Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	inputs[| 6] = nodeValue("Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Spawn surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 8] = nodeValue("Spawn radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 )	
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 9] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(100000, 999999) );
	
	input_display_list = [ 0, 9, 
		["Spawner",	false], 1, 7, 8, 2, 3, 4, 5, 
		["Physics", false], 6, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	spawn_amo = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _shp   = getInputData(1);
		var _posit = getInputData(2);
		var _velo  = getInputData(6);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _vx = _px + _velo[0] * _s;
		var _vy = _py + _velo[1] * _s;
		
		if(_shp == 0) {
			var _rad   = getInputData(8);
			
			if(inputs[| 8].drawOverlay(active, _px, _py, _s, _mx, _my, _snx, _sny, 0, 1, THEME.anchor_scale_hori)) active = false;
			
			draw_set_color(COLORS._main_accent);
			draw_circle(_px, _py, _rad * _s, true);
		} else if(_shp == 1) {
			var _surf  = getInputData(7);
			if(!is_surface(_surf)) return;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			draw_surface_ext(_surf, _px - _sw * _s / 2, _py - _sh * _s / 2, _s, _s, 0, c_white, 0.5);
		}
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_line_width2(_px, _py, _vx, _vy, 6, 2);
		draw_set_alpha(1);
		
		if(inputs[| 2].drawOverlay(active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 6].drawOverlay(active, _px, _py, _s, _mx, _my, _snx, _sny)) active = false;
		
	} #endregion
	
	static step = function() { #region
		var _shp = getInputData(1);
		var _typ = getInputData(3);
		
		inputs[| 4].setVisible(_typ == 1);
		inputs[| 7].setVisible(_shp == 1, _shp == 1);
		inputs[| 8].setVisible(_shp == 0);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _shape = getInputData(1);
		var _posit = getInputData(2);
		var _type  = getInputData(3);
		var _fra   = getInputData(4);
		var _amo   = getInputData(5);
		var _vel   = getInputData(6);
		var _surf  = getInputData(7);
		var _rad   = getInputData(8);
		var _seed  = getInputData(9);
		
		_amo = min(_amo, domain.maxParticles - domain.numParticles);
		spawn_amo += _amo;
		
		if(spawn_amo < 1)                     return;
		if(_type == 1 && frame != _fra)       return;
		if(_shape == 1 && !is_surface(_surf)) return;
		
		var _samo  = floor(spawn_amo);
		spawn_amo -= _samo;
		
		if(_shape == 1) {
			var _sw = surface_get_width(_surf);
			var _sh = surface_get_height(_surf);
			
			var _points = get_points_from_dist(_surf, _samo, _seed + ceil(_amo) * frame);
			_samo = array_length(_points);
			
			if(_samo == 0) return;
		}
		
		domain.numParticles += _samo;
		
		var _buffP = buffer_create(_samo * 2 * 8, buffer_fixed, 8);
		var _buffV = buffer_create(_samo * 2 * 8, buffer_fixed, 8);
		
		buffer_seek(_buffP, buffer_seek_start, 0);
		buffer_seek(_buffV, buffer_seek_start, 0);
		
		random_set_seed(_seed + ceil(_amo) * frame);
		var ind = 0;
		
		repeat(_samo) {
			var _x = _posit[0];
			var _y = _posit[1];
			
			if(_shape == 0) {
				var _dir = random(360);
				var _dis = sqrt(random(1)) * _rad;
				
				_x = _posit[0] + lengthdir_x(_dis, _dir);
				_y = _posit[1] + lengthdir_y(_dis, _dir);
				
				buffer_write(_buffP, buffer_f64, _x);
				buffer_write(_buffP, buffer_f64, _y);
			} else if(_shape == 1) {
				_x = _posit[0] - _sw / 2 + _points[ind][0] * _sw;
				_y = _posit[1] - _sh / 2 + _points[ind][1] * _sh;
				
				buffer_write(_buffP, buffer_f64, _x);
				buffer_write(_buffP, buffer_f64, _y);
			}
			
			buffer_write(_buffV, buffer_f64, _vel[0]);
			buffer_write(_buffV, buffer_f64, _vel[1]);
			
			ind++;
		}
		
		FLIP_spawnParticles(domain.domain, buffer_get_address(_buffP), buffer_get_address(_buffV), _amo);
		
		buffer_delete(_buffP);
		buffer_delete(_buffV);
	}
}