function Node_Array_CSV_Parse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "CSV Parse";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("CSV string", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Skip line", self, 0));
	
	newInput(2, nodeValue_Bool("First Row Header", self, false));
	
	newInput(3, nodeValue_Text("Sort", self, []))
		.setDisplay(VALUE_DISPLAY.text_array, { data: [] });
	
	newInput(4, nodeValue_Bool("Output Struct", self, false));
	
	newInput(5, nodeValue_Text("Columns", self, []))
		.setDisplay(VALUE_DISPLAY.text_array, { data: [] });
	
	newInput(6, nodeValue_Text("Number Columns", self, []))
		.setDisplay(VALUE_DISPLAY.text_array, { data: [] });
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0))
		.setArrayDepth(1);
	
	input_display_list = [
		["Input",  false], 0, 1, 
		["Table",  false], 2, 6, 3, 
		["Output", false], 5, 4,
	];
	
	inputs[0].editWidget.max_height = ui(240);
	inputs[3].editWidget.mode       = 1;
	
	__sortKey = "";
	
	function sortValueAsc(a,b,k) {
		var va = a[$ k];
		var vb = b[$ k];
		
		if(is_string(va))  return string_compare(va,vb);
		if(is_numeric(va)) return va-vb;
		return 0;
	}
	
	function sortValueDec(a,b,k) {
		var va = a[$ k];
		var vb = b[$ k];
		
		if(is_string(va))  return string_compare(vb,va);
		if(is_numeric(va)) return vb-va;
		return 0;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _str    = getInputData(0);
		var _skp    = getInputData(1);
		var _hed    = getInputData(2);
		var _sort   = getInputData(3);
		var _struct = getInputData(4);
		var _ocol   = getInputData(5);
		var _ncol   = getInputData(6);
		
		var _lines = _str;
		var _lAmo  = array_length(_lines);
		var _head  = noone;
		var _sarr  = [];
		
		var _col   = 0;
		
		////- PARSE
		
		for( var i = _skp; i < _lAmo; i++ ) {
			var _l = _lines[i];
				_l = string_replace_all(_l, "\"", "");
			    _l = string_trim(_l);
			   
			var _row = string_split(_l, ",");
			
			if(_hed && _head == noone) {
				_head = _row;
				_col  = array_length(_row);
				continue;
			}
			
			if(_head != noone) {
				var _rowStr = {};
				for( var j = 0, m = min(array_length(_row), _col); j < m; j++ )
					_rowStr[$ _head[j]] = _row[j];
				
				for( var j = 0, m = array_length(_ncol); j < m; j++ )
					if(struct_has(_rowStr, _ncol[j])) 
						_rowStr[$ _ncol[j]] = toNumber(_rowStr[$ _ncol[j]]);
				
				array_push(_sarr, _rowStr);
			}
		}
		
		////- SORT
		
		if(_hed && _head != noone) {
			inputs[3].editWidget.data = _head;
			inputs[5].editWidget.data = _head;
			inputs[6].editWidget.data = _head;
		}
		
		__sort = [];
		for( var i = 0, n = array_length(_sort); i < n; i++ ) {
			var _srt  = _sort[i];
			__sort[i] = [
				string_char_at(_srt, 1) == "+",
				string_copy(_srt, 2, string_length(_srt) - 1)
			];
		}
		
		array_sort(_sarr, function(a,b) /*=>*/ {
			for( var i = 0, n = array_length(__sort); i < n; i++ ) {
				var _srt = __sort[i];
				var _res = _srt[0]? sortValueAsc(a, b, _srt[1]) : sortValueDec(a, b, _srt[1]);
				if(_res != 0) return _res;
			}
			
			return 0;
		});
		
		////- OUTPUT
		
		if(_struct && _head != noone) {
			if(!array_empty(_ocol)) {
				var _a = [];
			
				for( var i = 0, n = array_length(_sarr); i < n; i++ ) {
					var _rw = {};
					for( var j = 0, m = array_length(outCol); j < m; j++ )
						_rw[$ outCol[j]] = _sarr[i][$ outCol[j]];
					_a[i] = _rw;
				}
				
				outputs[0].setValue(_a);
				
			} else 
				outputs[0].setValue(_sarr);
			
		} else {
			var outCol = array_empty(_ocol)? _head : _ocol;
			var _a = [];
			
			for( var i = 0, n = array_length(_sarr); i < n; i++ ) {
				var _rw = [];
				for( var j = 0, m = array_length(outCol); j < m; j++ )
					_rw[j] = _sarr[i][$ outCol[j]];
				_a[i] = _rw;
			}
			
			outputs[0].setValue(_a);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, "CSV");
	}
}