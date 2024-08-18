function Node_VFX_Spawner(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name   = "Spawner";
	color  = COLORS.node_blend_vfx;
	icon   = THEME.vfx;
	reloop = true;
	
	manual_ungroupable	 = false;
	
	attributes.Output_pool = false;
	array_push(attributeEditors, ["Output all particles", function() { return attributes.Output_pool; },
		new checkBox(function() { attributes.Output_pool = !attributes.Output_pool; }) ]);
	
	inputs[21].setVisible(false, false);
	
	inputs[input_len + 0] = nodeValue("Spawn trigger", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, false)
		.setVisible(true, true);
	
	newInput(input_len + 1, nodeValue_Int("Step interval", self, 1, "How often the 'on step' event is triggered.\nWith 1 being trigger every frame, 2 means triggered once every 2 frames."));
	
	outputs[0] = nodeValue_Output("Particles",	self, VALUE_TYPE.particle, [] );
	outputs[1] = nodeValue_Output("On create",	self, VALUE_TYPE.node, noone );
	outputs[2] = nodeValue_Output("On step",		self, VALUE_TYPE.node, noone );
	outputs[3] = nodeValue_Output("On destroy",	self, VALUE_TYPE.node, noone );
	
	array_insert(input_display_list, 0, ["Trigger", true], input_len + 0, input_len + 1);
	
	UPDATE_PART_FORWARD
	
	static onUpdate = function(frame = CURRENT_FRAME) {
		if(IS_PLAYING) runVFX(frame);
		
		if(attributes.Output_pool) {
			outputs[0].setValue(parts);
			return;
		} else {
			var _parts = [];
			for( var i = 0, n = array_length(parts); i < n; i++ ) {
				if(!parts[i].active) continue;
				array_push(_parts, parts[i]);
			}
			outputs[0].setValue(_parts);
		}
	}
	
	static onSpawn = function(_time, part) {
		part.step_int = inputs[input_len + 1].getValue(_time);
	}
	
	static onPartCreate = function(part) {
		var vt = outputs[1];
		if(array_empty(vt.value_to)) return;
		
		var pv = part.getPivot();
		
		for( var i = 0; i < array_length(vt.value_to); i++ ) {
			var _n = vt.value_to[i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(part.frame, pv);
		}
	}
	
	static onPartStep = function(part) {
		var vt = outputs[2];
		if(array_empty(vt.value_to)) return;
		
		var pv = part.getPivot();
		
		for( var i = 0; i < array_length(vt.value_to); i++ ) {
			var _n = vt.value_to[i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(part.frame, pv);
		}
	}
	
	static onPartDestroy = function(part) {
		var vt = outputs[3];
		if(array_empty(vt.value_to)) return;
		
		var pv = part.getPivot();
			
		for( var i = 0; i < array_length(vt.value_to); i++ ) {
			var _n = vt.value_to[i];
			if(_n.value_from != vt) continue;
			_n.node.spawn(part.frame, pv);
		}
	}
	
	static getGraphPreviewSurface = function() { return getInputData(0); }
		
	getPreviewingNode = VFX_PREVIEW_NODE;
}