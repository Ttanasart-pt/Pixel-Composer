function NodeTool(name, spr, contextString = instanceof(other)) constructor {
	ctx         = contextString;
	context     = noone;
	
	self.name   = name;
	self.spr    = spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
	toolObject  = noone;
	toolFn      = noone;
	toolFnParam = {};
	
	hk_object   = noone;
	
	static checkHotkey   = function() { return getToolHotkey(ctx, name); }
	
	static setContext    = function(_c) { context    = _c; return self; }
	static setToolObject = function(_o) { toolObject = _o; return self; }
	static setToolFn     = function(_f) { toolFn     = _f; return self; }
	
	static getName = function(index = 0) { return is_array(name)? array_safe_get_fast(name, index, "") : name; }
	
	static getToolObject = function() { return is_array(toolObject)? toolObject[selecting] : toolObject; }
	
	static getDisplayName = function(index = 0) {
		var _nme = getName(index);
		var _key = checkHotkey();
		
		if(_key == noone) return _nme;
		return new tooltipHotkey(_nme).setKey(_key.getName());
	}
	
	static setSettings = function(_s) { for(var i = 0; i < array_length(_s); i++) array_push(settings, _s[i]);    return self; }
	static setSetting  = function(_s) { for(var i = 0; i < argument_count; i++) array_push(settings, argument[i]); return self; }
	
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
		if(toolFn != noone) {
			if(subtools == 0) toolFn(context);
			else              toolFn[index](context);
			return;
		}
		
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
			
		var _obj = getToolObject();
		if(_obj) _obj.init(context);
	}
	
	static toggleKeyboard = function() {
		HOTKEY_BLOCK = true;
		
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
			
		var _obj = getToolObject();
		if(_obj) _obj.init(context);
	}
	
	static rightClick = function() {
		hk_object = checkHotkey();
		if(hk_object == noone) return;
		
		var _menu = [
			getName(),
			menuItem(__txt("Edit hotkey"), function() /*=>*/ { PANEL_PREVIEW.hk_editing = self; keyboard_lastchar = hk_object.key; }),
		];
		
		menuCall("", _menu);
	}
	
	static onToggle    = function() {}
	static setOnToggle = function(_fn) { onToggle = _fn; return self; }
}