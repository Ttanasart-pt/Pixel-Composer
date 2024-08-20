function Node_Rigid_Render_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	manual_ungroupable	 = false;
	
	previewable = true;
	
	newInput(0, nodeValue_Vec2("Render dimension", self, DEF_SURF))
		.rejectArray();
		
	newInput(1, nodeValue_Bool("Round position", self, false))
	
	attribute_surface_depth();
	
	attributes.show_objects = true;	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show objects", function() { return attributes.show_objects; }, 
		new checkBox(function() { 
			attributes.show_objects = !attributes.show_objects;
		})]);
	
	static createNewInput = function() {
		var index = array_length(inputs);
		newInput(index, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone ))
			.setVisible(true, true);
			
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.rigid);
	
	static createOutput = function() { #region
		if(group == noone) return;
		if(!is_struct(group)) return;
			
		if(!is_undefined(outParent))
			array_remove(group.outputs, outParent);
			
		outParent = nodeValue("Rendered", group, CONNECT_TYPE.output, VALUE_TYPE.surface, noone)
			.uncache()
			.setVisible(true, true);
		outParent.from = self;
		
		array_push(group.outputs, outParent);
		group.refreshNodeDisplay();
		group.sortIO();
	} if(!LOADING && !APPENDING) createOutput(); #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var gr = is_instanceof(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
					
		if(gr == noone) return;
		if(!attributes.show_objects) return;
		
		for( var i = 0, n = array_length(gr.nodes); i < n; i++ ) {
			var _node = gr.nodes[i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		
		var _dim = getInputData(0);
		var _rnd = getInputData(1);
		var _outSurf = outParent.getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		
		if(TESTING && keyboard_check(ord("D"))) {
			var flag = phy_debug_render_shapes | phy_debug_render_coms;
			draw_set_color(c_white);
			physics_world_draw_debug(flag);
		} else {
			for( var i = input_fix_len; i < array_length(inputs) - 1; i++ ) {
				var objNode = getInputData(i);
				if(!is_array(objNode)) continue;
				
				for( var j = 0; j < array_length(objNode); j++ ) {
					var _o = objNode[j];
					
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
		
		draw_set_color(c_white);
		physics_draw_debug();
		
		surface_reset_target();
		// cacheCurrentFrame(_outSurf);
	} #endregion
		
	// static recoverCache = function(frame = CURRENT_FRAME) { #region
	// 	if(!is_instanceof(outParent, NodeValue)) return false;
	// 	if(!cacheExist(frame)) return false;
		
	// 	var _s = cached_output[CURRENT_FRAME];
	// 	outParent.setValue(_s);
			
	// 	return true;
	// } #endregion
	
	static getGraphPreviewSurface = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
	
	static getPreviewValues = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
}