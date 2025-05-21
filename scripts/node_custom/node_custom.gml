function Node_Custom(_x, _y, _group = noone, _param = {}) : Node_Processor(_x, _y, _group) constructor {
    itype     = _param[$ "iname"]     ?? noone;
	sourceDir = _param[$ "sourceDir"] ?? "";
	dataPath  = _param[$ "data"]      ?? "";
	node_info = json_load_struct(sourceDir + "/" + dataPath);
	
	node_overlay = [];
	
	static parseInfo = function() {
	    inputs  = [];
		outputs = [];
		
		for( var i = 0, n = array_length(node_info.inputs); i < n; i++ ) {
			var _input    = node_info.inputs[i];
			var _name     = _input.name;
			var _type     = _input.type;
			var _valu     = _input.value;
			var _tooltip  = _input[$ "tooltip"]           ?? "";
			var _showIns  = _input[$ "show_in_inspector"] ?? true;
			var _showGra  = _input[$ "show_in_graph"]     ?? false;
			var _overl    = _input[$ "overlay"];
			var _n = noone;
			
			switch(_type) {
				case "surface" : _n = nodeValue_Surface( _name, _valu); break;
				case "float"   : _n = nodeValue_Float(   _name, _valu); break;
				case "int"     : _n = nodeValue_Int(     _name, _valu); break;
				case "color"   : _n = nodeValue_Color(   _name, _valu); break;
				
				case "dimension" :  _n = nodeValue_Dimension();              break;
				case "vec2"      :  _n = nodeValue_Vec2(    _name, _valu); break;
				case "vec3"      :  _n = nodeValue_Vec3(    _name, _valu); break;
				case "vec4"      :  _n = nodeValue_Vec4(    _name, _valu); break;
				
				case "mat2"   :  _n = nodeValue_Float(   _name, _valu).setDisplay(VALUE_DISPLAY.matrix, { size: 2 }); break;
				case "mat3"   :  _n = nodeValue_Float(   _name, _valu).setDisplay(VALUE_DISPLAY.matrix, { size: 3 }); break;
				case "mat4"   :  _n = nodeValue_Float(   _name, _valu).setDisplay(VALUE_DISPLAY.matrix, { size: 4 }); break;
			}
			
			var _disp = _input[$ "display"];
			if(_disp != undefined) {
				switch(_disp.type) {
					case "enum_button": _n.setDisplay(VALUE_DISPLAY.enum_button, _disp.data); break;
					case "enum_scroll": _n.setDisplay(VALUE_DISPLAY.enum_scroll, _disp.data); break;
						
					case "slider": _n.setDisplay(VALUE_DISPLAY.slider, { range: [_disp[$ "min"], _disp[$ "max"], _disp[$ "step"]] }); break;
				}
			}
			
			newInput(i, _n)
			    .setTooltip(_tooltip)
			    .setVisible(_showIns, _showGra);
			
			if(_overl != undefined) {
			    array_push(node_overlay, _n);
			}
		}
		
		for( var i = 0, n = array_length(node_info.outputs); i < n; i++ ) {
			var _output   = node_info.outputs[i];
			var _name     = _output.name;
			var _type     = _output.type;
			var _valu     = _output.value;
			var _showGra  = _output[$ "show_in_graph"] ?? true;
			
			newOutput(i, nodeValue_Output(_name, value_type_from_string(_type), _valu)).setVisible(_showGra);
		}
		
	    if(struct_has(node_info, "input_display"))  input_display_list  = node_info.input_display;
		if(struct_has(node_info, "output_display")) output_display_list = node_info.output_display;
		
		onParseInfo();
	}
	
	static onParseInfo = function() {}
	static postBuild   = function() { parseInfo(); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { 
	    var _hov = false;
	    
        for( var i = 0, n = array_length(node_overlay); i < n; i++ ) {
            var _n = node_overlay[i];
            var hv = _n.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); 
            
            _hov  = _hov || hv;
            hover = hover && !hv;
        }
        
        return _hov;
	}
}