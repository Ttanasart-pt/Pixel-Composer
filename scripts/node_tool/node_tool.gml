function NodeTool(name, spr) constructor {
	self.name = name;
	self.spr  = spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
	static getName = function(index = 0) {
		if(is_array(name)) return array_safe_get(name, index, "");
		return name;
	}
	
	static addSetting = function(name, type, onEdit, keyAttr, val) {
		var w;
		
		switch(type) {
			case VALUE_TYPE.float : 
				w = new textBox(TEXTBOX_INPUT.number, onEdit);
				w.font = f_p2;
				break;
			case VALUE_TYPE.boolean : 
				w = new checkBox(onEdit);
				break;
		}
		
		array_push(settings, [ name, w, keyAttr, attribute ]);
		attribute[$ keyAttr] = val;
		
		return self;
	}
	
	static toggle = function(index = 0) {
		if(subtools == 0) {
			PANEL_PREVIEW.tool_current = PANEL_PREVIEW.tool_current == self? noone : self;
		} else {
			if(PANEL_PREVIEW.tool_current == self && index == selecting) {
				PANEL_PREVIEW.tool_current = noone;
				selecting = 0;
			} else {
				PANEL_PREVIEW.tool_current = self;
				selecting = index;
			}
		}
		
		if(PANEL_PREVIEW.tool_current == self)
			onToggle();
	}
	
	static onToggle = function() {}
}