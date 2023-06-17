function NodeTool(name, spr) constructor {
	self.name = name;
	self.spr  = spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
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
	
	static toggle = function() {
		if(subtools == 0) {
			PANEL_PREVIEW.tool_current = PANEL_PREVIEW.tool_current == self? noone : self;
		} else {
			if(PANEL_PREVIEW.tool_current != self) {
				PANEL_PREVIEW.tool_current = self;
				selecting = 0;
				return;
			}
			
			selecting++;
			if(selecting == subtools) {
				selecting = 0;
				PANEL_PREVIEW.tool_current = noone;
			} else 
				PANEL_PREVIEW.tool_current = self;
		}
		
		if(PANEL_PREVIEW.tool_current == self)
			onToggle();
	}
	
	static onToggle = function() {}
}