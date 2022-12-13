function Node_VFX_effector(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Effector";
	previewable = false;
	
	w = 64;
	h = 64;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, -1 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 2] = nodeValue(2, "Falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [0, 0, 1, 1] )
		.setDisplay(VALUE_DISPLAY.curve);
	
	inputs[| 3] = nodeValue(3, "Falloff distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	inputs[| 4] = nodeValue(4, "Effect Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -1, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
	
	inputs[| 6] = nodeValue(6, "Rotate particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 7] = nodeValue(7, "Scale particle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 8] = nodeValue(8, "Turbulence scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	input_display_list = [ 0,
		["Area",	false], 1, 2, 3,
		["Effect",	false], 4, 5, 6, 7,
	];
	
	outputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, -1 );
	
	current_data = [];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	function onAffect(part, str) {}
	
	function affect(part) {
		if(!part.active) return;
		
		var _area = current_data[1];
		var _fall = current_data[2];
		var _fads = current_data[3];
		
		var _area_x = _area[0];
		var _area_y = _area[1];
		var _area_w = _area[2];
		var _area_h = _area[3];
		var _area_t = _area[4];
		
		var _area_x0 = _area_x - _area_w;
		var _area_x1 = _area_x + _area_w;
		var _area_y0 = _area_y - _area_h;
		var _area_y1 = _area_y + _area_h;
		
		random_set_seed(part.seed);
		
		var str = 0;
		var pv = part.getPivot();
		
		if(_area_t == AREA_SHAPE.rectangle) {
			if(point_in_rectangle(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y1)) {
				var _dst = min(	distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y0), 
								distance_to_line(pv[0], pv[1], _area_x0, _area_y1, _area_x1, _area_y1), 
								distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x0, _area_y1), 
								distance_to_line(pv[0], pv[1], _area_x1, _area_y0, _area_x1, _area_y1));
				str = eval_curve_bezier_cubic(_fall, clamp(_dst / _fads, 0., 1.));
			}
		} else if(_area_t == AREA_SHAPE.elipse) {
			if(point_in_circle(pv[0], pv[1], _area_x, _area_y, min(_area_w, _area_h))) {
				var _dst = point_distance(pv[0], pv[1], _area_x, _area_y);
				str = eval_curve_bezier_cubic(_fall, clamp(_dst / _fads, 0., 1.));
			}
		}
		
		if(str == 0) return;
		
		onAffect(part, str);
	}
	
	static update = function() {
		var val = inputs[| 0].getValue();
		outputs[| 0].setValue(val);
		if(val == -1) return;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			current_data[i] = inputs[| i].getValue();
		}
		
		for( var i = 0; i < ds_list_size(val); i++ )
			affect(val[| i]);
		
		var jun = outputs[| 0];
		for(var j = 0; j < ds_list_size(jun.value_to); j++) {
			if(jun.value_to[| j].value_from == jun)
				jun.value_to[| j].node.doUpdate();
		}
	}
}