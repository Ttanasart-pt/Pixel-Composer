globalvar GROUP_IO_TYPE_NAME, GROUP_IO_TYPE_MAP, GROUP_IO_DISPLAY;

#region data
	GROUP_IO_TYPE_NAME = [	"Integer",				"Float",				"Boolean",				"Color",				"Surface", 
							"File Path",			"Curve",				"Text",					"Object",				"Node", 
							-1,						"Any",					"Path",					"Particle", 			"Rigidbody Object", 
							"Domain",				"Struct",				"Strands",				"Mesh",					"Trigger",
							
							-1,						"3D Mesh",				"3D Light",				"3D Camera",			"3D Scene",	
							"3D Material",  		-1,						"PCX",					"Audio",				"Fluid Domain", 
							"SDF",
						 ];
	
	GROUP_IO_TYPE_MAP  = [	VALUE_TYPE.integer,		VALUE_TYPE.float,		VALUE_TYPE.boolean,		VALUE_TYPE.color,		VALUE_TYPE.surface, 
							VALUE_TYPE.path,		VALUE_TYPE.curve,		VALUE_TYPE.text,		VALUE_TYPE.object,		VALUE_TYPE.node, 
							noone,					VALUE_TYPE.any,			VALUE_TYPE.pathnode,	VALUE_TYPE.particle,	VALUE_TYPE.rigid, 
							VALUE_TYPE.sdomain,		VALUE_TYPE.struct,		VALUE_TYPE.strands,		VALUE_TYPE.mesh,		VALUE_TYPE.trigger,
							
							noone,					VALUE_TYPE.d3Mesh,		VALUE_TYPE.d3Light,		VALUE_TYPE.d3Camera,	VALUE_TYPE.d3Scene,		
							VALUE_TYPE.d3Material,  noone,					VALUE_TYPE.PCXnode,		VALUE_TYPE.audioBit,	VALUE_TYPE.fdomain,
							VALUE_TYPE.sdf,
						 ];
	
	GROUP_IO_DISPLAY = [
		
	/*Integer*/	    [ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area", "Enum button", "Menu scroll" ],
	/*Float*/	    [ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
	/*Boolean*/	    [ "Default" ],
	/*Color*/	    [ "Default", "Gradient", "Palette" ],
	/*Surface*/	    [ "Default" ],
	    
	/*Path*/	    [ "Default" ],
	/*Curve*/	    [ "Curve",  ],
	/*Text*/	    [ "Default" ],
	/*Object*/	    [ "Default" ],
	/*Node*/	    [ "Default" ],
	    
	/*3D*/		    [ "Default" ],
	/*Any*/		    [ "Default" ],
	/*Pathnode*/    [ "Default" ],
	/*Particle*/    [ "Default" ],
	/*Rigid*/	    [ "Default" ],
	    
	/*Sdomain*/	    [ "Default" ],
	/*Struct*/	    [ "Default" ],
	/*Strand*/	    [ "Default" ],
	/*Mesh*/	    [ "Default" ],
	/*Trigger*/	    [ "Default" ],
	
	//=========================//
	
	/*Noone*/	    [ "Default" ],
	/*3D Mesh*/     [ "Default" ],
	/*3D Light*/    [ "Default" ],
	/*3D Camera*/   [ "Default" ],
	/*3D Scene*/    [ "Default" ],
	
	/*3D Material*/ [ "Default" ],
	/*noone*/	    [ "Default" ],
	/*PCX*/         [ "Default" ],
	/*Audio*/       [ "Default" ],
	/*Fdomain*/     [ "Default" ],
	
	/*SDF*/         [ "Default" ],
	
	];
#endregion

function Node_Group_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name         = "Group Input";
	color        = COLORS.node_blend_collection;
	preview_draw = false;
	is_group_io  = true;
	inParent     = undefined;
	
	destroy_when_upgroup = true;
	
	skipDefault();
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue_Enum_Scroll("Display type", self,  0, { data: GROUP_IO_DISPLAY[11], update_hover: false }));
	
	newInput(1, nodeValue_Range("Range", self, [ 0, 1 ]))
		.setVisible(false);
	
	newInput(2, nodeValue_Enum_Scroll("Input type", self,  11, { data: GROUP_IO_TYPE_NAME, update_hover: false }));
	
	newInput(3, nodeValue_Text("Enum label", self, ""))
		.setVisible(false);
	
	newInput(4, nodeValue_Enum_Button("Vector size", self,  0, [ "2", "3", "4" ]))
		.setVisible(false);
	
	newInput(5, nodeValue_Int("Order", self, 0));
	
	newInput(6, nodeValue_Bool("Display preview gizmo", self, true));
		
	newInput(7, nodeValue_Float("Step", self, 0.01))
		.setVisible(false);
		
	newInput(8, nodeValue_Text("Button Label", self, "Trigger"))
		.setVisible(false);
	
	newInput(9, nodeValue_Enum_Scroll("Visible Condition", self,  0, [ "Show", "Hide", /* 2 */ new scrollItem("Equal",              s_node_condition_type, 0), 
												        		                       /* 3 */ new scrollItem("Not equal",          s_node_condition_type, 1), 
												        		                       /* 4 */ new scrollItem("Greater ",           s_node_condition_type, 4), 
												        		                       /* 5 */ new scrollItem("Greater or equal",   s_node_condition_type, 5), 
												        		                       /* 6 */ new scrollItem("Lesser",             s_node_condition_type, 2), 
												        		                       /* 7 */ new scrollItem("Lesser or equal",    s_node_condition_type, 3), ]));
	
	newInput(10, nodeValue_Float("Visible Check", self, 0));
	
	newInput(11, nodeValue_Float("Visible Check To", self, 0));
	
	inputs[10].setFrom_condition = function(_valueFrom) {
		if(is_instanceof(_valueFrom.node, Node_Group_Input)) return true;
		noti_warning("Group IO visibility must be connected directly to another group input.",, self);
		return false;
	}
	
	for( var i = 0, n = array_length(inputs); i < n; i++ )
		inputs[i].uncache().rejectArray();
		
	input_display_list = [ 
		["Display", false], 6, 9, 10, 11, 
		["Data",	false], 2, 0, 4, 1, 7, 3, 8, 
	];
	
	newOutput(0, nodeValue_Output("Value", self, VALUE_TYPE.any, 0))
		.uncache();
	
	attributes.inherit_name = true;
	attributes.inherit_type = true;
	doTrigger = 0;
	
	dtype  = -1;
	range  = 0;
	
	onSetDisplayName = function() { attributes.inherit_name = false; }
	
	outputs[0].onSetTo = function(juncTo) {
		if(attributes.inherit_name && !LOADING && !APPENDING)
			setDisplayName(juncTo.name);
		
		if(!attributes.inherit_type) return;
		attributes.inherit_type = false;
		
		var ind = array_find(GROUP_IO_TYPE_MAP, juncTo.type);
		if(ind == -1) return;
		
		if(ind == inputs[2].getValue()) return;
		
		outputs[0].setType(juncTo.type);
		inputs[2].setValue(ind);
	}
	
	static createInput = function() {
		if(group == noone || !is_struct(group)) return noone;
				
		if(!is_undefined(inParent))
			array_remove(group.inputs, inParent);
		
		inParent = nodeValue("Value", group, CONNECT_TYPE.input, VALUE_TYPE.any, -1)
			.uncache()
			.setVisible(true, true);
		
		inParent.from = self;
		inParent.index = array_length(group.inputs);
		
		array_push(group.inputs, inParent);
		if(is_array(group.input_display_list))
			array_push(group.input_display_list, inParent.index);
		
		if(!LOADING && !APPENDING) {
			group.refreshNodeDisplay();
			group.sortIO();
		}
			
		onValueUpdate(0);
		
		return inParent;
	} 
	
	////- Render
	
	static isRenderable = function(log = false) { //Check if every input is ready (updated)
		if(!active)	return false;
		if(!isRenderActive()) return false;
		
		for(var j = 0; j < 9; j++) if(!inputs[j].isRendered()) return false;
		return true;
	}
	
	static visibleCheck = function() {
		var _vty = inputs[ 9].getValue();
		
		inputs[10].setVisible(_vty >= 2, _vty >= 2);
		inputs[11].setVisible(_vty >= 2);
		
		var _val = inputs[10].getValue();
		var _vto = inputs[11].getValue();
		var _vis = true;
		
		switch(_vty) {
			case 0 : _vis =  true; break;
			case 1 : _vis = false; break;
				
			case 2 : _vis = _val == _vto; break;
			case 3 : _vis = _val != _vto; break;
			
			case 4 : _vis = _val >  _vto; break;
			case 5 : _vis = _val >= _vto; break;
			
			case 6 : _vis = _val <  _vto; break;
			case 7 : _vis = _val <= _vto; break;
		}
		
		var _v = inParent.visible;
		if(_v && !_vis) inParent.visible = false;
		inParent.show_in_inspector = _vis;
		
		if(_v != _vis) {
			group.setHeight();
			group.getJunctionList();
		}
	}
	
	static onValueUpdate = function(index = 0) {
		if(is_undefined(inParent)) return;
		
		var _dtype	    = getInputData(0);
		var _range	    = getInputData(1);
		var _type		= getInputData(2);
		var _val_type   = array_safe_get_fast(GROUP_IO_TYPE_MAP, _type, VALUE_TYPE.any);
		var _enum_label = getInputData(3);
		var _vec_size	= getInputData(4);
		var _step		= getInputData(7);
		
		if(index == 2) {
			if(outputs[0].type != _val_type) {
				var _o = outputs[0];
				for(var j = 0; j < array_length(_o.value_to); j++) {
					var _to = _o.value_to[j];
					if(_to.value_from == _o)
						_to.removeFrom();
				}
			}
			
			inputs[0].setValue(0);
			attributes.inherit_type = false;
		}
		
		_dtype = array_safe_get_fast(array_safe_get_fast(GROUP_IO_DISPLAY, _val_type), _dtype);
		
		inParent.setType(_val_type);
		outputs[0].setType(_val_type);
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case "Range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
					
				inParent.def_val = [0, 0];
				inParent.setDisplay(VALUE_DISPLAY.range); 
				break;
			
			case "Slider" :	
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.slider, { range: [_range[0], _range[1], _step] });	
				break;
			case "Slider range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
					
				inParent.def_val = [0, 0];
				inParent.setDisplay(VALUE_DISPLAY.slider_range, { range: [_range[0], _range[1], _step] });
				break;
				
			case "Rotation" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.rotation);	
				break;
				
			case "Rotation range" :
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
					
				inParent.def_val = [0, 0];
				inParent.setDisplay(VALUE_DISPLAY.rotation_range);
				break;
				
			case "Padding" :
				if(!is_array(_val) || array_length(_val) != 4)
					inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
					
				inParent.def_val = [0, 0, 0, 0];
				inParent.setDisplay(VALUE_DISPLAY.padding);
				break;
				
			case "Area" :
				if(!is_array(_val) || array_length(_val) != 5)
					inParent.animator = new valueAnimator(DEF_AREA, inParent);
					
				inParent.def_val = array_clone(DEF_AREA);
				inParent.setDisplay(VALUE_DISPLAY.area);
				break;
				
			case "Vector" :
			case "Vector range" :
				switch(_vec_size) {
					case 0 : 
						if(!is_array(_val) || array_length(_val) != 2)
							inParent.animator = new valueAnimator([0, 0], inParent);
							
							inParent.def_val = [0, 0];
						break;
					case 1 : 
						if(!is_array(_val) || array_length(_val) != 3)
							inParent.animator = new valueAnimator([0, 0, 0], inParent);
							
							inParent.def_val = [0, 0, 0];
						break;
					case 2 : 
						if(!is_array(_val) || array_length(_val) != 4)
							inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
							
							inParent.def_val = [0, 0, 0, 0];
						break;
				}
				if(_dtype == "Vector")				inParent.setDisplay(VALUE_DISPLAY.vector);
				else if(_dtype == "Vector range")	inParent.setDisplay(VALUE_DISPLAY.vector_range);
				break;
			
			case "Enum button" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.enum_button, string_splice(_enum_label, ",")); 
				break;
				
			case "Menu scroll" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.enum_scroll, string_splice(_enum_label, ",")); 
				break;
			
			case "Palette" :
				if(!is_array(_val))
					inParent.animator = new valueAnimator([c_black], inParent);
					
				inParent.def_val = [c_black];
				inParent.setDisplay(VALUE_DISPLAY.palette);
				break;
				
			case "Gradient":
				inParent.setType(VALUE_TYPE.gradient);
				outputs[0].setType(inParent.type);
				
				inParent.animator = new valueAnimator(new gradientObject(cola(c_white)), inParent);
				
				inParent.def_val = new gradientObject(cola(c_white));
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
				
			case "Curve":
				inParent.animator = new valueAnimator(CURVE_DEF_11, inParent);
				
				inParent.def_val = array_clone(CURVE_DEF_11);
				inParent.setDisplay(VALUE_DISPLAY.curve);
				break;
				
			default:
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
		}
		
		switch(_val_type) {
			case VALUE_TYPE.trigger : 
				var bname = getInputData(8);
				inParent.setDisplay(VALUE_DISPLAY.button, { name: bname, onClick: function() /*=>*/ { doTrigger = 1; } });
				break;
		}
		
		visibleCheck();
	}
	
	static updateGroupInput = function() {
		var _dstype = getInputData(0);
		var _data   = getInputData(2);
		var _dsList = array_safe_get_fast(GROUP_IO_DISPLAY, _data);
		if(!is_array(_dsList)) _dsList = [ "Default" ];
		
		inputs[0].display_data.data    = _dsList;
		inputs[0].editWidget.data_list = _dsList;
		
		_dstype = array_safe_get_fast(_dsList, _dstype);
		
		var _datype = array_safe_get_fast(GROUP_IO_TYPE_MAP, _data, VALUE_TYPE.any);
		
		inputs[1].setVisible(false);
		inputs[3].setVisible(false);
		inputs[4].setVisible(false);
		inputs[7].setVisible(false);
		inputs[8].setVisible(_datype == VALUE_TYPE.trigger);
		
		switch(_dstype) {
			case "Slider" :
			case "Slider range" :
				inputs[7].setVisible(true);
				inputs[1].setVisible(true);
				break;
				
			case "Range" :
				inputs[1].setVisible(true);
				break;
				
			case "Enum button" :
			case "Menu scroll" :
				inputs[3].setVisible(true);
				break;
				
			case "Vector" :
			case "Vector range" :
				inputs[4].setVisible(true);
				break;
		}
		
		visibleCheck();
	}
	
	static step = function() {
		if(is_undefined(inParent)) return;
		
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[$ string_replace_all(display_name, " ", "_")] = inParent;
		}
		
		if(inParent.type != VALUE_TYPE.trigger) return;
		
		switch(doTrigger) {
			case 1 : 
				outputs[0].setValue(true);
				doTrigger = -1;
				break;
			
			case -1 : 
				outputs[0].setValue(false);
				doTrigger = 0;
				break;
		}
	}
	
	doUpdate = doUpdateLite;
	__dstype = noone;
	__data   = noone;
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is(inParent, NodeValue)) return;
		outputs[0].setValue(inParent.getValue());
		
		var _dstype = inputs[0].getValue();
		var _data   = inputs[2].getValue();
		if(_dstype == __dstype && _data == __data) return;
		getInputs(frame);
		updateGroupInput();
		
		__dstype = _dstype;
		__data   = _data;
	}
	
	////- Draw

	static getGraphPreviewSurface = function() { var _in = array_safe_get(inputs, 0, noone); return _in == noone? noone : _in.getValue(); }
	
	static drawNodeDef = drawNode;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inParent.isArray()) return;
		return inParent.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, display_parameter = noone, _panel = noone) { 
		if(_s >= .75) return drawNodeDef(_draw, _x, _y, _mx, _my, _s, display_parameter, _panel);
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _name = renamed? display_name : name;
		var _ts   = _s * 0.5;
		var _tx   = round(xx + (w - 6) * _s - 2);
		var _ty   = round(outputs[0].y);
		
		draw_set_text(f_sdf, fa_right, fa_center);
		BLEND_ALPHA_MULP
		
		draw_set_color(0);					draw_text_transformed(_tx + 1, _ty + 1, _name, _ts, _ts, 0);
		draw_set_color(COLORS._main_text);	draw_text_transformed(_tx, _ty, _name, _ts, _ts, 0);
		
		BLEND_NORMAL
		
		return _s > 0.5? drawJunctions(_draw, xx, yy, _mx, _my, _s) : drawJunctions_fast(_draw, xx, yy, _mx, _my, _s);
	}
	
	////- Serialize
	
	static postDeserialize = function() { createInput(false); }
	
	static postApplyDeserialize = function() {
		if(inParent == undefined) return;
		if(group == noone) return;
		
		inParent.name = name;
		getInputs();
		onValueUpdate();
		
		group.sortIO();
	}
	
	////- Actions
	
	static onDestroy = function() {
		if(is_undefined(inParent)) return;
		
		array_remove(group.inputs, inParent);
		group.sortIO();
		group.refreshNodes();
	}
	
	static onUngroup = function() {
		var fr = inParent.value_from;
		
		for( var i = 0; i < array_length(outputs[0].value_to); i++ ) {
			var to = outputs[0].value_to[i];
			if(to.value_from != outputs[0]) continue;
			
			to.setFrom(fr);
		}
	}
		
	static onLoadGroup = function() { if(group == noone) destroy(); }
	
	if(!LOADING && !APPENDING) createInput();
}