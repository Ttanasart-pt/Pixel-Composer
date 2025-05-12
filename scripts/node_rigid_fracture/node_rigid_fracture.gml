function Node_Rigid_Fracture(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Fracture";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	worldIndex = undefined;
	worldScale = 100;
	objects    = [];
	meshes     = [];
	
	newInput( 0, nodeValue_Surface( "Base Texture",     self));
	newInput( 1, nodeValue_Surface( "Fracture Texture", self));
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 0,  
		["Fracture", false], 1, button(function() /*=>*/ {return fracture()}).setText("Fracture"), 
	];
	
	static fracture = function() {
		for( var i = 0, n = array_length(meshes); i < n; i++ ) {
			var _mesh = meshes[i];
			surface_free_safe(_mesh.mask);
			surface_free_safe(_mesh.texture);
		}
		
		meshes = [];
		var _fracSurf = getInputData(1);
		if(!is_surface(_fracSurf)) return;
		
		
	}
	
	static spawn = function() {
		objects = [];
		if(array_empty(meshes)) return;
		
		var _baseSurf = getInputData(0);
		if(!is_surface(_baseSurf)) return;
			
		var ww = surface_get_width_safe(_baseSurf);
		var hh = surface_get_height_safe(_baseSurf);
		
		var ow = ww / 2 / worldScale;
		var oh = hh / 2 / worldScale;
		
		for( var i = 0, n = array_length(meshes); i < n; i++ ) {
			var _mesh = meshes[i];
			var _mask = _mesh.mask;
			var _pnts = _mesh.points;
			var _bbox = _mesh.bbox;
			
			_mesh.texture = surface_verify(_mesh.texture, ww, hh);
			surface_set_target(_mesh.texture);
				DRAW_CLEAR
				BLEND_OVERRIDE
					draw_surface(_baseSurf, 0, 0);
				BLEND_MULTIPLY
					draw_surface(_mask, 0, 0);
				BLEND_NORMAL
			surface_reset_target();
			
			gmlBox2D_Object_Create_Begin(worldIndex, 0, 0, false);
			
			var len  = array_length(_pnts);
			var buff = buffer_create(8 * 2 * len, buffer_fixed, 8);
			
			buffer_to_start(buff);
			for(var i = 0; i < len; i++) {
				buffer_write(buff, buffer_f64, _pnts[i][0] / worldScale - ow);
				buffer_write(buff, buffer_f64, _pnts[i][1] / worldScale - oh);
			}
			
			gmlBox2D_Object_Create_Shape_Polygon(buffer_get_address(buff), len, 0);
			buffer_delete(buff);
			
			var objId  = gmlBox2D_Object_Create_Complete(); 
			var boxObj = new __Box2DObject(objId, _mesh.texture);
			
			array_push(objects, boxObj);
		}
		
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME)
			spawn();
		
		outputs[0].setValue(objects);
	}
	
}