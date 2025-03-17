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
	
	value_buffer   = noone;
	buffered_frame = noone;
	
	static bypassConnection = function() /*=>*/ {return CURRENT_FRAME > 0};
	static bypassNextNode   = function() /*=>*/ {return false};
	static getNextNode      = function() /*=>*/ {return []};
	
	static connectJunctions = function(jFrom, jTo) {
		junc_in  = jFrom.is_dummy? jFrom.dummy_get() : jFrom;
		junc_out = jTo;
		
		attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
		attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
	}
	
	static scanJunc = function() {
		var node_i = PROJECT.nodeMap[? attributes.junc_in[0]];
		var node_o = PROJECT.nodeMap[? attributes.junc_out[0]];
		
		junc_in  = node_i? node_i.inputs[attributes.junc_in[1]]   : noone;
		junc_out = node_o? node_o.outputs[attributes.junc_out[1]] : noone;
		
		if(junc_in)  junc_in.value_from_loop = self;
		if(junc_out) array_push(junc_out.value_to_loop, self);
	}
	
	static updateValue = function() {
		if(!IS_PLAYING && CURRENT_FRAME != 0 && CURRENT_FRAME != buffered_frame + 1) return;
		
		var type = junc_out.type;
		var val  = junc_out.getValue();
		
		switch(type) {
			case VALUE_TYPE.surface : 
				surface_array_free(value_buffer);
				value_buffer = surface_array_clone(val);
				break;
				
			default : value_buffer = variable_clone(val);
		}
		
		buffered_frame = CURRENT_FRAME;
	}
	
	static getValue = function(arr) {
		INLINE
		
		arr[@ 0] = value_buffer;
		arr[@ 1] = junc_out;
	}
	
	static drawConnections = function(params = {}) {
		if( junc_out == noone    ||  junc_in == noone)    return noone;
		if(!junc_out.node.active || !junc_in.node.active) return noone;
		
		params.dashed = true; params.loop   = true;
		drawJuncConnection(junc_out, junc_in, params);
		params.dashed = false; params.loop   = false;
		
		return noone;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, display_parameter = noone) {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static postDeserialize = function() { scanJunc(); }
		
	static onDestroy = function() {
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	}
}