function Node_Rigid_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rigidbody Override";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	node_draw_icon = s_node_rigid_override;
	
	manual_ungroupable = false;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
	
	newInput( 1, nodeValue_Bool(    "Set Surfaces", self, false ));
	newInput( 2, nodeValue_Surface( "Surfaces",     self ));
	
	newInput( 3, nodeValue_Bool(  "Set Positions",  self, false ));
	newInput( 4, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative" ])).setInternalName("Position mode");
	newInput( 5, nodeValue_Vec2(  "Positions",      self, [0, 0] ));
	
	newInput( 6, nodeValue_Bool(  "Set Rotations",  self, false ));
	newInput( 7, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative" ])).setInternalName("Rotation mode");
	newInput( 8, nodeValue_Float( "Rotations",      self, 0 ));
	
	newInput( 9, nodeValue_Bool(  "Set Scales",     self, false ));
	newInput(10, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Scale mode");
	newInput(11, nodeValue_Vec2(  "Scales",         self, [0, 0] ));
	
	newInput(12, nodeValue_Bool(  "Set Blends",     self, false ));
	newInput(13, nodeValue_Color( "Blends",         self, ca_white ));
	
	newInput(14, nodeValue_Bool(  "Set Alpha",      self, false ));
	newInput(15, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative" ])).setInternalName("Alpha mode");
	newInput(16, nodeValue_Float( "Alpha",          self, 0 ));
	
	newInput(17, nodeValue_Bool(  "Set Mass",       self, false ));
	newInput(18, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Mass mode");
	newInput(19, nodeValue_Float( "Mass",           self, 1 ));
	
	newInput(20, nodeValue_Bool(  "Set Friction",   self, false ));
	newInput(21, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Friction mode");
	newInput(22, nodeValue_Float( "Friction",       self, 1 ));
	
	newInput(23, nodeValue_Bool(  "Set Bounciness", self, false ));
	newInput(24, nodeValue_eb(    "Mode",           self, 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Bounciness mode");
	newInput(25, nodeValue_Float( "Bounciness",     self, 1 ));
	
	newInput(26, nodeValue_Bool(  "Set Gravity Scale", self, false ));
	newInput(27, nodeValue_eb(    "Mode",              self, 0, [ "Absolute", "Relative Add", "Relative Muliply" ])).setInternalName("Gravity Scale mode");
	newInput(28, nodeValue_Float( "Gravity Scale",     self, 1 ));
	
	// inputs 29
		
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone ));
	
	input_display_list = [ 0, 
		["Surface",       false,  1], 2, 
		["Position",      false,  3], 4, 5, 
		["Rotation",      false,  6], 7, 8, 
		["Scale",         false,  9], 10, 11, 
		["Blend",         false, 12], 13, 
		["Alpha",         false, 14], 15, 16, 
		["Mass",          false, 17], 18, 19, 
		["Friction",      false, 20], 21, 22, 
		["Bounciness",    false, 23], 24, 25, 
		["Gravity Scale", false, 26], 27, 28, 
	]
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var objs = getInputData(0);
		outputs[0].setValue(objs);
		
		var _setSurfs = getInputData(1);
		var _surfs    = getInputData(2);
		
		var _setPos = getInputData( 3); var _posMod = getInputData( 4); var _pos = getInputData( 5);
		var _setRot = getInputData( 6); var _rotMod = getInputData( 7); var _rot = getInputData( 8);
		var _setSca = getInputData( 9); var _scaMod = getInputData(10); var _sca = getInputData(11);
		var _setCol = getInputData(12);                                 var _col = getInputData(13);
		var _setAlp = getInputData(14); var _alpMod = getInputData(15); var _alp = getInputData(16);
		var _setMas = getInputData(17); var _masMod = getInputData(18); var _mas = getInputData(19);
		var _setFrc = getInputData(20); var _frcMod = getInputData(21); var _frc = getInputData(22);
		var _setBou = getInputData(23); var _bouMod = getInputData(24); var _bou = getInputData(25);
		var _setGra = getInputData(26); var _graMod = getInputData(27); var _gra = getInputData(28);
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(!is(obj, __Box2DObject)) continue;
			
			var _objId = obj.objId;
			
			if(_setSurfs) obj.texture = is_array(_surfs)? array_safe_get(_surfs, i, obj.texture) : _surfs;
			
			if(_setPos) {
				var _px = is_array(_pos[0])? _pos[i][0] / worldScale : _pos[0];
				var _py = is_array(_pos[1])? _pos[i][1] / worldScale : _pos[1];
				
				if(_posMod == 1) {
					_px += gmlBox2D_Object_Get_X(_objId);
					_py += gmlBox2D_Object_Get_Y(_objId);
				} 
				
				gmlBox2D_Object_Set_Position(_objId, _px, _py);
			}
			
			if(_setRot) {
				var _r = is_array(_rot)? array_safe_get(_rot, i) : _rot;
				if(_rotMod == 1) _r += gmlBox2D_Object_Get_Rotation(_objId);
				gmlBox2D_Object_Set_Rotation(_objId, _r);
			}
			
			if(_setSca) {
				var _sx = is_array(_sca[0])? _sca[i][0] : _sca[0];
				var _sy = is_array(_sca[1])? _sca[i][1] : _sca[1];
				
				if(_posMod == 1) {
					_sx += obj.xscale;
					_sy += obj.xscale;
					
				} else if(_posMod == 2) {
					_sx *= obj.xscale;
					_sy *= obj.xscale;
				} 
				
				obj.xscale = _sx;
				obj.yscale = _sy;
			}
			
			if(_setCol) obj.blend = is_array(_col)? array_safe_get(_col, i) : _col;
			
			if(_setAlp) {
				var _a = is_array(_alp)? array_safe_get(_alp, i) : _alp;
				if(_alpMod == 1) _a += obj.alpha;
				obj.alpha = _a;
			}
			
			if(_setMas) {
				var _m = is_array(_mas)? array_safe_get(_mas, i) : _mas;
				     if(_masMod == 1) _m += gmlBox2D_Object_Get_Mass(_objId);
				else if(_masMod == 2) _m *= gmlBox2D_Object_Get_Mass(_objId);
				gmlBox2D_Object_Set_Mass(_objId, _m);
			}
			
			if(_setFrc) {
				var _f = is_array(_frc)? array_safe_get(_frc, i) : _frc;
				     if(_frcMod == 1) _f += gmlBox2D_Object_Get_Friction(_objId);
				else if(_frcMod == 2) _f *= gmlBox2D_Object_Get_Friction(_objId);
				gmlBox2D_Shape_Set_Friction(_objId, _f);
			}
			
			if(_setBou) {
				var _b = is_array(_bou)? array_safe_get(_bou, i) : _bou;
				     if(_bouMod == 1) _b += gmlBox2D_Object_Get_Restitution(_objId);
				else if(_bouMod == 2) _b *= gmlBox2D_Object_Get_Restitution(_objId);
				gmlBox2D_Shape_Set_Restitution(_objId, _b);
			}
			
			if(_setGra) {
				var _g = is_array(_gra)? array_safe_get(_gra, i) : _gra;
				     if(_graMod == 1) _g += gmlBox2D_Object_Get_Gravity_Scale(_objId);
				else if(_graMod == 2) _g *= gmlBox2D_Object_Get_Gravity_Scale(_objId);
				gmlBox2D_Object_Set_Gravity_Scale(_objId, _g);
			}
			
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}