function NodeTool(name, spr, context = instanceof(other)) constructor {
	ctx = context;
	self.name   = name;
	self.spr    = spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
	static checkHotkey = function() {
		INLINE
		
		return getToolHotkey(ctx, name);
	}
	
	static getName = function(index = 0) {
		return is_array(name)? array_safe_get_fast(name, index, "") : name;
	}
	
	static getDisplayName = function(index = 0) {
		var _key = checkHotkey();
		
		var _nme = getName(index);
		if(_key != "") _nme += $" ({_key})";
		
		return _nme;
	}
	
	static setSetting = function(sets) { array_push(settings, sets); return self; }
	
	static addSetting = function(name, type, onEdit, keyAttr, val) {
		var w;
		
		switch(type) {
			case VALUE_TYPE.float : 
				w = new textBox(TEXTBOX_INPUT.number, onEdit);
				w.font = f_p3;
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
	
	static toggleKeyboard = function() {
		if(subtools == 0) {
			PANEL_PREVIEW.tool_current = PANEL_PREVIEW.tool_current == self? noone : self;
		} else if(PANEL_PREVIEW.tool_current != self) {
			PANEL_PREVIEW.tool_current = self;
			selecting = 0;
		} else if(selecting == subtools - 1) {
			PANEL_PREVIEW.tool_current = noone;
			selecting = 0;
		} else 
			selecting++;
		
		if(PANEL_PREVIEW.tool_current == self)
			onToggle();
	}
	
	static onToggle = function() {}
}