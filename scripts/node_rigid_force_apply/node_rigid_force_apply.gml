function Node_Rigid_Force_Apply(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Force";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame = true;
	setDimension(96, 96);
	
	worldIndex = undefined;
	worldScale = 100;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	
	////- Type
	
	newInput(1, nodeValue_Enum_Scroll( "Force type",  self, 0, [ "Constant", "Impulse", "Torque", "Explode" ]));
	newInput(6, nodeValue_Enum_Button( "Scope",       self, 0, [ "Global", "Local" ]));
	newInput(4, nodeValue_Int(         "Apply frame", self, 0, "Frame index to apply force."));
	newInput(2, nodeValue_Vec2(        "Position",    self, [ 0, 0 ]));
	
	////- Strength
	
	newInput(3, nodeValue_Float(       "Torque",      self, 0));
	newInput(5, nodeValue_Vec2(        "Force",       self, [ 0.1, 0 ]));
	newInput(8, nodeValue_Float(       "Range",       self, 8));
	newInput(7, nodeValue_Slider(      "Strength",    self, 1., [0, 16, 0.01]));
	
	// inputs 9
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone));
	
	for( var i = 1, n = array_length(inputs); i < n; i++ )
		inputs[i].rejectArray();
	
	input_display_list = [ 0,
		["Type",     false], 1, 6, 4, 2, 
		["Strength", false], 3, 5, 8, 7, 
	]
	
	array_push(attributeEditors, "Display");
	
	attributes.show_objects  = true;
	attributes.display_scale = 512;
	
	array_push(attributeEditors, ["Show objects",  function() /*=>*/ {return attributes.show_objects},  new checkBox(function() /*=>*/ {return toggleAttribute("show_objects")})]);
	array_push(attributeEditors, ["Display scale", function() /*=>*/ {return attributes.display_scale}, textBox_Number(function(v) /*=>*/ {return setAttribute("display_scale", v)})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
			
		if(_typ == 0 || _typ == 1) {
			var _for = getInputData(5);
			
			var fx = px + _for[0] * attributes.display_scale * _s;
			var fy = py + _for[1] * attributes.display_scale * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_line_width2(px, py, fx, fy, 8, 2);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, px, py, _s * attributes.display_scale, _mx, _my, _snx, _sny, 0, 10));
			
		} else if(_typ == 3) {
			var _rad = getInputData(8);
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_circle_prec(px, py, _rad * _s, 1);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
			
		} else 
			InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _obj = getInputData(0);
		outputs[0].setValue(_obj);
			
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var _tor = getInputData(3);
		var _frm = getInputData(4);
		var _for = getInputData(5);
		var _sco = getInputData(6);
		var _str = getInputData(7);
		var _rad = getInputData(8);
		
		inputs[3].setVisible(_typ == 2);
		inputs[4].setVisible(_typ > 0);
		inputs[5].setVisible(_typ == 0 || _typ == 1);
		inputs[6].setVisible(_typ != 3);
		inputs[8].setVisible(_typ == 3);
		
		if(!is_array(_obj)) return;
		
		var px = _pos[0] / worldScale;
		var py = _pos[1] / worldScale;
		
		var fx = _for[0] * _str;
		var fy = _for[1] * _str;
			
		for( var i = 0, n = array_length(_obj); i < n; i++ ) {
			var obj = _obj[i];
			if(!is(obj, __Box2DObject)) continue;
				
			var _objId   = obj.objId;
				
			switch(_typ) {
				case 0 : 
					if(_sco == 0) gmlBox2D_Object_Apply_Force(         _objId, fx, fy, px, py);
					else          gmlBox2D_Object_Apply_Force_Local(   _objId, fx, fy, px, py);
					break;
					
				case 1 : 
					if(CURRENT_FRAME != _frm) break;
					
					if(_sco == 0) gmlBox2D_Object_Apply_Impulse(       _objId, fx, fy, px, py);
					else          gmlBox2D_Object_Apply_Impulse_Local( _objId, fx, fy, px, py);
					break;
					
				case 2 : gmlBox2D_Object_Apply_Torque(_objId, _tor * _str); break;
					
				case 3 : 
					if(CURRENT_FRAME != _frm) break;
					
					var cx = gmlBox2D_Object_Get_WorldCOM_X(_objId);
					var cy = gmlBox2D_Object_Get_WorldCOM_Y(_objId);
					
					var dis = point_distance(px, py, cx, cy);
					
					if(dis < _rad) {
						var dir = point_direction(px, py, cx, cy);
						
						var str = _str * sqr(1 - dis / _rad);
						var fx = lengthdir_x(str, dir);
						var fy = lengthdir_y(str, dir);
						gmlBox2D_Object_Apply_Impulse(_objId, px, py, fx, fy);
					}
					break;
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigid_force_apply, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}