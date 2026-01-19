#region
	function Node_create_Color_Math(_x, _y, _group = noone, _param = {}) {
		var node  = new Node_Color_Math(_x, _y, _group).skipDefault();
		var query = struct_try_get(_param, "query", "");
		var ind   = array_find(global.node_blend_keys, query);
		
		if(ind >= 0) node.inputs[0].skipDefault().setValue(ind);
		return node;
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Color_Math", "Type > Add",      "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(BLEND_MODE.add);      });
		addHotkey("Node_Color_Math", "Type > Multiply", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(BLEND_MODE.multiply); });
	});
#endregion

function Node_Color_Math(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Color";
	setDimension(96, 48);
	
	newInput(0, nodeValue_EScroll( "Blend mode", 0, BLEND_TYPES )).rejectArray();
	
	////- =Colors
	newInput(1, nodeValue_Color(  "Color 0",   ca_black )).setVisible(true, true);
	newInput(2, nodeValue_Color(  "Color 1",   ca_white )).setVisible(true, true);
	newInput(3, nodeValue_Slider( "Intensity", 1        ));
	// inputs 4
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.color, ca_white));
	
	input_display_list = [ 0, 
		[ "Colors", false ], 1, 2, 3, 
	];
	
	////- Nodes
	
	static onValueUpdate = function(index = noone) {
		if(index != 0) return;
		
		var _type = inputs[0].getValue();
		setDisplayName(array_safe_get(BLEND_TYPES, _type, ""), false);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _bmode = _data[0];
			
			var _c0 = _data[1];
			var _c1 = _data[2];
			var _in = _data[3];
		#endregion
		
		var _r0 = _color_get_red(_c0);
		var _g0 = _color_get_green(_c0);
		var _b0 = _color_get_blue(_c0);
        var _l0 = 0.299 * _r0 + 0.587 * _g0 + 0.114 * _b0;
		
		var _r1 = _color_get_red(_c1);
		var _g1 = _color_get_green(_c1);
		var _b1 = _color_get_blue(_c1);
        var _l1 = 0.299 * _r1 + 0.587 * _g1 + 0.114 * _b1;

        var _ro = 0;
        var _go = 0;
        var _bo = 0;
		
		switch(_bmode) {
			case BLEND_MODE.normal       : 
            case BLEND_MODE.replace      : 
                _ro = _r1;
                _go = _g1;
                _bo = _b1;
                break;
			
			case BLEND_MODE.multiply     : 
                _ro = _r0 * _r1;
                _go = _g0 * _g1;
                _bo = _b0 * _b1;
                break;

			case BLEND_MODE.color_burn   : 
                _ro = (_r1 == 0) ? 0 : max(0, 1 - ((1 - _r0) / _r1));
                _go = (_g1 == 0) ? 0 : max(0, 1 - ((1 - _g0) / _g1));
                _bo = (_b1 == 0) ? 0 : max(0, 1 - ((1 - _b0) / _b1));
                break;

			case BLEND_MODE.linear_burn  : 
                _ro = max(0, _r0 + _r1 - 1);
                _go = max(0, _g0 + _g1 - 1);
                _bo = max(0, _b0 + _b1 - 1);
                break;

			case BLEND_MODE.minimum      : 
                _ro = min(_r0, _r1);
                _go = min(_g0, _g1);
                _bo = min(_b0, _b1);
                break;

			
			case BLEND_MODE.add          : 
                _ro = min(1, _r0 + _r1);
                _go = min(1, _g0 + _g1);
                _bo = min(1, _b0 + _b1);
                break;

			case BLEND_MODE.screen       : 
                _ro = 1 - (1 - _r0) * (1 - _r1);
                _go = 1 - (1 - _g0) * (1 - _g1);
                _bo = 1 - (1 - _b0) * (1 - _b1);
                break;

			case BLEND_MODE.color_dodge  : 
                _ro = (_r1 == 1) ? 1 : min(1, _r0 / (1 - _r1));
                _go = (_g1 == 1) ? 1 : min(1, _g0 / (1 - _g1));
                _bo = (_b1 == 1) ? 1 : min(1, _b0 / (1 - _b1));
                break;

			case BLEND_MODE.maximum      : 
                _ro = max(_r0, _r1);
                _go = max(_g0, _g1);
                _bo = max(_b0, _b1);
                break;

			
			case BLEND_MODE.overlay      : 
                _ro = _l1 > .5? (1 - 2 * (1 - _r0) * (1 - _r1)) : (2 * _r0 * _r1);
                _go = _l1 > .5? (1 - 2 * (1 - _g0) * (1 - _g1)) : (2 * _g0 * _g1);
                _bo = _l1 > .5? (1 - 2 * (1 - _b0) * (1 - _b1)) : (2 * _b0 * _b1);
                break;

			case BLEND_MODE.soft_light   : 
                _ro = _l1 > .5? 1. - (1. - _r0) * (1. - (_r1 - .5)) : _r0 * (_r1 + .5);
                _go = _l1 > .5? 1. - (1. - _g0) * (1. - (_g1 - .5)) : _g0 * (_g1 + .5);
                _bo = _l1 > .5? 1. - (1. - _b0) * (1. - (_b1 - .5)) : _b0 * (_b1 + .5);
                break;

			case BLEND_MODE.hard_light   : 
                _ro = _l1 > .5? 1. - (1. - _r0) * (1. - 2. * (_r1 - .5)) : 2. * _r0 * _r1;
                _go = _l1 > .5? 1. - (1. - _g0) * (1. - 2. * (_g1 - .5)) : 2. * _g0 * _g1;
                _bo = _l1 > .5? 1. - (1. - _b0) * (1. - 2. * (_b1 - .5)) : 2. * _b0 * _b1;
                break;

			case BLEND_MODE.vivid_light  : 
                _ro = _l1 > .5? 1. - (1. - _r0) * (2. * (_r1 - .5)) : _r0 / (1. - 2. * _r1);
                _go = _l1 > .5? 1. - (1. - _g0) * (2. * (_g1 - .5)) : _g0 / (1. - 2. * _g1);
                _bo = _l1 > .5? 1. - (1. - _b0) * (2. * (_b1 - .5)) : _b0 / (1. - 2. * _b1);
                break;

			case BLEND_MODE.linear_light : 
                _ro = _l1 > .5? _r0 + (2. * (_r1 - .5)) : _r0 + (2. * _r1 - 1.);
                _go = _l1 > .5? _g0 + (2. * (_g1 - .5)) : _g0 + (2. * _g1 - 1.);
                _bo = _l1 > .5? _b0 + (2. * (_b1 - .5)) : _b0 + (2. * _b1 - 1.);
                break;

			case BLEND_MODE.pin_light    : 
                _ro = _l1 > .5? max(_r0, 2. * (_r1 - .5)) : min(_r0, 2. * _r1);
                _go = _l1 > .5? max(_g0, 2. * (_g1 - .5)) : min(_g0, 2. * _g1);
                _bo = _l1 > .5? max(_b0, 2. * (_b1 - .5)) : min(_b0, 2. * _b1);
                break;

			
			case BLEND_MODE.difference   : 
                _ro = abs(_r0 - _r1);
                _go = abs(_g0 - _g1);
                _bo = abs(_b0 - _b1);
                break;

			case BLEND_MODE.exclusion    : 
                _ro = _r0 + _r1 - 2 * _r0 * _r1;
                _go = _g0 + _g1 - 2 * _g0 * _g1;
                _bo = _b0 + _b1 - 2 * _b0 * _b1;
                break;

			case BLEND_MODE.subtract     : 
                _ro = max(0, _r0 - _r1);
                _go = max(0, _g0 - _g1);
                _bo = max(0, _b0 - _b1);
                break;

			case BLEND_MODE.divide       : 
                _ro = (_r1 == 0) ? 1 : min(1, _r0 / _r1);
                _go = (_g1 == 0) ? 1 : min(1, _g0 / _g1);
                _bo = (_b1 == 0) ? 1 : min(1, _b0 / _b1);
                break;

			
			case BLEND_MODE.hue          : 
                var _h0 = _color_get_hue(_c0);
                var _s0 = _color_get_saturation(_c0);
                var _v0 = _color_get_value(_c0);

                var _h1 = _color_get_hue(_c1);
                
                var _cc = make_color_hsv(_h1, _s0, _v0);
                _ro = _color_get_red(_cc);
                _go = _color_get_green(_cc);
                _bo = _color_get_blue(_cc);
                break;  

			case BLEND_MODE.saturation   : 
                var _h0 = _color_get_hue(_c0);
                var _s0 = _color_get_saturation(_c0);
                var _v0 = _color_get_value(_c0);

                var _s1 = _color_get_saturation(_c1);

                var _cc = make_color_hsv(_h0, _s1, _v0);
                _ro = _color_get_red(_cc);
                _go = _color_get_green(_cc);
                _bo = _color_get_blue(_cc);
                break;

			case BLEND_MODE.luminosity   : 
                var _h0 = _color_get_hue(_c0);
                var _s0 = _color_get_saturation(_c0);
                var _v0 = _color_get_value(_c0);

                var _v1 = _color_get_value(_c1);

                var _cc = make_color_hsv(_h0, _s0, _v1);
                _ro = _color_get_red(_cc);
                _go = _color_get_green(_cc);
                _bo = _color_get_blue(_cc);
                break;

		}
		
        _ro = round(clamp(lerp(_r0, _ro, _in), 0, 1) * 255);
        _go = round(clamp(lerp(_g0, _go, _in), 0, 1) * 255);
        _bo = round(clamp(lerp(_b0, _bo, _in), 0, 1) * 255);
		
        var _out = make_color_rgba(_ro, _go, _bo, 255);
		return _out;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var col = outputs[0].getValue();
		
		if(is_array(col)) { drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h); return; }
		drawColor(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}