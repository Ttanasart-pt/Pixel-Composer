function Node_Rigid_Render_ID(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render ID";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	worldIndex = undefined;
	worldScale = 100;
	
	////- Simulation
	
	newInput(3, nodeValue_Bool(  "Simulate", false));
	newInput(1, nodeValue_Float( "Timestep (ms)", 20));
	newInput(2, nodeValue_Int(   "Quality",  8));
	
	////- Outputs
	
	newInput(0, nodeValue_Bool("Round Position", false));
	
	// inputs 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	input_display_list = [ 
		["Simulation", false, 3], 1, 2, 
		["Rendering",  false], 0,
	];
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone )).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.rigid);
	
	static update = function(frame = CURRENT_FRAME) { 
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _dim    = inline_context.dimension;
		var _rnd    = getInputData(0);
		var _timStp = getInputData(1);
		var _subStp = getInputData(2);
		var _simula = getInputData(3);
		
		var _outSurf    = outputs[0].getValue();
		    _outSurf    = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		preview_surface = surface_verify(preview_surface, _dim[0], _dim[1], attrDepth());
		outputs[0].setValue(_outSurf);
		
		if(_simula && IS_PLAYING) {
			gmlBox2D_World_Step(worldIndex, _timStp / 1000, _subStp);
			gmlBox2D_World_Step_Joint(worldIndex);
		}
		
		var _p   = [0,0];
		var _ind = 999;
		
		surface_set_shader(_outSurf, sh_rigid_draw_color);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _objects = getInputData(i);
			if(!is_array(_objects)) continue;
			
			for( var j = 0, m = array_length(_objects); j < m; j++ ) {
				var _o = _objects[j];
				if(!is(_o, __Box2DObject)) continue;
				random_set_seed(_ind++);
				
				var _objId   = _o.objId;
				var _texture = _o.texture;
				if(!is_surface(_texture)) continue;
					
				var xscale = _o.xscale;
				var yscale = _o.yscale;
				 
				var blend  = make_color_grey(random(1));
				var alpha  = _o.alpha;
				
				var xx = gmlBox2D_Object_Get_X(_objId) * worldScale;
				var yy = gmlBox2D_Object_Get_Y(_objId) * worldScale;
				var rr = gmlBox2D_Object_Get_Rotation(_objId);
				    rr = -radtodeg(rr);
				
				var sw = surface_get_width(_texture)  * xscale;
				var sh = surface_get_height(_texture) * yscale;
				
				var ox = -sw / 2 + _o.xoffset;
				var oy = -sh / 2 + _o.yoffset;
				
				point_rotate_origin(ox, oy, rr, _p);
				
				var dx = xx + _p[0];
				var dy = yy + _p[1];
				
				if(_rnd) {
					dx = round(dx);
					dy = round(dy);
				}
				
				draw_surface_ext_safe(_texture, dx, dy, xscale, yscale, rr, blend, alpha);
			}
		}
		
		surface_reset_shader();
	} 
	
	static getPreviewValues = function() { 
		var _surf = outputs[0].getValue();
		return is_surface(_surf)? _surf : preview_surface;
	} 
}