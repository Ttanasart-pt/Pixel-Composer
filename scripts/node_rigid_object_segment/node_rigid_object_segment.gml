function Node_Rigid_Object_Segment(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Segment";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	worldIndex = undefined;
	worldScale = 100;
	objects    = [];
	
	////- Segment
		
	newInput(0, nodeValue_Vec2( "Segment Start", [  0, 0 ]));
	newInput(1, nodeValue_Vec2( "Segment End", [ 16, 0 ]));
		
	////- Physics
		
	newInput(2, nodeValue_Float(  "Contact Friction", 0.2));
	newInput(3, nodeValue_Slider( "Bounciness", 0.2));
		
	// inputs 4
		
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 
		["Segment", false], 0, 1, 
		["Physics",	false],	2, 3, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pst = getInputData(0);
		var _ped = getInputData(1);
		
		var x0 = _x + _pst[0] * _s;
		var y0 = _y + _pst[1] * _s;
		var x1 = _x + _ped[0] * _s;
		var y1 = _y + _ped[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(x0, y0, x1, y1);
		
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static buildPath = function() {
		if(worldIndex == undefined) return undefined;
		
		objects = [];
		var _pst = getInputData(0);
		var _ped = getInputData(1);
		var _frc = getInputData(2);
		var _res = getInputData(3);
		
		var ox = _pst[0] / worldScale;
		var oy = _pst[1] / worldScale;
		var nx = _ped[0] / worldScale;
		var ny = _ped[1] / worldScale;
		
		gmlBox2D_Object_Create_Begin(worldIndex, 0, 0, false);
		gmlBox2D_Object_Create_Shape_Segment(ox, oy, nx, ny);
		var objId  = gmlBox2D_Object_Create_Complete();
		
		var boxObj = new __Box2DObject(objId);
		gmlBox2D_Object_Set_Body_Type( objId,    0);
		gmlBox2D_Shape_Set_Friction(   objId, _frc);
		gmlBox2D_Shape_Set_Restitution(objId, _res);
		
		array_push(objects, boxObj);
	}
	
	static update = function() {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) buildPath();
		outputs[0].setValue(objects);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_rigid_object_segment, 0, bbox);
	}
}