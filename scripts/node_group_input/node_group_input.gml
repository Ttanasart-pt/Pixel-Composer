function Node_Group_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Group Input";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	previewable = false;
	auto_height = false;
	input_fix_len = -1;
	
	inParent = undefined;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	data_type_list = [	"Integer",		"Float",	"Boolean",	"Color",	"Surface", 
						"File Path",	"Curve",	"Text",		"Object",	"Node", 
						"3D object",	"Any",		"Path",		"Particle", "Rigidbody Object", 
						"Fluid Domain", "Struct",	"Strands",	"Mesh",		"Trigger"
					 ];
	
	data_type_map  = [	VALUE_TYPE.integer,		VALUE_TYPE.float,	VALUE_TYPE.boolean,		VALUE_TYPE.color,		VALUE_TYPE.surface, 
						VALUE_TYPE.path,		VALUE_TYPE.curve,	VALUE_TYPE.text,		VALUE_TYPE.object,		VALUE_TYPE.node, 
						VALUE_TYPE.d3object,	VALUE_TYPE.any,		VALUE_TYPE.pathnode,	VALUE_TYPE.particle,	VALUE_TYPE.rigid, 
						VALUE_TYPE.fdomain,		VALUE_TYPE.struct,	VALUE_TYPE.strands,		VALUE_TYPE.mesh,		VALUE_TYPE.trigger
					 ];
	
	display_list = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area", "Enum button", "Menu scroll" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
		/*Boolean*/	[ "Default" ],
		/*Color*/	[ "Default", "Gradient", "Palette" ],
		/*Surface*/	[ "Default", ],
		/*Path*/	[ "Default", ],
		/*Curve*/	[ "Default", ],
		/*Text*/	[ "Default", ],
		/*Object*/	[ "Default", ],
		/*Node*/	[ "Default", ],
		/*3D*/		[ "Default", ],
		/*Any*/		[ "Default", ],
		/*Pathnode*/[ "Default", ],
		/*Particle*/[ "Default", ],
		/*Rigid*/	[ "Default", ],
		/*Fdomain*/	[ "Default", ],
		/*Struct*/	[ "Default", ],
		/*Strand*/	[ "Default", ],
		/*Mesh*/	[ "Default", ],
		/*Trigger*/	[ "Default", ],
	];
	
	inputs[| 0] = nodeValue("Display type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, display_list[0])
		.rejectArray();
	inputs[| 0].editWidget.update_hover = false;
	
	inputs[| 1] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector_range)
		.setVisible(false)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, data_type_list, { update_hover: false })
		.rejectArray();
	inputs[| 2].editWidget.update_hover = false;
	
	inputs[| 3] = nodeValue("Enum label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(false)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Vector size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "2", "3", "4" ], { update_hover: false })
		.setVisible(false)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.rejectArray();
	
	inputs[| 6] = nodeValue("Display preview gizmo", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	inputs[| 7] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.01)
		.setVisible(false)
		.rejectArray();
	
	inputs[| 8] = nodeValue("Button Label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "Trigger")
		.setVisible(false)
		.rejectArray();
		
	input_display_list = [ 
		["Display", false], 5, 6, 
		["Data",	false], 2, 0, 4, 1, 7, 3, 8, 
	];
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	attributes.inherit_name = true;
	doTrigger = 0;
	
	_onSetDisplayName = function() {
		attributes.inherit_name = false;
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inParent.isArray()) return;
		inParent.drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static onValueUpdate = function(index = 0) {
		if(is_undefined(inParent)) return;
		
		var _dtype	    = inputs[| 0].getValue();
		var _range	    = inputs[| 1].getValue();
		var _type		= inputs[| 2].getValue();
		var _val_type   = data_type_map[_type];
		var _enum_label = inputs[| 3].getValue();
		var _vec_size	= inputs[| 4].getValue();
		var _step		= inputs[| 7].getValue();
		
		if(index == 2) {
			var _o = outputs[| 0];
			for(var j = 0; j < ds_list_size(_o.value_to); j++) {
				var _to = _o.value_to[| j];
				if(_to.value_from == _o)
					_to.removeFrom();
			}
			
			inputs[| 0].display_data = display_list[_val_type];
			inputs[| 0].editWidget.data_list = display_list[_val_type];
			inputs[| 0].setValue(0);
			_dtype = 0;
		}
		
		_dtype = display_list[_val_type][_dtype];
		
		inParent.type     = _val_type;
		outputs[| 0].type = _val_type;
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case "Range" :	
				inParent.setDisplay(VALUE_DISPLAY.range); 
				break;
			
			case "Slider" :	
				inParent.setDisplay(VALUE_DISPLAY.slider, [_range[0], _range[1], _step]);	
				break;
			case "Slider range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.slider_range, [_range[0], _range[1], _step]);	
				break;
				
			case "Rotation" : 
				inParent.setDisplay(VALUE_DISPLAY.rotation);	
				break;
				
			case "Rotation range" :
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.rotation_range);
				break;
				
			case "Padding" :
				if(!is_array(_val) || array_length(_val) != 4)
					inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.padding);
				break;
				
			case "Area" :
				if(!is_array(_val) || array_length(_val) != 5)
					inParent.animator = new valueAnimator([0, 0, 0, 0, 5], inParent);
				inParent.setDisplay(VALUE_DISPLAY.area);
				break;
				
			case "Vector" :
			case "Vector range" :
				switch(_vec_size) {
					case 0 : 
						if(!is_array(_val) || array_length(_val) != 2)
							inParent.animator = new valueAnimator([0, 0], inParent);
						break;
					case 1 : 
						if(!is_array(_val) || array_length(_val) != 3)
							inParent.animator = new valueAnimator([0, 0, 0], inParent);
						break;
					case 2 : 
						if(!is_array(_val) || array_length(_val) != 4)
							inParent.animator = new valueAnimator([0, 0, 0, 0], inParent);
						break;
				}
				if(_dtype == "Vector")				inParent.setDisplay(VALUE_DISPLAY.vector);
				else if(_dtype == "Vector range")	inParent.setDisplay(VALUE_DISPLAY.vector_range);
				break;
			
			case "Enum button" : inParent.setDisplay(VALUE_DISPLAY.enum_button, string_splice(_enum_label, ",")); break;
			case "Menu scroll" : inParent.setDisplay(VALUE_DISPLAY.enum_scroll, string_splice(_enum_label, ",")); break;
			
			case "Palette" :
				if(!is_array(_val))
					inParent.animator = new valueAnimator([c_black], inParent);
				inParent.setDisplay(VALUE_DISPLAY.palette);
				break;
				
			case "Gradient":
				inParent.type     = VALUE_TYPE.gradient;
				outputs[| 0].type = inParent.type;
				
				inParent.animator = new valueAnimator(new gradientObject(c_white), inParent);
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
				
			default:
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
		}
		
		switch(_val_type) {
			case VALUE_TYPE.trigger : 
				var bname = inputs[| 8].getValue();
				inParent.setDisplay(VALUE_DISPLAY.button, [ function() { doTrigger = 1; }, bname]);
				break;
		}
		
		if(index == 5)
			group.sortIO();
	}
	
	static createInput = function(override_order = true) {
		if(group == noone || !is_struct(group)) return noone;
		
		if(override_order) {
			input_fix_len = ds_list_size(group.inputs);
			inputs[| 5].setValue(input_fix_len);
		} else {
			input_fix_len = inputs[| 5].getValue();
		}
		
		if(!is_undefined(inParent))
			ds_list_remove(group.inputs, inParent);
		
		inParent = nodeValue("Value", group, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
			.setVisible(true, true);
		inParent.from = self;
		
		ds_list_add(group.inputs, inParent);
		outputs[| 0].setFrom(inParent, false, false);
		group.setHeight();
		group.sortIO();
			
		onValueUpdate(0);
		
		return inParent;
	}
	
	if(!LOADING && !APPENDING) createInput();
	
	dtype  = -1;
	range  = 0;
	
	static step = function() {
		if(is_undefined(inParent)) return;
		
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[? string_replace_all(display_name, " ", "_")] = inParent;
		}
		
		var _to_list = outputs[| 0].value_to;
		onSetDisplayName = _onSetDisplayName;
		if(attributes.inherit_name && !ds_list_empty(_to_list)) {
			for( var i = 0; i < ds_list_size(_to_list); i++ ) {
				if(_to_list[| i].value_from != outputs[| 0]) continue;
				if(display_name == _to_list[| i].name) break;
				onSetDisplayName = noone;
				setDisplayName(_to_list[| i].name);
			}
		}
		
		if(inParent.type == VALUE_TYPE.trigger) {
			if(doTrigger == 1) {
				outputs[| 0].setValue(true);
				doTrigger = -1;
			} else if(doTrigger == -1) {
				outputs[| 0].setValue(false);
				doTrigger = 0;
			}
		}
	}
	
	PATCH_STATIC
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(is_undefined(inParent)) return;
		
		var _dstype = inputs[| 0].getValue();
		var _data  = inputs[| 2].getValue();
		_dstype = display_list[_data][_dstype];
		
		var _datype = data_type_map[_data];
		
		inputs[| 1].setVisible(false);
		inputs[| 3].setVisible(false);
		inputs[| 4].setVisible(false);
		inputs[| 7].setVisible(false);
		inputs[| 8].setVisible(_datype == VALUE_TYPE.trigger);
		
		switch(_dstype) {
			case "Slider" :
			case "Slider range" :
				inputs[| 7].setVisible(true);
			case "Range" :
				inputs[| 1].setVisible(true);
				break;
			case "Enum button" :
			case "Menu scroll" :
				inputs[| 3].setVisible(true);
				break;
			case "Vector" :
			case "Vector range" :
				inputs[| 4].setVisible(true);
				break;
		}
	}
	
	static postDeserialize = function() {
		createInput(false);
		
		var _inputs = load_map.inputs;
		inputs[| 5].applyDeserialize(_inputs[5], load_scale);
		group.sortIO();
		
		inputs[| 2].applyDeserialize(_inputs[2], load_scale);
		onValueUpdate(2);
	}
	
	static applyDeserialize = function() {
		var _inputs = load_map.inputs;
		var amo = min(array_length(_inputs), ds_list_size(inputs));
		
		for(var i = 0; i < amo; i++) {
			if(i == 2 || i == 5) continue;
			inputs[| i].applyDeserialize(_inputs[i], load_scale);
		}
		
		inParent.name = name;
		onValueUpdate(0);
	}
	
	static onDestroy = function() {
		if(is_undefined(inParent)) return;
		ds_list_remove(group.inputs, inParent);
	}
	
	static ungroup = function() {
		var fr = inParent.value_from;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var to = outputs[| 0].value_to[| i];
			if(to.value_from != outputs[| 0]) continue;
			
			to.setFrom(fr);
		}
	}
}