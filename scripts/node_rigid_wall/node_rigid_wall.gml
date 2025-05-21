function Node_Rigid_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	worldIndex = undefined;
	worldScale = 100;
	objects    = [];
	
	newInput(2, nodeValue_Dimension());
	newInput(3, nodeValue_Int("Collision Group", 1));
	newInput(0, nodeValue_Toggle("Sides", 0b0010, { data : [ "T", "B", "L", "R" ] }));
		
	////- Physics
		
	newInput(1, nodeValue_Float(  "Contact Friction", 0.2));
	newInput(4, nodeValue_Slider( "Bounciness", 0.2));
		
	// input 5
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 0, 
		["Physics",	false],	1, 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!is(inline_context, Node_Rigid_Group_Inline)) return;
		var _dim  = inline_context.dimension;
		var _sids = getInputData(0);
		
		draw_set_color(COLORS._main_accent);
		
		var x0 = _x, x1 = _x + _dim[0] * _s;
		var y0 = _y, y1 = _y + _dim[1] * _s;
		
		if(_sids & 0b0001) draw_line_round(x0, y0, x1, y0, 4);
		if(_sids & 0b0010) draw_line_round(x0, y1, x1, y1, 4);
		if(_sids & 0b0100) draw_line_round(x0, y0, x0, y1, 4);
		if(_sids & 0b1000) draw_line_round(x1, y0, x1, y1, 4);
		
	}
	
	static spawn = function(side = 0) {
		if(worldIndex == undefined) return undefined;
		
		var _dim = inline_context.dimension;
		var _frc = getInputData(1);
		var _res = getInputData(4);
		
		var ww = _dim[0] / worldScale;
		var hh = _dim[1] / worldScale;
		
		gmlBox2D_Object_Create_Begin(worldIndex, 0, 0, false);
		
		switch(side) {
			case 0 : gmlBox2D_Object_Create_Shape_Segment( 0,  0, ww,  0); break;
			case 1 : gmlBox2D_Object_Create_Shape_Segment( 0, hh, ww, hh); break;
			case 2 : gmlBox2D_Object_Create_Shape_Segment( 0,  0,  0, hh); break;
			case 3 : gmlBox2D_Object_Create_Shape_Segment(ww,  0, ww, hh); break;
				
		}
		
		var objId  = gmlBox2D_Object_Create_Complete();
		var boxObj = new __Box2DObject(objId);
		
		gmlBox2D_Object_Set_Body_Type( objId,    0);
		gmlBox2D_Shape_Set_Friction(   objId, _frc);
		gmlBox2D_Shape_Set_Restitution(objId, _res);
		
		return boxObj;
	}
	
	static update = function() {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) reset();
		outputs[0].setValue(objects);
	}
	
	static reset = function() {
		objects = [];
		
		var _sids = getInputData(0);
		for( var i = 0; i < 4; i++ )
			if(_sids & (1 << i)) array_push(objects, spawn(i));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox  = drawGetBbox(xx, yy, _s);
		var _sids = getInputData(0);
		var spr   = s_rigid_walls;
		
		var ss = min(bbox.w / sprite_get_width(spr), bbox.h / sprite_get_height(spr));
		
		draw_sprite_ext(spr, 0, bbox.xc, bbox.yc, ss, ss, 0, c_white, 1);
		
		if(_sids & (1 << 0)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss, 180, c_white, 1);
		if(_sids & (1 << 1)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss,   0, c_white, 1);
		if(_sids & (1 << 2)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss, 270, c_white, 1);
		if(_sids & (1 << 3)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss,  90, c_white, 1);
	}
}