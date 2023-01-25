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
			__nodeLeafList(group.nodes, RENDER_QUEUE);
			var loopEnt = inputs[| 2].value_from.node;
			ds_queue_enqueue(RENDER_QUEUE, loopEnt);
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			printIf(global.RENDER_LOG, "    > Loop completed");
			group.setRenderStatus(true);
			var _ot = outParent;
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == group) {
					_to.node.triggerRender();
					if(_to.node.isUpdateReady()) ds_queue_enqueue(RENDER_QUEUE, _to.node);
				}
			}
		} else 
			printIf(global.RENDER_LOG, "    > Loop not ready");
	}
	
	static initLoop = function() {
		cache_value = noone;
	}
	
	static update = function() {
		if(inputs[| 0].value_from == noone) return;
		
		var _val_get = inputs[| 0].getValue();
		var _arr     = inputs[| 0].value_from.isArray();
		var is_surf	 = inputs[| 0].type == VALUE_TYPE.surface;
		
		if(is_array(cache_value)) {
			for( var i = 0; i < array_length(cache_value); i++ ) {
				if(is_surface(cache_value[i])) 
					surface_free(cache_value[i]);
			}
		} else if(is_surface(cache_value)) 
			surface_free(cache_value);
		
		if(_arr) {
			var amo  = array_length(_val_get);
			cache_value = array_create(amo);
			
			if(is_surf) {
				for( var i = 0; i < amo; i++ ) {
					if(is_surface(_val_get[i]))	
						cache_value[i] = surface_clone(_val_get[i]);
				}
			} else 
				cache_value = _val_get;
		} else {
			if(is_surf) {
				if(is_surface(_val_get))	
					cache_value = surface_clone(_val_get);
			} else
				cache_value = _val_get;
		}
	}
}