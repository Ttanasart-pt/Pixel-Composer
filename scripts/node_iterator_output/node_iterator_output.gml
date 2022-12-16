function Node_Iterator_Output(_x, _y, _group = -1) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Output";
	color = COLORS.node_blend_loop;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	inputs[| 2] = nodeValue(2, "Loop exit", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, -1)
		.setVisible(true, true);
	
	cache_value = -1;
	
	static getNextNodes = function() {
		var _node_it = group;
		var _ren = _node_it.iterationStatus();
			
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(group.iterated));
			__nodeLeafList(group.nodes, RENDER_STACK);
			var loopEnt = inputs[| 2].value_from.node;
			ds_stack_push(RENDER_STACK, loopEnt);
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			var _ot = outParent;
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
					_to.node.triggerRender();
					if(_to.node.isUpdateReady()) ds_stack_push(RENDER_STACK, _to.node);
				}
			}
		} else 
			printIf(global.RENDER_LOG, "    > Loop not ready");
	}
	
	static initLoop = function() {
		cache_value = noone;
	}
	
	static update = function() {
		var _val_get = inputs[| 0].getValue();
		
		switch(inputs[| 0].type) {
			case VALUE_TYPE.surface	: 
				if(is_surface(cache_value)) 
					surface_free(cache_value);
				if(is_surface(_val_get))
					cache_value = surface_clone(_val_get);
				printIf(global.RENDER_LOG, "LOOP cache result");
				break;
			default : 
				cache_value = _val_get;
		}
	}
}