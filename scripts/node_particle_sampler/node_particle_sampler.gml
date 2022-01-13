function Node_create_Particle_Sampler(_x, _y) {
	var node = new Node_Particle_Sampler(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function __part_sampler() : __part() constructor {
	sample = -1;
	sam_x = 0;
	sam_y = 0;
	sam_w = 1;
	sam_h = 1;
	
	function setSample(_sample, _sam_x, _sam_y, _sam_w, _sam_h) {
		sample = _sample;
		sam_x = _sam_x;
		sam_y = _sam_y;
		sam_w = _sam_w;
		sam_h = _sam_h;
	}
	
	function draw() {
		if(!active) return;
		if(col == -1) return;
		if(surf) {
			var cc = gradient_eval(col, 1 - life / life_total);
			var _pp = point_rotate(x + sam_w * (1 - scx) / 2, y + sam_h * (1 - scy) / 2, x + sam_w * scx / 2, y + sam_h * scy / 2, rot);
			
			draw_surface_general(surf, sam_x, sam_y, sam_w, sam_h, _pp[0], _pp[1], scx, scy, rot, cc, cc, cc, cc, alp);
		}
	}
}

function Node_Particle_Sampler(_x, _y) : Node(_x, _y) constructor {
	name = "Particle Sampler";
	auto_update = false;

	use_cache     = true;
	
	inputs[| 0] = nodeValue(0, "Sample surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Particle shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue(2, "Particle size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 32 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 100);
	inputs[| 4] = nodeValue(4, "Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	inputs[| 5] = nodeValue(5, "Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 16, 16, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	inputs[| 6] = nodeValue(6, "Spawn distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Uniform", "Random", "Border" ])
		.setVisible(false);
	
	inputs[| 7] = nodeValue(7, "Lifespan", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 20, 30 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 8] = nodeValue(8, "Velocity", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	inputs[| 9] = nodeValue(9, "Acceleration", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue(10, "Spawn angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	inputs[| 11] = nodeValue(11, "Rotational speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 12] = nodeValue(12, "Spawn scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	inputs[| 13] = nodeValue(13, "Scaling speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 14] = nodeValue(14, "Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	inputs[| 15] = nodeValue(15, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	inputs[| 16] = nodeValue(16, "Alpha fading", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);

	inputs[| 17] = nodeValue(17, "Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false);
	
	inputs[| 18] = nodeValue(18, "Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ])
		.setVisible(false);
	
	inputs[| 19] = nodeValue(19, "Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 20] = nodeValue(20, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false, false);
	
	inputs[| 21] = nodeValue(21, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, OUTPUT_SCALING.same_as_input)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Same as sample", "Constant" ])
		.setVisible(false);
	
	inputs[| 22] = nodeValue(22, "Full surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			render();
		
			var _outSurf	= outputs[| 0].getValue();
			var _w = surface_get_width(_outSurf);
			var _h = surface_get_height(_outSurf);
		
			inputs[| 5].setValue([ _w / 2, _h / 2, _w / 2, _h / 2, AREA_SHAPE.rectangle ]);
		}, "Full surface"] );
	
	input_display_list = [ 0, 1, 
		["Output",		true],	21, 20, 
		["Spawn",		false], 18, 3, 4, 5, 22, 6, 7, 
		["Movement",	false], 8, 9, 
		["Transform",	false], 10, 11, 12, 19, 13, 
		["Color",		false], 14, 15, 16 
	];

	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	def_surface = -1;
	
	parts = ds_list_create();
	for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
		ds_list_add(parts, new __part_sampler());
	outputs[| 1] = nodeValue(1, "Particle data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, parts );
	
	function spawn() {
		var _inSurf = inputs[| 0].getValue();
		if(!is_surface(_inSurf)) return;
		var _samSurf = inputs[| 1].getValue();
		if(!is_surface(_samSurf)) {
			if(def_surface == -1 || !surface_exists(def_surface)) { 
				def_surface = surface_create(3, 3);
				surface_set_target(def_surface);
				draw_clear(c_white);
				surface_reset_target();
			}
			_samSurf = def_surface;
		}
		
		var sam_w = surface_get_width(_samSurf);
		var sam_h = surface_get_height(_samSurf);
		
		var _spawn_amount	= inputs[| 4].getValue();
		var _amo = _spawn_amount;
		
		var _spawn_area		= inputs[| 5].getValue();
		var _dist			= inputs[| 6].getValue();
		var _life			= inputs[| 7].getValue();
		var _velocity		= inputs[| 8].getValue();
		var _accel			= inputs[| 9].getValue();

		var _point			= inputs[| 17].getValue();
		var _rotation		= inputs[| 10].getValue();
		var _rotation_speed	= inputs[| 11].getValue();
		var _scale			= inputs[| 12].getValue();
		var _size			= inputs[| 19].getValue();
		var _scale_speed	= inputs[| 13].getValue();
		
		var _color	= inputs[| 14].getValue();
		var _alpha	= inputs[| 15].getValue();
		var _fade	= inputs[| 16].getValue();
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
			if(!parts[| i].active) {
				var _spr = is_array(_inSurf)? _inSurf[irandom(array_length(_inSurf) - 1)] : _inSurf;
				var xx, yy;
				
				var sp = area_get_random_point(_spawn_area, _dist, spawn_index, _spawn_amount);
				xx = sp[0];
				yy = sp[1];


				var _lif = random_range(_life[0], _life[1]);
				
				var _rot = (_point? point_direction(_spawn_area[0], _spawn_area[1], xx, yy) : 0) + random_range(_rotation[0], _rotation[1]);
				var _vx = random_range(_velocity[0], _velocity[1]);
				var _vy = random_range(_velocity[2], _velocity[3]);
				
				var _ss  = random_range(_size[0], _size[1]);
				var _scx = random_range(_scale[0], _scale[1]) * _ss;
				var _scy = random_range(_scale[2], _scale[3]) * _ss;
				
				var _alp = random_range(_alpha[0], _alpha[1]);
				
				parts[| i].create(_spr, xx, yy, _lif);
				parts[| i].setSample(_samSurf, xx, yy, sam_w, sam_h);
				parts[| i].setPhysic(_vx, _vy, _accel[0], _accel[1]);
				parts[| i].setTransform(_scx, _scy, _scale_speed[0], _scale_speed[1], _rot, _rotation_speed);
				parts[| i].setDraw(_color, _alp, _fade);
				spawn_index = safe_mod(spawn_index + 1, PREF_MAP[? "part_max_amount"]);
				if(_amo-- <= 0)
					return;
			}
		}
	}
	
	function reset() {
		spawn_index = 0;
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
			parts[| i].kill();
		render();
	}
	
	function updateParticle() {
		var jun = outputs[| 1];
		for(var j = 0; j < ds_list_size(jun.value_to); j++) {
			if(jun.value_to[| j].value_from == jun) {
				jun.value_to[| j].node.updateParticle();
			}
		}
		
		render();
	}
	
	function resetPartPool() {
		var _part_amo = PREF_MAP[? "part_max_amount"];
		if(_part_amo > ds_list_size(parts)) {
			repeat(_part_amo - ds_list_size(parts)) {
				ds_list_add(parts, new __part_sampler());
			}
		} else if(_part_amo < ds_list_size(parts)) {
			repeat(ds_list_size(parts) - _part_amo) {
				ds_list_delete(parts, 0);
			}
		}
	}
	
	function step() {
		resetPartPool();
		var _spawn_type = inputs[| 18].getValue();
		if(_spawn_type == 0) {
			inputs[| 3].name = "Spawn delay";
		} else {
			inputs[| 3].name = "Spawn frame";
		}
		
		var _spawn_delay = inputs[| 3].getValue();

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
	
	drag_type = -1;
	drag_sx   = 0;
	drag_sy   = 0;
	drag_mx   = 0;
	drag_my   = 0;
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 5].drawOverlay(_active, _x, _y, _s, _mx, _my);
		
		var out_type	= inputs[| 21].getValue();
		switch(out_type) {
			case OUTPUT_SCALING.same_as_input :
				inputs[| 20].show_in_inspector = false;
				break;
			case OUTPUT_SCALING.constant :	
				inputs[| 20].show_in_inspector = true;
				break;
		}
	}
	
	function render() {
		var _inSurf = inputs[| 0].getValue();
		if(!is_surface(_inSurf)) return;
		
		var _dim		= inputs[| 20].getValue();
		var out_type	= inputs[| 21].getValue();
		
		var _outSurf	= outputs[| 0].getValue();
		
		switch(out_type) {
			case OUTPUT_SCALING.same_as_input :
				surface_size_to(_outSurf, surface_valid(surface_get_width(_inSurf)), surface_valid(surface_get_height(_inSurf)));
				break;
			case OUTPUT_SCALING.constant :	
				surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
				break;
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
			parts[| i].draw();
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
	
	function update() {
		reset();
	}
	update();
	render();
}