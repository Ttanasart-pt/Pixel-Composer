function Node_Rigid_Object_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object Spawner";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable	 = false;
	
	object = [];
	
	inputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Spawn area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, AREA_DEF)
		.setDisplay(VALUE_DISPLAY.area)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ])
		.rejectArray();
	
	inputs[| 3] = nodeValue("Spawn delay", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Spawn frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.rejectArray();
	
	inputs[| 6] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	inputs[| 7] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(10000, 99999))
	
	outputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.rigid, object);
	
	input_display_list = [ 0, 7, 
		["Spawn",	false],	6, 1, 2, 3, 5, 4,
	];
	
	spawn_index = 0;
	
	attributes.show_objects = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show objects", function() { return attributes.show_objects; }, 
		new checkBox(function() { 
			attributes.show_objects = !attributes.show_objects;
		})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(attributes.show_objects) 
		for( var i = 0, n = ds_list_size(group.nodes); i < n; i++ ) {
			var _node = group.nodes[| i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
		
		return inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static reset = function() {
		spawn_index = 0;
		object = [];
	}
	
	static step = function() {
		var _typ = getInputData(2);
		
		inputs[| 3].setVisible(_typ == 0);
		inputs[| 5].setVisible(_typ == 1);
	}
	
	static spawn = function(seed = 0) {
		var _obj = getInputData(0);
		var _are = getInputData(1);
		var _amo = getInputData(4);
		
		random_set_seed(seed);
		
		repeat(_amo) {
			var pos = area_get_random_point(_are);
			var _o = _obj;
			if(is_array(_o))
				_o = _o[irandom_range(0, array_length(_o) - 1)];
				
			array_push(object, _o.spawn(pos, spawn_index++));
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		RETURN_ON_REST
			
		var _obj = getInputData(0);
		if(_obj == noone) return;
		
		var _spw = getInputData(6);
		if(!_spw) return;
		
		var _typ = getInputData(2);
		var _del = getInputData(3);
		var _frm = getInputData(5);
		var _amo = getInputData(4);
		var _sed = getInputData(7) + frame * _amo * 20;
		
		if(_typ == 0 && (safe_mod(CURRENT_FRAME, _del) == 0)) 
			spawn(_sed);
		else if(_typ == 1 && CURRENT_FRAME == _frm) 
			spawn(_sed);
			
		outputs[| 0].setValue(object);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var _obj = getInputData(0);
		if(_obj == noone) return;
		if(is_array(_obj)) return;
		
		var _tex  = _obj.getInputData(6);
		var _spos = _obj.getInputData(7);
		
		draw_surface_stretch_fit(_tex, bbox.xc, bbox.yc, bbox.w, bbox.h, _spos[2], _spos[3]);
	}
}