function Node_Rigid_Object_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object Spawner";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	objects = [];
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	newInput(7, nodeValueSeed());
	
	////- Spawn
	
	newInput(6, nodeValue_Bool( "Spawn", true));
	newInput(1, nodeValue_Area( "Spawn area", DEF_AREA)).setHotkey("A");
	newInput(2, nodeValue_Enum_Button(   "Spawn type", 0, [ "Stream", "Burst" ]));
	newInput(3, nodeValue_Int(  "Spawn delay", 4));
	newInput(5, nodeValue_Int(  "Spawn frame", 0));
	newInput(4, nodeValue_Int(  "Spawn amount", 1));
	
	////- Color
	
	newInput(8, nodeValue_Gradient( "Random Color", gra_white));
	newInput(9, nodeValue_Range(    "Alpha", [ 1, 1 ], { linked : true }));
	
	// inputs 10
	
	for( var i = 1, n = array_length(inputs); i < n; i++ ) inputs[i].rejectArray();
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 0, 7, 
		["Spawn", false], 6, 1, 2, 3, 5, 4,
		["Color", false], 8, 9, 
	];
	
	spawn_index = 0;
	
	attributes.show_objects = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, Node_Attribute("Show objects", function() /*=>*/ {return attributes.show_objects}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("show_objects")})}));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static spawn = function(seed = 0) {
		var _nod = inputs[0].value_from.node;
		var _are = getInputData(1);
		var _amo = getInputData(4);
		
		var _randColor = getInputData(8);
		var _randAlph  = getInputData(9);
		
		random_set_seed(seed);
		
		repeat(_amo) {
			var  pos = area_get_random_point(_are);
			var _rig = _nod.spawn(spawn_index++, pos);
			if(!is(_rig, __Box2DObject)) break;
			
			var _bld = _randColor.eval(random(1));
			var _alp = random_range(_randAlph[0], _randAlph[1]);
			
			_rig.blend = _bld;
			_rig.alpha = _alp;
			
			array_push(objects, _rig);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _obj = getInputData(0);
		var _sed = getInputData(7);
		
		var _spw = getInputData(6);
		var _typ = getInputData(2);
		var _del = getInputData(3);
		var _frm = getInputData(5);
		var _amo = getInputData(4);
		
		inputs[3].setVisible(_typ == 0);
		inputs[5].setVisible(_typ == 1);
		
		if(IS_FIRST_FRAME) {
			spawn_index = 0;
			objects     = [];
			outputs[0].setValue(objects);
		}
		
		if(_obj == noone || !_spw) return;
		
		var _frm = inputs[0].value_from;
		if(_frm == noone || !struct_has(_frm.node, "spawn")) return;
		
		_sed = _sed + frame * _amo * 20;
		
		switch(_typ) {
			case 0 : if(safe_mod(CURRENT_FRAME, _del) == 0) spawn(_sed); break;
			case 1 : if(CURRENT_FRAME == _frm)              spawn(_sed); break;
		}
			
		outputs[0].setValue(objects);
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {
		var _in = array_safe_get(inputs, 0, noone);
		if(_in == noone) return noone;
		
		if(_in.value_from == noone) return;
		return _in.value_from.node.getGraphPreviewSurface();
	}
}