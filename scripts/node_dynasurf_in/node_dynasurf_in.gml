function Node_DynaSurf_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Input";
	color = COLORS.node_blend_dynaSurf;
	setDimension(96, 48);
	
	manual_deletable	 = false;
	destroy_when_upgroup = true;
	
	inParent = undefined;
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.PCXnode, noone));
	
	static createInput = function() { #region
		if(group == noone || !is_struct(group)) return noone;
		
		if(!is_undefined(inParent))
			array_remove(group.inputs, inParent);
		
		inParent = new __NodeValue_Surface("Value", group)
			.uncache()
			.setVisible(true, true);
		inParent.from = self;
		
		array_push(group.inputs, inParent);
		group.refreshNodeDisplay();
		group.sortIO();
		
		return inParent;
	} #endregion
	
	if(!LOADING && !APPENDING) createInput();
	
	static step = function() { #region
		if(is_undefined(inParent)) return;
		
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[$ string_replace_all(display_name, " ", "_")] = inParent;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(is_undefined(inParent)) return;
		var _val = inParent.getValue();
		
		outputs[0].setValue(new __funcTree("", _val));
	} #endregion
	
	static postDeserialize = function() { #region
		createInput(false);
	} #endregion
	
	static postApplyDeserialize = function() { #region
		if(group == noone) return;
		group.sortIO();
	} #endregion
	
}