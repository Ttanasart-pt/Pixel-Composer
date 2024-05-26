function widget() constructor {
	active  = false;
	hover   = false;
	hovering= false;
	iactive = false;
	ihover  = false;
	parent  = noone;
	interactable = true;
	
	right_click_block = true;
	
	side_button  = noone;
	front_button = noone;
	
	hide = false;
	
	lua_thread = noone;
	lua_thread_key = "";
	
	font = f_p0;
	
	x = 0; 
	y = 0;
	w = 0; 
	h = 0;
	
	rx = 0;
	ry = 0;
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) { #region
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onModify = method(self, _lua_func);
	} #endregion
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		if(!interactable) return;
		
		array_push(WIDGET_ACTIVE, self); 
		self.parent = parent;
	} #endregion
	
	static setParam = function(params) { #region
		font = params.font;
		rx   = params.rx;
		ry   = params.ry;
	} #endregion
	
	static trigger = function() { }
	
	static parentFocus = function() { #region
		if(parent == noone) return;
		
		if(y < 0)
			parent.scroll_y_to += abs(y) + ui(16);
		else if(y + ui(16) > parent.surface_h)
			parent.scroll_y_to -= abs(parent.surface_h - y) + h + ui(16);
	} #endregion
	
	static isHovering = function() { return hovering; }
	
	static activate = function() { #region
		if(!interactable) return;
		
		WIDGET_CURRENT = self;
		WIDGET_CURRENT_SCROLL = parent;
		parentFocus();
	} #endregion
	
	static deactivate = function() { #region
		if(WIDGET_CURRENT != self) return;
		WIDGET_CURRENT = noone;
		WIDGET_CURRENT_SCROLL = noone;
	} #endregion
	
	static setFocusHover = function(active = false, hover = false) { #region
		self.active  = interactable && active;
		self.hover   = interactable && hover;
		self.iactive = active;
		self.ihover  = hover;
	} #endregion
	
	static resetFocus = function() { #region
		active = false;
		hover  = false;
	} #endregion
	
	static clone = function() { return variable_clone(self); }
	
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