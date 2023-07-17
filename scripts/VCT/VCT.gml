function VCT(node) constructor {
	self.node = node;
	panel	  = PanelVCT;
	vars	  = [];
	
	static reset = function() {
		for( var i = 0; i < array_length(vars); i++ )
			vars[i].set(vars[i].def_val);
	}
	
	static createDialog = function() {
		var pane = new panel(self);
		dialogPanelCall(pane);
	}
	
	static process = function(params) {}
	
	static serialize = function() { 
		var s = [];
		for( var i = 0; i < array_length(vars); i++ )
			s[i] = vars[i].get();
		return s; 
	}
	
	static deserialize = function(load_arr) {
		var amo = min(array_length(load_arr), array_length(vars));
		for( var i = 0; i < amo; i++ ) 
			vars[i].set(load_arr[i]);
	}
}

function PanelVCT(vct) : PanelContent() constructor {
	self.vct = vct;
	title = "VCT";
	
	w = ui(480);
	h = ui(320);
	resizable = false;
	
	function drawContent(panel) {}
}

function VCT_var(type, val) {
	var v = new __VCT_var(self, type, val);
	array_append(vars, v);
	return v;
}

function __VCT_var(vct, type, val) constructor {
	self.vct  = vct;
	self.type = type;
	self.val  = val;
	def_val   = val;
	
	disp	  = VALUE_DISPLAY._default;
	disp_data = 0;
	
	static setDisplay = function(disp, disp_data = 0) {
		self.disp = disp;
		self.disp_data = disp_data;
		
		return self;
	}
	
	static update = function() { vct.node.triggerRender(); }
	
	static setDirect = function(val) { if(val == undefined) return; self.val = val; }
	
	static set = function(val, _update = true) { 
		if(val == undefined) return; 
		self.val = val; 
		if(_update) update();
	}
	static get = function() { return val; }
}