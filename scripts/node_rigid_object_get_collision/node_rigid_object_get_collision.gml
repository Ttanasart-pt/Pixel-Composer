function Node_Rigid_Object_Get_Collision(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Get Collisions";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Objects", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
	
	////- Filter
	
	newInput(1, nodeValue("Filter Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
	
	// inputs 2
	
	newOutput(0, nodeValue_Output("Collision Data",        self, VALUE_TYPE.struct,  []));
	newOutput(1, nodeValue_Output("Collision Points",      self, VALUE_TYPE.float,   [0, 0])).setDisplay(VALUE_DISPLAY.vector);
	newOutput(4, nodeValue_Output("Collision Normals",     self, VALUE_TYPE.float,   [0, 0])).setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(2, nodeValue_Output("New Collision Trigger", self, VALUE_TYPE.trigger, false)).setVisible(false);
	newOutput(3, nodeValue_Output("New Collision Points",  self, VALUE_TYPE.float,   [0, 0])).setDisplay(VALUE_DISPLAY.vector).setVisible(false);
	newOutput(5, nodeValue_Output("New Collision Normals", self, VALUE_TYPE.float,   [0, 0])).setDisplay(VALUE_DISPLAY.vector).setVisible(false);
	
	input_display_list = [ 0,
		["Filter", false], 1, 
	];
	
	output_display_list = [
		0, 1, 4, 2, 3, 5, 
	]
	
	coll_map = {};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) coll_map = {};
		
		var objs  = getInputData(0);
		var filt  = getInputData(1);
		var colls = [];
		
		var filtList    = [];
		
		if(filt != noone) {
			if(!is_array(filt)) filt = [ filt ];
			filtList = array_spread(filt)
			array_map_ext(filtList, function(o) /*=>*/ {return gmlBox2D_Object_Get_Index(o.objId)});
		}
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(!is(obj, __Box2DObject)) continue;
			
			var _objId = obj.objId;
			var _datas = gmlBox2D_Object_Get_Collision_Data(_objId);
			
			if(array_empty(filtList)) {
				array_append(colls, _datas);
				continue;
			}
			
			for( var j = 0, m = array_length(_datas); j < m; j++ ) {
				var _data = _datas[j];
				var _aId  = _data.shapeA_id;
				var _bId  = _data.shapeB_id;
				
				if(array_exists(filtList, _aId) || array_exists(filtList, _bId))
					array_push(colls, _data);
			}
		}
		
		var cpoints = [], cpoints_new = [];
		var cnorms  = [], cnorms_new  = [];
		var cnew    = false;
		
		for( var i = 0, n = array_length(colls); i < n; i++ ) {
			var _data  = colls[i];
			var _count = _data.point_count;
			var _aId   = _data.shapeA_id;
			var _bId   = _data.shapeB_id;
				
			var _collKey = $"{_aId}|{_bId}";
			var _collNew = !struct_has(coll_map, _collKey);
			    cnew     = cnew || _collNew;
			coll_map[$ _collKey] = CURRENT_FRAME;
				
			if(_count == 0) continue;
			
			if(_count == 1) {
				var _pnt = _data.mani_points_0.point;
				var _par = [ _pnt.x * worldScale, _pnt.y * worldScale ];
				
				array_push(cpoints, _par);
				if(_collNew) array_push(cpoints_new, _par);
				
			} else if(_count == 2) {
				var _pnt0 = _data.mani_points_0.point;
				var _pnt1 = _data.mani_points_1.point;
				var _par  = [ (_pnt0.x + _pnt1.x) / 2 * worldScale, (_pnt0.y + _pnt1.y) / 2 * worldScale ];
				
				array_push(cpoints, _par);
				if(_collNew) array_push(cpoints_new, _par);
			}
			
			var _colNorm = _data.mani_normal;
			var _norm    = [ _colNorm.x, _colNorm.y ];
			
			array_push(cnorms, _norm);
			if(_collNew) array_push(cnorms_new, _norm);
			
		}
		
		var _arr = struct_get_names(coll_map);
		for( var i = 0, n = array_length(_arr); i < n; i++ ) {
			if(coll_map[$ _arr[i]] != CURRENT_FRAME)
				struct_remove(coll_map, _arr[i]);
		}
		
		outputs[0].setValue(colls);
		outputs[1].setValue(cpoints);
		outputs[4].setValue(cnorms);
		
		outputs[2].setValue(cnew);
		outputs[3].setValue(cpoints_new);
		outputs[5].setValue(cnorms_new);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_rigid_object_get_collision, 0, bbox);
	}
}
