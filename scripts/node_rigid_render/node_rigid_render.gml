function Node_Rigid_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	manual_ungroupable	 = false;
	
	use_cache = CACHE_USE.auto;
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Render dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	setIsDynamicInput(1);
	
	attribute_surface_depth();
	
	attributes.show_objects = true;	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show objects", function() { return attributes.show_objects; }, 
		new checkBox(function() { 
			attributes.show_objects = !attributes.show_objects;
		})]);
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone )
			.setVisible(true, true);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static refreshDynamicInput = function() { #region
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var gr = is_instanceof(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
					
		if(gr == noone) return;
		if(!attributes.show_objects) return;
		
		for( var i = 0, n = ds_list_size(gr.nodes); i < n; i++ ) {
			var _node = gr.nodes[| i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(recoverCache() || !PROJECT.animator.is_playing)
			return;
			
		var _dim = getInputData(0);
		var _rnd = getInputData(1);
		var _outSurf = outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		
		if(TESTING && keyboard_check(ord("D"))) {
			var flag = phy_debug_render_shapes | phy_debug_render_coms;
			draw_set_color(c_white);
			physics_world_draw_debug(flag);
		} else {
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
				var objNode = getInputData(i);
				if(!is_array(objNode)) objNode = [ objNode ];
				
				for( var j = 0; j < array_length(objNode); j++ ) {
					if(!variable_struct_exists(objNode[j], "object")) continue;
					var obj = objNode[j].object;
					
					if(!is_array(obj)) obj = [ obj ];
					
					for( var k = 0; k < array_length(obj); k++ ) {
						var _o = obj[k]; 
						
						if(_o == noone || !instance_exists(_o)) continue;
						if(is_undefined(_o.phy_active)) continue;
						
						var ixs = max(0, _o.xscale);
						var iys = max(0, _o.yscale);
						
						var xx = _rnd? round(_o.phy_position_x) : _o.phy_position_x;
						var yy = _rnd? round(_o.phy_position_y) : _o.phy_position_y;
						
						draw_surface_ext_safe(_o.surface, xx, yy, ixs, iys, _o.image_angle, _o.image_blend, _o.image_alpha);
					}
				}
			}
		}
		
		draw_set_color(c_white);
		physics_draw_debug();
		
		surface_reset_target();
		cacheCurrentFrame(_outSurf);
	} #endregion
}