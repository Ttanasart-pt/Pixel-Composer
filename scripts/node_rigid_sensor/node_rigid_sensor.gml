function Node_Rigid_Sensor(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sensor";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame    = true;
	manual_ungroupable = false;
	setDrawIcon(s_node_rigid_sensor);
	setDimension(96, 48);
	
	worldIndex  = undefined;
	worldScale  = 100;
	sensorIndex = undefined;
	
	////- =Objects
	newInput(0, nodeValue("Detect Objects", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
		
	////- =Segment
	newInput(1, nodeValue_EScroll( "Shape", AREA_SHAPE.rectangle, [ 
		new scrollItem("Rectangle", s_node_shape_rectangle, 0), 
		new scrollItem("Elipse",	s_node_shape_circle,	0) 
	])); 
	
	newInput(2, nodeValue_Vec2(  "Position", [.5,.5] )).setUnitSimple().setHotkey("G");
	newInput(3, nodeValue_Vec2(  "Span",     [.5,.5] )).setUnitSimple();
	newInput(4, nodeValue_Float( "Radius",    .5     )).setUnitSimple();
	// inputs 5
		
	newOutput(0, nodeValue_Output("Detected Objects", VALUE_TYPE.rigid, []));
	
	input_display_list = [ 0,
		["Sensor", false], 1, 2, 3, 4, 
	];
	
	////- Node
	
	detectCapacity = 1024;
	detectBuffer   = buffer_create(4 * detectCapacity, buffer_fixed, 4);
	
	static getDimension = function() /*=>*/ {return struct_try_get(inline_context, "dimension", [1,1])};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var _px = _x + _pos[0] * _s;
		var _py = _y + _pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		
	    if(_typ == 0) {
	    	var _siz = getInputData(3);
	    	var _pw  = _siz[0] * _s;
	    	var _ph  = _siz[1] * _s;
	    	
	    	draw_rectangle(_px - _pw, _py - _ph, _px + _pw, _py + _ph, true);
	    	InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    	
	    } else if(_typ == 1) {
	    	var _rad = getInputData(4);
	    	var _pr  = _rad * _s;
	    	
	    	draw_circle_prec(_px, _py, _pr, true);
			InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		}
		
		return w_hovering;
	}
	
	static buildSensor = function() {
		if(worldIndex == undefined) return undefined;
		
		objects = [];
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var _siz = getInputData(3);
		var _rad = getInputData(4);
		
		var ax = _pos[0] / worldScale;
		var ay = _pos[1] / worldScale;
		var aw = _siz[0] / worldScale;
		var ah = _siz[1] / worldScale;
		var ar = _rad    / worldScale;
		
		sensorIndex = undefined;
		
		     if(_typ == 0) sensorIndex = gmlBox2D_Sensor_Create_Rectangle(worldIndex, ax, ay, aw, ah);
		else if(_typ == 1) sensorIndex = gmlBox2D_Sensor_Create_Circle(worldIndex, ax, ay, ar);
	}
	
	static update = function() {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) { outputs[0].setValue([]); return; }
		
		var _type = getInputData(1);
		inputs[3].setVisible(_type == 0);
		inputs[4].setVisible(_type == 1);
		
		if(IS_FIRST_FRAME) buildSensor();
		if(sensorIndex == undefined) { outputs[0].setValue([]); return; }
		
		var _objects = getInputData(0);
		var _pos     = getInputData(2);
		var _objectMap = {};
		
		gmlBox2D_Sensor_Set_Position(sensorIndex, _pos[0] / worldScale, _pos[1] / worldScale);
		
		for( var i = 0, n = array_length(_objects); i < n; i++ ) {
			var o = _objects[i];
			_objectMap[$ gmlBox2D_Object_Get_Index(o.objId)] = o;
		}
		
		var _detectCount = gmlBox2D_Sensor_Get_Overlap(sensorIndex, buffer_get_address(detectBuffer), detectCapacity);
		var _res = [];
		
		buffer_to_start(detectBuffer);
		for( var i = 0; i < _detectCount; i++ ) {
			var _sid = buffer_read(detectBuffer, buffer_s32);
			if(!struct_has(_objectMap, _sid)) continue;
			
			array_push(_res, _objectMap[$ _sid]);
		}
		
		outputs[0].setValue(_res);
	}
	
}