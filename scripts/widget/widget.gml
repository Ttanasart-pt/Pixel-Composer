function widget() constructor {
	active  = false;
	hover   = false;
	iactive = false;
	ihover  = false;
	parent = noone;
	interactable = true;
	
	x = 0; 
	y = 0;
	w = 0; 
	h = 0;
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
	}
	
	static register = function(parent = noone) { 
		if(!interactable) return;
		
		array_push(WIDGET_ACTIVE, self); 
		self.parent = parent;
	}
	
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
	
	static setActiveFocus = function(active = false, hover = false) {
		self.active  = interactable && active;
		self.hover   = interactable && hover;
		self.iactive = active;
		self.ihover  = hover;
	}
	
	static resetFocus = function() {
		active = false;
		hover  = false;
	}
}