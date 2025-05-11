function Node_Rigid_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rigidbody Override";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	node_draw_icon = s_node_rigid_override;
	
	manual_ungroupable	 = false;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Positions", self, [0, 0] ));
	
	newInput(2, nodeValue_Vec2("Scales", self, [0, 0] ));
	
	newInput(3, nodeValue_Float("Rotations", self, 0 ));
	
	newInput(4, nodeValue_Color("Blends", self, 0 ));
	
	newInput(5, nodeValue_Float("Alpha", self, 0 ));
	
	newInput(6, nodeValue_Vec2("Velocity", self, [0, 0] ));
		
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone ));
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var objs = getInputData(0);
		outputs[0].setValue(objs);
		
		var _pos = getInputData(1);
		var _sca = getInputData(2);
		var _rot = getInputData(3);
		var _col = getInputData(4);
		var _alp = getInputData(5);
		var _vel = getInputData(6);
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(!is(obj, __Box2DObject)) continue;
			
			var _objId = obj.objId;
			
			if(is_array(_pos) && array_length(_pos)) {
				if(is_array(_pos[0])) gmlBox2D_Object_Set_Position(_objId, _pos[i][0] / worldScale, _pos[i][1] / worldScale);
				else                  gmlBox2D_Object_Set_Position(_objId,    _pos[0] / worldScale,    _pos[1] / worldScale);
			}
			
			if(is_array(_sca) && array_length(_sca)) {
				if(is_array(_sca[0])) {
					obj.xscale = _sca[i][0];
					obj.yscale = _sca[i][1];
				} else {
					obj.xscale = _sca[0];
					obj.yscale = _sca[1];
				}
			}
			
			if(is_array(_rot) && array_length(_rot) > i)
				gmlBox2D_Object_Set_Rotation(_objId, _rot[i]);
			
			if(is_array(_col) && array_length(_col) > i)
				obj.blend = _col[i];
			
			if(is_array(_alp) && array_length(_alp) > i)
				obj.alpha = _alp[i];
			
			if(is_array(_vel) && array_length(_vel) > i && is_array(_vel[i]))
				gmlBox2D_Object_Set_Velocity(_objId, _vel[i][0], _vel[i][1]);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}