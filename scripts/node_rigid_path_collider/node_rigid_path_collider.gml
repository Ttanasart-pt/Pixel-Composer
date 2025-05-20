function Node_Rigid_Path_Collider(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Path Collider";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	worldIndex = undefined;
	worldScale = 100;
	objects    = [];
	
	////- Path
		
	newInput(0, nodeValue_PathNode( "Path",    self)).setVisible(true, true);
	newInput(3, nodeValue_Int(      "Samples", self, 8));
		
	////- Physics
		
	newInput(1, nodeValue_Float(  "Contact Friction", self, 0.2));
	newInput(2, nodeValue_Slider( "Bounciness",       self, 0.2));
		
	// inputs 4
		
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 
		["Path",    false], 0, 3, 	
		["Physics",	false],	1, 2, 
	];
	
	paths = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_empty(paths)) return;
		
		var nx, ny;
		var ox = _x + paths[0][0] * _s;
		var oy = _y + paths[0][1] * _s;
		
		draw_set_color(COLORS._main_accent);
		for( var i = 1, n = array_length(paths); i < n; i++ ) {
			nx = _x + paths[i][0] * _s;
			ny = _y + paths[i][1] * _s;
			
			draw_line(ox, oy, nx, ny);
			
			ox = nx;
			oy = ny;
		}
	}
	
	static buildPath = function() {
		if(worldIndex == undefined) return undefined;
		
		objects = [];
		var _pth = getInputData(0);
		if(!struct_has(_pth, "getPointRatio")) return undefined;
		
		var _smp = getInputData(3);
		
		var _frc = getInputData(1);
		var _res = getInputData(2);
		
		var _ismp = 1 / (_smp - 1);
		
		var ox, oy, nx, ny;
		var _p = new __vec2P();
		
		paths = array_verify(paths, _smp + 1);
		
		_p = _pth.getPointRatio(0, 0, _p);
		ox = _p.x / worldScale;
		oy = _p.y / worldScale;
		paths[0] = [_p.x, _p.y];
		
		for( var i = 1; i <= _smp; i++ ) {
			var _t = clamp(i * _ismp, 0, 0.999);
			_p = _pth.getPointRatio(_t, 0, _p);
			
			nx = _p.x / worldScale;
			ny = _p.y / worldScale;
			paths[i] = [_p.x, _p.y];
			
			gmlBox2D_Object_Create_Begin(worldIndex, 0, 0, false);
			gmlBox2D_Object_Create_Shape_Segment(ox, oy, nx, ny);
			var objId  = gmlBox2D_Object_Create_Complete();
			
			var boxObj = new __Box2DObject(objId);
			gmlBox2D_Object_Set_Body_Type( objId,    0);
			gmlBox2D_Shape_Set_Friction(   objId, _frc);
			gmlBox2D_Shape_Set_Restitution(objId, _res);
			
			array_push(objects, boxObj);
			
			ox = nx;
			oy = ny;
		}
	}
	
	static update = function() {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) buildPath();
		outputs[0].setValue(objects);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}