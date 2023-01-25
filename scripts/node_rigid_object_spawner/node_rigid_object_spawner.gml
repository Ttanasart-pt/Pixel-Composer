function Node_Rigid_Object_Spawner(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Object Spawner";
	w = 96;
	min_h = 96;
	
	object = [];
	
	inputs[| 0] = nodeValue(0, "Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Spawn area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 2] = nodeValue(2, "Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ]);
	
	inputs[| 3] = nodeValue(3, "Spawn delay", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 4] = nodeValue(4, "Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 5] = nodeValue(5, "Spawn frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 6] = nodeValue(6, "Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue(0, "Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, self);
	
	input_display_list = [ 0,
		["Spawn",	false],	6, 1, 2, 3, 5, 4,
	];
	
	spawn_index = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static reset = function() {
		spawn_index = 0;
		object = [];
	}
	
	static step = function() {
		var _typ = inputs[| 2].getValue();
		
		inputs[| 3].setVisible(_typ == 0);
		inputs[| 5].setVisible(_typ == 1);
	}
	
	static spawn = function() {
		var _obj = inputs[| 0].getValue();
		var _are = inputs[| 1].getValue();
		var _amo = inputs[| 4].getValue();
		
		repeat(_amo) {
			var pos = area_get_random_point(_are,,,,, irandom(9999));
			var _o = _obj;
			if(is_array(_o))
				_o = _o[irandom(array_length(_o) - 1)];
				
			array_push(object, _o.spawn(pos, spawn_index++));
		}
	}
	
	static update = function() {
		if(!ANIMATOR.is_playing)
			return;
			
		var _obj = inputs[| 0].getValue();
		if(_obj == noone) return;
		
		var _typ = inputs[| 2].getValue();
		var _del = inputs[| 3].getValue();
		var _frm = inputs[| 5].getValue();
		var _spw = inputs[| 6].getValue();
		
		if(_spw) {
			if(_typ == 0 && (ANIMATOR.current_frame % _del == 0)) 
				spawn();
			if(_typ == 1 && ANIMATOR.current_frame == _frm) 
				spawn();
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var _obj = inputs[| 0].getValue();
		if(_obj == noone) return;
		
		var _tex  = _obj.inputs[| 6].getValue();
		var _spos = _obj.inputs[| 7].getValue();
		
		draw_surface_stretch_fit(_tex, bbox.xc, bbox.yc, bbox.w, bbox.h, _spos[2], _spos[3]);
	}
}