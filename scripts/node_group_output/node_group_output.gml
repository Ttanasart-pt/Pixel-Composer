function Node_Group_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Group Output";
	color		= COLORS.node_blend_collection;
	is_group_io = true;
	destroy_when_upgroup = true;
	
	skipDefault();
	setDimension(96, 48);
	
	newInput(0, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1))
		.uncache()
		.setVisible(true, true);
	inputs[0].onSetFrom = function(juncFrom) /*=>*/ { if(attributes.inherit_name && !LOADING && !APPENDING) setDisplayName(juncFrom.name); }
	
	attributes.inherit_name = true;
	outParent   			= undefined;
	output_index			= -1;
	
	onSetDisplayName = function() /*=>*/ { attributes.inherit_name = false; }
	
	static setRenderStatus = function(result) {
		if(rendered == result) return;
		LOG_LINE_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		
		rendered = result;
		if(group) group.setRenderStatus(result);
	}
	
	static onValueUpdate = function(index = 0) { if(is_undefined(outParent)) return; }
	
	static getNextNodes = function(checkLoop = false) {
		if(checkLoop) return;
		if(is_undefined(outParent)) return [];
		
		LOG_BLOCK_START();
		var nodes = [];
		for(var j = 0; j < array_length(outParent.value_to); j++) {
			var _to = outParent.value_to[j];
			
			if(!_to.node.isRenderActive())					continue;
			if(!_to.node.active || _to.value_from == noone) continue;
			if(_to.value_from.node != group)				continue;
			
			array_push(nodes, _to.node);
			LOG_IF(global.FLAG.render == 1, $"Check complete, push {_to.node.internalName} to queue.");
		}
		LOG_BLOCK_END();
		
		return nodes;
	}
	
	static createOutput = function() {
		if(group == noone)    return;
		if(!is_struct(group)) return;
		if(!is_undefined(outParent)) array_remove(group.outputs, outParent);
			
		outParent = nodeValue("Value", group, CONNECT_TYPE.output, VALUE_TYPE.any, -1)
			.uncache()
			.setVisible(true, true);
		
		outParent.from  = self;
		outParent.index = array_length(group.outputs);
		
		array_push(group.outputs, outParent);
		if(is_array(group.output_display_list))
			array_push(group.output_display_list, outParent.index);
		
		if(!LOADING && !APPENDING) {
			group.refreshNodeDisplay();
			group.sortIO();
			group.setHeight();
		}
		
	} if(!LOADING && !APPENDING) createOutput();
	
	static step = function() {
		if(is_undefined(outParent)) return;
		outParent.name = display_name; 
	}
	
	static update = function() {
		var _in0 = inputs[0];
		var _pty = _in0.type;
		var _typ = _in0.value_from == noone? VALUE_TYPE.any         : _in0.value_from.type;
		var _dis = _in0.value_from == noone? VALUE_DISPLAY._default : _in0.value_from.display_type;
		
		_in0.setType(_typ);
		_in0.display_type = _dis;
		if(!is(outParent, NodeValue)) return;
		
		var ww = _typ == VALUE_TYPE.surface? 128 : 96;
		var hh = _typ == VALUE_TYPE.surface? 128 : 56;
		setDimension(ww, hh);
		
		outParent.setType(_in0.type);
		outParent.display_type  = _in0.display_type;
		outParent.color_display = _in0.color_display;
		outParent.draw_bg       = _in0.draw_bg;
		outParent.draw_fg       = _in0.draw_fg;
		
		if(group && _pty != _typ) group.setHeight();
		
		outParent.setValue(inputs[0].getValue());
	}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	static getGraphPreviewSurface = function() { var _in = array_safe_get(inputs, 0, noone); return _in == noone? noone : _in.getValue(); }
	static getPreviewValues       = function() { var _in = array_safe_get(inputs, 0, noone); return _in == noone? noone : _in.getValue(); }
	
	static drawNodeDef = drawNode;
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, display_parameter = noone, _panel = noone) { 
		if(_s >= .75) return drawNodeDef(_draw, _x, _y, _mx, _my, _s, display_parameter, _panel);
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _name = renamed? display_name : name;
		var _ts   = _s * 0.5;
		var _tx   = round(xx + 6 * _s + 2);
		var _ty   = round(inputs[0].y);
		
		draw_set_text(f_sdf, fa_left, fa_center);
		BLEND_ALPHA_MULP
		
		draw_set_color(0);					draw_text_transformed(_tx + 1, _ty + 1, _name, _ts, _ts, 0);
		draw_set_color(COLORS._main_text);	draw_text_transformed(_tx, _ty, _name, _ts, _ts, 0);
		
		BLEND_NORMAL
		
		return drawJunctions(_draw, xx, yy, _mx, _my, _s, _s <= 0.5);
	}
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	static postDeserialize		  = function() { if(group == noone) return; createOutput(false); }
	static postApplyDeserialize	  = function() {}
	
	static onDestroy = function() {
		if(is_undefined(outParent)) return;
		
		array_remove(group.outputs, outParent);
		group.sortIO();
		group.refreshNodes();
		
		var _tos = outParent.getJunctionTo();
		
		for (var i = 0, n = array_length(_tos); i < n; i++) 
			_tos[i].removeFrom();
		
	}
	
	static onUngroup = function() {
		var fr = inputs[0].value_from;
		
		for( var i = 0; i < array_length(outParent.value_to); i++ ) {
			var to = outParent.value_to[i];
			if(to.value_from != outParent) continue;
			
			to.setFrom(fr);
		}
	}
		
	static onLoadGroup = function() { if(group == noone) destroy(); }
}