globalvar GROUP_IO_TYPE_NAME, GROUP_IO_TYPE_MAP, GROUP_IO_DISPLAY;

#region data
	GROUP_IO_TYPE_NAME = [	"Integer",				"Float",				"Boolean",				"Color",				"Surface", 
							"File Path",			"Curve",				"Text",					"Object",				"Node", 
							-1,						"Any",					"Path",					"Particle", 			"Rigidbody Object", 
							"Domain",				"Struct",				"Strands",				"Mesh",					"Trigger",
							
							-1,						"3D Mesh",				"3D Light",				"3D Camera",			"3D Scene",	
							"3D Material",  		-1,						"PCX",					"Audio",				"Fluid Domain", 
							"SDF",                  "Gradient", 
						 ];
	
	GROUP_IO_TYPE_MAP  = [	VALUE_TYPE.integer,		VALUE_TYPE.float,		VALUE_TYPE.boolean,		VALUE_TYPE.color,		VALUE_TYPE.surface, 
							VALUE_TYPE.path,		VALUE_TYPE.curve,		VALUE_TYPE.text,		VALUE_TYPE.object,		VALUE_TYPE.node, 
							noone,					VALUE_TYPE.any,			VALUE_TYPE.pathnode,	VALUE_TYPE.particle,	VALUE_TYPE.rigid, 
							VALUE_TYPE.sdomain,		VALUE_TYPE.struct,		VALUE_TYPE.strands,		VALUE_TYPE.mesh,		VALUE_TYPE.trigger,
							
							noone,					VALUE_TYPE.d3Mesh,		VALUE_TYPE.d3Light,		VALUE_TYPE.d3Camera,	VALUE_TYPE.d3Scene,		
							VALUE_TYPE.d3Material,  noone,					VALUE_TYPE.PCXnode,		VALUE_TYPE.audioBit,	VALUE_TYPE.fdomain,
							VALUE_TYPE.sdf,         VALUE_TYPE.gradient,
						 ];
	
	GROUP_IO_DISPLAY = [
		
	/*Integer*/	    [ "Integer", "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area", "Enum button", "Menu scroll" ],
	/*Float*/	    [ "Float",   "Range", "Rotation", "Rotation range", "Slider", "Slider range", "Padding", "Vector", "Vector range", "Area" ],
	/*Boolean*/	    [ "Boolean" ],
	/*Color*/	    [ "Color", "Palette" ],
	/*Surface*/	    [ "Surface" ],
	    
	/*Path*/	    [ "Path"    ],
	/*Curve*/	    [ "Curve",  ],
	/*Text*/	    [ "Text"    ],
	/*Object*/	    [ "Object"  ],
	/*Node*/	    [ "Node"    ],
	    
	/*3D*/		    [ "-" ],
	/*Any*/		    [ "Any"      ],
	/*Pathnode*/    [ "Pathnode" ],
	/*Particle*/    [ "Particle" ],
	/*Rigid*/	    [ "Rigidbody Object" ],
	    
	/*Sdomain*/	    [ "Domain"  ],
	/*Struct*/	    [ "Struct"  ],
	/*Strand*/	    [ "Strand"  ],
	/*Mesh*/	    [ "Mesh"    ],
	/*Trigger*/	    [ "Trigger" ],
	
	//=========================//
	
	/*Noone*/	    [ "-" ],
	/*3D Mesh*/     [ "3D Mesh"   ],
	/*3D Light*/    [ "3D Light"  ],
	/*3D Camera*/   [ "3D Camera" ],
	/*3D Scene*/    [ "3D Scene"  ],
	
	/*3D Material*/ [ "3D Material" ],
	/*noone*/	    [ "-" ],
	/*PCX*/         [ "PCX"      ],
	/*Audio*/       [ "Audio"    ],
	/*Fdomain*/     [ "Fdomain"  ],
	
	/*SDF*/         [ "SDF"      ],
	/*Gradient*/    [ "Gradient" ],
	
	];
#endregion

