function Node_Rigid_Object_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object Spawner";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	objects = [];
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	newInput(7, nodeValueSeed(self));
	
	////- Spawn
	
	newInput(6, nodeValue_Bool(        "Spawn",        self, true));
	newInput(1, nodeValue_Area(        "Spawn area",   self, DEF_AREA));
	newInput(2, nodeValue_Enum_Button( "Spawn type",   self, 0, [ "Stream", "Burst" ]));
	newInput(3, nodeValue_Int(         "Spawn delay",  self, 4));
	newInput(5, nodeValue_Int(         "Spawn frame",  self, 0));
	newInput(4, nodeValue_Int(         "Spawn amount", self, 1));
	
	// inputs 8
	
	for( var i = 1, n = array_length(inputs); i < n; i++ ) inputs[i].rejectArray();
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 0, 7, 
		["Spawn",	false],	6, 1, 2, 3, 5, 4,
	];
	
	spawn_index = 0;
	
	attributes.show_objects = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show objects", function() /*=>*/ {return attributes.show_objects}, new checkBox(function() /*=>*/ {return toggleAttribute("show_objects")})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static spawn = function(seed = 0) {
		var _frm = inputs[0].value_from;
		if(_frm == noone) return;
		
		var _nod = _frm.node;
		if(!struct_has(_nod, "spawn")) return;
		
		var _are = getInputData(1);
		var _amo = getInputData(4);
		
		random_set_seed(seed);
		
		repeat(_amo) {
			var  pos = area_get_random_point(_are);
			var _rig = _nod.spawn(spawn_index++, pos);
			
			array_push(objects, _rig);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(IS_FIRST_FRAME) reset();
		
		var _obj = getInputData(0);
		var _sed = getInputData(7);
		
		var _spw = getInputData(6);
		var _typ = getInputData(2);
		var _del = getInputData(3);
		var _frm = getInputData(5);
		var _amo = getInputData(4);
		
		inputs[3].setVisible(_typ == 0);
		inputs[5].setVisible(_typ == 1);
		
		RETURN_ON_REST
		if(_obj == noone || !_spw) return;
		
		_sed = _sed + frame * _amo * 20;
		
		switch(_typ) {
			case 0 : if(safe_mod(CURRENT_FRAME, _del) == 0)  spawn(_sed); break;
			case 1 : if(CURRENT_FRAME == _frm)               spawn(_sed); break;
		}
			
		outputs[0].setValue(objects);
	}
	
	static reset = function() {
		spawn_index = 0;
		objects     = [];
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {
		var _in = array_safe_get(inputs, 0, noone);
		if(_in == noone) return noone;
		
		if(_in.value_from == noone) return;
		return _in.value_from.node.getGraphPreviewSurface();
	}
}