function Node_FLIP_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spawner";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	manual_ungroupable = false;
	
	newInput( 9, nodeValueSeed());
	newInput( 0, nodeValue_Fdomain( "Domain" )).setVisible(true, true);
	
	////- =Spawner
	spawner_shapes = [ new scrollItem("Circle", s_node_shape_circle, 0), new scrollItem("Rectangle", s_node_shape_rectangle, 0), "Surface" ];
	newInput( 1, nodeValue_Enum_Scroll( "Spawn Shape",  0 , spawner_shapes));
	newInput( 7, nodeValue_Surface(     "Spawn Surface" ));
	newInput( 8, nodeValue_Slider(      "Spawn Radius",    2, [1, 16, 0.1] ));
	newInput(13, nodeValue_Vec2(        "Spawn Size",     [2,2]    ));
	newInput( 2, nodeValue_Vec2(        "Spawn Position", [.5,.25] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Enum_Button( "Spawn Type",      0, [ "Stream", "Splash" ]));
	newInput( 4, nodeValue_Int(         "Spawn Frame",     0 ));
	newInput(12, nodeValue_Int(         "Spawn Duration",  1 ));
	newInput( 5, nodeValue_Float(       "Spawn Amount",    8 ));
	
	////- =Physics
	newInput(10, nodeValue_Rotation_Random( "Spawn Direction",  [0,45,135,0,0 ] ));
	newInput( 6, nodeValue_Range(           "Spawn Velocity",   [0,0] ));
	newInput(11, nodeValue_Slider(          "Inherit Velocity",  0    ));
	// input 14
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 9, 
		["Spawner",	false], 1, 7, 8, 13, 2, 3, 4, 12, 5, 
		["Physics", false], 10, 6, 11, 
	]
	
	spawn_amo     = 0;
	prev_position = [ 0, 0 ];
	toReset       = true;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
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
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static getDimension = function() { 
		var domain = getInputData(0);
		if(!instance_exists(domain)) return [ 1, 1 ];
		
		return [ domain.width, domain.height ];
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		outputs[0].setValue(domain);
		
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
		
		inputs[ 4].setVisible(_type == 1);
		inputs[12].setVisible(_type == 1);
		
		inputs[ 7].setVisible(_shape == 2, _shape == 2);
		inputs[ 8].setVisible(_shape == 0);
		inputs[13].setVisible(_shape == 1);
		
		if(!instance_exists(domain)) return;
		
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
			var _vdir = rotation_random_eval(_dirr);
			
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
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox   = drawGetBbox(xx, yy, _s, false);
		var _shape = getInputData(1);
		var _surf  = getInputData(7);
		
		var ss = max(0, min(bbox.w, bbox.h) / 2 - 16 * _s);
		draw_set_color(c_white);
		switch(_shape) {
			case 0 : draw_circle_prec(bbox.xc, bbox.yc, ss, false); break;
			case 1 : draw_rectangle(bbox.xc - ss, bbox.yc - ss, bbox.xc + ss, bbox.yc + ss, false); break;
			case 2 : draw_surface_bbox(_surf, bbox); break;
		}
	}
	
	static getPreviewValues = function() { 
		var domain = getInputData(0); 
		return instance_exists(domain)? domain.domain_preview : noone; 
	}
	
}