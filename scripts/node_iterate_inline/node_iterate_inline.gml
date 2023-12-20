function Node_Iterate_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name    = "Loop";
	color   = COLORS.node_blend_loop;
	icon    = THEME.loop;
	icon_24 = THEME.loop_24;
	
	inputs[| 0] = nodeValue("Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.uncache();
		
	managedRenderOrder = true;
	
	draw_line_feed        = true;
	draw_line_shift_x	  = 0;
	draw_line_shift_y	  = 0;
	draw_line_thick		  = 1;
	draw_line_shift_hover = false;
	
	attributes.junc_in  = [ "", 0 ];
	attributes.junc_out = [ "", 0 ];
	
	junc_in  = noone;
	junc_out = noone;
	
	value_buffer    = undefined;
	iterated        = 0;
	
	static getIterationCount = function() { return getInputData(0); }
	
	static bypassConnection = function() { #region
		return iterated > 0 && !is_undefined(value_buffer);
	} #endregion
	
	static bypassNextNode = function() { #region
		return iterated < getIterationCount();
	} #endregion
	
	static getNextNodes = function() { #region
		LOG_BLOCK_START();	
		LOG_IF(global.FLAG.render == 1, "[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		LOG_IF(global.FLAG.render == 1, $"Loop restart: iteration {iterated}");
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, junc_in.node);
		iterated++;
		
		LOG_BLOCK_END();
		
		return _nodes;
	} #endregion
	
	static scanJunc = function() { #region
		var node_in  = PROJECT.nodeMap[? attributes.junc_in[0]];
		var node_out = PROJECT.nodeMap[? attributes.junc_out[0]];
		
		junc_in  = node_in?  node_in.inputs[| attributes.junc_in[1]]   : noone;
		junc_out = node_out? node_out.outputs[| attributes.junc_out[1]] : noone;
		
		if(junc_in)  { junc_in.value_from_loop = self;				addNode(junc_in.node);  }
		if(junc_out) { array_push(junc_out.value_to_loop, self);	addNode(junc_out.node); }
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
	
	static update = function() { #region
		iteration_count = inputs[| 0].getValue();
		iterated        = 0;
		value_buffer    = undefined;
	} #endregion
	
	static drawConnections = function(params = {}) { #region
		if(!active) return;
		if(!junc_in || !junc_out) return;
		if(!junc_in.node.active || !junc_out.node.active) return;
		
		if(drawJuncConnection(junc_out, junc_in, params, self))
			return self;
	} #endregion
	
	static postDeserialize = function() { #region
		refreshMember();
		scanJunc();
	} #endregion
	
	static onDestroy = function() { #region
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	} #endregion
}