function Node_Group_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name         = "Group Input";
	color        = COLORS.node_blend_collection;
	preview_draw = false;
	is_group_io  = true;
	inParent     = undefined;
	doUpdate     = doUpdateLite;
	
	__inType = noone;
	__dsType = noone;
	
	destroy_when_upgroup = true;
	
	skipDefault();
	setDimension(96, 48);
	
	////- =Visibility
	__visible_condition = [ "Always Show", "Always Hide", 
		/* 2 */ new scrollItem("Equal",              s_node_condition_type, 0), 
		/* 3 */ new scrollItem("Not equal",          s_node_condition_type, 1), 
		/* 4 */ new scrollItem("Greater ",           s_node_condition_type, 4), 
		/* 5 */ new scrollItem("Greater or equal",   s_node_condition_type, 5), 
		/* 6 */ new scrollItem("Lesser",             s_node_condition_type, 2), 
		/* 7 */ new scrollItem("Lesser or equal",    s_node_condition_type, 3), ]
		
	newInput( 9, nodeValue_Enum_Scroll("Visible Condition", 0, __visible_condition));
	newInput(10, nodeValue_Float(      "Visible Check",     0 ));
	newInput(11, nodeValue_Float(      "Visible Check To",  0 ));
	
	////- =Data
	newInput(2, nodeValue_Enum_Scroll( "Input Type",    11, { data: GROUP_IO_TYPE_NAME,   update_hover: false })).setUnclamp();
	newInput(0, nodeValue_Enum_Scroll( "Subtype",        0, { data: GROUP_IO_DISPLAY[11], update_hover: false })).setUnclamp();
	newInput(4, nodeValue_Enum_Button( "Vector Size",    0, [ "2", "3", "4" ] ));
	newInput(1, nodeValue_Range(       "Range",         [0,1] ));
	newInput(7, nodeValue_Float(       "Step",           0.01 ));
	newInput(3, nodeValue_Text(        "Enum Labels")).setTooltip("Define enum choices, use comma to separate each choice.");
	newInput(8, nodeValue_Text(        "Button Label", "Trigger"));
	newInput(5, nodeValue_Int(         "Order",         0));
	
	////- =Gizmo
	newInput( 6, nodeValue_Bool(       "Display Preview Gizmo",  true ));
	newInput(12, nodeValue_Vec2(       "Gizmo Position",        [0,0] ));
	newInput(13, nodeValue_Float(      "Gizmo Scale",            1    ));
	newInput(14, nodeValue_Rotation(   "Gizmo Rotation",         0    ));
	newInput(15, nodeValue_Bool(       "Gizmo Label",            true ));
	
	inputs[10].setFrom_condition = function(v) /*=>*/ {
		if(is(v.node, Node_Group_Input)) return true;
		noti_warning("Group IO visibility must be connected directly to another group input.", noone, self);
		return false;
	}
	
	array_foreach(inputs, function(i) /*=>*/ {return i.uncache().rejectArray()});
		
	input_display_list = [ 
		["Visibility", false   ],  9, 10, 11, 
		["Data",       false   ],  2,  0,  4,  1,  7,  3,  8, 
		["Gizmo",      false, 6], 12, 13, 14, 15, 
	];
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, 0)).uncache();
	
	////- Nodes
	
	attributes.inherit_name = true;
	attributes.inherit_type = true;
	doTrigger = 0;
	
	dtype = -1;
	range = 0;
	
	onSetDisplayName = function() /*=>*/ { attributes.inherit_name = false; }
	
	outputs[0].onSetTo = function(juncTo) {
		if(attributes.inherit_name && !LOADING && !APPENDING)
			setDisplayName(juncTo.name);
		
		if(!attributes.inherit_type) return;
		attributes.inherit_type = false;
		
		var ind = array_find(GROUP_IO_TYPE_MAP, juncTo.type);
		outputs[0].setType(juncTo.type);
		
		if(ind != -1) inputs[2].setValue(ind);
		
		switch(instanceof(juncTo)) {
			case "__NodeValue_Vec2" : 
			case "__NodeValue_Dimension" : 
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Vector"));       inputs[4].setValue(0); break;
			
			case "__NodeValue_Vec2_Range" :
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Vector range")); inputs[4].setValue(0); break;
			
			case "__NodeValue_Vec3" :
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Vector"));       inputs[4].setValue(1); break;
			
			case "__NodeValue_Vec3_Range" :
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Vector range")); inputs[4].setValue(1); break;
			
			case "__NodeValue_Vec4" :
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Vector"));       inputs[4].setValue(2); break;
				
			case "__NodeValue_Rotation" : 
				inputs[0].setValue(array_find(GROUP_IO_DISPLAY[0], "Rotation"));     inputs[4].setValue(2); break;
				
			case "__NodeValue_Palette" : inputs[0].setValue(1); break;
		} 
		
		juncTo.value_from = noone;
		inParent.setValue(juncTo.getValue());
		juncTo.value_from = outputs[0];
		
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
		
		refreshWidget();
		
		return inParent;
	} 
	
	////- Render
	
	static updateGroupInput = function(_get = true) {
		var _inType = _get? inputs[2].getValue() : __inType;
		var _dsType = _get? inputs[0].getValue() : __dsType;
		var _dsList = array_safe_get_fast(GROUP_IO_DISPLAY, _inType);
		if(!is_array(_dsList)) _dsList = [ "Default" ];
		
		__inType = _inType;
		__dsType = _dsType;
			
		inputs[0].display_data.data    = _dsList;
		inputs[0].editWidget.data_list = _dsList;
		
		var _dsType = array_safe_get_fast(_dsList, _dsType);
		var _datype = array_safe_get_fast(GROUP_IO_TYPE_MAP, _inType, VALUE_TYPE.any);
		
		inputs[1].setVisible(false);
		inputs[3].setVisible(false);
		inputs[4].setVisible(false);
		inputs[7].setVisible(false);
		inputs[8].setVisible(_datype == VALUE_TYPE.trigger);
		
		switch(_dsType) {
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
		
	}
	
	static refreshWidget = function() {
		var _inType = inputs[2].getValue();
		var _vtype  = array_safe_get_fast(GROUP_IO_TYPE_MAP, _inType, VALUE_TYPE.any);
		
		var _disp  = inputs[0].getValue();
		var _dtype = array_safe_get_fast(array_safe_get_fast(GROUP_IO_DISPLAY, _vtype), _disp);
		
		inParent.setType(_vtype);
		outputs[0].setType(_vtype);
		var _val = inParent.getValue();
		
		switch(_dtype) {
			case "Range" :	
				if(!is_array(_val) || array_length(_val) != 2) 
					inParent.animator = new valueAnimator([0, 0], inParent);
					
				inParent.def_val = [0, 0];
				inParent.setDisplay(VALUE_DISPLAY.range); 
				break;
			
			case "Slider" :	
				var _range = inputs[1].getValue();
				var _step  = inputs[7].getValue();
				
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.slider, { range: [_range[0], _range[1], _step] });	
				break;
				
			case "Slider range" :
				var _range = inputs[1].getValue();
				var _step  = inputs[7].getValue();
					
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
				var _vsize = inputs[4].getValue() + 2;
				
				if(!is_array(_val) || array_length(_val) != _vsize) {
					inParent.animator = new valueAnimator(array_create(_vsize), inParent);
					inParent.def_val = array_create(_vsize);
				}
				
				     if(_dtype == "Vector")       inParent.setDisplay(VALUE_DISPLAY.vector);
				else if(_dtype == "Vector range") inParent.setDisplay(VALUE_DISPLAY.vector_range);
				break;
			
			case "Enum button" : 
				var _elabel = inputs[3].getValue();
				
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.enum_button, string_splice(_elabel, ",")); 
				break;
				
			case "Menu scroll" : 
				var _elabel = inputs[3].getValue();
				
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY.enum_scroll, string_splice(_elabel, ",")); 
				break;
			
			case "Palette" :
				if(!is_array(_val)) inParent.animator = new valueAnimator([ca_black], inParent);
					
				inParent.def_val = [ca_black];
				inParent.setDisplay(VALUE_DISPLAY.palette);
				break;
				
			case "Gradient":
				inParent.setType(VALUE_TYPE.gradient);
				outputs[0].setType(inParent.type);
				
				inParent.animator = new valueAnimator(new gradientObject(ca_white), inParent);
				inParent.def_val  = new gradientObject(ca_white);
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
				
			case "Curve":
				inParent.animator = new valueAnimator(CURVE_DEF_11, inParent);
				inParent.def_val  = array_clone(CURVE_DEF_11);
				inParent.setDisplay(VALUE_DISPLAY.curve);
				break;
			
			case "Surface":
			case "Object":
			case "Node":
			case "Pathnode":
			case "Particle":
			case "Rigidbody Object":
			case "Domain":
			case "Struct":
			case "Strand":
			case "Mesh":
			case "Trigger":
			case "3D Mesh":
			case "3D Light":
			case "3D Camera":
			case "3D Scene":
			case "3D Material":
			case "PCX":
			case "Audio":
			case "Fdomain":
			case "SDF":
				inParent.animator = new valueAnimator(noone, inParent);
				inParent.def_val  = array_clone(noone);
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
			
			default:
				if(is_array(_val)) inParent.animator = new valueAnimator(0, inParent);
				
				inParent.def_val = 0;
				inParent.setDisplay(VALUE_DISPLAY._default);
				break;
		}
		
		switch(_vtype) {
			case VALUE_TYPE.trigger : 
				var bname = inputs[8].getValue();
				inParent.setDisplay(VALUE_DISPLAY.button, { name: bname, onClick: function() /*=>*/ { doTrigger = 1; } });
				break;
		}
	}
	
	static isRenderable = function(log = false) { //Check if every input is ready (updated)
		if(!active)	return false;
		if(!isRenderActive()) return false;
		
		for(var j = 0; j < 9; j++) if(!inputs[j].isRendered()) return false;
		return true;
	}
	
	static visibleCheck = function() {
		var _vty = inputs[9].getValue();
		
		inputs[10].setVisible(_vty >= 2, _vty >= 2);
		inputs[11].setVisible(_vty >= 2);
		
		     if(_vty == 0) { inParent.setVisible( true,  true); return; }
		else if(_vty == 1) { inParent.setVisible(false, false); return; }
		
		var _val = inputs[10].getValue();
		var _vto = inputs[11].getValue();
		var _vis = true;
		
		switch(_vty) {
			case 2 : _vis = _val == _vto; break;
			case 3 : _vis = _val != _vto; break;
			
			case 4 : _vis = _val >  _vto; break;
			case 5 : _vis = _val >= _vto; break;
			
			case 6 : _vis = _val <  _vto; break;
			case 7 : _vis = _val <= _vto; break;
		}
		
		inParent.setVisible(_vis, _vis);
	}
	
	static onValueUpdate = function(index = 0) {
		if(is_undefined(inParent)) return;
		
		var _inType		= inputs[2].getValue();
		var _val_type   = array_safe_get_fast(GROUP_IO_TYPE_MAP, _inType, VALUE_TYPE.any);
		
		if(index == 2) {
			if(outputs[0].type != _val_type) {
				var _to = outputs[0].getJunctionTo();
				for( var i = 0, n = array_length(_to); i < n; i++ )
					_to[i].removeFrom();
			}
			
			inputs[0].setValue(0);
			attributes.inherit_type = false;
		}
		
		refreshWidget();
		visibleCheck();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is(inParent, NodeValue)) return;
		if(inParent.name != display_name) {
			inParent.name = display_name;
			group.inputMap[$ string_replace_all(display_name, " ", "_")] = inParent;
		}
		
		outputs[0].setValue(inParent.getValue());
		
		visibleCheck();
		
		var _inType = inputs[2].getValue();
		var _dsType = inputs[0].getValue();
		if(_inType != __inType || _dsType != __dsType) {
			__inType = _inType;
			__dsType = _dsType;
			
			updateGroupInput(false);
		}
	}
	
	////- Draw

	static getGraphPreviewSurface = function() { var _in = array_safe_get(inputs, 0, noone); return _in == noone? noone : _in.getValue(); }
	
	static drawNodeDef = drawNode;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(inParent.isArray()) return false;
		
		var _vis = inputs[ 6].getValue();
		if(!_vis) return false;
		
		var _pos = inputs[12].getValue();
		var _sca = inputs[13].getValue();
		var _rot = inputs[14].getValue();
		
		var _px  = _x + _pos[0] * _s;
		var _py  = _y + _pos[1] * _s;
		_s *= _sca;
		
		inParent.overlay_draw_text = inputs[15].getValue();
		return inParent.drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny, _params);
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
		
		return drawJunctions(_draw, xx, yy, _mx, _my, _s, _s <= 0.5);
	}
	
	////- Serialize
	
	static postDeserialize = function() { createInput(false); }
	
	static postApplyDeserialize = function() {
		if(inParent == undefined) return;
		if(group == noone) return;
		
		inParent.name = name;
		getInputs();
		onValueUpdate();
		refreshWidget();
		
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