function Node_DLL(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "DLL";
	setDimension(96, 32 + 24 * 1);
	
	newInput(0, nodeValue_Text("DLL File", self, ""))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Dynamic-link library (.dll)|*.dll" })
		.setVisible(true, false);
	
	newInput(1, nodeValue_Text("Function name", self, ""));
	
	newInput(2, nodeValue_Enum_Button("Return type", self,  0, [ "Number", "Buffer" ]));
	
	outputs[0] = nodeValue_Output("Return Value", self, VALUE_TYPE.float, 0);
	
	ext_cache       = "";
	ext_function    = -1;
	attributes.size = 0;
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			attributes.size++;
			refreshDynamicInput();
			triggerRender();
		}
		
		var amo = attributes.size;
		if(buttonTextIconInstant(attributes.size > 0, THEME.button_hide, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2) {
			attributes.size--;
			refreshDynamicInput();
			triggerRender();
		}
		
		return _h;
	}); #endregion
	
	input_display_list = [ 
		["Function",   	false], 0, 1, 2, 
		["Parameters",	false], array_adjust_tool, 
	]
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index + 0, nodeValue_Enum_Button("Parameter type", self,  0, [ "Number", "Buffer" ]));
		
		newInput(index + 1, nodeValue_Float("Parameter value", self, 0 ))
			.setVisible(true, true);
		
		array_push(input_display_list, index + 0, index + 1);
		
		return [ inputs[index + 0], inputs[index + 1] ];
	} 
	
	setDynamicInput(2, false);
	
	static refreshDynamicInput = function() {
		var _l   = [];
		var amo  = attributes.size;
		var _ind = input_fix_len + amo * data_length;
		
		for( var i = 0; i < min(_ind, array_length(inputs)); i++ )
			array_push(_l, inputs[i]);
		
		var _add = amo - getInputAmount();
		repeat(_add) array_append(_l, createNewInput());
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len; i < array_length(_l); i++ ) {
			_l[i].index = i;
			array_push(input_display_list, i);
		}
		

		inputs = _l;
		
		getJunctionList();
		setHeight();
		
	}
	
	val_types = [ VALUE_TYPE.float, VALUE_TYPE.buffer ];
	val_typeo = [ VALUE_TYPE.float, VALUE_TYPE.text ];
	
	static update = function() { 
		var amo = getInputAmount();
		    amo = clamp(round(amo), 0, 16);
		var ts  = array_create(amo);
		var tv  = array_create(amo);
		var _rdy = true;
		
		for(var i = 0; i < amo; i++) {
			var _ind = input_fix_len + i * data_length;
			var _typ = getInputData(_ind + 0);
			
			inputs[_ind + 1].setType(val_types[_typ]);
			ts[i] = _typ? ty_string : ty_real;
			
			var _val = getInputData(_ind + 1);
			if(_typ == 1) _val = buffer_to_string(_val);
			
			tv[i] = _val;
		}
		
		var _fnS = {
			path   : getInputData(0),
			func   : getInputData(1),
			type   : getInputData(2)? ty_string : ty_real,
			params : ts
		}
		
		var _str = json_stringify(_fnS);
		if(ext_cache != _str) {
			
			switch(amo) {
				case  0 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  0); break;
				case  1 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  1, ts[0]); break;
				case  2 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  2, ts[0],ts[1]); break;
				case  3 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  3, ts[0],ts[1],ts[2]); break;
				case  4 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  4, ts[0],ts[1],ts[2],ts[3]); break;
				case  5 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  5, ts[0],ts[1],ts[2],ts[3],ts[4]); break;
				case  6 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  6, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5]); break;
				case  7 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  7, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6]); break;
				case  8 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  8, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7]); break;
				case  9 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type,  9, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8]); break;
				case 10 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 10, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9]); break;
				case 11 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 11, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10]); break;
				case 12 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 12, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10],ts[11]); break;
				case 13 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 13, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10],ts[11],ts[12]); break;
				case 14 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 14, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10],ts[11],ts[12],ts[13]); break;
				case 15 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 15, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10],ts[11],ts[12],ts[13],ts[14]); break;
				case 16 : ext_function = external_define(_fnS.path, _fnS.func, dll_cdecl, _fnS.type, 16, ts[0],ts[1],ts[2],ts[3],ts[4],ts[5],ts[6],ts[7],ts[8],ts[9],ts[10],ts[11],ts[12],ts[13],ts[14],ts[15]); break;
			}
			
			ext_cache = _str;
		}
		
		var _res = 0;
		
		if(_rdy) {
			switch(amo) {
				case  0 : _res = external_call(ext_function); break;
				case  1 : _res = external_call(ext_function, tv[0]); break;
				case  2 : _res = external_call(ext_function, tv[0],tv[1]); break;
				case  3 : _res = external_call(ext_function, tv[0],tv[1],tv[2]); break;
				case  4 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3]); break;
				case  5 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4]); break;
				case  6 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5]); break;
				case  7 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6]); break;
				case  8 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7]); break;
				case  9 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8]); break;
				case 10 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9]); break;
				case 11 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10]); break;
				case 12 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10],tv[11]); break;
				case 13 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10],tv[11],tv[12]); break;
				case 14 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10],tv[11],tv[12],tv[13]); break;
				case 15 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10],tv[11],tv[12],tv[13],tv[14]); break;
				case 16 : _res = external_call(ext_function, tv[0],tv[1],tv[2],tv[3],tv[4],tv[5],tv[6],tv[7],tv[8],tv[9],tv[10],tv[11],tv[12],tv[13],tv[14],tv[15]); break;
			}
		}
		
		outputs[0].setType(val_types[_fnS.type]);
		
		if(_fnS.type) _res = buffer_from_string(_res);
		
		outputs[0].setValue(_res);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _fn  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, _fn);
	}
}