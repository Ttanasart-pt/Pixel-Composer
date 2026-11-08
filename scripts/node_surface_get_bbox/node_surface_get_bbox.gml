function Node_Surface_Get_BBOX(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Get BBOX";
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Surface("Surface In")).setRequired();
	// 1
	
	newOutput( 0, nodeValue_Output( "BBOX",   VALUE_TYPE.float, [0,0,0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 1, nodeValue_Output( "Area",   VALUE_TYPE.float, DEF_AREA  )).setDisplay(VALUE_DISPLAY.area, { useShape:false });
	newOutput( 2, nodeValue_Output( "Center", VALUE_TYPE.float, [0,0]     )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _data = outputs[0].getValue();
		var _bbox = array_safe_get(_data, preview_index, undefined);
		if(!is_array(_bbox)) return;
		
		var _cx = _x + _bbox[0] * _s;
		var _cy = _y + _bbox[1] * _s;
		var _cw = _bbox[2] * _s;
		var _ch = _bbox[3] * _s;
		
		var _bx0 = _cx;
		var _by0 = _cy;
		var _bx1 = _cx + _cw;
		var _by1 = _cy + _ch;
		
		draw_set_color(c_black);
		draw_rectangle_width(_bx0, _by0, _bx1, _by1, 3);
		
		draw_set_color(COLORS._main_icon);
		draw_rectangle_width(_bx0, _by0, _bx1, _by1, 1);
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			if(!is_surface(_surf)) return _outData;
		#endregion
		
		var bbox = surface_get_bbox(_surf);
		
		var _cx = bbox[0] + bbox[2] / 2;
		var _cy = bbox[1] + bbox[3] / 2;
		var _ww = bbox[2] / 2;
		var _hh = bbox[3] / 2;
		
		_outData[0] = bbox;
		_outData[1] = [ _cx, _cy, _ww, _hh, AREA_SHAPE.rectangle, AREA_MODE.area ];
		_outData[2] = [ _cx, _cy ];
		
		return _outData;
	}
	
	////- PREVIEW
	
	static getPreviewValues = function() {
		var val = inputs[0].getValue();
		if(is(val, dynaSurf)) 
			val = array_safe_get_fast(val.surfaces, 0, noone);
		return val;
	}
	
}