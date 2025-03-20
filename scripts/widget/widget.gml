function widget() constructor {
	active   = false;
	hover    = false;
	hovering = false;
	
	iactive  = false;
	ihover   = false;
	
	temp_hovering = false;
	
	parent   = noone;
	keyframe = noone;
	interactable = true;
	
	hover_content = false;
	
	right_click_block = true;
	
	side_button  = noone;
	front_button = noone;
	
	hide = false;
	
	lua_thread = noone;
	lua_thread_key = "";
	
	font     = f_p1;
	sep_axis = false;
	unit     = noone;
	
	boxColor = c_white;
	
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
	
	static setInteract = function(_i = noone) /*=>*/ { interactable = _i; return self; }
	static setFont     = function(_f = noone) /*=>*/ { font = _f;         return self; }
	
	static register = function(parent = noone) {
		if(!interactable) return;
		
		array_push(WIDGET_ACTIVE, self); 
		self.parent = parent;
	}
	
	static setParam = function(params) {
		font = params.font;
		rx   = params.rx;
		ry   = params.ry;
		
		sep_axis = params.sep_axis;
		boxColor = params.color;
		
		if(!is_undefined(params.interact))
			setInteract(params.interact);
			
		if(!is_undefined(params.focus))
			setFocusHover(params.focus, params.hover);
			
		if(!is_undefined(params.scrollpane) && inBBOX(params.m)) {
			register(params.scrollpane);
			params.scrollpane.hover_content = true;
		}
	}
	
	static trigger = function() { }
	
	static parentFocus = function() {
		if(parent == noone) return;
		
		if(y < 0)
			parent.scroll_y_to += abs(y) + ui(16);
		else if(y + ui(16) > parent.surface_h)
			parent.scroll_y_to -= abs(parent.surface_h - y) + h + ui(16);
	}
	
	static isHovering = function() { return hovering; }
	
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
	
	static inBBOX    = function(_m) { return point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h); }
	static clone     = function()   { return struct_clone(self); }
	
	static drawParam = function(params) {}
	static draw      = function() {}
	
	static free = function() {}
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
	
	self.font       = f_p1;
	
	color    = c_white;
	sep_axis = false;
	
	focus      = undefined;
	hover      = undefined;
	interact   = undefined;
	scrollpane = undefined;
	
	static setX          = function(_x) /*=>*/ { x    = _x;      return self; }
	static setY          = function(_y) /*=>*/ { y    = _y;      return self; }
	static setS          = function(_s) /*=>*/ { s    = _s;      return self; }
	static setData       = function( d) /*=>*/ { data  = d;      return self; }
	static setColor      = function( c) /*=>*/ { color = c;      return self; }
	static setFont       = function( f) /*=>*/ { font  = f;      return self; }
	static setScrollpane = function( s) /*=>*/ { scrollpane = s; return self; }
	
	static setFocusHover = function(f, h, i = undefined) { 
		focus = f; 
		hover = h; 
		interact = i; 
		return self; 
	}
}