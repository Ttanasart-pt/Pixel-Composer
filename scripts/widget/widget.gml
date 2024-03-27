function widget() constructor {
	active  = false;
	hover   = false;
	iactive = false;
	ihover  = false;
	parent  = noone;
	interactable = true;
	side_button  = noone;
	
	lua_thread = noone;
	lua_thread_key = "";
	
	font = f_p0;
	
	x = 0; 
	y = 0;
	w = 0; 
	h = 0;
	
	rx = 0;
	ry = 0;
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) { 
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onModify = method(self, _lua_func);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
	}
	
	static register = function(parent = noone) { 
		if(!interactable) return;
		
		array_push(WIDGET_ACTIVE, self); 
		self.parent = parent;
	}
	
	static setParam = function(params) { #region
		font = params.font;
		rx   = params.rx;
		ry   = params.ry;
	} #endregion
	
	static trigger = function() { }
	
	static parentFocus = function() {
		if(parent == noone) return;
		
		if(y < 0)
			parent.scroll_y_to += abs(y) + ui(16);
		else if(y + ui(16) > parent.surface_h)
			parent.scroll_y_to -= abs(parent.surface_h - y) + h + ui(16);
	}
	
	static activate = function() { 
		if(!interactable) return;
		
		WIDGET_CURRENT = self;
		WIDGET_CURRENT_SCROLL = parent;
		parentFocus();
	}
	
	static deactivate = function() { 
		if(WIDGET_CURRENT != self) return;
		WIDGET_CURRENT = noone;
		WIDGET_CURRENT_SCROLL = noone;
	}
	
	static setFocusHover = function(active = false, hover = false) {
		self.active  = interactable && active;
		self.hover   = interactable && hover;
		self.iactive = active;
		self.ihover  = hover;
	}
	
	static resetFocus = function() {
		active = false;
		hover  = false;
	}
	
	static drawParam = function(params) {}
	static draw = function() {}
}

function widgetParam(x, y, w, h, data, display_data = {}, m = mouse_ui, rx = 0, ry = 0) constructor {
	self.x = x;
	self.y = y;
	
	self.w			= w;
	self.h			= h;
	self.s			= ui(24);
	self.data		= data;
	self.m			= m;
	self.rx			= rx;
	self.ry			= ry;
	
	self.halign		= fa_left;
	self.valign		= fa_top;
	
	self.display_data = display_data;
	
	self.font       = f_p0;
}