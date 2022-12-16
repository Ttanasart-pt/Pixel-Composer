function Node_VFX_Spawner(_x, _y, _group = -1) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Spawner";
	
	inputs[| input_len + 0] = nodeValue(input_len + 0, "Spawn trigger", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, false)
		.setVisible(true, true);
	
	inputs[| input_len + 1] = nodeValue(input_len + 1, "Step interval", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	outputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, parts );
	outputs[| 1] = nodeValue(1, "On create", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	outputs[| 2] = nodeValue(2, "On step", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	outputs[| 3] = nodeValue(3, "On destroy", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	array_insert(input_display_list, 0, ["Trigger", true], input_len + 0, input_len + 1);
	
	static onSpawn = function(_time, part) {
		part.step_int = inputs[| input_len + 1].getValue(_time);
	}
	
	static onPartCreate = function(part) {
		var pv = part.getPivot();
		
		var vt = outputs[| 1];
		for( var i = 0; i < ds_list_size(vt.value_to); i++ ) {
			var _n = vt.value_to[| i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(, pv);
		}
	}
	
	static onPartStep = function(part) {
		var pv = part.getPivot();
		
		var vt = outputs[| 2];
		for( var i = 0; i < ds_list_size(vt.value_to); i++ ) {
			var _n = vt.value_to[| i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(, pv);
		}
	}
	
	static onPartDestroy = function(part) {
		var pv = part.getPivot();
		
		var vt = outputs[| 3];
		for( var i = 0; i < ds_list_size(vt.value_to); i++ ) {
			var _n = vt.value_to[| i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(, pv);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var spr = inputs[| 0].getValue();
		
		if(spr == 0) {
			if(def_surface == -1 || !surface_exists(def_surface)) { 
				def_surface = PIXEL_SURFACE;
				surface_set_target(def_surface);
				draw_clear(c_white);
				surface_reset_target();
			}
			spr = def_surface;	
		}
		
		if(is_array(spr))
			spr = spr[safe_mod(round(current_time / 100), array_length(spr))];
		
		var cx = xx + w * _s / 2;
		var cy = yy + h * _s / 2;
		var ss = min((w - 8) / surface_get_width(spr), (h - 8) / surface_get_height(spr)) * _s;
		draw_surface_align(spr, cx, cy, ss, fa_center, fa_center);
	}
}