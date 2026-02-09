function Node_Rigid_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rigidbody Variable";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDrawIcon(s_node_rigid_variable);
	setDimension(96, 48);
	
	worldIndex = undefined;
	worldScale = 100;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Objects", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	newOutput(0, nodeValue_Output( "Positions",          VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(1, nodeValue_Output( "Scales",             VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(2, nodeValue_Output( "Rotations",          VALUE_TYPE.float,  0    ));
	newOutput(3, nodeValue_Output( "Blends",             VALUE_TYPE.color,  0    ));
	newOutput(4, nodeValue_Output( "Alpha",              VALUE_TYPE.float,  0    ));
	newOutput(5, nodeValue_Output( "Velocity",           VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(6, nodeValue_Output( "Center of Mass",     VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(7, nodeValue_Output( "Velocity Magnitude", VALUE_TYPE.float,  0    )).setDisplay(VALUE_DISPLAY.vector);
	
	array_foreach(outputs, function(i) /*=>*/ {return i.setVisible(false)});
	
	////- Nodes
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var objs = getInputData(0);
		
		var _get = [];
		var _val = [];
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			_get[i] = outputs[i].isVisible();
			_val[i] = _get[i]? array_create(array_length(objs)) : [];
		}
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(!is(obj, __Box2DObject)) continue;
			
			var _objId = obj.objId;
			
			if(_get[0]) _val[0][i] = [ gmlBox2D_Object_Get_X(_objId) * worldScale, gmlBox2D_Object_Get_Y(_objId) * worldScale ];
			if(_get[1]) _val[1][i] = [ obj.xscale, obj.yscale ];
			if(_get[2]) _val[2][i] = -radtodeg(gmlBox2D_Object_Get_Rotation(_objId));
			if(_get[3]) _val[3][i] = obj.blend;
			if(_get[4]) _val[4][i] = obj.alpha;
			if(_get[5]) _val[5][i] = [ gmlBox2D_Object_Get_Velocity_X(_objId), gmlBox2D_Object_Get_Velocity_Y(_objId) ];
			if(_get[6]) _val[6][i] = [ gmlBox2D_Object_Get_WorldCOM_X(_objId) * worldScale, gmlBox2D_Object_Get_WorldCOM_Y(_objId) * worldScale ];
			if(_get[7]) _val[7][i] = point_distance(0, 0, gmlBox2D_Object_Get_Velocity_X(_objId), gmlBox2D_Object_Get_Velocity_Y(_objId));
		}
		
		for( var i = 0; i < array_length(outputs); i++ )
			if(_get[i]) outputs[i].setValue(_val[i]);
	}
}