function NodeTool(_name = "", _spr = noone, _contextString = instanceof(other)) constructor {
	ctx       = _contextString;
	context   = noone;
	
	name      = _name;
	spr       = _spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
	toolObject  = noone;
	toolFn      = noone;
	toolFnParam = {};
	
	hk_object   = noone;
	visible     = true;
	
	////- Get Set
	
	static checkHotkey   = function() /*=>*/ {return getToolHotkey(ctx, getName())};
	
	static setContext    = function(_c) /*=>*/ { context    = _c; return self; }
	static setToolObject = function(_o) /*=>*/ { toolObject = _o; return self; }
	static setToolFn     = function(_f) /*=>*/ { toolFn     = _f; return self; }
	static setVisible    = function(_v) /*=>*/ { visible    = _v; return self; }
	
	static getName        = function(index = 0) { return is_array(name)? array_safe_get_fast(name, index, "") : name; }
	static getToolObject  = function() { return is_array(toolObject)? toolObject[selecting] : toolObject; }
	static getDisplayName = function(index = 0) {
		var _nme = getName(index);
		var _key = checkHotkey();
		
		if(_key == noone) return _nme;
		return new tooltipKey(_nme, _key.getName());
	}
	
	////- Settings
	
	static setSettings = function(_s) { for(var i = 0; i < array_length(_s); i++) array_push(settings, _s[i]);       return self; }
	static setSetting  = function(_s) { for(var i = 0; i < argument_count; i++)   array_push(settings, argument[i]); return self; }
	
	static addSetting = function(_name, type, onEdit, keyAttr, val) {
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
		
		array_push(settings, [ _name, w, keyAttr, attribute ]);
		attribute[$ keyAttr] = val;
		
		return self;
	}
	
	////- Toggle
	
	static toggle = function(index = 0) {
		if(toolFn != noone) {
			if(subtools == 0) toolFn(context);
			else              toolFn[index](context);
			return;
		}
		
		if(subtools == 0) {
			if(PANEL_PREVIEW.getTool() == self) PANEL_PREVIEW.resetTool();
			else PANEL_PREVIEW.setTool(self);
			
		} else {
			if(PANEL_PREVIEW.getTool() == self && index == selecting) {
				PANEL_PREVIEW.resetTool();
				selecting = 0;
			} else {
				PANEL_PREVIEW.setTool(self);
				selecting = index;
			}
		}
		
		if(onToggle != undefined && PANEL_PREVIEW.getTool() == self)
			onToggle();
			
		var _obj = getToolObject();
		if(_obj) _obj.init(context);
	}
	
	static toggleKeyboard = function() {
		HOTKEY_BLOCK = true;
		
		if(subtools == 0) {
			if(PANEL_PREVIEW.getTool() == self) PANEL_PREVIEW.resetTool();
			else PANEL_PREVIEW.setTool(self);
			
		} else if(PANEL_PREVIEW.getTool() != self) {
			PANEL_PREVIEW.setTool(self);
			selecting = 0;
			
		} else if(selecting == subtools - 1) {
			PANEL_PREVIEW.resetTool();
			selecting = 0;
			
		} else 
			selecting++;
		
		if(onToggle != undefined && PANEL_PREVIEW.getTool() == self)
			onToggle();
			
		var _obj = getToolObject();
		if(_obj) {
			_obj.init(context);
			_obj.initKeyboard();
		}
	}
	
	static onToggle    = undefined
	static setOnToggle = function(_fn) /*=>*/ { onToggle = _fn; return self; }
	
	static rightClick = function() {
		hk_object = checkHotkey();
		if(hk_object == noone) return;
		
		var _menu = [
			getName(),
			menuItem(__txt("Edit Hotkey"),  function() /*=>*/ { PANEL_PREVIEW.hk_editing = self; keyboard_lastchar = hk_object.key; }),
			menuItem(__txt("Reset Hotkey"), function() /*=>*/ {return hk_object.reset(true)}, THEME.refresh_20).setActive(hk_object.isModified()),
		];
		
		menuCall("", _menu);
	}
	
}

function ToolObject() constructor {
	node = noone;
	
	////- GetSet
	
	static setNode = function(_n) /*=>*/ { node = _n; return self; }
	
	////- Draw
	
	static drawOverlay   = function(hover, active, _x, _y, _s, _mx, _my ) /*=>*/ {}
	static drawOverlay3D = function(active, _mx, _my, _params) /*=>*/ {}
	
	////- Actions
	
	static step = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {}
	
	static init         = function() /*=>*/ {}
	static initKeyboard = function() /*=>*/ {}
	
	////- Disable
	
	static escapable = function() /*=>*/ {return true}
	static disable   = function() /*=>*/ {}
	static onDisable = function() /*=>*/ {}
	
}