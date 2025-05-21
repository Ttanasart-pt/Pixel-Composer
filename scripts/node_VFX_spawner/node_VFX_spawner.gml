function Node_VFX_Spawner(_x, _y, _group = noone) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name   = "Spawner";
	color  = COLORS.node_blend_vfx;
	icon   = THEME.vfx;
	reloop = true;
	manual_ungroupable = false;
	
	attributes.Output_pool = false;
	array_push(attributeEditors, ["Output all particles", function() /*=>*/ {return attributes.Output_pool}, new checkBox(function() /*=>*/ {return toggleAttribute("Output_pool")}) ]);
	
	newInput(input_len + 0, nodeValue("Spawn trigger", self, CONNECT_TYPE.input, VALUE_TYPE.node, false))
		.setVisible(true, true);
	
	newInput(input_len + 1, nodeValue_Int("Step interval", 1, "How often the 'on step' event is triggered.\nWith 1 being trigger every frame, 2 means triggered once every 2 frames."));
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, [] ));
	newOutput(1, nodeValue_Output("On create", VALUE_TYPE.node, noone ));
	newOutput(2, nodeValue_Output("On step", VALUE_TYPE.node, noone ));
	newOutput(3, nodeValue_Output("On destroy", VALUE_TYPE.node, noone ));
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()}, input_len);
	
	array_insert(input_display_list, 0, ["Trigger", true], input_len + 0, input_len + 1);
	
	UPDATE_PART_FORWARD
	junction_tos = array_create(array_length(outputs));
	
	static getDimension = function() /*=>*/ {return inline_context.dimension};
	
	static onUpdate = function(frame = CURRENT_FRAME) {
		
		#region visibility
			var _ntTrig = inputs[input_len + 0].value_from == noone;
			
			inputs[16].setVisible(_ntTrig);
			inputs[ 1].setVisible(_ntTrig);
			inputs[51].setVisible(_ntTrig);
			
			if(_ntTrig) {
				inputs[30].setVisible(false);
				inputs[55].setVisible(false);
			}
		#endregion
		
		if(IS_PLAYING) runVFX(frame);
		if(attributes.Output_pool) { outputs[0].setValue(parts); return; } 
		
		var _parts = [];
		for( var i = 0, n = array_length(parts); i < n; i++ ) {
			if(!parts[i].active) continue;
			array_push(_parts, parts[i]);
		}
		
		outputs[0].setValue(_parts);
		
		for( var i = 1; i <= 3; i++ ) junction_tos[i] = outputs[i].getJunctionTo();
	}
	
	static onSpawn = function(_time, part) {
		part.step_int = inputs[input_len + 1].getValue(_time);
	}
	
	static onPartCreate = function(part) {
		var jn = junction_tos[1];
		var pv = part.getPivot();
		
		for( var i = 0, n = array_length(jn); i < n; i++ )
			jn[i].node.spawn(part.frame, pv);
	}
	
	static onPartStep = function(part) {
		var jn = junction_tos[2];
		var pv = part.getPivot();
		
		for( var i = 0, n = array_length(jn); i < n; i++ )
			jn[i].node.spawn(part.frame, pv);
	}
	
	static onPartDestroy = function(part) {
		var jn = junction_tos[3];
		var pv = part.getPivot();
		
		for( var i = 0, n = array_length(jn); i < n; i++ )
			jn[i].node.spawn(part.frame, pv);
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getInputData(0)};
	static getPreviewingNode      = function() /*=>*/ {return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self};
	static getPreviewValues       = function() /*=>*/ {return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self};
}