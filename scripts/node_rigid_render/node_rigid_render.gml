function Node_Rigid_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	worldIndex = undefined;
	worldScale = 100;
	
	////- Simulation
	
	newInput(2, nodeValue_Float( "Timestep (ms)", self, 10));
	newInput(3, nodeValue_Int(   "Quality",       self,  8));
	
	////- Outputs
	
	newInput(0, nodeValue_Vec2("Render dimension", self, DEF_SURF));
	newInput(1, nodeValue_Bool("Round position",   self, false))
	
	// inputs 2
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	input_display_list = [ 
		["Simulation", false], 2, 3, 
		["Outputs",    false], 1,
	];
	
	attributes.show_objects = true;	
	attributes.show_debug   = false;	
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show Objects", function() /*=>*/ {return attributes.show_objects}, new checkBox(function() /*=>*/ {return toggleAttribute("show_objects")})]);
	array_push(attributeEditors, ["Debug",        function() /*=>*/ {return attributes.show_debug},   new checkBox(function() /*=>*/ {return toggleAttribute("show_debug")})]);
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.rigid);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(worldIndex == undefined) return;
		
		if(attributes.show_debug) {
			draw_set_text(_f_debug_s, fa_left, fa_top, c_white);
			
			var _tx = ui(16);
			var _ty = ui(80);
			
			var _count   = gmlBox2D_World_Get_Body_Count(worldIndex);
			var _awcount = gmlBox2D_World_Get_Awake_Body_Count(worldIndex);
			draw_text_transformed(_tx, _ty, $"Bodies: {_awcount}/{_count}", ui(2), ui(2), 0);
			
			_ty += ui(24);
			var _shcount = gmlBox2D_World_Get_Shape_Count(worldIndex);
			draw_text_transformed(_tx, _ty, $"Shapes: {_shcount}", ui(2), ui(2), 0);
			
		}
	} 
	
	static update = function(frame = CURRENT_FRAME) { 
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _dim    = inline_context.dimension;
		var _rnd    = getInputData(1);
		var _timStp = getInputData(2);
		var _subStp = getInputData(3);
		
		var _outSurf    = outputs[0].getValue();
		    _outSurf    = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		preview_surface = surface_verify(preview_surface, _dim[0], _dim[1], attrDepth());
		outputs[0].setValue(_outSurf);
		
		if(IS_PLAYING) gmlBox2D_World_Step(worldIndex, _timStp / 1000, _subStp);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		
		var _p = [0,0];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _objects = getInputData(i);
			if(!is_array(_objects)) continue;
			
			for( var j = 0, m = array_length(_objects); j < m; j++ ) {
				var _o = _objects[j];
				if(!is(_o, __Box2DObject)) continue;
					
				var _objId   = _o.objId;
				var _texture = _o.texture;
				if(!is_surface(_texture)) continue;
					
				var xscale = _o.xscale;
				var yscale = _o.yscale;
				
				var blend  = _o.blend;
				var alpha  = _o.alpha;
				
				var xx = gmlBox2D_Object_Get_X(_objId) * worldScale;
				var yy = gmlBox2D_Object_Get_Y(_objId) * worldScale;
				var rr = gmlBox2D_Object_Get_Rotation(_objId);
				    rr = -radtodeg(rr);
				
				var sw = surface_get_width(_texture)  * xscale;
				var sh = surface_get_height(_texture) * yscale;
				
				point_rotate_origin(-sw/2, -sh/2, rr, _p);
				draw_surface_ext_safe(_texture, xx + _p[0], yy + _p[1], xscale, yscale, rr, blend, alpha);
				
				if(attributes.show_debug) {
					var _awa = gmlBox2D_Object_Get_Awake(_objId);
					
					var vx = gmlBox2D_Object_Get_Velocity_X(_objId) * 2;
					var vy = gmlBox2D_Object_Get_Velocity_Y(_objId) * 2;
					var vr = gmlBox2D_Object_Get_Angular_Velocity(_objId);
					
					var cx = gmlBox2D_Object_Get_WorldCOM_X(_objId) * worldScale;
					var cy = gmlBox2D_Object_Get_WorldCOM_Y(_objId) * worldScale;
					
					var lx = gmlBox2D_Object_Get_LocalCOM_X(_objId) * worldScale;
					var ly = gmlBox2D_Object_Get_LocalCOM_Y(_objId) * worldScale;
					
					var aabb = gmlBox2D_Object_Get_AABB_arr(_objId, worldScale);
					
					draw_set_color(c_aqua);
					draw_line(xx, yy, xx + vx, yy + vy);
					
					draw_set_color(c_blue);
					draw_line(xx, yy, xx + lengthdir_x(8, rr), yy + lengthdir_y(8, rr));
					
					draw_set_color(_awa? c_red : c_blue);
					draw_point(xx, yy);
					draw_rectangle(aabb[0], aabb[1], aabb[2]-1, aabb[3]-1, true);
					
					// draw_set_text(_f_debug_s, fa_center, fa_center, c_grey);
					// draw_text(xx, yy, _rr);
				}
			}
		}
		
		draw_set_color(c_white);
		physics_draw_debug();
		
		surface_reset_target();
	} 
	
	static getPreviewValues = function() { 
		var _surf = outputs[0].getValue();
		return is_surface(_surf)? _surf : preview_surface;
	} 
}