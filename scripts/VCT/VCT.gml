function VCT(node) constructor {
	self.node = node;
	panel	  = PanelVCT;
	vars	  = [];
	
	static reset = function() {
		for( var i = 0, n = array_length(vars); i < n; i++ )
			vars[i].set(vars[i].def_val);
	}
	
	static createDialog = function() {
		var pane = new panel(self);
		dialogPanelCall(pane);
	}
	
	static process = function(params) {}
	
	static serialize = function() { 
		var s = {};
		
		s.variables = [];
		for( var i = 0, n = array_length(vars); i < n; i++ )
			s.variables[i] = vars[i].get();
			
		doSerialize(s);
		return s; 
	}
	
	static doSerialize = function(s) {}
	
	static deserialize = function(load_arr) {
		var variables = load_arr.variables;
		var amo = min(array_length(variables), array_length(vars));
		for( var i = 0; i < amo; i++ ) 
			vars[i].set(variables[i]);
			
		doDeserialize(load_arr);
	}
	
	static doDeserialize = function(load_arr) {}
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