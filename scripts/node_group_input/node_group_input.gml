function Node_Group_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Group Input";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	previewable = false;
	
	inParent = undefined;
	
	attributes.input_priority = 0;
	if(!CLONING && !LOADING && !APPENDING && group != noone) attributes.input_priority = group.getInputFreeOrder();
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	#region data
	data_type_list = [	"Integer",		"Float",	"Boolean",	"Color",	"Surface", 
						"File Path",	"Curve",	"Text",		"Object",	"Node", 
						-1,				"Any",		"Path",		"Particle", "Rigidbody Object", 
						"Domain",		"Struct",	"Strands",	"Mesh",		"Trigger",
						-1,				"3D Mesh",	"3D Light",	"3D Scene",	"3D Material",
						-1,				"Audio"
					 ];
	
	data_type_map  = [	VALUE_TYPE.integer,		VALUE_TYPE.float,		VALUE_TYPE.boolean,		VALUE_TYPE.color,		VALUE_TYPE.surface, 
						VALUE_TYPE.path,		VALUE_TYPE.curve,		VALUE_TYPE.text,		VALUE_TYPE.object,		VALUE_TYPE.node, 
						noone,					VALUE_TYPE.any,			VALUE_TYPE.pathnode,	VALUE_TYPE.particle,	VALUE_TYPE.rigid, 
						VALUE_TYPE.fdomain,		VALUE_TYPE.struct,		VALUE_TYPE.strands,		VALUE_TYPE.mesh,		VALUE_TYPE.trigger,
						
						noone,					VALUE_TYPE.d3Mesh,		VALUE_TYPE.d3Light,		VALUE_TYPE.d3Scene,		VALUE_TYPE.d3Material,
						noone,					VALUE_TYPE.audioBit,
					 ];
	
	display_list = [
		/*Integer*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area", "Enum button", "Menu scroll" ],
		/*Float*/	[ "Default", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
		/*Boolean*/	0,
		/*Color*/	[ "Default", "Gradient", "Palette" ],
		/*Surface*/	0,
		
		/*Path*/	0,
		/*Curve*/	[ "Curve", ],
		/*Text*/	0,
		/*Object*/	0,
		/*Node*/	0,
		
		/*3D*/		0,
		/*Any*/		0,
		/*Pathnode*/0,
		/*Particle*/0,
		/*Rigid*/	0,
		
		/*Fdomain*/	0,
		/*Struct*/	0,
		/*Strand*/	0,
		/*Mesh*/	0,
		/*Trigger*/	0,
		
		/*noone*/	    0,
		/*3D Mesh*/     0,
		/*3D Light*/    0,
		/*3D Scene*/    0,
		/*3D Material*/ 0,
		
		/*noone*/	0,
		/*Audio*/   0,
	];
	#endregion
	
	inputs[| 0] = nodeValue("Display type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: display_list[0], update_hover: false })
		.uncache()
		.rejectArray();
	
	inputs[| 1] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 1])
		.setDisplay(VALUE_DISPLAY.range)
		.uncache()
		.setVisible(false)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Input type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 11)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: data_type_list, update_hover: false })
		.uncache()
		.rejectArray();
	
	inputs[| 3] = nodeValue("Enum label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(false)
		.uncache()
		.rejectArray();
	
	inputs[| 4] = nodeValue("Vector size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "2", "3", "4" ])
		.setVisible(false)
		.uncache()
		.rejectArray();
	
	inputs[| 5] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.uncache()
		.rejectArray();
	
	inputs[| 6] = nodeValue("Display preview gizmo", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.uncache()
		.rejectArray();
	
	inputs[| 7] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.01)
		.setVisible(false)
		.uncache()
		.rejectArray();
	
	inputs[| 8] = nodeValue("Button Label", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "Trigger")
		.setVisible(false)
		.uncache()
		.rejectArray();
		
	input_display_list = [ 
		["Display", false], 6, 
		["Data",	false], 2, 0, 4, 1, 7, 3, 8, 
	];
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0)
		.uncache();
	
	attributes.inherit_name = !LOADING && !APPENDING;
	attributes.inherit_type = !LOADING && !APPENDING;
	doTrigger = 0;
	
	_onSetDisplayName = function() {
		attributes.inherit_name = false;
	}
	
	outputs[| 0].onSetTo = function(juncTo) {
		if(!attributes.inherit_type) return;
		attributes.inherit_type = false;
		
		var ind = array_find(data_type_map, juncTo.type);
		if(ind == -1) return;
		
		if(ind == inputs[| 2].getValue()) return;
		
		outputs[| 0].setType(juncTo.type);
		inputs[| 2].setValue(ind);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(inParent.isArray()) return;
		return inParent.drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(is_undefined(inParent)) return;
		
		var _dtype	    = getInputData(0);
		var _range	    = getInputData(1);
		var _type		= getInputData(2);
		var _val_type   = array_safe_get(data_type_map, _type, VALUE_TYPE.any);
		var _enum_label = getInputData(3);
		var _vec_size	= getInputData(4);
		var _step		= getInputData(7);
		
		if(index == 2) {
			if(outputs[| 0].type != _val_type) {
				var _o = outputs[| 0];
				for(var j = 0; j < ds_list_size(_o.value_to); j++) {
					var _to = _o.value_to[| j];
					if(_to.value_from == _o)
						_to.removeFrom();
				}
			}
			
			inputs[| 0].setValue(0);
			attributes.inherit_type = false;
		}
		
		_dtype = array_safe_get(array_safe_get(display_list, _val_type), _dtype);
		
		inParent.setType(_val_type);
		outputs[| 0].setType(_val_type);
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case "Range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.range); 
				break;
			
			case "Slider" :	
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				inParent.setDisplay(VALUE_DISPLAY.slider, { range: [_range[0], _range[1], _step] });	
				break;
			case "Slider range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
				inParent.setDisplay(VALUE_DISPLAY.slider_range, { range: [_range[0], _range[1], _step] });
				break;
				
			case "Rotation" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
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
			
			case "Enum button" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				inParent.setDisplay(VALUE_DISPLAY.enum_button, string_splice(_enum_label, ",")); 
				break;
				
			case "Menu scroll" : 
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				inParent.setDisplay(VALUE_DISPLAY.enum_scroll, string_splice(_enum_label, ",")); 
				break;
			
			case "Palette" :
				if(!is_array(_val))
					inParent.animator = new valueAnimator([c_black], inParent);
				inParent.setDisplay(VALUE_DISPLAY.palette);
				break;
				
			case "Gradient":
				inParent.setType(VALUE_TYPE.gradient);
				outputs[| 0].setType(inParent.type);
				
				inParent.animator = new valueAnimator(new gradientObject(c_white), inParent);
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
				
			case "Curve":
				inParent.animator = new valueAnimator(CURVE_DEF_11, inParent);
				inParent.setDisplay(VALUE_DISPLAY.curve);
				break;
				
			default:
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
		}
		
		switch(_val_type) {
			case VALUE_TYPE.trigger : 
				var bname = getInputData(8);
				inParent.setDisplay(VALUE_DISPLAY.button, { name: bname, onClick: function() { doTrigger = 1; } });
				break;
		}
	} #endregion
	
	static createInput = function() { #region
		if(group == noone || !is_struct(group)) return noone;
				
		if(!is_undefined(inParent))
			ds_list_remove(group.inputs, inParent);
		
		inParent = nodeValue("Value", group, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
			.uncache()
			.setVisible(true, true);
		inParent.from = self;
		
		ds_list_add(group.inputs, inParent);
		outputs[| 0].setFrom(inParent, false, false);
		group.setHeight();
		group.sortIO();
			
		onValueUpdate(0);
		
		return inParent;
	} #endregion
	
	if(!LOADING && !APPENDING) createInput();
	
	dtype  = -1;
	range  = 0;
	
	static step = function() { #region
		if(is_undefined(inParent)) return;
		
		var _type		= getInputData(2);
		var _val_type   = array_safe_get(data_type_map, _type, VALUE_TYPE.any);
		var _dsList     = array_safe_get(display_list, _val_type);
		if(_dsList == 0) _dsList = [ "Default" ];
		inputs[| 0].display_data.data    = _dsList;
		inputs[| 0].editWidget.data_list = _dsList;
			
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[? string_replace_all(display_name, " ", "_")] = inParent;
		}
		
		var _to_list = outputs[| 0].value_to;
		onSetDisplayName = _onSetDisplayName;
		if(!renamed && attributes.inherit_name && !ds_list_empty(_to_list)) {
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
		
		var _dstype = getInputData(0);
		var _data   = getInputData(2);
		var _dsList = array_safe_get(display_list, _data);
		_dstype = _dsList == 0? "Default" : array_safe_get(_dsList, _dstype);
		
		var _datype = array_safe_get(data_type_map, _data, VALUE_TYPE.any);
		
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
	} #endregion
	
	PATCH_STATIC
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(is_undefined(inParent)) return;
	} #endregion
	
	static postDeserialize = function() { createInput(false); }
	
	static doApplyDeserialize = function() { #region
		if(inParent == undefined) return;
		if(group == noone) return;
		
		inParent.name = name;
		getInputs();
		if(PROJECT.version < 11520) attributes.input_priority = getInputData(5);
		onValueUpdate();
		
		group.sortIO();
	} #endregion
	
	static onDestroy = function() { #region
		if(is_undefined(inParent)) return;
		ds_list_remove(group.inputs, inParent);
		group.sortIO();
	} #endregion
	
	static ungroup = function() { #region
		var fr = inParent.value_from;
		
		for( var i = 0; i < ds_list_size(outputs[| 0].value_to); i++ ) {
			var to = outputs[| 0].value_to[| i];
			if(to.value_from != outputs[| 0]) continue;
			
			to.setFrom(fr);
		}
	} #endregion
		
	static onLoadGroup = function() { #region
		if(group == noone) nodeDelete(self);
	} #endregion
	
}