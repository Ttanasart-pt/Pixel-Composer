function Node_Iterator_Inject() {
	selectable      = false;
	
	draw_line_shift_x	  = 0;
	draw_line_shift_y	  = 0;
	draw_line_thick		  = 1;
	draw_line_shift_hover = false;
		
	attributes.junc_in  = [ "", 0 ];
	attributes.junc_out = [ "", 0 ];
	
	junc_in  = noone;
	junc_out = noone;
	
	value_buffer = noone;
	
	static bypassConnection = function() { #region
		return false;
	} #endregion
	
	static bypassNextNode = function() { #region
		return false;
	} #endregion
	
	static getNextNode = function() { return [] };
	
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
	
	static getValue = function() { #region
		return [ value_buffer, junc_out ];
	} #endregion
	
	static drawConnections = function(params = {}) { #region
		if(!active) return;
		if(!junc_in || !junc_out) return;
		if(!junc_in.node.active || !junc_out.node.active) return;
		
		params.feedback = true;
		
		if(drawJuncConnection(junc_out, junc_in, params, self))
			return self;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s, display_parameter = noone) {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static postDeserialize = function() { #region
		scanJunc();
	} #endregion
		
	static onDestroy = function() { #region
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	} #endregion
}