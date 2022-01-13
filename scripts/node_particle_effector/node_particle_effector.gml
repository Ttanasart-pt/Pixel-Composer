function Node_create_Particle_Effector(_x, _y) {
	var node = new Node_Particle_Effector(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum FORCE_TYPE {
	Wind,
	Attract,
	Repel,
	Vortex,
	Turbulence,
	Destroy
}

function Node_Particle_Effector(_x, _y) : Node(_x, _y) constructor {
	name = "Particle Effector";
	previewable = false;
	
	inputs[| 0] = nodeValue(0, "Particle data", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, -1 );
	inputs[| 1] = nodeValue(1, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 3] = nodeValue(3, "Falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [0, 0, 1, 1] )
		.setDisplay(VALUE_DISPLAY.curve);
	
	inputs[| 4] = nodeValue(4, "Falloff distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	inputs[| 5] = nodeValue(5, "Effect type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Wind", "Attract", "Repel", "Vortex", "Turbulence", "Destroy" ] );
	
	inputs[| 6] = nodeValue(6, "Effect Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -1, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue(7, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
	
	inputs[| 8] = nodeValue(8, "Rotate particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 9] = nodeValue(9, "Scale particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue(10, "Turbulence scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16 );
	
	input_display_list = [ 0, 1, 
		["Area",	false], 2, 3, 4, 
		["Effect",	false], 5, 10, 7, 6, 8, 9 
	];
	
	outputs[| 0] = nodeValue(0, "Particle data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, -1 );
	
	current_data = [];
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 2].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	function step() {
		var _type = inputs[| 5].getValue();
		switch(_type) {
			case FORCE_TYPE.Wind :	
				node_input_visible(inputs[| 6],  true);
				node_input_visible(inputs[| 10], false);
				break;
			case FORCE_TYPE.Turbulence :	
				node_input_visible(inputs[| 6],  true);
				node_input_visible(inputs[| 10], true);
				break;
			case FORCE_TYPE.Destroy :	
				node_input_visible(inputs[| 6],  false);
				node_input_visible(inputs[| 8],  false);
				node_input_visible(inputs[| 9],  false);
				node_input_visible(inputs[| 10], false);
				break;
			default :	
				node_input_visible(inputs[| 6],  false);
				node_input_visible(inputs[| 10], false);
				break;
		}	
	}
	
	function affect(part) {
		if(!part.active) return;
		if(array_length(current_data) < ds_list_size(inputs)) return;
		
		var _area = current_data[2];
		var _fall = current_data[3];
		var _fads = current_data[4];
		var _type = current_data[5];
		var _vect = current_data[6];
		var _sten = current_data[7];
		
		var _rot = current_data[8];
		var _sca = current_data[9];
		
		var _area_x = _area[0];
		var _area_y = _area[1];
		var _area_w = _area[2];
		var _area_h = _area[3];
		var _area_t = _area[4];
		
		var _area_x0 = _area_x - _area_w;
		var _area_x1 = _area_x + _area_w;
		var _area_y0 = _area_y - _area_h;
		var _area_y1 = _area_y + _area_h;
		
		var str = 0;
		
		if(_area_t == AREA_SHAPE.rectangle) {
			if(point_in_rectangle(part.x, part.y, _area_x0, _area_y0, _area_x1, _area_y1)) {
				var _dst = min(	distance_to_line(part.x, part.y, _area_x0, _area_y0, _area_x1, _area_y0), 
								distance_to_line(part.x, part.y, _area_x0, _area_y1, _area_x1, _area_y1), 
								distance_to_line(part.x, part.y, _area_x0, _area_y0, _area_x0, _area_y1), 
								distance_to_line(part.x, part.y, _area_x1, _area_y0, _area_x1, _area_y1));
				str = eval_curve_bezier_cubic(_fall, clamp(_dst / _fads, 0., 1.));
			}
		} else if(_area_t == AREA_SHAPE.elipse) {
			if(point_in_circle(part.x, part.y, _area_x, _area_y, min(_area_w, _area_h))) {
				var _dst = point_distance(part.x, part.y, _area_x, _area_y);
				str = eval_curve_bezier_cubic(_fall, clamp(_dst / _fads, 0., 1.));
			}
		}
		
		if(str > 0) {
			switch(_type) {
				case FORCE_TYPE.Wind :
					part.x = part.x + _vect[0] * _sten * str;
					part.y = part.y + _vect[1] * _sten * str;
					break;
				case FORCE_TYPE.Attract :
					var dirr = point_direction(part.x, part.y, _area_x, _area_y);
					
					part.x = part.x + lengthdir_x(_sten * str, dirr);
					part.y = part.y + lengthdir_y(_sten * str, dirr);
					break;
				case FORCE_TYPE.Repel :
					var dirr = point_direction(_area_x, _area_y, part.x, part.y);
					
					part.x = part.x + lengthdir_x(_sten * str, dirr);
					part.y = part.y + lengthdir_y(_sten * str, dirr);
					break;
				case FORCE_TYPE.Vortex :
					var dirr = point_direction(_area_x, _area_y, part.x, part.y) + 90;
					
					part.x = part.x + lengthdir_x(_sten * str, dirr);
					part.y = part.y + lengthdir_y(_sten * str, dirr);
					break;
				case FORCE_TYPE.Turbulence :
					var t_scale = current_data[10];
					var per = (perlin_noise(part.x / t_scale, part.y / t_scale, 4, part.seed) - 0.5) * 2;
					per *= str;
					
					part.x = part.x + _vect[0] * per;
					part.y = part.y + _vect[1] * per;
					break;
				case FORCE_TYPE.Destroy :
					if(random(1) < _sten)
						part.kill();
					break;
			}
			
			var scx_s = _sca[0] * str;
			var scy_s = _sca[1] * str;
			if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
			else			part.scx += sign(part.scx) * scx_s;
			if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
			else			part.scy += sign(part.scy) * scy_s;
			
			part.rot += _rot * str;
		}
	}
	
	function updateParticle() {
		var jun = outputs[| 0];
		for(var j = 0; j < ds_list_size(jun.value_to); j++) {
			if(jun.value_to[| j].value_from == jun) {
				jun.value_to[| j].node.updateParticle();
			}
		}
		
		render();
	}
	
	function render() {
		var parts = inputs[| 0].getValue();
		if(!parts) return;
		
		for(var i = 0; i < ds_list_size(inputs); i++) {
			current_data[i] = inputs[| i].getValue();
		}
		for(var i = 0; i < ds_list_size(parts); i++)
			affect(parts[| i]);
	}
}