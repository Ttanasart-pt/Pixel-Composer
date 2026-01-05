function Node_Rigid_Force_Apply(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Force";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame    = true;
	manual_ungroupable = false;
	setDrawIcon(s_node_rigid_force_apply);
	setDimension(96, 48);
	
	worldIndex = undefined;
	worldScale = 100;
	
	process_amount  = 0;
	inputs_data_len = [];
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	
	////- Type
	
	newInput(1, nodeValue_Enum_Scroll( "Force type", 0, [ "Constant", "Impulse", "Torque", "Torque Impulse", "Explode" ]));
	newInput(6, nodeValue_Enum_Button( "Scope", 0, [ "Global", "Local" ]));
	newInput(4, nodeValue_Bool(        "Apply",  true));
	newInput(9, nodeValue_Trigger(     "Trigger"));
	
	////- Force
	
	newInput(2, nodeValue_Vec2(   "Position",  [ 0, 0 ] )).setHotkey("G");
	newInput(3, nodeValue_Float(  "Torque",      0      ));
	newInput(5, nodeValue_Vec2(   "Force",     [.1, 0 ] ));
	newInput(8, nodeValue_Float(  "Range",       8      ));
	newInput(7, nodeValue_Slider( "Strength",    1, [0, 16, 0.01] ));
	
	// inputs 10
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, noone));
	
	input_display_list = [ 0,
		["Type",  false], 1, 6, 4, 9, 
		["Force", false], 2, 3, 5, 8, 7, 
	];
	
	array_push(attributeEditors, "Display");
	
	attributes.show_objects  = true;
	attributes.display_scale = 512;
	
	array_push(attributeEditors, Node_Attribute("Show objects",  function() /*=>*/ {return attributes.show_objects},  function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("show_objects")})}));
	array_push(attributeEditors, Node_Attribute("Display scale", function() /*=>*/ {return attributes.display_scale}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("display_scale", v)})}));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(process_amount > 0) return;
		
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		
		if(array_empty(_pos)) return;
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
			
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		if(_typ == 0 || _typ == 1) {
			var _for = getInputData(5);
			
			var fx = px + _for[0] * attributes.display_scale * _s;
			var fy = py + _for[1] * attributes.display_scale * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_line_width2(px, py, fx, fy, 8, 2);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, px, py, _s * attributes.display_scale, _mx, _my, _snx, _sny, 0, 10));
			
		} else if(_typ == 3) {
			var _rad = getInputData(8);
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_circle_prec(px, py, _rad * _s, 1);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
			
		} 
			
		return w_hovering;
	}
	
	static applyForce = function(_objId, _type, _scope, _position, _torque, _force, _radius, _strength) {
		
		var px = _position[0];
		var py = _position[1];
		
		var fx = _force[0];
		var fy = _force[1];
		
		switch(_type) {
			case 0 : 
				if(_scope == 0) gmlBox2D_Object_Apply_Force(         _objId, fx, fy, px, py);
				else            gmlBox2D_Object_Apply_Force_Local(   _objId, fx, fy, px, py);
				break;
				
			case 1 : 
				if(_scope == 0) gmlBox2D_Object_Apply_Impulse(       _objId, fx, fy, px, py);
				else            gmlBox2D_Object_Apply_Impulse_Local( _objId, fx, fy, px, py);
				break;
				
			case 2 : gmlBox2D_Object_Apply_Torque(_objId, _torque); break;
			
			case 3 : gmlBox2D_Object_Apply_Angular_Impulse( _objId, _torque); break;
				
			case 4 : 
				var cx = gmlBox2D_Object_Get_WorldCOM_X(_objId);
				var cy = gmlBox2D_Object_Get_WorldCOM_Y(_objId);
				
				var dis = point_distance(px, py, cx, cy);
				
				if(dis < _radius) {
					var dir = point_direction(px, py, cx, cy);
					
					var str = _strength * sqr(1 - dis / _radius);
					var fx  = lengthdir_x(str, dir);
					var fy  = lengthdir_y(str, dir);
					gmlBox2D_Object_Apply_Impulse(_objId, fx / worldScale, fy / worldScale, px, py);
				}
				break;
		}
	}
	
	static getForceData = function() {
		var _len = array_length(inputs);
		
		process_amount  = 0;
		inputs_data_len = array_create(array_length(inputs));
		
		array_foreach(inputs, function(_in, i) /*=>*/ {
			var raw = _in.getValue();
			var amo = _in.arrayLength(raw);
			inputs_data_len[i] = amo;
			process_amount = max(process_amount, amo);
		}, 1);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _obj = getInputData(0);
		outputs[0].setValue(_obj);
			
		__typ  = getInputData(1);
		__sco  = getInputData(6);
		__aply = getInputData(4);
		__trig = getInputData(9);
		
		__pos  = getInputData(2);
		__tor  = getInputData(3);
		__for  = getInputData(5);
		__rad  = getInputData(8);
		__str  = getInputData(7);
		
		inputs[6].setVisible(__typ != 4);
		inputs[4].setVisible(__typ == 0 || __typ == 2);
		inputs[9].setVisible(__typ == 1 || __typ == 3 || __typ == 4);
		
		inputs[3].setVisible(__typ == 2);
		inputs[5].setVisible(__typ == 0 || __typ == 1);
		inputs[8].setVisible(__typ == 4);
		
		if(!is_array(_obj)) return;
		
		var doForce = (__typ == 0 || __typ == 2)               && __aply;
		var doImpul = (__typ == 1 || __typ == 3 || __typ == 4) && __trig;
			
		if(!doForce && !doImpul) return;
		
		getForceData();
		
		if(process_amount == 0) {
			__ppos = [ __pos[0] / worldScale, __pos[1] / worldScale ];
			__ffor = [ __for[0] * __str,      __for[1] * __str      ];
			__ttor = __tor * __str;
			
			array_foreach(_obj, function(obj) /*=>*/ { if(is(obj, __Box2DObject)) applyForce(obj.objId, __typ, __sco, __ppos, __ttor, __ffor, __rad, __str) });
			return;
		}
		
		for( var i = 0; i < process_amount; i++ ) {
			_pos = inputs_data_len[2] == -1? __pos : __pos[i];
			_for = inputs_data_len[5] == -1? __for : __for[i];
			_tor = inputs_data_len[3] == -1? __tor : __tor[i];
			_str = inputs_data_len[7] == -1? __str : __str[i];
			
			__ppos = [ _pos[0] / worldScale, _pos[1] / worldScale ];
			__ffor = [ _for[0] * _str,       _for[1] * _str       ];
			__ttor = _tor * _str;
			
			array_foreach(_obj, function(obj) /*=>*/ { if(is(obj, __Box2DObject)) applyForce(obj.objId, __typ, __sco, __ppos, __ttor, __ffor, __rad, _str) });
		}
	}
}