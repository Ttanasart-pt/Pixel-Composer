function Node_DynaSurf_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Input";
	color = COLORS.node_blend_dynaSurf;
	w    = 96;
	
	manual_deletable	 = false;
	destroy_when_upgroup = true;
	
	inParent = undefined;
	
	attributes.input_priority = group == noone? 0 : ds_list_size(group.inputs);
	array_push(attributeEditors, "Group");
	array_push(attributeEditors, ["Input Order", function() { return attributes.input_priority; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.input_priority = val; 
			group.setHeight();
			group.sortIO();
		})]);
		
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static createInput = function(override_order = true) { #region
		if(group == noone || !is_struct(group)) return noone;
		
		if(override_order)
			attributes.input_priority = ds_list_size(group.inputs);
		
		if(!is_undefined(inParent))
			ds_list_remove(group.inputs, inParent);
		
		inParent = nodeValue("Value", group, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
			.uncache()
			.setVisible(true, true);
		inParent.from = self;
		
		ds_list_add(group.inputs, inParent);
		group.setHeight();
		group.sortIO();
		
		return inParent;
	} #endregion
	
	if(!LOADING && !APPENDING) createInput();
	
	static step = function() { #region
		if(is_undefined(inParent)) return;
		
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[? string_replace_all(display_name, " ", "_")] = inParent;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) {
		if(is_undefined(inParent)) return;
		var _val = inParent.getValue();
		
		outputs[| 0].setValue(new __funcTree("", _val));
	}
	
	static postDeserialize = function() { #region
		createInput(false);
	} #endregion
}