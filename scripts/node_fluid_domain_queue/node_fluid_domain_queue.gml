function Node_Fluid_Domain_Queue(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name = "Queue Domain";
	previewable = false;
	
	w = 96;
	
	outputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
			.setVisible(true, true);
		
		return inputs[| index];
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static update = function() {
		for( var i = 0; i < ds_list_size(inputs) - 1; i++ ) {
			var _dom = inputs[| i].getValue();
			if(_dom != noone && instance_exists(_dom))
				outputs[| 0].setValue(_dom);
		}
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = 0; i < ds_list_size(_inputs); i++)
			createNewInput();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_fluidSim_domain_queue, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}