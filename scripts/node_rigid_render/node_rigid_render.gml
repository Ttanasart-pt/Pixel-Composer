function Node_Rigid_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	manual_ungroupable	 = false;
	
	//use_cache = CACHE_USE.auto;
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Render dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
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
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone )
			.setVisible(true, true);
		
		return inputs[| index];	
	} setDynamicInput(1, true, VALUE_TYPE.rigid);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var gr = is_instanceof(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
					
		if(gr == noone) return;
		if(!attributes.show_objects) return;
		
		for( var i = 0, n = array_length(gr.nodes); i < n; i++ ) {
			var _node = gr.nodes[i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _dim = getInputData(0);
		preview_surface = surface_verify(preview_surface, _dim[0], _dim[1], attrDepth());
		
		//if(!(TESTING && keyboard_check(ord("D"))) )
		//	return;
		
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
			for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
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
		cacheCurrentFrame(_outSurf);
	} #endregion
	
	static getPreviewValues = function() { #region
		var _surf = outputs[| 0].getValue();
		if(is_surface(_surf)) return _surf;
		return preview_surface;
	} #endregion
}