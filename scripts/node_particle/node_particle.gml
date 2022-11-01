function Node_create_Particle(_x, _y) {
	var node = new Node_Particle(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum ANIM_END_ACTION {
	loop,
	pingpong,
	destroy,
}

function __part() constructor {
	seed   = irandom(99999);
	active = false;
	surf   = noone;
	x   = 0;
	y   = 0;
	sx  = 0;
	sy  = 0;
	ac  = 0;
	g   = 0;
	wig = 0;
	
	boundary_data = -1;
	
	fx  = 0;
	fy  = 0;
	
	gy  = 0;
	
	scx   = 1;
	scy   = 1;
	scx_s = 1;
	scy_s = 1;
	
	rot		= 0;
	follow	= false;
	rot_s	= 0;
	
	col      = -1;
	alp      = 1;
	alp_draw = alp;
	alp_fade = 0;
	
	life       = 0;
	life_total = 0;
	
	anim_speed = 1;
	anim_end   = ANIM_END_ACTION.loop;
	
	is_loop = false;
	
	
	function create(_surf, _x, _y, _life) {
		active	= true;
		surf	= _surf;
		x		= _x;
		y		= _y;
		gy		= 0;
		
		life = _life;
		life_total = life;
	}
	
	function setPhysic(_sx, _sy, _ac, _g, _wig) {
		sx  = _sx;
		sy  = _sy;
		ac  = _ac;
		g   = _g;
		
		wig = _wig;
	}
	function setTransform(_scx, _scy, _scxs, _scys, _rot, _rots, _follow) {
		scx   = _scx;
		scy   = _scy;
		scx_s = _scxs;
		scy_s = _scys;
		rot   = _rot;
		rot_s = _rots;
		follow = _follow;
	}
	function setDraw(_col, _alp, _fade) {
		col      = _col;
		alp      = _alp;
		alp_draw = _alp;
		alp_fade = _fade;
	}
	
	function kill() {
		active = false;	
	}
	
	static step = function() {
		if(!active) return;
		var xp = x, yp = y;
		x  += sx;
		y  += sy;
		
		var dirr = point_direction(0, 0, sx, sy);
		var diss = point_distance(0, 0, sx, sy);
		if(diss > 0) {
			diss += ac;
			dirr += random_range(-wig, wig);
			sx = lengthdir_x(diss, dirr);
			sy = lengthdir_y(diss, dirr);
		}
		
		gy += g;
		y += gy;
		
		if(scx_s < 0)	scx = max(scx + scx_s, 0);
		else			scx = scx + scx_s;
		if(scy_s < 0)	scy = max(scy + scy_s, 0);
		else			scy = scy + scy_s;
		
		if(follow) 
			rot = point_direction(xp, yp, x, y);
		else
			rot += rot_s;
		alp_draw = alp * eval_bezier_cubic(1 - life / life_total, alp_fade[0], alp_fade[1], alp_fade[2], alp_fade[3]);
		
		if(life-- < 0) kill();
	}
	
	function draw(exact) {
		if(!active) return;
		var ss = surf;
		if(is_array(surf)) {
			var ind = abs(round((life_total - life) * anim_speed));
			var len = array_length(surf);
			
			switch(anim_end) {
				case ANIM_END_ACTION.loop: 
					ss = surf[safe_mod(ind, len)];
					break;
				case ANIM_END_ACTION.pingpong:
					var ping = safe_mod(ind, (len - 1) * 2 + 1); 
					ss = surf[ping >= len? (len - 1) * 2 - ping : ping];
					break;
				case ANIM_END_ACTION.destroy:
					if(ind >= len)	return;
					else			ss = surf[ind];
					break;
			}
		}
		if(!is_surface(ss)) return;
		
		var cc = (col == -1)? c_white : gradient_eval(col, 1 - life / life_total);
		var _xx, _yy;
		var s_w = surface_get_width(ss) * scx;
		var s_h = surface_get_height(ss) * scy;
		
		if(boundary_data == -1) {
			var _pp = point_rotate(-s_w / 2, -s_h / 2, 0, 0, rot);
			_xx = x + _pp[0];
			_yy = y + _pp[1];
		} else {
			var ww = boundary_data[2] + boundary_data[0];
			var hh = boundary_data[3] + boundary_data[1];
			
			var cx = (boundary_data[0] + boundary_data[2]) / 2;
			var cy = (boundary_data[1] + boundary_data[3]) / 2;
			
			var _pp = point_rotate(-cx, -cy, 0, 0, rot);
			
			_xx = x + cx + _pp[0] * scx;
			_yy = y + cy + _pp[1] * scy;
		}
		
		if(exact) {
			_xx = round(_xx);
			_yy = round(_yy);
		}
			
		draw_surface_ext_safe(ss, _xx, _yy, scx, scy, rot, cc, alp_draw);
	}
	
	function getPivot() {
		if(boundary_data == -1) 
			return [x, y];
		
		var ww = (boundary_data[2] - boundary_data[0]) * scx;
		var hh = (boundary_data[3] - boundary_data[1]) * scy;
		var cx = x + boundary_data[0] + ww / 2;
		var cy = y + boundary_data[1] + hh / 2;
		
		return [cx, cy];
	}
}

enum PARTICLE_BLEND_MODE {
	normal,
	additive
}

function Node_Particle(_x, _y) : Node(_x, _y) constructor {
	name = "Particle";
	auto_update = false;
	use_cache = true;
	
	inputs[| 0] = nodeValue(0, "Particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.setDisplay(noone, "particles");
		
	inputs[| 1] = nodeValue(1, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	inputs[| 3] = nodeValue(3, "Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	inputs[| 4] = nodeValue(4, "Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 1].getValue(); });
	
	inputs[| 5] = nodeValue(5, "Spawn distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Area", "Border" ]);
	
	inputs[| 6] = nodeValue(6, "Lifespan", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 20, 30 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 7] = nodeValue(7, "Spawn direction", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 45, 135 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	inputs[| 8] = nodeValue(8, "Acceleration", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 9] = nodeValue(9, "Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
		
	inputs[| 10] = nodeValue(10, "Rotational speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 11] = nodeValue(11, "Spawn scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	inputs[| 12] = nodeValue(12, "Scaling speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 13] = nodeValue(13, "Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	inputs[| 14] = nodeValue(14, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	inputs[| 15] = nodeValue(15, "Alpha over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [1, 1, 1, 1]);
	
	inputs[| 16] = nodeValue(16, "Rotate by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 17] = nodeValue(17, "Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ]);
	
	inputs[| 18] = nodeValue(18, "Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 19] = nodeValue(19, "Draw exact", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 20] = nodeValue(20, "Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 2] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 21] = nodeValue(21, "Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	inputs[| 22] = nodeValue(22, "Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  0 );
	
	inputs[| 23] = nodeValue(23, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 24] = nodeValue(24, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Additive" ]);
	
	inputs[| 25] = nodeValue(25, "Surface array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Order", "Animation" ])
		.setVisible(false);
	
	inputs[| 26] = nodeValue(26, "Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setVisible(false);
	
	inputs[| 27] = nodeValue(27, "Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random", "Data" ]);
	
	inputs[| 28] = nodeValue(28, "Boundary data", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setVisible(false, true);
	
	inputs[| 29] = nodeValue(29, "On animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, ANIM_END_ACTION.loop)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Loop", "Ping pong", "Destroy" ])
		.setVisible(false);
	
	input_display_list = [		
		["Output",		true],	1,
		["Sprite",	   false],	0, 25, 26, 29,
		["Spawn",		true],	17, 2, 3, 4, 5, 27, 28, 6,
		["Movement",	true],	7, 20, 8,
		["Physics",		true],	21, 22,
		["Rotation",	true],	16, 9, 10, 
		["Scale",		true],	11, 18, 12, 
		["Color",		true],	13, 14, 15, 
		["Render",		true],	24, 19, 23,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	seed = irandom(9999999);
	def_surface = -1;
	
	parts = ds_list_create();
	for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
		ds_list_add(parts, new __part());
	
	outputs[| 1] = nodeValue(1, "Particle data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, parts );
	
	function spawn() {
		randomize();
		var _inSurf = inputs[| 0].getValue();
		
		if(_inSurf == 0) {
			if(def_surface == -1 || !surface_exists(def_surface)) { 
				def_surface = PIXEL_SURFACE;
				surface_set_target(def_surface);
				draw_clear(c_white);
				surface_reset_target();
			}
			_inSurf = def_surface;	
		}
		
		var _spawn_amount	= inputs[| 3].getValue();
		var _amo = _spawn_amount;
		
		var _spawn_area		= inputs[| 4].getValue();
		var _distrib		= inputs[| 5].getValue();
		var _scatter		= inputs[| 27].getValue();
		
		var _life			= inputs[| 6].getValue();
		var _direction		= inputs[| 7].getValue();
		var _velocity		= inputs[| 20].getValue();
		
		var _accel			= inputs[| 8].getValue();
		var _grav			= inputs[| 21].getValue();
		var _wigg			= inputs[| 22].getValue();
		
		var _follow			= inputs[| 16].getValue();
		var _rotation		= inputs[| 9].getValue();
		var _rotation_speed	= inputs[| 10].getValue();
		var _scale			= inputs[| 11].getValue();
		var _size 			= inputs[| 18].getValue();
		var _scale_speed	= inputs[| 12].getValue();
		
		var _loop	= inputs[| 23].getValue();
		
		var _color	= inputs[| 13].getValue();
		var _alpha	= inputs[| 14].getValue();
		var _fade	= inputs[| 15].getValue();
		
		var _arr_type	= inputs[| 25].getValue();
		var _anim_speed	= inputs[| 26].getValue();
		var _anim_end	= inputs[| 29].getValue();
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
			if(!parts[| i].active) {
				var _spr = _inSurf, _index = 0;
				if(is_array(_inSurf)) {
					if(_arr_type == 0) {
						_index = irandom(array_length(_inSurf) - 1);
						_spr = _inSurf[_index];						
					} else if(_arr_type == 1) {
						_index = safe_mod(spawn_index, array_length(_inSurf));
						_spr = _inSurf[_index];
					} else if(_arr_type == 2)
						_spr = _inSurf;
				}
				var xx = 0;
				var yy = 0;
				
				if(_scatter == 2) {
					var _b_data = inputs[| 28].getValue();
					if(!is_array(_b_data) || array_length(_b_data) <= 0) return;
					var _b = _b_data[safe_mod(_index, array_length(_b_data))];
					if(!is_array(_b) || array_length(_b) != 4) return;
					
					xx = array_safe_get(_spawn_area, 0) - array_safe_get(_spawn_area, 2);
					yy = array_safe_get(_spawn_area, 1) - array_safe_get(_spawn_area, 3);
					
					parts[| i].boundary_data = _b;
				} else {
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_amount);
					xx = sp[0];
					yy = sp[1];
					
					parts[| i].boundary_data = -1;
				}
				
				var _lif = random_range(_life[0], _life[1]);
				
				var _rot	 = random_range(_rotation[0], _rotation[1]);
				var _rot_spd = random_range(_rotation_speed[0], _rotation_speed[1]);
				
				var _dirr	= random_range(_direction[0], _direction[1]);
				
				var _velo	= random_range(_velocity[0], _velocity[1]);
				var _vx		= lengthdir_x(_velo, _dirr);
				var _vy		= lengthdir_y(_velo, _dirr);
				var _acc	= random_range(_accel[0], _accel[1]);
				
				var _ss  = random_range(_size[0], _size[1]);
				var _scx = random_range(_scale[0], _scale[1]) * _ss;
				var _scy = random_range(_scale[2], _scale[3]) * _ss;
				
				var _alp = random_range(_alpha[0], _alpha[1]);
				
				parts[| i].create(_spr, xx, yy, _lif);
				parts[| i].anim_speed = _anim_speed;
				parts[| i].anim_end = _anim_end;
				
				parts[| i].setPhysic(_vx, _vy, _acc, _grav, _wigg);
				parts[| i].setTransform(_scx, _scy, _scale_speed[0], _scale_speed[1], _rot, _rot_spd, _follow);
				parts[| i].setDraw(_color, _alp, _fade);
				setUpPart(parts[| i]);
				spawn_index = safe_mod(spawn_index + 1, PREF_MAP[? "part_max_amount"]);
				
				if(_loop && ANIMATOR.current_frame + _lif > ANIMATOR.frames_total)
					parts[| i].is_loop = true;
				
				if(--_amo <= 0)
					return;
			}
		}
	}
	
	function setUpPart(part) {}
	
	function reset() {
		spawn_index = 0;
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
			if(parts[| i].is_loop)
				parts[| i].is_loop = false;
			else
				parts[| i].kill();
		}
		render();
	}
	
	function updateParticle() {
		var jun = outputs[| 1];
		for(var j = 0; j < ds_list_size(jun.value_to); j++) {
			if(jun.value_to[| j].value_from == jun) {
				jun.value_to[| j].node.doUpdate();
			}
		}
		
		render();
	}
	
	function resetPartPool() {
		var _part_amo = PREF_MAP[? "part_max_amount"];
		if(_part_amo > ds_list_size(parts)) {
			repeat(_part_amo - ds_list_size(parts)) {
				ds_list_add(parts, new __part());
			}
		} else if(_part_amo < ds_list_size(parts)) {
			repeat(ds_list_size(parts) - _part_amo) {
				ds_list_delete(parts, 0);
			}
		}
	}
	
	static step = function() {
		var _inSurf = inputs[| 0].getValue();
		var _scatt  = inputs[| 27].getValue();
		
		inputs[| 25].setVisible(false);
		inputs[| 26].setVisible(false);
		inputs[| 28].setVisible(_scatt == 2);
		
		if(is_array(_inSurf)) {
			inputs[| 25].setVisible(true);
			var _type = inputs[| 25].getValue();
			if(_type == 2) {
				inputs[| 26].setVisible(true);
				inputs[| 29].setVisible(true);
			}
		}
		
		resetPartPool();
		var _spawn_type = inputs[| 17].getValue();
		if(_spawn_type == 0)
			inputs[| 2].name = "Spawn delay";
		else
			inputs[| 2].name = "Spawn frame";
		
		var _spawn_delay = inputs[| 2].getValue();
		
		if(ANIMATOR.is_playing && ANIMATOR.frame_progress) {
			if(ANIMATOR.current_frame == 0) reset();
			
			if(_spawn_type == 0) {
				if(safe_mod(ANIMATOR.current_frame, _spawn_delay) == 0)
					spawn();
			} else if(_spawn_type == 1) {
				if(ANIMATOR.current_frame == _spawn_delay)
					spawn();
			}
			
			for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
				parts[| i].step();
			updateParticle();
			
			updateForward();
		}
		
		if(ANIMATOR.is_scrubing) {
			recoverCache();	
		}
	}
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 4].drawOverlay(_active, _x, _y, _s, _mx, _my);
		if(onDrawOverlay != -1)
			onDrawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	static onDrawOverlay = -1;
	
	function render() {
		var _dim		= inputs[| 1].getValue();
		var _exact 		= inputs[| 19].getValue();
		var _blend 		= inputs[| 24].getValue();
		
		var _outSurf	= outputs[| 0].getValue();
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		else {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		}
		
		surface_set_target(_outSurf);
			draw_clear_alpha(c_white, 0);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal :	gpu_set_blendmode(bm_normal);	break;
				case PARTICLE_BLEND_MODE.additive : gpu_set_blendmode(bm_add);		break;
			}
			
			for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
				parts[| i].draw(_exact);
			
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
	
	static update = function() {
		reset();
	}
	doUpdate();
	render();
}