function Node_Feedback_Inline(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name    = "Feedback";
	color   = COLORS.node_blend_feedback;
	icon    = THEME.feedback;
	icon_24 = THEME.feedback_24;
	
	w = 0;
	h = 0;
	
	is_root         = false;
	selectable      = false;
	update_on_frame = true;
	
	attributes.junc_in  = [ "", 0 ];
	attributes.junc_out = [ "", 0 ];
	
	junc_in  = noone;
	junc_out = noone;
	
	value_buffer = noone;
	
	static bypassConnection = function() { return CURRENT_FRAME > 0; }
	static bypassNextNode   = function() { return false; }
	static getNextNode      = function() { return [] };
	
	static connectJunctions = function(jFrom, jTo) {
		junc_in  = jFrom.is_dummy? jFrom.dummy_get() : jFrom;
		junc_out = jTo;
		
		attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
		attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
	}
	
	static scanJunc = function() { #region
		var node_in  = PROJECT.nodeMap[? attributes.junc_in[0]];
		var node_out = PROJECT.nodeMap[? attributes.junc_out[0]];
		
		junc_in  = node_in?  node_in.inputs[| attributes.junc_in[1]]   : noone;
		junc_out = node_out? node_out.outputs[| attributes.junc_out[1]] : noone;
		
		if(junc_in)  junc_in.value_from_loop = self;
		if(junc_out) array_push(junc_out.value_to_loop, self);
	} #endregion
	
	static updateValue = function() { #region
		var type = junc_out.type;
		var val  = junc_out.getValue();
		
		switch(type) {
			case VALUE_TYPE.surface : 
				surface_array_free(value_buffer);
				value_buffer = surface_array_clone(val);
				break;
				
			default :
				value_buffer = variable_clone(val);
				break;
		}
	} #endregion
	
	static getValue = function(arr) { #region
		INLINE
		
		arr[@ 0] = value_buffer;
		arr[@ 1] = junc_out;
	} #endregion
	
	static drawConnections = function(params = {}) { #region
		if(!active) return noone;
		if(!junc_in || !junc_out) return noone;
		if(!junc_in.node.active || !junc_out.node.active) return noone;
		
		params.dashed = true;  params.loop = true;
			var sel = drawJuncConnection(junc_out, junc_in, params);
		params.dashed = false; params.loop = false;
		
		if(sel) return self;
		return noone;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s, display_parameter = noone) {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static postDeserialize = function() { scanJunc(); }
		
	static onDestroy = function() { #region
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	} #endregion
}