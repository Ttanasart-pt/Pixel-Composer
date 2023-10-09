function Node_Rigid_Render_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Render";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	use_cache = CACHE_USE.auto;
	
	w = 128;
	h = 128;
	min_h = h;
	previewable = true;
	
	inputs[| 0] = nodeValue("Render dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
		
	inputs[| 1] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
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
	
	static createOutput = function(override_order = true) { #region
		if(group == noone) return;
		if(!is_struct(group)) return;
		
		if(override_order)
			attributes.input_priority = ds_list_size(group.outputs);
			
		if(!is_undefined(outParent))
			ds_list_remove(group.outputs, outParent);
			
		outParent = nodeValue("Rendered", group, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone)
			.uncache()
			.setVisible(true, true);
		outParent.from = self;
		
		ds_list_add(group.outputs, outParent);
		group.setHeight();
		group.sortIO();
	} if(!LOADING && !APPENDING) createOutput(); #endregion
	
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
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(!is_instanceof(group, Node_Rigid_Group)) return;
		if(!attributes.show_objects) return;
		
		for( var i = 0, n = ds_list_size(group.nodes); i < n; i++ ) {
			var _node = group.nodes[| i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
	} #endregion
	
	static step = function() { #region
		var _dim = getInputData(0);
		var _outSurf = outParent.getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outParent.setValue(_outSurf);
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
		
	static recoverCache = function(frame = CURRENT_FRAME) { #region
		if(!is_instanceof(outParent, NodeValue)) return false;
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outParent.setValue(_s);
			
		return true;
	} #endregion
	
	static getGraphPreviewSurface = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
	
	static getPreviewValues = function() { #region
		if(!is_instanceof(outParent, NodeValue)) return noone;
		return outParent.getValue();
	} #endregion
}