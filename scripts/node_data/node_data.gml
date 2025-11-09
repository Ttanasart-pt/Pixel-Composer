#region global
	#macro SHOW_PARAM (previewable && show_parameter)
	
	enum NODE_3D   { none, polygon, sdf }
	
	enum DYNA_INPUT_COND {
		none       = 0, 
		connection = 1 << 0,
		zero       = 1 << 1,
	}
#endregion

function Node(_x, _y, _group = noone) : __Node_Base(_x, _y) constructor {
	INIT_BASE_CLASS
	
	#region ---- Main & Active ----
		project      = PROJECT;
		itype        = noone;
		active       = true;
		renderActive = true;
		
		x = _x;
		y = _y;
		
		node_id              = UUID_generate();
		internalSeed         = seed_random(5);
		group                = _group;
		manual_deletable	 = true;
		manual_ungroupable	 = true;
		destroy_when_upgroup = false;
		
		if(NOT_LOAD) array_push(_group == noone? project.nodes : _group.getNodeList(), self);
		
		array_push(project.allNodes, self);
		
		inline_input         = true;
		inline_output        = true;
		inline_context       = noone;
		inline_parent_object = "";
		
		search_match  = -9999;
		onDoubleClick = -1;
		is_controller = false;
		is_instancer  = false;
		instanceBase  = undefined;
		
		static setParam = function() /*=>*/ {return false};
	#endregion
	
	if(NOT_LOAD) {
		project.nodeMap[? node_id] = self;
		project.setModified();
		
		run_in(1, function() /*=>*/ { 
			resetInternalName();
			if(renamed) return;
			
			display_name = __txt_node_name(instanceof(self), name);
			if(!LOCALE_DEF || TESTING) renamed = true;
		});
		
		RENDER_PARTIAL_REORDER
	}
	
	#region ---- Display ----
		visible        = true;
		color          = c_white;
		icon           = noone;
		icon_24        = noone;
		icon_blend     = undefined;
		node_draw_icon = noone;
		bg_spr         = THEME.node_bg;
		bg_spr_add     = .25;
		bg_spr_add_clr = c_white;
		
		name             = "";
		display_name     = "";
		internalName     = "";
		renamed          = false;
		tooltip          = "";
		
		w = 128;
		h = 128;
		
		min_w       = w;
		h_param     = h;
		name_height = 16;
		custom_grid = 0;
		
		preserve_height_for_preview = false;
		
		selectable   = true;
		clonable     = true;
		auto_height  = true;
		draw_padding = 4;
		draw_pad_w   = 0;
		draw_pad_h   = 0;
		
		display_parameter = new connectionParameter();
		
		draw_name = true;
		draggable = true;
		
		draw_boundary       = [0,0,0,0];
		draw_graph_culled   = false;
		
		active_drawing      = false;
		active_draw_index   = -1;
		active_draw_anchor  = false;
		
		draw_droppable      = false;
		
		junction_draw_pad_y = 32;
		junction_draw_hei_y = 16;
		junction_outp_hei_y = 16;
		
		branch_drawing      = false;
		draw_metadata       = true;
	#endregion
	
	#region ---- Junctions ----
		inputs           = [];
		outputs          = [];
		input_bypass     = [];
		inputm           = {};
		inputMappable    = [];
		
		inputMap         = {};
		outputMap        = {};
		input_value_map  = {};
		dimension_index  = 0;
		active_index     = -1;
		
		use_display_list		= true;
		input_display_list		= -1;
		output_display_list		= -1;
		inspector_display_list	= -1;
		is_dynamic_output		= false;
		
		frameInput         = nodeValue_Float("Render Frame", 0).setIndex(-1);
		inspectInput1      = nodeValue("Toggle Execution", self, CONNECT_TYPE.input, VALUE_TYPE.action,  false).setIndex(-1);
		inspectInput2      = nodeValue("Toggle Execution", self, CONNECT_TYPE.input, VALUE_TYPE.action,  false).setIndex(-1);
		updatedInTrigger   = nodeValue("Update",           self, CONNECT_TYPE.input, VALUE_TYPE.trigger, false).setIndex(-1).setTags(VALUE_TAG.updateInTrigger);
		updatedOutTrigger  = nodeValue_Output("Updated", VALUE_TYPE.trigger, false).setIndex(-1).setTags(VALUE_TAG.updateOutTrigger);
		
		insp1UpdateActive  = true;
		insp1UpdateTooltip = __txtx("panel_inspector_execute", "Execute node");
		insp1UpdateIcon    = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		insp2UpdateActive  = true;
		insp2UpdateTooltip = __txtx("panel_inspector_execute", "Execute node");
		insp2UpdateIcon    = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		is_dynamic_input   = false;
		auto_input		   = false;
		input_display_len  = 0;
		input_fix_len	   = 0;
		data_length        = 1;
		inputs_data		   = [];
		input_hash		   = "";
		input_hash_raw	   = "";
		
		inputs_amount        = 0;
		in_cache_len         = -4;
		inputDisplayList     = [];
		inputDisplayGroup    = [];
		inputDisplayBuilding = false;
		
		outputDisplayList    = [];
		
		inputs_draw_index    = [];
		outputs_draw_index   = [];
		out_cache_len        = -4;
		
		toRefreshNodeDisplay = true;
		input_mask_index     = -1;
		__mask_index         = undefined;
		__mask_mod_index     = undefined;
		
		current_data = [];
		junc_meta    = [
			nodeValue_Output( "Name",     VALUE_TYPE.text,  ""    ),
			nodeValue_Output( "Position", VALUE_TYPE.float, [0,0] ).setDisplay(VALUE_DISPLAY.vector),
		];
		
		for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
			junc_meta[i].index = i;
			junc_meta[i].tags  = VALUE_TAG.matadata;
		}
	#endregion
	
	#region ---- Attributes ----
		attributes.node_param_width = PREFERENCES.node_param_width;
		attributes.node_width        = 0;
		attributes.node_height       = 0;
		attributes.outp_meta         = false;
		attributes.show_render_frame = false;
		attributes.preview_size      = 128;
		
		attributes.annotation        = "";
		attributes.annotation_size   = .4;
		attributes.annotation_color  = COLORS._main_text_sub;
		
		setAttribute = function(k, v, r = false) /*=>*/ { attributes[$ k] = v;                if(r) triggerRender(); project.modified = true; }
		toggleAttribute = function(k, r = false) /*=>*/ { attributes[$ k] = !attributes[$ k]; if(r) triggerRender(); project.modified = true; }
		
		array_append(attributeEditors, [
			"Display",  
			["Annotation",     function() /*=>*/ {return attributes.annotation},       new textArea(TEXTBOX_INPUT.text,  function(v) /*=>*/ { setAttribute("annotation", v);          }) ],
			["Node Width",     function() /*=>*/ {return attributes.node_width},       textBox_Number(function(v) /*=>*/ { setAttribute("node_width", v);       refreshNodeDisplay(); }) ],
			["Node Height",    function() /*=>*/ {return attributes.node_height},      textBox_Number(function(v) /*=>*/ { setAttribute("node_height", v);      refreshNodeDisplay(); }) ],
			["Preview Height", function() /*=>*/ {return attributes.preview_size},     textBox_Number(function(v) /*=>*/ { setAttribute("preview_size", max(32, v)); refreshNodeDisplay(); }) ],
			["Params Width",   function() /*=>*/ {return attributes.node_param_width}, textBox_Number(function(v) /*=>*/ { setAttribute("node_param_width", v); refreshNodeDisplay(); }) ],
			
			"Node",
			["Auto Update",       function() /*=>*/ {return attributes.update_graph},        new checkBox(function() /*=>*/ { toggleAttribute("update_graph");            }) ],
			["Render Frame Input",function() /*=>*/ {return attributes.show_render_frame},   new checkBox(function() /*=>*/ { toggleAttribute("show_render_frame"); refreshNodeDisplay(); }) ],
			["Update Trigger",    function() /*=>*/ {return attributes.show_update_trigger}, new checkBox(function() /*=>*/ { toggleAttribute("show_update_trigger");     }) ],
			["Output Metadata",   function() /*=>*/ {return attributes.outp_meta},           new checkBox(function() /*=>*/ { toggleAttribute("outp_meta"); setHeight();  }) ],
			["Show In Timeline",  function() /*=>*/ {return attributes.show_timeline},       new checkBox(function() /*=>*/ { toggleAttribute("show_timeline"); 
				anim_timeline = attributes.show_timeline;
				refreshTimeline();
			})],
		]);
	#endregion
	
	#region ---- Preview ----
		show_parameter = PREFERENCES.node_param_show;
		
		show_input_name  = false;
		show_output_name = false;
	
		inspecting	     = false;
		previewing	     = 0;
		
		preview_surface	 = noone;
		preview_amount   = 0;
		previewable		 = true;
		preview_draw     = true;
		preview_speed	 = 0;
		preview_index	 = 0;
		preview_channel  = 0;
		preview_channel_temp = undefined;
		preview_alpha	 = 1;
		
		__preview_surf = false;
		__preview_sw   = noone;
		__preview_sh   = noone;
		
		preview_surface_sample = true;
		preview_select_surface = true;
		
		preview_x  = 0;
		preview_y  = 0;
		preview_mx = 0;
		preview_my = 0;
		
		graph_preview_alpha	= 1;
		
		getPreviewingNode = function() /*=>*/ {return self};
		
		preview_value = 0;
		preview_array = "";
		
		w_hovering  = false;
		w_hoverable = false;
		w_active    = false;
		
		inspector_scroll   = 0;
		inspector_collapse = {};
		
		reactive_on_hover  = false;
	#endregion
	
	#region ---- Rendering ------
		rendered         = false;
		update_on_frame  = false;
		render_timer     = 0;
		render_time		 = 0;
		render_cached    = false;
		auto_render_time = true;
		updated			 = false;
		passiveDynamic   = false;
		force_requeue    = false;
		
		temp_surface     = [];
		
		is_simulation    = false;
		is_group_io      = false;
		
		use_trigger      = false;
		loopable         = true;
		renderAll        = false;
	#endregion
	
	#region ---- Timeline ------
		timeline_item    = new timelineItemNode(self);
		anim_priority    = array_length(project.allNodes);
		is_anim_timeline = false;
	#endregion
	
	#region ---- Notification ----
		value_validation = [0,0,0];
		manual_updated   = false;
	#endregion
	
	#region ---- Tools ----
		tools		= -1;
		rightTools	= -1;
		toolShow    = false;
		
		isGizmoGlobal   = false;
		tool_settings	= [];
		tool_attribute	= {};
	#endregion
	
	#region ---- 3D ----
		is_3D = NODE_3D.none;
	#endregion
	
	#region ---- Log ----
		messages     = [];
		messages_bub = false;
		messages_dbg = [];
		
		static logNode = function(text, _bubble = true) { 
			var _time = $"{string_lead_zero(current_hour, 2)}:{string_lead_zero(current_minute, 2)}.{string_lead_zero(current_second, 2)}";
			array_push(messages, [ _time, text ]); 
			if(_bubble) messages_bub = true;
		}
		
		static logNodeDebug = function(text, level = 1) { 
			LOG_IF(global.FLAG.render >= level, text);
			if(PROFILER_STAT == 0) return;
			
			_report = {
				type : "message",
				text, level,	
			};
			_report.node  = self;
			array_push(PROFILER_DATA, _report); 
		}
	#endregion
	
	#region ---- Serialization ----
		load_scale  = false;
		load_map    = -1;
		load_inst   = noone;
		load_group  = noone;
		load_igroup = noone;
	#endregion
	
	////- NAME
	
	static getFullName       = function() /*=>*/ {return renamed? $"[{name}] " + display_name : name};
	static getDisplayName    = function() /*=>*/ {return renamed?                display_name : name};
	static getInternalName   = function() /*=>*/ {return internalName != ""?     internalName : name};
	
	static resetInternalName = function() {
		var _str = string_replace_all(name, " ", "_");
			_str = string_replace_all(_str,  "/", "");
			_str = string_replace_all(_str,  "-", "");
		
		ds_map_delete(project.nodeNameMap, internalName);
		internalName = $"{_str}{internalSeed}";
		project.nodeNameMap[? internalName] = self;
	}
	
	static onSetDisplayName  = noone;
	static setDisplayName    = function(_name, _rec = true) {
		if(NOT_LOAD && _rec && display_name != _name) 
			recordAction(ACTION_TYPE.custom, function(data) /*=>*/ { 
			var _name = data.name;
			data.name = display_name;
			setDisplayName(_name, false);
		}, { name : display_name, tooltip : $"Rename node" }).setRef(self);
		
		renamed      = true;
		display_name = _name;
		internalName = string_replace_all(display_name, " ", "_");
		refreshNodeMap();
		PANEL_GRAPH.refreshDraw(1);
		
		if(onSetDisplayName) onSetDisplayName();
		return self;
	}
	
	static getNodeBase = function() /*=>*/ {return instanceBase ?? self};
	
	////- INSPECTOR
	
	static onInspector1Update  = noone;
	static inspector1Update    = function() /*=>*/ { onInspector1Update(); }
	static hasInspector1Update = function() /*=>*/ { return onInspector1Update != noone; }
	
	static onInspector2Update  = noone;
	static inspector2Update    = function() /*=>*/ { onInspector2Update(); }
	static hasInspector2Update = function() /*=>*/ { return onInspector2Update != noone; }
	
	////- STEP
	
	static stepBegin = function() {
		if(use_cache) cacheArrayCheck();
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.getValue()) { 
				getInputs();
				update();
				updatedInTrigger.setValue(false);
			}
			updatedOutTrigger.setValue(false);
		}
		
		if(is_simulation) project.animator.is_simulating = true;
		
		if(attributes.outp_meta) {
			junc_meta[0].setValue(getDisplayName());
			junc_meta[1].setValue([ x, y ]);
		}
		
		if(toRefreshNodeDisplay) {
			refreshNodeDisplay();
			toRefreshNodeDisplay = false;
		}
	}
	
	static setTrigger = function(index, 
	                             _tooltip  = __txtx("panel_inspector_execute", "Execute"), 
	                             _icon     = [ THEME.sequence_control, 1, COLORS._main_value_positive ], 
	                             _function = undefined) {
	                             	
		use_trigger         = true;
		
		if(index == 1) {
			insp1UpdateTooltip  = _tooltip;
			insp1UpdateIcon     = _icon;
			if(!is_undefined(_function)) onInspector1Update  = _function;
			
		} else if(index == 2) {
			insp2UpdateTooltip  = _tooltip;
			insp2UpdateIcon     = _icon;
			if(!is_undefined(_function)) onInspector2Update  = _function;
		} 
	}
	
	static triggerCheck = function() {
		if(!use_trigger) return;
		
		if(hasInspector1Update()) {
			inspectInput1.name = insp1UpdateTooltip;
			
			if(inspectInput1.getStaticValue()) {
				onInspector1Update();
				inspectInput1.setValue(false);
			}
		}
		
		if(hasInspector2Update()) {
			inspectInput2.name = insp2UpdateTooltip;
			
			if(inspectInput2.getStaticValue()) {
				onInspector2Update();
				inspectInput2.setValue(false);
			}
		}
	}
	
	static checkMask = function() {
		var _msk = is_surface(getSingleValue(__mask_index));
		inputs[__mask_mod_index + 0].setVisible(_msk);
		inputs[__mask_mod_index + 1].setVisible(_msk);
	}
	
	static checkMap = function() {
		for( var i = 0, n = array_length(inputMappable); i < n; i++ )
			inputMappable[i].mappableStep();
	}
	
	static step          = undefined
	static focusStep     = function() /*=>*/ {}
	static inspectorStep = function() /*=>*/ {}
	
	////- DYNAMIC IO
	
	dummy_input      = noone;
	dummy_insert     = noone;
	dummy_add_index  = noone;
	_dummy_add_index = noone;
	_dummy_start     = 0;
	
	auto_input                 = false;
	dyna_input_check_shift     =  0;
	input_display_dynamic      = -1;
	input_display_dynamic_full = undefined;
	dynamic_input_inspecting   =  0;
	
	createNewInput      = -1;
	dynamic_visibility  = -1;
	
    static setDynamicInput = function(_data_length = 1, _auto_input = true, _dummy_type = VALUE_TYPE.any, _dynamic_input_cond = DYNA_INPUT_COND.connection) {
		is_dynamic_input	= true;						
		auto_input			= _auto_input;
		dummy_type	 		= _dummy_type;
		data_length			= _data_length;
		dynamic_input_cond  = _dynamic_input_cond;
		
		if(auto_input) {
			dummy_input = nodeValue("Add value", self, CONNECT_TYPE.input, dummy_type, 0)
				.setDummy(function() /*=>*/ {
					var index = array_length(inputs);
					if(dummy_insert != noone) 
						index = input_fix_len + dummy_insert * data_length;
					
					repeat(data_length) array_insert(inputs, index, 0);
					return createNewInput(index);
				})
				.setVisible(false, true);
		}
		
		attributes.size = 0;
		resetDynamicInput();
	}
	
	static resetDynamicInput = function() {
		input_display_list_raw = array_clone(input_display_list, 1);
		input_display_len	   = input_display_list == -1? 0 : array_length(input_display_list);
		input_fix_len		   = array_length(inputs);
	}
	
	static refreshDynamicInput = function() {
		if(LOADING || APPENDING) return;
		if(dynamic_input_cond == DYNA_INPUT_COND.none) return;
		
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		var _input_display_list = array_clone(input_display_list_raw, 1);
		var sep = false;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _active = false;
			var _inp    = inputs[i + dyna_input_check_shift];
			
			if(dynamic_input_cond & DYNA_INPUT_COND.connection)
				_active = _active || _inp.hasJunctionFrom();
				
			if(dynamic_input_cond & DYNA_INPUT_COND.zero) {
				var _val = _inp.getValue();
				_active = _active || _val != 0 || _val != "";
			}
			
			if(_active) {
				if(sep && data_length > 1) array_push(_input_display_list, new Inspector_Spacer(20, true));
				sep = true;
				
				for( var j = 0; j < data_length; j++ ) {
					var _ind = i + j;
					
					if(_input_display_list != -1)
						array_push(_input_display_list, array_length(_in));
					array_push(_in, inputs[_ind]);
				}
			} else {
				for( var j = 0; j < data_length; j++ )
					delete inputs[i + j];
			}
		}
		
		array_foreach(_in, function(inp, i) /*=>*/ { inp.index = i });
		
		if(dummy_input) dummy_input.index = array_length(_in);
		inputs = _in;
		setHeight();
		
		if(input_display_dynamic == -1) input_display_list = _input_display_list;
	}

	static refreshDynamicDisplay = function() {
		if(input_display_dynamic == -1) return;
		array_resize(input_display_list, array_length(input_display_list_raw));
		
		var _amo = getInputAmount();
		if(_amo == 0) { dynamic_input_inspecting = 0; return; }
		
		dynamic_input_inspecting = min(dynamic_input_inspecting, _amo - 1);
		
		if(dynamic_input_inspecting == noone) {
			for( var i = 0; i < _amo; i++ ) {
				var _ind = input_fix_len + i * data_length;
				var _list = input_display_dynamic;
				
				if(!is_undefined(input_display_dynamic_full))
					_list = input_display_dynamic_full(i);
					
				for( var j = 0, n = array_length(_list); j < n; j++ ) {
					var v = _list[j]; 
					if(is_real(v)) v += _ind;
					
					array_push(input_display_list, v);
				}
			}
			return;
		} 
		
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		for( var i = 0, n = array_length(input_display_dynamic); i < n; i++ ) {
			var v = input_display_dynamic[i]; if(is_real(v)) v += _ind;
			array_push(input_display_list, v);
		}
		
		if(dynamic_visibility != -1) dynamic_visibility();
	}
	
	static getInputAmount = function() { return (array_length(inputs) - input_fix_len) / data_length; }
	
	static onInputResize = function() { refreshDynamicInput(); triggerRender(); }
	
	static getOutput = function(_y = 0, junc = noone) {
		var _targ = noone;
		var _dy   = infinity;
		
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _outp = outputs[i];
			
			if(!is(_outp, NodeValue)) continue;
			if(!_outp.isVisible())    continue;
			if(junc != noone && !junc.isConnectable(_outp, true)) continue;
			
			var _ddy = abs(_outp.y - _y);
			if(_ddy < _dy) {
				_targ = _outp;
				_dy   = _ddy;
			}
		}
		return _targ;
	}
	
	static getInput = function(_y = 0, _junc = noone, _shft = input_fix_len, _over = false) {
		
		var _targ = noone;
		var _dy   = infinity;
		for( var i = _shft, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			
			if(!_inp.isVisible()) continue;
			if(_inp.value_from != noone) continue;
			if(_junc != noone && (value_bit(_junc.type) & value_bit(_inp.type)) == 0) continue;
			
			var _ddy = abs(_inp.y - _y);
			
			if(_ddy < _dy) {
				_targ = _inp;
				_dy   = _ddy;
			}
		}
		
		if(dummy_input) {
			var _ddy = abs(dummy_input.y - _y);
			if(_ddy < _dy) _targ = dummy_input;
		}
		
		if(_targ != noone || !_over) return _targ;
		
		var _dy = infinity;
		for( var i = _shft, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			
			if(!_inp.isVisible()) continue;
			if(_junc != noone && (value_bit(_junc.type) & value_bit(_inp.type)) == 0) continue;
			
			var _ddy = abs(_inp.y - _y);
			
			if(_ddy < _dy) {
				_targ = _inp;
				_dy   = _ddy;
			}
		}
		
		return _targ;
	}
	
	static deleteDynamicInput = function(index) {
		var _ind = input_fix_len + index * data_length;
		
		array_delete(inputs, _ind, data_length);
		dynamic_input_inspecting = min(dynamic_input_inspecting, getInputAmount() - 1);
		refreshDynamicDisplay();
		triggerRender();
	}
	
	////- JUNCTIONS
	
	static newActiveInput = function(i) /*=>*/ { newInput(i, nodeValue_Active()); active_index = i; }
	static newInput = function(i, j) /*=>*/ { 
		inputs = array_verify_min(inputs, i);
		
		inputm[$ j.name] = j;
		inputs[i] = j; 
		
		j.setIndex(i); 
		if(j.name == "Mask") input_mask_index = i;
		
		return j;
	}
	
	static newOutput = function(i, j) /*=>*/ { outputs[i] = j; j.setIndex(i); return j; }
	
	static getInputJunctionAmount  = function( ) /*=>*/ {return (input_display_list == -1 || !use_display_list)? array_length(inputs) : array_length(input_display_list)};
	static getInputJunctionIndex   = function(i) /*=>*/ { INLINE 
		if(input_display_list == -1 || !use_display_list) return i;
		
		var _junci = input_display_list[i];
		return is_numeric(_junci)? _junci : noone;
	}
	
	static getOutputJunctionAmount = function( ) /*=>*/ {return output_display_list == -1? array_length(outputs) : array_length(output_display_list)};
	static getOutputJunctionIndex  = function(i) /*=>*/ {return output_display_list == -1? i : output_display_list[i]};
	
	static getOutputChannelAmount  = function( ) /*=>*/ {return array_length(outputs)};
	static getOutputChannelName    = function(i) /*=>*/ {return outputs[i].name};
	
	static updateIO = function() {
		
		for( var i = 0, n = array_length(inputs); i < n; i++ )
			if(is(inputs[i], NodeValue)) inputs[i].visible_in_list = false;
		
		inputs_amount     = getInputJunctionAmount();
		inputs_draw_index = [];
		
		for( var i = 0; i < inputs_amount; i++ ) {
			var _input = getInputJunctionIndex(i);
			if(_input == noone) continue;
			
			var _inp = array_safe_get(inputs, _input);
			if(!is(_inp, NodeValue)) continue;
			
			_inp.visible_in_list = true;
			
			if(_inp.index && _inp.isVisible()) array_push(inputs_draw_index, _inp.index);
		}
		
		outputs_draw_index  = array_create_ext(getOutputJunctionAmount(), function(i) /*=>*/ {return getOutputJunctionIndex(i)});
	}
	
	static getJunctionList = function() {
		inputDisplayList = [];
		
		var iamo = getInputAmount();
		if(input_display_dynamic != -1 && iamo) {
			
			for( var i = 0, n = array_length(input_display_list_raw); i < n; i++ ) {
				var ind = input_display_list_raw[i];
				if(!is_real(ind)) continue;
				
				var jun = array_safe_get(inputs, ind, noone);
				if(!is(jun, NodeValue) || !jun.isVisible()) continue;
				
				array_push(inputDisplayList, jun);
			}
			
			for( var i = 0; i < iamo; i++ ) {
				var ind = input_fix_len + i * data_length;
				
				for( var j = 0, n = array_length(input_display_dynamic); j < n; j++ ) {
					if(!is_real(input_display_dynamic[j])) continue;
					
					var _in_ind = ind + input_display_dynamic[j];
					var jun = array_safe_get(inputs, _in_ind, noone);
					if(!is(jun, NodeValue) || !jun.isVisible()) continue;
					
					array_push(inputDisplayList, jun);
				}
			}
			
		} else if (input_display_list != -1) {
			
			for( var i = 0, n = array_length(input_display_list); i < n; i++ ) {
				var ind = input_display_list[i];
				
				if(is_real(ind)) {
					var jun = array_safe_get(inputs, ind, noone);
					if(!is(jun, NodeValue) || !jun.isVisible()) continue;
					array_push(inputDisplayList, jun);
					
				} else if(is_array(ind) && array_length(ind) >= 3) {
					var _trInd = ind[2];
					var jun = array_safe_get(inputs, _trInd, noone);
					if(!is(jun, NodeValue) || !jun.isVisible()) continue;
					array_push(inputDisplayList, jun);
				}
			}
			
		} else {
			
			for( var i = 0, n = array_length(inputs); i < n; i++ ) {
				var jun = inputs[i];
				if(!is(jun, NodeValue) || !jun.isVisible()) continue;
				array_push(inputDisplayList, jun);
			}
		}
		
		if(auto_input && dummy_input) {
			if(dummy_add_index == noone) array_push(inputDisplayList, dummy_input);
			else array_insert(inputDisplayList, _dummy_start + dummy_add_index, dummy_input);
		}
		
		if(attributes.show_render_frame) array_insert(inputDisplayList, 0, frameInput);
		
		outputDisplayList = [];
		
		array_foreach(outputs, function(jun) /*=>*/ { if(jun.isVisible()) array_push(outputDisplayList, jun); });
		array_foreach(inputs,  function(jun) /*=>*/ { if(jun.bypass_junc.isVisible()) array_push(outputDisplayList, jun.bypass_junc); });
		if(attributes.outp_meta) array_foreach(junc_meta, function(jun) /*=>*/ { if(jun.isVisible()) array_push(outputDisplayList, jun); });
		
	}
	
	static onValidate = function() {
		value_validation[VALIDATION.pass]	 = 0;
		value_validation[VALIDATION.warning] = 0;
		value_validation[VALIDATION.error]   = 0;
		
		array_foreach(inputs, function(jun) /*=>*/ { value_validation[jun.value_validation] += (is(jun, NodeValue) && jun.value_validation); });
	}
	
	static onIOValidate = function() {
		var _inline_input = noone;
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _j = inputs[i];
			if(_j.value_from == noone) continue;
			
			var _n = _j.value_from.node;
			if(_n.inline_context == noone) continue;
			
			if(_inline_input != noone && _inline_input != _n.inline_context)
				noti_warning($"Node {getDisplayName()} connected to multiple inline loop inputs, this can cause render error.", noone, self);
				
			_inline_input = _n.inline_context;
		}
		
		var _inline_output = noone;
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _j = outputs[i];
			var _t = _j.getJunctionTo();
			
			for( var j = 0, m = array_length(_t); j < m; j++ ) {
				var _n = _t[j].node;
				if(_n.inline_context == noone) continue;
			
				if(_inline_output != noone && _inline_output != _n.inline_context)
					noti_warning($"Node {getDisplayName()} connected to multiple inline loop outputs, this can cause render error.", noone, self);
					
				_inline_output = _n.inline_context;
			}
		}
		
		if(_inline_input != noone && _inline_output != noone && _inline_input != inline_context) {
			noti_warning($"Node {getDisplayName()} connected between two inline nodes, but the node itself is not part of the group. The program has automatically add the node back to inline group.", noone, self);
			_inline_input.addNode(self);
		}
	}
	
	static getJunctionTos = function() {
		var _vto = array_create(array_length(outputs));
		for (var j = 0; j < array_length(outputs); j++)
			_vto[j] = array_clone(outputs[j].value_to);
			
		return _vto;
	}
	
	static getNodeFrom = function() {
		var _nodes = [];
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) { //inputs
			var jun = inputDisplayList[i];
			var _fr = jun.getNodeFrom();
			if(_fr != noone) array_push(_nodes, _fr);
		}
		
		return array_unique(_nodes);
	}
	
	static getNodeTo = function() {
		var _nodes = [];
		
		for (var j = 0; j < array_length(outputs); j++) {
			var _to = outputs[j].value_to;
			
			for( var i = 0, n = array_length(_to); i < n; i++ )
				if(_to[i].node.active) array_push(_nodes, _to[i].node);
		}
		
		return array_unique(_nodes);
	}
	
	static checkConnectGroup = function(_io) {
		
		var _y  = y;
		var _n  = noone;
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _in = inputs[i];
			if(_in.value_from == noone)				continue;
			if(_in.value_from.node.group == group)	continue;
			
			var _ind = string(_in.value_from);
			_io.map[$ _ind] = _in.value_from;
			
			if(!struct_has(_io.inputs, _ind))
				_io.inputs[$ _ind ] = [];
			array_push(_io.inputs[$ _ind ], _in);
		}
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _ou = outputs[i];
			
			for(var j = 0; j < array_length(_ou.value_to); j++) {
				var _to = _ou.value_to[j];
				if(_to.value_from != _ou)   continue;
				if(!_to.node.active)        continue;
				if(_to.node.group == group) continue;
				
				var _ind = string(_ou);
				_io.map[$ _ind] = _ou;
				
				if(!struct_has(_io.outputs, _ind))
					_io.outputs[$ _ind] = [];
				array_push(_io.outputs[$ _ind ], _to);
			}
		}
	}
	
	////- PRESETS
	
	set_default = true;
	static skipDefault = function() /*=>*/ { set_default = false; return self; }
	
	static resetDefault = function() {
		var _defPreset = setPreset("_default");
		if(_defPreset) return;
		
		array_foreach(inputs, function(i) /*=>*/ {return i.resetValue()});
	} 
	
	static setPreset = function(pName) {
		var _fName = $"{instanceof(self)}>{pName}";
		if(!ds_map_exists(global.PRESETS_MAP_NODE, _fName)) return false;
		
		var _preset = global.PRESETS_MAP_NODE[? _fName];
		if(_preset.content == -1) _preset.content = json_load_struct(_preset.path);
		
		deserialize(_preset.content, true, 1 + (pName == "_default"));
		return true;
	}
	
	////- INPUTS
	
	static addInput = function(junctionFrom, shift = input_fix_len) {
		var targ = getInput(y, junctionFrom, shift);
		if(targ == noone) return noone;
		
		return targ.setFrom(junctionFrom);
	}
	
	static getInputs = function(frame = CURRENT_FRAME) {
		inputs_data	= array_verify_min(inputs_data, array_length(inputs));
		__frame     = frame;
		
		array_foreach(inputs, function(_inp, i) /*=>*/ {
			if(!is(_inp, NodeValue) || !_inp.isDynamic()) return;
			
			var val = _inp.getValue(__frame);
			
			if(_inp.bypass_junc.visible) _inp.bypass_junc.setValue(val);
			inputs_data[i] = val;
			input_value_map[$ _inp.internalName] = val;
		});
		
	}
	
	////- UPDATE
	
	static preUpdate = undefined
	static update    = function() /*=>*/ {}
	
	static forceUpdate = function() {
		input_hash = "";
		doUpdate();
	}
	
	static postUpdate = function(frame = CURRENT_FRAME) {}
	
	static doUpdateLite = function(frame = CURRENT_FRAME) {
		if(is_3D == NODE_3D.polygon) USE_DEPTH = true;
		render_timer = get_timer();
		setRenderStatus(true);
		
		if(frameInput.value_from != noone) frame = frameInput.getValue() - 1;
		
		if(attributes.update_graph) {
			try      { if(preUpdate) preUpdate(frame); update(frame);   } 
			catch(e) { log_warning("RENDER", exception_print(e), self); }
		}
		
		render_time = get_timer() - render_timer;
	}
	
	static doUpdateFull = function(frame = CURRENT_FRAME) {
		if(is_3D == NODE_3D.polygon) USE_DEPTH = true;
		if(project.safeMode) return;
		
		render_timer = get_timer();
		var _updateRender = !is(self, Node_Collection) || !managedRenderOrder;
		if(_updateRender) setRenderStatus(true);
		
		if(frameInput.value_from != noone) frame = frameInput.getValue() - 1;
		
		getInputs(frame);
		
		if(cached_manual || (use_cache == CACHE_USE.auto && recoverCache())) {
			render_cached = true;
			
		} else {
			render_cached = false;
			
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $">>>>>>>>>> DoUpdate called from {getInternalName()} <<<<<<<<<<");
			
			var sBase = surface_get_target();	
			
			try { if(attributes.update_graph) { if(preUpdate) preUpdate(frame); update(frame); } }
			catch(exception) {
				var sCurr = surface_get_target();
				while(surface_get_target() != sBase)
					surface_reset_target();
			
				log_warning("RENDER", exception_print(exception), self);
			}
		}
		
		if(!IS_PLAYING) {
			array_foreach(inputs,  function(in, i) /*=>*/ { in.updateColor(getInputData(i)); });
			array_foreach(outputs, function(in, i) /*=>*/ { in.updateColor(in.getValue());   });
		}
		
		postUpdate(frame);
		cached_manual = false;
		
		if(!use_cache && project.onion_skin.enabled) {
			var _amo = array_length(outputs), _i = 0, i;
			repeat(_amo) { i = _i++;
				if(outputs[i].type != VALUE_TYPE.surface) continue;
				cacheCurrentFrame(outputs[i].getValue());
				break;
			}
		}
		
		if(hasInspector1Update() && inspectInput1.getValue()) onInspector1Update(true);
		if(hasInspector2Update() && inspectInput2.getValue()) onInspector2Update(true);
		
		updatedOutTrigger.setValue(true);
		
		if(!is(self, Node_Collection)) render_time = get_timer() - render_timer;
		
		LOG_BLOCK_END();
	}
	
	doUpdate     = doUpdateFull;
	getInputData = function(i,d=0) /*=>*/ {return array_safe_get_fast(inputs_data, i, d)};
	
	static valueUpdate     = function(index = noone) { onValueUpdate(index); cacheCheck(); }
	static valueFromUpdate = function(index = noone) {
		onValueFromUpdate(index);
		onValueUpdate(index);
		
		if(auto_input && !LOADING && !APPENDING) 
			refreshDynamicInput();
			
		cacheCheck();
	}
	
	static onValueUpdate     = function(index = noone) {}
	static onValueFromUpdate = function(index = noone) {}
	
	static getDimension = function() /*=>*/ {return inputs[dimension_index].getValue()};
	
	////- RENDER
	
	static isAnimated = function(frame = CURRENT_FRAME) {
		if(update_on_frame) return true;
		return array_any(inputs, function(inp) /*=>*/ {return inp.getAnim()});
	}
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) {
		if(update_on_frame)           return true;
		if(!rendered)                 return true;
		if(instanceBase != undefined) return true;
		
		force_requeue = false;
		__temp_frame  = frame;
		return array_any(inputs, function(inp) /*=>*/ {return inp.isActiveDynamic(__temp_frame)});
	}
	
	static triggerRender = function(resetSelf = true) {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Trigger render for {getFullName()}");
		
		if(resetSelf) resetRender(false);
		if(renderAll) RENDER_ALL
		else          RENDER_PARTIAL
		
		if(!IS_PLAYING) {
			if(is(group, Node_Collection)) group.triggerRender();
			else array_foreach(getNextNodesRaw(), function(n) /*=>*/ {return n.triggerRender()});
		}
		
		LOG_BLOCK_END();
	}
	
	static forwardPassiveDynamic = function() {
		rendered = false;
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _outp = outputs[i];
			
			array_foreach(_outp.getJunctionTo(), function(_t) /*=>*/ {
				if(has(_t, "from") && is(_t.from, Node_Group_Input)) {
					profile_log(3, $"Propagate passive dynamic to group io {_t.from}");
					_t.from.passiveDynamic = true;
					_t.from.rendered       = false;
				}
				
				profile_log(3, $"Propagate passive dynamic to {_t.node}");
				_t.node.passiveDynamic = true;
				_t.node.rendered       = false;
			});
		}
	}
	
	static resetRender = function(_clearCache = false) { setRenderStatus(false); if(_clearCache) clearInputCache(); }
	
	static isLeaf = function(frame = CURRENT_FRAME) { return array_all(inputs, function(inp) /*=>*/ {return inp.value_from == noone}); }
	
	static isLeafList = function(list = noone) {
		INLINE 
		
		if(list == noone) return isLeaf();
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i].value_from;
			
			if(_inp != noone && array_exists(list, _inp.node)) 
				return false;
		}
		
		return true;
	}
	
	static isRenderActive = function() { return !is_instancer && (renderActive || (PREFERENCES.render_all_export && IS_RENDERING)); }
	
	static isRenderable = function(log = false) { //Check if every input is ready (updated)
		if(!active || !isRenderActive()) return false;
		
		for(var i = 0, n = array_length(inputs); i < n; i++) {
			if(inputs[i].isRendered()) continue;
			
			LOG_IF(global.FLAG.render == 1, $"→→ x Node {internalName} {inputs[i]} not rendered.");
			return false;
		}
		
		return true;
	}
	
	static setRenderStatus = function(result) {
		if(rendered == result) return;
		logNodeDebug($"Set render status for {getFullName()} : {result}", 3);
		
		rendered = result;
	}
	
	static getPreviousNodes = function() {
		var prev = [];
		var prMp = {};
		var _n;
		
		if(attributes.show_update_trigger && updatedInTrigger.value_from) {
			_n = updatedInTrigger.value_from.node;
			
			if(!struct_has(prMp, _n.node_id)) {
				array_push(prev, _n);
				prMp[$ _n.node_id] = 1;
			}
		}
		
		if(frameInput.value_from != noone) {
			_n = frameInput.value_from.node;
			if(!struct_has(prMp, _n.node_id)) {
				array_push(prev, _n);
				prMp[$ _n.node_id] = 1;
			}
			
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _in = inputs[i];
			
			if(_in.value_from != noone) {
				_n = _in.value_from.node;
				if(!struct_has(prMp, _n.node_id)) {
					array_push(prev, _n);
					prMp[$ _n.node_id] = 1;
				}
				
			}
				
			if(_in.value_from_loop != noone) {
				_n = _in.value_from_loop;
				if(!struct_has(prMp, _n.node_id)) {
					array_push(prev, _n);
					prMp[$ _n.node_id] = 1;
				}
			}
		}
		
		onGetPreviousNodes(prev);
		return prev;
	}
	
	static onGetPreviousNodes = function(arr) {}
	
	__nextNodes       = noone;
	__nextNodesToLoop = noone;
	
	static getNextNodes = function(checkLoop = false) {
		if(checkLoop) { if(__nextNodesToLoop != noone && __nextNodesToLoop.bypassNextNode()) __nextNodesToLoop.getNextNodes(); return; }
		__nextNodesToLoop = noone;
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _ot = outputs[i];
			if(is(_ot, NodeValue) && !_ot.forward) continue;
			
			for( var j = 0, n = array_length(_ot.value_to_loop); j < n; j++ ) {
				var _to = _ot.value_to_loop[j];
				if(!_to.active) continue;
				
				__nextNodesToLoop = _to;
				if(!_to.bypassNextNode()) continue;
				return _to.getNextNodes();
			}
		}
		
		if(__nextNodes != noone) return __nextNodes;
		var nodes = [];
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _ot = outputs[i];
			if(is(_ot, NodeValue) && !_ot.forward) continue;
			
			for( var j = 0, m = array_length(_ot.value_to); j < m; j++ ) {
				var _jto = _ot.value_to[j];
				if(_jto.value_from != _ot || !_jto.node.active) continue;
				array_push(nodes, _jto.node);
			}
		}	
		
		for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
			var _ot  = junc_meta[i];
			
			for( var j = 0, m = array_length(_ot.value_to); j < m; j++ ) {
				var _jto = _ot.value_to[j];
				if(_jto.value_from != _ot || !_jto.node.active) continue;
				array_push(nodes, _jto.node);
			}
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _in = inputs[i].bypass_junc;
			if(_in == noone || !_in.visible) continue;
			
			for( var j = 0, m = array_length(_in.value_to); j < m; j++ ) {
				var _jto = _in.value_to[j];
				if(_jto.value_from != _in || !_jto.node.active) continue;
				array_push(nodes, _jto.node);
			}
		}
		
		nodes = array_unique(nodes);
		__nextNodes = nodes;
		
		return nodes;
	}
	
	static getNextNodesRaw = function() {
		var nodes = [];
		
		for(var i = 0; i < array_length(outputs); i++) {
			var _ot = outputs[i];
			if(!is(_ot, NodeValue)) continue;
			if(!_ot.forward || _ot.type == VALUE_TYPE.node) continue;
			
			for( var j = 0, n = array_length(_ot.value_to_loop); j < n; j++ ) {
				var _to = _ot.value_to_loop[j];
				if(!_to.active || !_to.bypassNextNode()) continue;
				
				return _to.getNextNodes();
			}
		
			var _tos = _ot.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ )
				array_push(nodes, _tos[j].node);
		}	
		
		for(var i = 0; i < array_length(inputs); i++) {
			var _in = inputs[i];
			if(!is(_in, NodeValue)) continue;
			
			var _tos = _in.bypass_junc.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ )
				array_push(nodes, _tos[j].node);
		}
		
		return nodes;
	}
	
	__getNodeChildList_cache   = {};
	__getNodeChildList_cacheId = "";
	
	static __getNodeChildList = function(_node, _arr) {
		if(_node == self) {
			array_push(_arr, self);
			return true;
		}
		
		var _prev = getPreviousNodes();
		for( var i = 0, n = array_length(_prev); i < n; i++ ) {
			if(_prev[i].__getNodeChildList(_node, _arr)) {
				array_push(_arr, self);
				return true;
			}
		}
		
		return false;
	}
	
	static getNodeChildList = function(_node) {
		if(__getNodeChildList_cacheId != project.nodeTopoID) 
			__getNodeChildList_cache = {};
		
		if(struct_has(__getNodeChildList_cache, _node)) return __getNodeChildList_cache[$ _node];
		
		var _ind_self = array_find(project.nodeTopo, self);
		var _ind_node = array_find(project.nodeTopo, _node);
		if(_ind_self == -1 || _ind_node == -1) return noone;
		
		var _arr  = [];
		var _reach = __getNodeChildList(_node, _arr);
		if(_reach == false) _arr = noone;
		
		__getNodeChildList_cache[$ _node] = _arr;
		__getNodeChildList_cacheId = project.nodeTopoID;
		return _arr;
	}
	
	static onAnimationStart = function() {
		if(use_cache == CACHE_USE.auto && !isAllCached()) clearCache();
	}
	
	static postRender = function() {}
	
	////- DRAW
	
	static setHeight = function() {
		w = attributes.node_width? attributes.node_width : min_w;
		if(SHOW_PARAM) w = attributes.node_param_width;
		
		if(!auto_height) return;
		
		var _ps = is_surface(getGraphPreviewSurface()) || preserve_height_for_preview;
		var _oo = array_safe_get(outputs, preview_channel, noone)
		var _ou = _oo != noone && _oo.type == VALUE_TYPE.surface;
		var _prev_surf = previewable && preview_draw && (_ps || _ou);
		
		junction_draw_hei_y = SHOW_PARAM? 32 : 16;
		junction_draw_pad_y = SHOW_PARAM? attributes.preview_size : 24;
		
		var surf_h = min(w, attributes.preview_size);
		var _hi, _ho;
		
		if(SHOW_PARAM) {
			_hi = attributes.preview_size;
			_ho = 24;
			
		} else if(previewable) {
			_hi = junction_draw_pad_y;
			_ho = junction_draw_pad_y;
			
		} else {
			junction_draw_hei_y = 16;
			junction_draw_pad_y = name_height / 2;
			
			_hi = name_height;
			_ho = name_height;
		}
		
		var _p = previewable;
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			if(!inputs[i].isVisible()) continue;
			
			if(_p) _hi += junction_draw_hei_y;
			_p = true;
		}
		
		if(auto_input && dummy_input) _hi += junction_draw_hei_y;
		var _p = previewable;
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			if(!outputs[i].isVisible()) continue;
			
			if(_p) _ho += junction_draw_hei_y;
			_p = true;
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			if(!inputs[i].bypass_junc.visible) continue;
			
			if(_p) _ho += junction_outp_hei_y;
			_p = true;
		}
		
		if(attributes.outp_meta) 
		for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
			if(!junc_meta[i].isVisible()) continue;
			
			if(_p) _ho += junction_draw_hei_y;
			_p = true;
		}
		
		h = max(previewable? attributes.preview_size : name_height, _prev_surf * surf_h, _hi, _ho);
		if(attributes.node_height) h = max(h, attributes.node_height);
	}
	
	static setShowParameter = function(showParam) {
		show_parameter = showParam;
		refreshNodeDisplay();
		return self;
	}
	
	static setPreviewable = function(prev) {
		if(previewable == prev) return;
		
		previewable = prev;
		y += previewable? -16 : 16;
	}
	
	static setVisible = function(vis) { visible = vis; return self; }
	
	static onInspect = function() {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
	}
	
	static cullCheck = function(_x, _y, _s, minx, miny, maxx, maxy) {
		var x0 = x * _s + _x;
		var y0 = y * _s + _y;
		var x1 = (x + w) * _s + _x;
		var y1 = (y + h) * _s + _y;
		
		draw_boundary[0] = minx;
		draw_boundary[1] = miny;
		draw_boundary[2] = maxx;
		draw_boundary[3] = maxy;
		
		draw_graph_culled = !rectangle_in_rectangle(minx, miny, maxx, maxy, x0, y0, x1, y1);
		return !draw_graph_culled;
	}
	
	static refreshNodeDisplay = function() {
		updateIO();
		setHeight();
		getJunctionList();
		setJunctionIndex();
		
		PANEL_GRAPH.refreshDraw(1);
		__preDraw_data.force     = true;
	} 
	
	__preDraw_data = { _x: undefined, _y: undefined, _w: undefined, _h: undefined, _s: undefined, _p: undefined, sp: undefined, force: false };
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _d   = __preDraw_data;
		var _upd = _d.force || _d._x != xx || _d._y != yy || _d._s != _s || _d._w != w || _d._h != h || _d._p != previewable || _d.sp != show_parameter 
		
		_d._x = xx;
		_d._y = yy;
		_d._w = w;
		_d._h = h;
		_d._s = _s;
		_d._p = previewable;
		_d.sp = show_parameter;
		
		_d.force = false;
		
		#region dummy
			_dummy = auto_input && dummy_input && PANEL_GRAPH.value_dragging;
			
			if(_dummy || _dummy_add_index != dummy_add_index) {
				getJunctionList();
				PANEL_GRAPH.refreshDraw(1);
			}
			_dummy_add_index = dummy_add_index;
			dummy_add_index  = noone;
			dummy_insert     = noone;
			
			if(!_upd && !_dummy) {
				if(SHOW_PARAM) h = h_param;
				onPreDraw(_x, _y, _s, _iy, _oy);
				return;
			}
		#endregion
		
		var jun;
		var inspCount = hasInspector1Update() + hasInspector2Update();
		var ind = 1;
		if(hasInspector1Update()) {
			inspectInput1.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput1.y = yy;
			ind++;
		}
		
		if(hasInspector2Update()) {
			inspectInput2.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput2.y = yy;
			ind++;
		}
		
		updatedInTrigger.x = xx;
		updatedInTrigger.y = yy + 10;
		
		updatedOutTrigger.x = xx + w * _s;
		updatedOutTrigger.y = yy + 10;
		
		if(in_cache_len != array_length(inputDisplayList) || out_cache_len != array_length(outputs)) {
			refreshNodeDisplay();
			
			in_cache_len  = array_length(inputDisplayList);
			out_cache_len = array_length(outputs);
		}
		
		if(SHOW_PARAM) {
			var _junRy = attributes.preview_size + junction_draw_hei_y / 2;
			var _junSy = yy + _junRy * _s;
			
			_ix = xx;           _rix = x;
			_iy = _junSy;       _riy = y + _junRy;
			
			var _junRy = 24;
			var _junSy = yy + _junRy * _s;
			
			_ox = xx + w * _s;  _rox = x + w;
			_oy = _junSy;       _roy = y + _junRy;
			
		} else {
			var _junRy = junction_draw_pad_y;
			var _junSy = yy + _junRy * _s;
		
			_ix = xx;           _rix = x;
			_iy = _junSy;       _riy = y + _junRy;
			
			_ox = xx + w * _s;  _rox = x + w;
			_oy = _junSy;       _roy = y + _junRy;
			
		}
		
		__s = _s;
		__mx = _mx;
		__my = _my;
		
		array_foreach(inputs, function(jun) /*=>*/ { jun.x = _ix; jun.y = _iy; });
		
		inputDisplayGroup = [];
		_curr_group  = noone;
		_curr_index  = noone;
		
		_dummy_curr  = 0; 
		_dummy_start = 0;
		_dummy = _dummy && key_mod_press(CTRL);
		if(_dummy) dummy_insert = 0;
		
		array_foreach(inputDisplayList, function(jun, i) /*=>*/ { 
			jun.x = _ix; jun.rx = _rix; 
			jun.y = _iy; jun.ry = _riy; 
			
			if(_dummy) {
				if(jun.index < input_fix_len)
					_dummy_start = max(_dummy_start, i + 1);
				
				var _jy = _iy - junction_draw_hei_y * __s * .5;
				
				if(!jun.is_dummy) 
					_dummy_curr = max(_dummy_curr, floor((jun.index - input_fix_len) / data_length) + 1);
				
				if(jun.index >= input_fix_len && __my > _jy) {
					dummy_add_index = i - _dummy_start;
					dummy_insert    = _dummy_curr;
				}
			}
			
			if(is_dynamic_input && !jun.is_dummy && jun.index >= input_fix_len) {
				var _ind = floor((jun.index - input_fix_len) / data_length);
				
				if(_ind != _curr_index || _curr_group == noone) {
					_curr_index = _ind;
					_curr_group = [ jun.x, jun.y, undefined, 0 ];
					
				} else if(_curr_group[2] == undefined) {
					_curr_group[2] = jun.y;
					array_push(inputDisplayGroup, _curr_group);
					
				} else 
					_curr_group[2] = max(_curr_group[2], jun.y);
			}
			
			if(jun.draw_group != undefined) {
				if(jun.draw_group != _curr_index || _curr_group == noone) {
					_curr_index = jun.draw_group;
					_curr_group = [ jun.x, jun.y, undefined, 0 ];
					
				} else if(_curr_group[2] == undefined) {
					_curr_group[2] = jun.y;
					array_push(inputDisplayGroup, _curr_group);
					
				} else 
					_curr_group[2] = max(_curr_group[2], jun.y);
			}
			
			_riy += junction_draw_hei_y;
			_iy  += junction_draw_hei_y * __s;
		});
		
		array_foreach(outputs_draw_index, function(jun) /*=>*/ { 
			jun = outputs[jun]; 
			jun.x = _ox; jun.rx = _rox; 
			jun.y = _oy; jun.ry = _roy; 
			
			if(jun.draw_group != undefined) {
				if(jun.draw_group != _curr_index || _curr_group == noone) {
					_curr_index = jun.draw_group;
					_curr_group = [ jun.x, jun.y, undefined, 0 ];
					
				} else if(_curr_group[2] == undefined) {
					_curr_group[2] = jun.y;
					array_push(inputDisplayGroup, _curr_group);
					
				} else 
					_curr_group[2] = max(_curr_group[2], jun.y);
			}
			
			var __vis = jun.isVisible();
			_roy += junction_outp_hei_y * __vis 
			_oy  += junction_outp_hei_y * __vis * __s; 
		});
		
		array_foreach(inputs,           function(jun) /*=>*/ { jun   = jun.bypass_junc; if(!jun.visible) return; 
		                                           jun.x = _ox; jun.y = _oy; _oy += junction_draw_hei_y * jun.visible * __s; });
		array_foreach(junc_meta,        function(jun) /*=>*/ { jun.x = _ox; jun.y = _oy; _oy += junction_draw_hei_y * jun.isVisible() * __s; });
		
		if(SHOW_PARAM) h = h_param;
		onPreDraw(_x, _y, _s, _iy, _oy);
	}
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) {}
	
	static isHighlightingInGraph = function() {
		var  high = display_parameter.highlight;
		var _selc = active_draw_index == 0 || branch_drawing;
		return !high || _selc;
	}
	
	static getColor = function() {
		var cc = attributes.color == -1? color : attributes.color; 
		return cc;
	}
	
	static drawNodeBase = function(xx, yy, _s) { 
		var cc = colorMultiply(getColor(), COLORS.node_base_bg);
		var aa = .75 * (.25 + .75 * isHighlightingInGraph());
		
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, cc, aa); 
	}
	
	static drawNodeOverlay = undefined;
	
	__draw_bbox = BBOX();
	static drawGetBbox = function(xx, yy, _s, label = true) {
		var pad_label = ((display_parameter.avoid_label || label) && draw_name) || label == 2;
		
		var x0 = xx;
		var x1 = xx + w * _s;
		var y0 = yy;
		var y1 = yy + h * _s;
		
		if(pad_label)  y0 += name_height * _s;
		if(SHOW_PARAM) y1  = yy + attributes.preview_size  * _s;
		
		x0 += max(draw_padding, draw_pad_w) * _s; 
		x1 -= max(draw_padding, draw_pad_w) * _s;
		y0 += max(draw_padding, draw_pad_h) * _s; 
		y1 -= max(draw_padding, draw_pad_h) * _s;
		
		var _w = x1 - x0;
		var _h = y1 - y0;
		
		var _xc = (x0 + x1) / 2;
		var _yc = (y0 + y1) / 2;
		
		_w *= display_parameter.preview_scale / 100;
		_h *= display_parameter.preview_scale / 100;
		
		x0 = _xc - _w / 2;
		x1 = _xc + _w / 2;
		y0 = _yc - _h / 2;
		y1 = _yc + _h / 2;
		
		return __draw_bbox.fromPoints(x0, y0, x1, y1);
	}
	
	static drawNodeName = function(xx, yy, _s, _panel = noone) {
		var _name = renamed? display_name : name;
		if(_name == "") return;
		
		draw_name = true;
		
		var nodeC = colorMultiply(getColor(), COLORS.node_name_bg);
		var aa = (.25 + .5 * renderActive) * (.25 + .75 * isHighlightingInGraph());
		var nh = previewable? name_height * _s : h * _s;
		var ba = aa;
		
		if(_panel && _panel.node_hovering == self) ba = .1;
		draw_sprite_stretched_ext(bg_spr, 2, xx, yy, w * _s, nh, nodeC, ba);
		
		var cc = renderActive? COLORS._main_text : COLORS._main_text_sub;
		if(PREFERENCES.node_show_render_status && !rendered)
			cc = isRenderable()? COLORS._main_value_positive : COLORS._main_value_negative;
		
		aa += 0.25;
		
		var tx = xx + 4 * _s;
		var ty = round(yy + nh / 2);
		
		if(_panel && _panel.is_searching && _panel.search_string != "" && search_match == -9999)
			aa *= .15;
				
		if(icon) {
			var _icx = tx + 6 * _s;
			var _ics = _s / THEME_SCALE * .8;
			gpu_set_texfilter(true);
			draw_sprite_ext(icon, 0, _icx, ty, _ics, _ics, 0, icon_blend ?? getColor(), .75);
			if(sprite_get_number(icon) > 1) draw_sprite_ext(icon, 1, _icx, ty, _ics, _ics, 0, c_white, .8);
			gpu_set_texfilter(false);
			
			tx += 16 * _s;
		}
		
		var _tx   = round(tx);
		var _ts   = _s * .275 / UI_SCALE;
		var _scis = gpu_get_scissor();
		
		gpu_set_scissor(xx, yy, w * _s - 4, nh);
		draw_set_text(f_sdf, fa_left, fa_center, cc, aa);
			BLEND_ALPHA_MULP
			
			draw_set_color(c_black); draw_text_transformed(_tx+1, ty+1, _name, _ts, _ts, 0);
			draw_set_color(cc);      draw_text_transformed(_tx,   ty,   _name, _ts, _ts, 0);
			
			BLEND_NORMAL
		draw_set_alpha(1);
		gpu_set_scissor(_scis);
	}
	
	static drawJunctionWidget = function(_x, _y, _mx, _my, _s, _hover, _focus, _display_parameter = noone, _panel = noone) {
		var hover = noone;
		
		var _m = [ _mx, _my ];
		var pd = junction_draw_pad_y * _s;
		var wh = junction_draw_hei_y * _s;
		
		var ww = w * _s * 0.5;
		var wt = w * _s * 0.25;
		var wx = _x + w * _s - ww - 8 * _s;
		var lx = _x + 12 * _s;
		
		var jy = _y + attributes.preview_size * _s + wh / 2;
		
		var rx = _panel.x;
		var ry = _panel.y;
		
		var extY = 0;
		var drwT = _s > 0.5;
		var outY = 24;
		var _fnt = _s < 2? f_p4 : f_p3;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			var wd  = jun.graphWidget;
			
			jun.y = jy;
			
			if(drwT) {
				draw_set_text(f_sdf, fa_left, fa_center, jun.color_display);
				draw_text_add(lx, jun.y, jun.getName(), _s * 0.25 / UI_SCALE);
				
			} else {
				draw_set_color(jun.color_display);
				draw_rectangle(lx, jun.y - 1 * _s, lx + wt, jun.y + 4 * _s, false);
			}
			
			if(jun.value_from || wd == noone) {
				extY += junction_draw_hei_y;
				jy   += wh;
				continue;
			}
			
			var _param = jun.graphWidgetP;
			
			_param.w    = ww;
			_param.h    = wh - 4 * _s;
			_param.x    = wx;
			_param.y    = jy - _param.h / 2;
			
			_param.data = jun.showValue();
			_param.m	= _m;
			_param.rx	= rx;
			_param.ry	= ry;
			_param.s    = wh;
			_param.font = _fnt;
			_param.color = getColor();
			
			if(is(wd, checkBox)) _param.halign = fa_center;
			
			wd.setInteract(wh > line_get_height(_fnt));
			wd.setFocusHover(_focus, _hover);
			var _h = wd.drawParam(_param);
			jun.graphWidgetH = _h / _s;
			
			extY += max(0, jun.graphWidgetH + 4);
			jy   += (jun.graphWidgetH + 4) * _s;
			
			if(wd.isHovering()) draggable = false;
		}
		
		for( var i = 0, n = array_length(outputs); i < n; i++ )
			outY += junction_outp_hei_y * outputs[i].isVisible();
		
		extY += bool(extY) * 4;
		h = max(outY, attributes.preview_size + extY);
		h_param = h;
	}
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		var hover = noone;
		
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			jun = inputDisplayList[i];
			if(jun.isHovering(_s, _dx, _dy, _mx, _my)) hover = jun;
		}
		
		preview_channel_temp = undefined;
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			jun = outputs[i];
			if(!jun.isVisible()) continue;
			
			if(jun.isHovering(_s, _dx, _dy, _mx, _my)) {
				hover = jun;
				
				if(jun.type == VALUE_TYPE.surface)
					preview_channel_temp = i;
			}
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			jun = inputs[i].bypass_junc;
			if(jun == noone || !jun.visible) continue;
			
			if(jun.isHovering(_s, _dx, _dy, _mx, _my)) hover = jun;
		}
		
		if(hasInspector1Update() && inspectInput1.isHovering(_s, _dx, _dy, _mx, _my)) hover = inspectInput1;
		if(hasInspector2Update() && inspectInput2.isHovering(_s, _dx, _dy, _mx, _my)) hover = inspectInput2;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.isHovering(_s, _dx, _dy, _mx, _my))  hover = updatedInTrigger;
			if(updatedOutTrigger.isHovering(_s, _dx, _dy, _mx, _my)) hover = updatedOutTrigger;
		}
		
		if(attributes.outp_meta) {
			for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
				jun = junc_meta[i];
				if(!jun.isVisible()) continue;
				if(jun.isHovering(_s, _dx, _dy, _mx, _my)) hover = jun;
			}
		}
		
		return hover;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		var _scs = gpu_get_scissor();
		gpu_set_scissor(_x, _y, w * _s, h * _s);
		draw_set_circle_precision(_fast? 16 : 64);
		
		var _js = 14 * _s;
		for( var i = 0, n = array_length(inputDisplayGroup); i < n; i++ ) {
			var _gr  = inputDisplayGroup[i];
			
			var _gx  = _gr[0] - 1;
			var _gx0 = _gx - _js/2;
			var _gx1 = _gx + _js/2;
			
			var _gy0 = _gr[1] - 1 - _js/2;
			var _gy1 = _gr[2] - 1 + _js/2;
				
			_gr[3] = key_mod_press(CTRL) && point_in_rectangle(_mx, _my, _gx0, _gy0, _gx1, _gy1);
				
			draw_set_color_alpha(_gr[3]? CDEF.main_dkgrey : CDEF.main_mdblack, .75);
			draw_roundrect_ext(_gx0, _gy0, _gx1, _gy1, _js, _js, false);
			draw_set_alpha(1);
			
			draw_set_color(_gr[3]? CDEF.main_grey : CDEF.main_dark);
			draw_roundrect_ext(_gx0, _gy0, _gx1, _gy1, _js, _js, true);
		}
		gpu_set_scissor(_scs);
			
		if(_fast) draw_set_circle_precision(4);
		else      gpu_set_texfilter(true);
		
		var jun;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			jun = inputDisplayList[i];
			jun.drawJunction(_s, _mx, _my, _fast);
		}
		
		preview_channel_temp = undefined;
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			jun = outputs[i];
			if(!jun.isVisible()) continue;
			
			jun.drawJunction(_s, _mx, _my, _fast);
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			jun = inputs[i].bypass_junc;
			if(jun == noone || !jun.visible) continue;
			
			jun.drawJunction(_s, _mx, _my, _fast);
		}
		
		if(hasInspector1Update()) inspectInput1.drawJunction(_s, _mx, _my, _fast);
		if(hasInspector2Update()) inspectInput2.drawJunction(_s, _mx, _my, _fast);
		
		if(attributes.show_update_trigger) {
			updatedInTrigger.drawJunction(_s, _mx, _my, _fast);
			updatedOutTrigger.drawJunction(_s, _mx, _my, _fast);
		}
		
		if(attributes.outp_meta) {
			for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
				jun = junc_meta[i];
				if(!jun.isVisible()) continue;
				
				jun.drawJunction(_s, _mx, _my, _fast);
			}
		}
		
		if(!_fast) gpu_set_texfilter(false);
	}
	
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {
		var amo = input_display_list == -1? array_length(inputs) : array_length(input_display_list);
		var jun;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var y0 = previewable? yy + name_height * _s : yy;
		var y1 = yy + h * _s;
		
		var _hov = _panel.pHOVER && (_panel.node_hovering == noone || _panel.node_hovering == self);
		show_input_name  = _hov;
		show_output_name = _hov;
		
		show_input_name  = show_input_name  && point_in_rectangle(_mx, _my, xx - (    12) * _s, y0, xx + (    12) * _s, y1);
		show_output_name = show_output_name && point_in_rectangle(_mx, _my, xx + (w - 12) * _s, y0, xx + (w + 12) * _s, y1);
		
		if(_panel.value_dragging && _panel.node_hovering == self) {
			if(_panel.value_dragging.connect_type == CONNECT_TYPE.input)  show_output_name = true;
			if(_panel.value_dragging.connect_type == CONNECT_TYPE.output) show_input_name  = true;
		}
		
		__s  = _s;
		__mx = _mx;
		__my = _my;
		
		if(show_input_name) {
			array_foreach(inputDisplayList, function(i) /*=>*/ { i.drawNameBG(__s);           });
			array_foreach(inputDisplayList, function(i) /*=>*/ { i.drawName(__s, __mx, __my); });
		}
		
		if(show_output_name) {
			array_foreach(outputDisplayList, function(i) /*=>*/ { i.drawNameBG(__s);           });
			array_foreach(outputDisplayList, function(i) /*=>*/ { i.drawName(__s, __mx, __my); });
		}
		
		if(hasInspector1Update() && _panel.pHOVER && point_in_circle(_mx, _my, inspectInput1.x, inspectInput1.y, 10 * _s)) {
			inspectInput1.drawNameBG(_s);
			inspectInput1.drawName(_s, _mx, _my);
		}
		
		if(hasInspector2Update() && _panel.pHOVER && point_in_circle(_mx, _my, inspectInput2.x, inspectInput2.y, 10 * _s)) {
			inspectInput2.drawNameBG(_s);
			inspectInput2.drawName(_s, _mx, _my);
		}
	}
	
	__draw_inputs     = [];
	__draw_inputs_len = 0;
	
	static setJunctionIndex = function() {
		var drawLineIndex  = 1;
		__draw_outputs_len = 0;
		
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			var _jun      = outputs[i];
			var connected = !array_empty(_jun.value_to);
			
			if(connected) __draw_outputs_len++;
		}
		
		var _ind = 0;
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			var _jun      = outputs[i];
			var connected = !array_empty(_jun.value_to);
			
			if(connected) {
				_jun.drawLineIndex = 1 + (_ind > __draw_outputs_len / 2? (__draw_outputs_len - 1 - _ind) : _ind) * 0.5;
				_ind++;
			}
		}
		
		__draw_inputs = array_verify(__draw_inputs, array_length(inputs));
		var drawLineIndex = 1;
		__draw_inputs_len = 0;
		
		if(attributes.show_render_frame && frameInput.value_from != noone)
			__draw_inputs[__draw_inputs_len++] = frameInput;
		
		for(var i = 0, n = array_length(inputs); i < n; i++) {
			_jun = inputs[i];
			
			if(!is_struct(_jun) || _jun.value_from == noone || !_jun.value_from.node.active || !_jun.isVisible()) continue;
			__draw_inputs[__draw_inputs_len++] = _jun;
		}
		
		for( var i = 0; i < __draw_inputs_len; i++ ) {
			_jun = __draw_inputs[i];
			_jun.drawLineIndexRaw = i;
			_jun.drawLineIndex = 1 + (i > __draw_inputs_len / 2? (__draw_inputs_len - 1 - i) : i) * 0.5;
		}
	}
	
	static drawConnections = function(params = {}, _draw = true) { 
		if(!active) return noone;
		
		var _hov, hovering = noone;
		if(hasInspector1Update()) { _hov = inspectInput1.drawConnections(params, _draw); if(_hov) hovering = _hov; }
		if(hasInspector2Update()) { _hov = inspectInput2.drawConnections(params, _draw); if(_hov) hovering = _hov; }
		
		for( var i = 0; i < __draw_inputs_len; i++ ) {
			var _jun = __draw_inputs[i];
			if(_jun.bypass_junc.visible) _jun.bypass_junc.drawBypass(params);
			
			_hov = _jun.drawConnections(params, _draw); 
			if(_hov) hovering = _hov;
		}
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawConnections(params, _draw))  hovering = updatedInTrigger;
			if(updatedOutTrigger.drawConnections(params, _draw)) hovering = updatedOutTrigger;
		}
		
		return hovering;
	}
	
	static setPreview = function(_surf) {
		preview_surface = _surf;
		__preview_surf  = is_surface(_surf);
	}
	
	static drawPreview = function(xx, yy, _s) {
		var surf = getGraphPreviewSurface();
		if(surf == noone) return;
		
		preview_amount = 0;
		if(is_array(surf)) {
			if(array_length(surf) == 0) return;
			preview_amount = array_length(surf);
			
			if(preview_speed != 0) {
				preview_index += preview_speed;
				if(preview_index <= 0)
					preview_index = array_length(surf) - 1;
			}
			
			if(floor(preview_index) > array_length(surf) - 1) preview_index = 0;
			surf = surf[preview_index];
		}
		
		setPreview(surf);
		if(!__preview_surf) return;
		
		__preview_sw   = surface_get_width_safe(preview_surface);
		__preview_sh   = surface_get_height_safe(preview_surface);
		
		var bbox = drawGetBbox(xx, yy, _s, false);
		var aa   = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		
		var _sw = __preview_sw;
		var _sh = __preview_sh;
		var _ss = min(bbox.w / _sw, bbox.h / _sh);
		
		var _ps = preview_surface;
		if(is_struct(_ps) && is(_ps, dynaSurf))
			_ps = array_safe_get_fast(_ps.surfaces, 0, noone);
		
		draw_surface_ext_safe(_ps, bbox.xc - _sw * _ss / 2, bbox.yc - _sh * _ss / 2, _ss, _ss);
	}
	
	static getNodeDimension = function(showFormat = true) {
		if(!__preview_surf) return preview_array;
		
		var pw = surface_get_width_safe(preview_surface);
		var ph = surface_get_height_safe(preview_surface);
		var format = surface_get_format_safe(preview_surface);
		
		var txt = $"[{pw} x {ph}";
		if(preview_amount) txt = $"{preview_amount} x {txt}";
		
		switch(format) {
			case surface_rgba8unorm	 : break;
			case surface_rgba4unorm	 : txt += showFormat? " 4RGBA"	: " 4R";  break;
			case surface_rgba16float : txt += showFormat? " 16RGBA"	: " 16R"; break;
			case surface_rgba32float : txt += showFormat? " 32RGBA"	: " 32R"; break;
			case surface_r8unorm	 : txt += showFormat? " 8BW"	: " 8B";  break;
			case surface_r16float	 : txt += showFormat? " 16BW"	: " 16B"; break;
			case surface_r32float	 : txt += showFormat? " 32BW"	: " 32B"; break;
		}
		
		txt += "]";
		
		return txt;
	}
	
	static drawDimension = function(xx, yy, _s) {
		draw_set_text(f_p4, fa_center, fa_top, COLORS.panel_graph_node_dimension);
		var tx = xx + w * _s / 2;
		var ty = yy + (h + 4) * _s - 2;
		
		if(struct_get(display_parameter, "show_dimension")) {
			var txt = string(getNodeDimension(_s > 0.65));
			draw_text(round(tx), round(ty), txt);
			ty += string_height(txt) - 2;
		}
		
		if(struct_get(display_parameter, "show_compute")) {
			var rt = 0, unit = "";
			
			if(render_time == 0) {
				draw_set_color(COLORS._main_text_sub);
				unit = "us";
				
			} else if(render_time < 1000) {
				rt = round(render_time / 10) * 10;
				unit = "us";
				draw_set_color(COLORS.speed[2]);
				
			} else if(render_time < 1000000) {
				rt = string_format(render_time / 1000, -1, 2);
				unit = "ms";
				draw_set_color(COLORS.speed[1]);
				
			} else {
				rt = string_format(render_time / 1000000, -1, 2);
				unit = "s";
				draw_set_color(COLORS.speed[0]);
			}
			
			if(render_cached) draw_set_color(COLORS._main_text_sub);
			
			draw_text(round(tx), round(ty), $"{rt} {unit}");
		}
	}
	
	static groupCheck = function(_x, _y, _s, _mx, _my) {}
	
	static drawInputGroup = function(_x, _y, _mx, _my, _s) { 
		var _js = 16 * _s;
		for( var i = 0, n = array_length(inputDisplayGroup); i < n; i++ ) {
			var _gr  = inputDisplayGroup[i];
			var _gx  = _gr[0] - 1;
			var _gy0 = _gr[1] - 1;
			var _gy1 = _gr[2] - 1;
			
			draw_set_color_alpha(_gr[3]? CDEF.main_dkgrey : CDEF.main_mdblack, .9);
				draw_roundrect_ext(_gx - _js/2, _gy0 - _js/2, _gx + _js/2, _gy1 + _js/2, _js, _js, false);
			draw_set_alpha(1);
		}
	}
	
	static drawNodeBG = undefined;
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _display_parameter = noone, _panel = noone) { }
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, _display_parameter = noone, _panel = noone) { 
		if(_display_parameter != noone) display_parameter = _display_parameter;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		preview_mx = _mx;
		preview_my = _my;
		
		if(value_validation[VALIDATION.error])
			draw_sprite_stretched_ext(THEME.node_glow_border, 0, xx - 9, yy - 9, w * _s + 18, h * _s + 18, COLORS._main_value_negative, 1);
		
		drawNodeBase(xx, yy, _s);
		draggable = true;
		
		var _hover = _panel == noone? false : _panel.node_hovering     == self;
		var _focus = _panel == noone? false : _panel.getFocusingNode() == self;
		
		if(previewable) {
			if(preview_draw) drawPreview(xx, yy, _s);
			if(node_draw_icon != noone) {
				var bbox = drawGetBbox(xx, yy, _s);
				draw_sprite_bbox_uniform(node_draw_icon, 0, bbox);
			}
			
			try { onDrawNode(xx, yy, _mx, _my, _s, _hover, _focus); }
			catch(e) { log_warning("NODE onDrawNode", exception_print(e)); }
		} 
		
		if(SHOW_PARAM) drawJunctionWidget(xx, yy, _mx, _my, _s, _hover, _focus, _display_parameter, _panel);
		
		draw_name = false;
		if((previewable && _s >= 0.5) || (!previewable && h * _s >= name_height * .5)) drawNodeName(xx, yy, _s, _panel);
		
		if(attributes.annotation != "") {
			draw_set_text(f_sdf_medium, fa_left, fa_bottom, attributes.annotation_color);
			var _ts = _s * attributes.annotation_size;
			
			BLEND_ADD
			draw_text_ext_transformed(xx, yy - 4  * _s, attributes.annotation, -1, (w + 8) * _s / _ts, _ts, _ts, 0);
			BLEND_NORMAL
		}
		
		if(bg_spr_add > 0) draw_sprite_stretched_add(bg_spr, 1, xx, yy, w * _s, h * _s, getColor(), bg_spr_add);
		
		active_drawing = active_draw_index > -1;
		if(active_draw_index > -1) {
			var cc = COLORS._main_accent;
			switch(active_draw_index) {
				case 1 : cc = COLORS.node_border_context;   break;
				case 2 : cc = COLORS.node_border_file_drop; break;
			}
			
			draw_sprite_stretched_ext(bg_spr, 1, xx, yy, w * _s, h * _s, cc, 1);
			if(active_draw_anchor) draw_sprite_stretched_add(bg_spr, 1, xx, yy, w * _s, h * _s, COLORS._main_accent, 0.5);
			
			active_draw_anchor = false;
			active_draw_index  = -1;
		}
		
		if(draw_droppable) {
			draw_sprite_stretched_ext(THEME.color_picker_box, 0, xx - 2 * _s, yy - 2 * _s, w * _s + 4 * _s, h * _s + 4 * _s, COLORS._main_value_positive, 1);
			draw_droppable = false;
		}
		
		if(drawNodeOverlay) drawNodeOverlay(xx, yy, _mx, _my, _s);
	}
	
	static drawNodeBehind = undefined
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {}
	
	static onDrawHover = undefined;
	static drawPreviewBackground = undefined;
	
	static drawBadge = function(_x, _y, _s) {
		var bPreview = bool(previewing);
		var bInspect = bool(inspecting);
		var bTool    = group != noone && group.toolNode == self;
		
		var _full    = previewable && w * _s > 64;
		var _scale   = UI_SCALE;
		
		if(_full) {
			var xx = x * _s + _x + w * _s;
			var yy = y * _s + _y;
			var xw = 22 * _scale;
			
			if(bPreview) { draw_sprite_ui_uniform(THEME.node_state, bool(is_3D) * 3, xx, yy); xx -= xw; }
			if(bInspect) { draw_sprite_ui_uniform(THEME.node_state, 1,               xx, yy); xx -= xw; }
			if(bTool)    { draw_sprite_ui_uniform(THEME.node_state, 2,               xx, yy); xx -= xw; }
			
		} else {
			var xx = _x + _s * (x + w - 10);
			var yy = _y + _s *  y;
			
			var ss = .5 * _s;
			var xw = 12 * _s * _scale;
			
			gpu_set_tex_filter(true);
			if(bPreview) { draw_sprite_ui_uniform(THEME.circle_16, 0, xx, yy, ss, CDEF.orange); xx -= xw; }
			if(bInspect) { draw_sprite_ui_uniform(THEME.circle_16, 0, xx, yy, ss, CDEF.lime);   xx -= xw; }
			if(bTool)    { draw_sprite_ui_uniform(THEME.circle_16, 0, xx, yy, ss, CDEF.blue);   xx -= xw; }
			gpu_set_tex_filter(false);
		}
		
		inspecting = false;
		previewing = 0;
	}
	
	static drawBranch = function(_depth = 0) {
		if(branch_drawing) return;
		branch_drawing = true;
		
		if(!project.graphConnection.line_highlight_all && _depth == 1) return;
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			if(inputs[i].value_from == noone) continue;
			inputs[i].value_from.node.drawBranch(_depth + 1);
		}
	}
	
	static drawActive = function(ind = 0) {
		active_draw_index = max(active_draw_index, ind);
		if(display_parameter.highlight) drawBranch();
	}
	
	static InputDrawOverlay = function(hv) {
		hv = hv ?? false;
		w_hovering  = w_hovering || bool(hv); 
		w_hoverable = w_hoverable && !hv;
		return hv;
	}
	
	static doDrawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params = {}) { 
		w_hovering     = false; 
		w_hoverable    = hover;
		w_active       = active;
		__preview_bbox = getPreviewBoundingBox();
		
		try {
			var _hv = drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
			if(_hv != undefined) w_hovering = w_hovering || _hv;
		} catch(e) { log_warning($"{toString()}, drawOverlay", exception_print(e)); }
		
		attribute_drawOverlay(hover, active);
		
		return w_hovering;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params = {}) {}
	
	static drawOverlayChainTransform = function(_node) {
		var _ch = getNodeChildList(_node);
		var _tr = [ 0, 0, 1, 1, 0 ];
		if(_ch == noone) return _tr;
		
		for( var i = 0, n = array_length(_ch) - 1; i < n; i++ ) {
			var _trn = _ch[i + 1].drawOverlayTransform(_ch[i]);
			if(_trn == noone) continue;
			
			_tr[0]  = (_trn[0] + _tr[0]) * _tr[2];
			_tr[1]  = (_trn[1] + _tr[1]) * _tr[2];
			_tr[2] *= _trn[2];
		}
		
		return _tr;
	}
	
	static drawOverlayTransform = function(_node) { return noone; }
	
	static drawPreviewToolOverlay = function(hover, active, _mx, _my, _panel) { return false; }
	
	static drawAnimationTimeline = function(_w, _h, _s) {}
	
	////- PREVIEW
	
	static getPreviewValues = function() {
		if(preview_channel < 0 || preview_channel >= array_length(outputs)) return noone;
		
		var _type = outputs[preview_channel].type;
		if(_type != VALUE_TYPE.surface && _type != VALUE_TYPE.dynaSurface)
			return noone;
		
		var val = outputs[preview_channel].getValue();
		if(is_struct(val) && is(val, dynaSurf))
			val = array_safe_get_fast(val.surfaces, 0, noone);
		
		return val;
	}
	
	__preview_bbox = BBOX();
	static getPreviewBoundingBox = function() {
		var _surf = getPreviewValues();
		if(is_array(_surf)) 
			_surf = array_safe_get_fast(_surf, preview_index, noone);
		
		if(!is_surface(_surf)) return BBOX().fromWH(0, 0, DEF_SURF_W, DEF_SURF_H);
			
		return BBOX().fromWH(preview_x, preview_y, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
	}
	
	static getPreviewBoundingBoxExpanded = function() /*=>*/ {return __preview_bbox};
	
	static getGraphPreviewSurface = function() { 
		var _node = array_safe_get(outputs, preview_channel_temp ?? preview_channel);
		if(!is(_node, NodeValue)) return noone;
		
		switch(_node.type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				return _node.showValue();
		}
		
		return noone;
	}
	
	////- TOOLS
	
	static isNotUsingTool = function() { var t = PANEL_PREVIEW.tool_current; return t == noone || t.ctx != instanceof(self); }
	static isUsingTool    = function(i = undefined, subt = noone) {
		if(tools == -1) return false;
		
		var t = PANEL_PREVIEW.tool_current;
		if(t == noone)     return false; // not using any tool
		if(i == undefined) return true;  // check for any tool
		
		if(is_real(i) && t != tools[i]) 
			return false;
			
		if(is_string(i) && t.getName(t.selecting) != i) 
			return false;
		
		return subt == noone || t.selecting == subt;
	}
	
	static getUsingToolName = function() { 
		var _tool  = PANEL_PREVIEW.tool_current;
		return _tool == noone? "" : _tool.getName(_tool.selecting);
	}
	
	static getTool         = undefined;
	static getToolSettings = function() /*=>*/ {return tool_settings};
	static showTool        = function() /*=>*/ {return tools != -1 || toolShow};
	static drawTools       = noone;
	
	static selectAll   = undefined;
	static selectClear = undefined;
	
	////- INSTANCE
	
	static setInstance = function(n) /*=>*/ { instanceBase = n.instanceBase ?? n; return self; }
	
	////- CACHE
	
	use_cache     = CACHE_USE.none;
	cached_manual = false;
	cached_output = [];
	cache_result  = [];
	cache_group   = noone;
	clearCacheOnChange = true;
	
	static isAllCached = function() {
		for( var i = 0; i < TOTAL_FRAMES; i++ )
			if(!cacheExist(i)) return false;
		return true;
	}
	
	static cacheCheck = function() {
		INLINE
		
		if(cache_group) cache_group.enableNodeGroup();
		if(group != noone) group.cacheCheck();
	}
	
	static getAnimationCacheExist = function(f) /*=>*/ {return cacheExist(f)};
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ )
			inputs[i].cache_value[0] = false;
	}
	
	static cacheArrayCheck = function() {
		cached_output = array_verify(cached_output, TOTAL_FRAMES + 1);
		cache_result  = array_verify(cache_result,  TOTAL_FRAMES + 1);
	}
	
	static cacheCurrentFrame = function(_surface) {
		cacheArrayCheck();
		var _frame = CURRENT_FRAME;
		
		if(_frame < 0) return;
		if(_frame >= array_length(cached_output)) return;
		
		if(is_array(_surface)) {
			surface_array_free(cached_output[_frame]);
			cached_output[_frame] = surface_array_clone(_surface);
			
		} else if(surface_exists(_surface)) {
			var _sw = surface_get_width(_surface);
			var _sh = surface_get_height(_surface);
			
			cached_output[_frame] = surface_verify(cached_output[_frame], _sw, _sh);
			surface_set_target(cached_output[_frame]);
				DRAW_CLEAR BLEND_OVERRIDE
				draw_surface(_surface, 0, 0);
			surface_reset_target();
		}
		
		array_safe_set(cache_result, _frame, true);
		
		return cached_output[_frame];
	}
	
	static cacheExist = function(frame = CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result))  return false;
		if(!array_safe_get_fast(cache_result, frame, false)) return false;
		
		var s = array_safe_get_fast(cached_output, frame);
		return is_array(s) || surface_exists(s);
	}
	
	static getCacheFrame = function(frame = CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(!cacheExist(frame)) return noone;
		var surf = array_safe_get_fast(cached_output, frame);
		return surf;
	}
	
	static recoverCache = function(frame = CURRENT_FRAME) {
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outputs[0].setValue(_s);
			
		return true;
	}
	
	static clearCache = function(_force = false) {
		clearInputCache();
		
		if(!_force) {
			if(!use_cache)          return;
			if(!clearCacheOnChange) return;
			if(!isRenderActive())   return;
		}
		
		if(array_length(cached_output) != TOTAL_FRAMES)
			array_resize(cached_output, TOTAL_FRAMES);
		for(var i = 0; i < array_length(cached_output); i++) {
			var _s = cached_output[i];
			if(is_surface(_s))
				surface_free(_s);
			cached_output[i] = 0;
			cache_result[i] = false;
		}
	}
	
	static clearCacheForward = function() {
		if(!isRenderActive()) return;
		
		clearCache();
		var arr = getNextNodesRaw();
		for( var i = 0, n = array_length(arr); i < n; i++ )
			arr[i].clearCacheForward();
	}
	
	static cachedPropagate = function(_group = group) {
		if(group != _group) return;
		setRenderStatus(true);
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _input = inputs[i];
			if(_input.value_from == noone) continue;
			
			_input.value_from.node.cachedPropagate(_group);
		}
	}
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(!is(inputs[i], NodeValue)) continue;
			inputs[i].resetCache();
		}
	}
	
	////- SERIALIZE
	
	static serialize = function(scale = false, preset = false) {
		if(!active) return;
		
		var _map = {};
		
		_map.version = SAVE_VERSION;
		if(!visible)     _map.visible      = visible;
		if(is_instancer) _map.is_instancer = is_instancer;
		
		if(!preset) {
			_map.id	     = node_id;
			_map.name	 = display_name;
			_map.iname	 = internalName;
			_map.x		 = x;
			_map.y		 = y;
			_map.type    = itype == noone? instanceof(self) : itype;
			
			if(group != noone)          _map.group = group.node_id;
			if(inline_context != noone) _map.ictx  = inline_context.node_id;
			
			if(!renderActive)    _map.render         = renderActive;
			if(!previewable)     _map.previewable    = previewable;
			if(show_parameter)   _map.show_parameter = show_parameter;
			
			if(inspector_scroll) _map.insp_scr       = inspector_scroll;
			_map.insp_col = variable_clone(inspector_collapse);
		}
		
		var _attr = attributeSerialize();
		var attri = struct_append(variable_clone(attributes), _attr); 
		
		#region attribute stripping // TODO : make it an array
			if(struct_try_get(attri, "color_depth")         == 3)     struct_remove(attri, "color_depth");
			if(struct_try_get(attri, "interpolate")         == 1)     struct_remove(attri, "interpolate");
			if(struct_try_get(attri, "oversample")          == 1)     struct_remove(attri, "oversample");
			if(struct_try_get(attri, "node_width")          == 0)     struct_remove(attri, "node_width");
			if(struct_try_get(attri, "node_height")         == 0)     struct_remove(attri, "node_height");
			if(struct_try_get(attri, "node_param_width")    == 192)   struct_remove(attri, "node_param_width");
			if(struct_try_get(attri, "outp_meta")           == false) struct_remove(attri, "outp_meta");
			
			if(struct_try_get(attri, "annotation")          == "")                       struct_remove(attri, "annotation");
			if(struct_try_get(attri, "annotation_size")     == .4)                       struct_remove(attri, "annotation_size");
			if(struct_try_get(attri, "annotation_color")    == COLORS._main_text_sub)    struct_remove(attri, "annotation_color");
			
			if(struct_try_get(attri, "color")               == -1)    struct_remove(attri, "color");
			if(struct_try_get(attri, "update_graph")        == true)  struct_remove(attri, "update_graph");
			if(struct_try_get(attri, "show_update_trigger") == false) struct_remove(attri, "show_update_trigger");
			if(struct_try_get(attri, "array_process")       == 0)     struct_remove(attri, "array_process");
			
			if(struct_has(attri, "use_project_dimension"))			  struct_remove(attri, "use_project_dimension");
			
			if(struct_names_count(attri)) _map.attri = attri;
		#endregion	
		
		if(is_dynamic_input) {
			_map.input_fix_len  = input_fix_len;
			_map.data_length    = data_length;
		}
		
		var _inputs = [];
		for(var i = 0; i < array_length(inputs); i++)
			array_push(_inputs, inputs[i].serialize(scale, preset));
		_map.inputs = _inputs;
		
		var _outputs = [];
		for(var i = 0; i < array_length(outputs); i++)
			array_push(_outputs, outputs[i].serialize(scale, preset));
		_map.outputs = _outputs;
		
		var _trigger = [];
		_trigger[0] = inspectInput1.serialize(scale, preset);
		_trigger[1] = inspectInput2.serialize(scale, preset);
		_trigger[2] = updatedInTrigger.serialize(scale, preset);
		_trigger[3] = updatedOutTrigger.serialize(scale, preset);
		_trigger[4] = frameInput.serialize(scale, preset);
		
		var _outMeta = [];
		for(var i = 0; i < array_length(junc_meta); i++)
			_outData[i] = junc_meta[i].serialize(scale, preset);
		
		_map.inspectInputs = _trigger;
		if(!array_empty(_outMeta)) _map.outputMeta = _outMeta;
		if(renamed)                _map.renamed    = renamed;
		
		if(instanceBase)  _map.instanceBase = instanceBase.node_id;
		
		doSerialize(_map);
		processSerialize(_map);
		return _map;
	}
	
	static attributeSerialize = function() { return {}; }
	static doSerialize		  = function(_map) {}
	static processSerialize   = function(_map) {}
	
	////- DESERIALIZE
	
	static deserialize = function(_map, scale = false, preset = false) {
		if(preset) LOADING_VERSION = _map[$ "version"] ?? SAVE_VERSION;
		
		load_map   = _map;
		load_scale = scale;
		
		preDeserialize();
		
		if(!preset) {
			if(APPENDING) APPEND_MAP[? load_map.id] = node_id;
			else		  node_id = load_map.id;
			
			project.nodeMap[? node_id] = self;
			renamed    = load_map[$ "renamed"] ?? false;
			
			if(struct_has(load_map, "name")) setDisplayName(load_map.name);
			internalName = load_map[$ "iname"] ?? internalName;
			if(internalName == "") resetInternalName();
			
			load_inst  = load_map[$ "instanceBase"] ?? noone;
			load_group = load_map[$ "group"]        ?? noone;
			if(load_group == -1) load_group = noone;
			
			x = load_map[$ "x"] ?? 0;
			y = load_map[$ "y"] ?? 0;
			renderActive   = load_map[$ "render"]         ?? true;
			previewable    = load_map[$ "previewable"]    ?? true;
			show_parameter = load_map[$ "show_parameter"] ?? false;
			load_igroup    = load_map[$ "ictx"]           ?? "";
			
			inspector_scroll = load_map[$ "insp_scr"] ?? inspector_scroll;
			if(struct_has(load_map, "insp_col")) inspector_collapse = variable_clone(load_map[$ "insp_col"]);
		}
		
		visible      = load_map[$ "visible"] ?? true;
		is_instancer = load_map[$ "is_instancer"] ?? is_instancer;
		
		if(struct_has(load_map, "attri")) {
			var _lattr = load_map.attri;
			_lattr.color_depth         = _lattr[$ "color_depth"]      ?? 3;
			_lattr.interpolate         = _lattr[$ "interpolate"]      ?? 1;
			_lattr.oversample          = _lattr[$ "oversample"]       ?? 1;
			_lattr.node_width          = _lattr[$ "node_width"]       ?? 0;
			_lattr.node_height         = _lattr[$ "node_height"]      ?? 0;
			_lattr.node_param_width    = _lattr[$ "node_param_width"] ?? 192;
			_lattr.outp_meta           = _lattr[$ "outp_meta"]        ?? false;
		
			_lattr.color               = _lattr[$ "color"]               ?? -1;
			_lattr.update_graph        = _lattr[$ "update_graph"]        ?? true;
			_lattr.show_update_trigger = _lattr[$ "show_update_trigger"] ?? false;
			_lattr.array_process       = _lattr[$ "array_process"]       ?? 0;
			
			attributeDeserialize(CLONING? variable_clone(_lattr) : _lattr);
		}
		
		if(is_dynamic_input) {
			inputBalance();
			inputGenerate();
		}
		
		doDeserialize(_map);
		
		if(preset) {
			postDeserialize();
			applyDeserialize(preset);
			
			triggerRender();
			postLoad();
		}
		
		anim_timeline = attributes[$ "show_timeline"] ?? false;
		if(anim_timeline) refreshTimeline();
		
	}
	
	static inputBalance = function() { // Cross-version compatibility for dynamic input nodes
		if(!struct_has(load_map, "data_length")) 
			return;
		
		var _input_fix_len  = load_map.input_fix_len;
		var _data_length    = load_map.data_length;
		var _dynamic_inputs = (array_length(load_map.inputs) - _input_fix_len) / _data_length;
		if(frac(_dynamic_inputs) != 0) {
			noti_warning("LOAD: Uneven dynamic input.", noone, self);
			
			_dynamic_inputs = ceil(_dynamic_inputs);
		}
		
		if(_input_fix_len == input_fix_len && _data_length == data_length) 
			return;
		
		var _pad_dyna = data_length - _data_length;
		
		for( var i = _dynamic_inputs; i >= 1; i-- ) {
			var _ind = _input_fix_len + i * _data_length;
			
			if(_pad_dyna > 0)
				repeat(_pad_dyna) array_insert(load_map.inputs, _ind, noone);
			else
				array_delete(load_map.inputs, _ind + _pad_dyna, -_pad_dyna);
		}
		
		var _pad_fix = input_fix_len - _input_fix_len;
		repeat(_pad_fix) 
			array_insert(load_map.inputs, _input_fix_len, noone);
	}
	
	static inputGenerate = function() { // Generate inputs for dynamic input nodes
		if(createNewInput == noone) return;
		
		var _dynamic_inputs = ceil((array_length(load_map.inputs) - input_fix_len) / data_length);
		repeat(_dynamic_inputs) createNewInput();
	}
	 
	static attributeDeserialize = function(attr) {
		struct_override(attributes, attr, true); 
		
		if(!CLONING && LOADING_VERSION < 1_18_02_0) {
			if(struct_has(attributes, "color_depth")) attributes.color_depth += (!array_empty(inputs) && inputs[0].type == VALUE_TYPE.surface)? 1 : 2;
			if(struct_has(attributes, "interpolate")) attributes.interpolate++;
			if(struct_has(attributes, "oversample"))  attributes.oversample++;
			
		}
		
		if(struct_has(attributes, "color_depth") && !global.SURFACE_FORMAT_SUPP[attributes[$ "color_depth"]])
			attributes.color_depth = PREFERENCES.node_default_depth;
	}
	
	static doDeserialize   = function(_map) /*=>*/ {}
	static preDeserialize  = function() /*=>*/ {}
	static postDeserialize = function() /*=>*/ {}
	
	static applyDeserialize = function(preset = false) {
		preApplyDeserialize();
		
		var _inputs = load_map.inputs;
		var amo = min(array_length(inputs), array_length(_inputs));
		
		var i = -1;
		repeat(amo) { i++;
			if(_inputs[i] == noone) continue;
			if(preset == 2 && !inputs[i].set_default) continue;
			
			inputs[i].applyDeserialize(_inputs[i], load_scale, preset);
		}
		
		if(struct_has(load_map, "outputs")) {
			var _outputs = load_map.outputs;
			var amo = min(array_length(outputs), array_length(_outputs));
			
			var i = -1;
			repeat(amo) { i++; outputs[i].applyDeserialize(_outputs[i], load_scale, preset); }
		}
		
		if(struct_has(load_map, "inspectInputs")) {
			var insInp = load_map.inspectInputs;
			inspectInput1.applyDeserialize(insInp[0], load_scale, preset);
			inspectInput2.applyDeserialize(insInp[1], load_scale, preset);
			
			if(array_length(insInp) > 2) updatedInTrigger.applyDeserialize(insInp[2], load_scale, preset);
			if(array_length(insInp) > 3) updatedOutTrigger.applyDeserialize(insInp[3], load_scale, preset);
			if(array_length(insInp) > 4) frameInput.applyDeserialize(insInp[4], load_scale, preset);
		}
		
		if(struct_has(load_map, "outputMeta")) {
			var _outMeta = load_map.outputMeta;
			var _amo = min(array_length(_outMeta), array_length(junc_meta));
			var i = -1;
			repeat(amo) { i++; junc_meta[i].applyDeserialize(_outMeta[i], load_scale, preset); }
		}
		
		postApplyDeserialize();
		
	}
	
	static preApplyDeserialize  = function() /*=>*/ {}
	static postApplyDeserialize = function() /*=>*/ {}
	
	static onLoadGroup = function() /*=>*/ {}
	static loadGroup   = function(ctx = noone) { 
		if(load_igroup != noone) {
			load_igroup = GetAppendID(load_igroup);
			
			if(ds_map_exists(project.nodeMap, load_igroup)) {
				var _grp = project.nodeMap[? load_igroup];
				if(is(_grp, Node_Collection_Inline))
					_grp.addNode(self);
			}
		}
		
		if(load_group == noone) {
			if(ctx) ctx.add(self);
			else    array_push(project.nodes, self);
			
		} else {
			if(APPENDING) {
				load_group = GetAppendID(load_group);
				load_inst  = GetAppendID(load_inst);
			}
			
			if(ds_map_exists(project.nodeMap, load_group)) {
				var _grp = project.nodeMap[? load_group];
				if(struct_has(_grp, "add")) _grp.add(self);
				else throw($"Group load failed. Node ID {load_group} is not a group.");
				
			} else throw($"Group load failed. Can't find node ID {load_group}");
			
			instanceBase = ds_map_exists(project.nodeMap, load_inst)? project.nodeMap[? load_inst] : undefined;
		}
		
		onLoadGroup();
	}
	
	static connect = function(log = false, _nodeGroup = undefined) {
		var connected = true;
		for( var i = 0, n = array_length(inputs); i < n; i++ )
			connected = inputs[i].connect(log, _nodeGroup) && connected;
		
		inspectInput1.connect(    log, _nodeGroup );
		inspectInput2.connect(    log, _nodeGroup );
		updatedInTrigger.connect( log, _nodeGroup );
		frameInput.connect(       log, _nodeGroup );
		
		if(!connected) {
			// if(log) log_warning("LOAD", $"[Connect] Connection failed {name}", self);
			ds_queue_enqueue(CONNECTION_CONFLICT, self);
		}
		refreshTimeline();
		
		return connected;
	}
	
	static preConnect  = function() /*=>*/ {}
	static postConnect = function() /*=>*/ {}
	static postLoad    = function() /*=>*/ {}
	
	////- CLEAN UP
	
	static cleanUp = function() {
		for( var i = 0; i < array_length(inputs);  i++ ) { inputs[i].cleanUp();  delete inputs[i];  }
		for( var i = 0; i < array_length(outputs); i++ ) { outputs[i].cleanUp(); delete outputs[i]; }
		
		if(struct_has(self, "__blur_pass")) {
			surface_free_safe(__blur_pass[0]);
			surface_free_safe(__blur_pass[1]);
		}
		
		surface_array_free(temp_surface);
		onCleanUp();
	}
	
	static onCleanUp = function() {}
	
	////- ACTION
	
	static setDimension = function(_w = 128, _h = undefined, _apply = undefined) {
		INLINE
		
		min_w = _w;
		w     = max(w, min_w);
		// if(_h == 0) previewable = false;
		
		if(_h != undefined && (NODE_NEW_MANUAL || LOADING_VERSION < 1_19_05_0)) attributes.preview_size = _h;
		if(_apply == undefined) return;
		
		refreshNodeDisplay();
	}
	
	static move = function(_x, _y) {
		moved = true;
		if(x == _x && y == _y) return;
		
		x = _x;
		y = _y; 
		
		if(!LOADING) project.setModified();
	}
	
	static enable  = function() { INLINE active = true;  timeline_item.active = true;  }
	static disable = function() { INLINE active = false; timeline_item.active = false; }
	
	static onDestroy = undefined
	static destroy   = function(_merge = false, record = true) {
		if(!active) return;
		disable();
		
		PANEL_GRAPH.refreshDraw(1);
		array_remove(group == noone? project.nodes : group.getNodeList(), self);
		
		if(PANEL_GRAPH.node_hover == self) PANEL_GRAPH.node_hover = noone;
		array_remove(PANEL_GRAPH.nodes_selecting, self);
		
		if(PANEL_INSPECTOR.inspecting == self) PANEL_INSPECTOR.inspecting = noone;
		
		PANEL_PREVIEW.removeNodePreview(self);
		
		var val_from_map = {};
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _i = inputs[i];
			if(_i.value_from == noone)     continue;
			if(has(val_from_map, _i.type)) continue;
			
			val_from_map[$ _i.type] = _i.value_from;
		}
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var jun = outputs[i];
			
			for(var j = array_length(jun.value_to) - 1; j >= 0; j--) {
				var _vt = jun.value_to[j];
				
				if(_vt.value_from == noone || _vt.value_from.node != self) 
					continue;
				
				if(_merge && struct_has(val_from_map, _vt.type))
					_vt.setFrom(val_from_map[$ _vt.type]);
				else
					_vt.removeFrom(false);
			}
			
			jun.value_to = [];
		}
		
		for( var i = 0; i < array_length( inputs); i++ )  inputs[i].destroy();
		for( var i = 0; i < array_length(outputs); i++ ) outputs[i].destroy();
		
		if(onDestroy) onDestroy();
		if(group)  group.refreshNodes();
		if(record) recordAction(ACTION_TYPE.node_delete, self).setRef(self);
		
		RENDER_ALL_REORDER
	}
	
	static onRestore = function() {}
	
	static restore = function() {
		if(active) return;
		enable();
		
		PANEL_GRAPH.refreshDraw(1);
		array_push(group == noone? project.nodes : group.getNodeList(), self);
		
		onRestore();
		if(group) group.refreshNodes();
		
		RENDER_ALL_REORDER
	}
	
	static droppable = function(dragObj) {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(dragObj.type == inputs[i].drop_key)
				return true;
		}
		return false;
	}
	
	on_drop_file = undefined;
	static onDrop = function(dragObj) {
		if(dragObj.type == "Asset" && is_callable(on_drop_file)) {
			on_drop_file(dragObj.data.path);
			return;
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			if(dragObj.type == inputs[i].drop_key) {
				inputs[i].setValue(dragObj.data);
				return;
			}
		}
	}
	
	static dropPath = noone;  
	 
	static clone = function(target = PANEL_GRAPH.getCurrentContext()) {
		CLONING = true;
		var _type = instanceof(self);
		var _node = nodeBuild(_type, x, y, target).skipDefault();
		CLONING = false;
		
		LOADING_VERSION = SAVE_VERSION;
		
		if(!_node) return undefined;
		
		CLONING = true;
		var _nid = _node.node_id;
		_node.deserialize(serialize());
		_node.postDeserialize();
		_node.applyDeserialize();
		_node.node_id = _nid;
		
		project.nodeMap[? node_id] = self;
		project.nodeMap[? _nid] = _node;
		CLONING = false;
		refreshTimeline();
		
		if(instanceBase) _node.setInstance(instanceBase);
		
		onClone(_node, target);
		
		return _node;
	}
	
	static onClone = function(_NewNode, target = PANEL_GRAPH.getCurrentContext()) {}
	
	////- MISC
	
	static postBuild = function() {}
	
	static isTerminal = function() {
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _to = outputs[i].getJunctionTo();
			if(array_length(_to)) return false;
		}
		
		return true;
	}
	
	static getAttribute = function(_key) {
		if(instanceBase) return instanceBase.getAttribute(_key);
		
		var _val = struct_try_get(attributes, _key, 0);
		
		switch(_key) {
			case "interpolate" :
			case "oversample" :
				if(_val == 0 && group != noone) return group.getAttribute(_key);
				return _val;
		}
		
		return _val;
	}
	
	static attrDepth = function() {
		if(instanceBase) return instanceBase.attrDepth();
		
		var form = -1;
		
		if(struct_has(attributes, "color_depth")) {
			form = global.SURFACE_FORMAT[attributes.color_depth];
			if(form >= 0) return form;
		}
		
		if(form == -1) { // input
			var _s = getInputData(0);
			while(is_array(_s) && array_length(_s)) _s = _s[0];
			if(is_surface(_s)) return surface_get_format(_s);
		}
		
		if(form == -2 && group != noone) // group
			return group.attrDepth();
		
		return surface_rgba8unorm;
	}
	
	static checkGroup = function() /*=>*/ { array_foreach(attributeEditors, function(_attr) /*=>*/ {return checkGroupAttribute(_attr)}); } 
	static checkGroupAttribute = function(_attr) {
		if(!is_array(_attr) || array_length(_attr) <= 3) return;
		
		var _grp = group != noone;
		var _wid = _attr[2];
		var _key = _attr[3];
		
		if(!is(_wid, scrollBox)) return;
		var _l   = _wid.data_list;
		
		for( var i = 0, n = array_length(_l); i < n; i++ ) {
			var _scl = _l[i];
			
			if(is(_scl, scrollItem) && _scl.name == "Group") {
				_scl.active = _grp;
				if(!_grp && attributes[$ _key] == i) // Reset value if select "group" while not in any group
					attributes[$ _key] = _attr[0] == "Color depth"? 3 : 1;
			}
		}
	}
	
	nextn = [];
	static generateNodeRenderReport = function() {
		var _report = {};
		
		_report.search_res = true;
		_report.type = "render";
		_report.node = self;
		_report.inputs  = array_create(array_length(inputs));
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _j = inputs[i];
			_report.inputs[i] = _j.getValue();
			
			if(_j.type == VALUE_TYPE.surface)
				_report.inputs[i] = surface_array_clone(_report.inputs[i]);
		}
		
		_report.outputs = array_create(array_length(outputs));
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _j = outputs[i];
			_report.outputs[i] = _j.getValue();
			
			if(_j.type == VALUE_TYPE.surface)
				_report.outputs[i] = surface_array_clone(_report.outputs[i]);
		}
		
		_report.logs  = array_clone(messages_dbg);
		
		_report.nextn = nextn;
		_report.queue = array_clone(RENDER_QUEUE.data, 1);
		
		nextn = [];
		
		return _report;
	}
	static summarizeReport = function(_startTime) {
		var _srcstr = $"{getFullName()}";
		var _report = generateNodeRenderReport();
		
		for( var i = 0, n = array_length(_report.nextn); i < n; i++ ) _srcstr += $"{_report.nextn[i].getFullName()}";
		for( var i = 0, n = array_length(_report.queue); i < n; i++ ) _srcstr += $"{_report.queue[i].getFullName()}";
		
		_report.time          = get_timer() - _startTime;
		_report.renderTime    = render_time;
		_report.search_string = _srcstr;
		array_push(PROFILER_DATA, _report);
	}
	
	static toString = function() { return $"Node [{internalName}] [{instanceof(self)}]: {node_id}"; }
}