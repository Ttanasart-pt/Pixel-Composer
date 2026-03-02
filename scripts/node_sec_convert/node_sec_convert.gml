function Node_Sec_Convert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Seconds Convert";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Float( "Seconds", 0)).setVisible(true, true);
	
	////- =Format
	newInput( 1, nodeValue_Text( "Format", "%h:%n:%s" ));
	newInput( 2, nodeValue_Bool( "Seconds Decimal", true ));
	// 
	
	newOutput( 0, nodeValue_Output( "Format String", VALUE_TYPE.text,  "" ));
	newOutput( 1, nodeValue_Output( "Seconds",       VALUE_TYPE.float, 0  ));
	newOutput( 2, nodeValue_Output( "Minutes",       VALUE_TYPE.float, 0  ));
	newOutput( 3, nodeValue_Output( "Hours",         VALUE_TYPE.float, 0  ));
	newOutput( 4, nodeValue_Output( "DAys",          VALUE_TYPE.float, 0  ));
	
	template_guide = [
		["%s", "Second",   function() /*=>*/ {return string_lead_zero(current_second,  2)} ],
		["%n", "Minute",   function() /*=>*/ {return string_lead_zero(current_minute,  2)} ],
		["%h", "Hour",     function() /*=>*/ {return string_lead_zero(current_hour,    2)} ],
		-1,
		
		["%d", "Day",      function() /*=>*/ {return string_lead_zero(current_day,     2)} ],
	];
	
	export_template = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _hg = ui(20);
		var _hh = ui(16);
		var _yy = _y + ui(8);
		
		for( var i = 0, n = array_length(template_guide); i < n; i++ ) {
		    var _temp = template_guide[i];
		    
		    if(_temp == -1) {
    			_yy += ui(6);
    			_hh += ui(6);
		        continue;
		    }
		    
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + ui(16 + 16), _yy,_temp[0]);
			
			draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + _w - ui(4 + 16), _yy,_temp[1]);
			
			_yy += _hg;
			_hh += _hg;
		}
		
		return _hh;
	});
	
	input_display_list = [ 0, 
		[ "Format", false ], 1, export_template, 2, 
	];
	
	////- Node
	
	static processData = function(_outdata, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		#region data
			var _sec = _data[0];
			
			var _for = _data[1];
			var _dec = _data[2];
		#endregion
		
		var  s = _sec;
		var _d = floor(s / 86400); s -= _d * 86400;
		var _h = floor(s / 3600);  s -= _h * 3600;
		var _m = floor(s / 60);    s -= _m * 60;
		var _s = floor(s);
		
		var _txt = _for;
		_txt = string_replace(_txt, "%d", string_lead_zero(_d, 2));
		_txt = string_replace(_txt, "%h", string_lead_zero(_h, 2));
		_txt = string_replace(_txt, "%n", string_lead_zero(_m, 2));
		_txt = string_replace(_txt, "%s", string_lead_zero(_s, 2));
		
		if(_dec) {
			var _frac = floor(frac(s) * 100);
			_txt += "." + string_lead_zero(_frac, 2);
		}
		
		_outdata[0] = _txt;
		_outdata[1] =  s;
		_outdata[2] = _m;
		_outdata[3] = _h;
		_outdata[4] = _d;
		
		return _outdata;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[0].getValue();
		var bbox = draw_bbox;
		draw_text_bbox(bbox, str);
	}
}