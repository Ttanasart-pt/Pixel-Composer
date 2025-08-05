function Node_Rigid_Explode(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Explode";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame    = true;
	manual_ungroupable = false;
	setDimension(96, 48);
	
	worldIndex = undefined;
	worldScale = 100;
	
	process_amount  = 0;
	inputs_data_len = [];
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	
	////- Explosion
	
	newInput(1, nodeValue_Trigger( "Trigger"));
	newInput(2, nodeValue_Vec2(    "Position", [ 0, 0 ] )).setHotkey("G");
	newInput(3, nodeValue_Float(   "Range",      8      )).setHotkey("S");
	newInput(4, nodeValue_Slider(  "Strength",   1, [0, 16, 0.01] ));
	
	// inputs 5
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, noone));
	
	input_display_list = [ 0,
		["Explosion",  false], 1, 2, 3, 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(process_amount > 0) return;
		
		var _pos = getInputData(2);
		var _rad = getInputData(3);
		
		if(array_empty(_pos)) return;
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
			
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle_prec(px, py, _rad * _s, 1);
		draw_set_alpha(1);
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static applyForce = function(_objId, _position, _radius, _strength) {
		
		var px = _position[0];
		var py = _position[1];
		
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
			
		__trig = getInputData(1);
		__pos  = getInputData(2);
		__rad  = getInputData(3);
		__str  = getInputData(4);
		
		if(!is_array(_obj)) return;
		if(!__trig) return;
		
		getForceData();
		
		if(process_amount == 0) {
			__ppos = [ __pos[0] / worldScale, __pos[1] / worldScale ];
			
			array_foreach(_obj, function(obj) /*=>*/ { if(is(obj, __Box2DObject)) applyForce(obj.objId, __ppos, __rad, __str) });
			return;
		}
		
		for( var i = 0; i < process_amount; i++ ) {
			_pos = inputs_data_len[1] == -1? __pos : __pos[i];
			_str = inputs_data_len[4] == -1? __str : __str[i];
			
			__ppos = [ _pos[0] / worldScale, _pos[1] / worldScale ];
			
			array_foreach(_obj, function(obj) /*=>*/ { if(is(obj, __Box2DObject)) applyForce(obj.objId, __ppos, __rad, _str) });
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigid_explode, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}