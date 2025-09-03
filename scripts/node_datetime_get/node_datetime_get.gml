function Node_Datetime_Get(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Datetime";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Format", "%y-%m-%dT%h:%n:%s"));
	
	newInput(1, nodeValue_Bool("Update", true));
	
	newOutput(0, nodeValue_Output("Data", VALUE_TYPE.text, ""));
	
	template_guide = [
		["%s", "Second",   function() /*=>*/ {return string_lead_zero(current_second,  2)} ],
		["%n", "Minute",   function() /*=>*/ {return string_lead_zero(current_minute,  2)} ],
		["%h", "Hour",     function() /*=>*/ {return string_lead_zero(current_hour,    2)} ],
		-1,
		
		["%d", "Day",      function() /*=>*/ {return string_lead_zero(current_day,     2)} ],
		["%w", "Week Day", function() /*=>*/ {return current_weekday} ],
		["%m", "Month",    function() /*=>*/ {return string_lead_zero(current_month,   2)} ],
		["%y", "Year",     function() /*=>*/ {return current_year}   ],
		
		-1,
		["%tm", "Program microsec", function() /*=>*/ {return get_timer()} ],
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
	    export_template,
	    1,
    ]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
	    update_on_frame = _data[1];
	    
	    var _format = _data[0];
	    var _res = _format;
	    
	    for( var i = 0, n = array_length(template_guide); i < n; i++ ) {
	        var _temp = template_guide[i];
	        if(_temp == -1) continue;
	        
	        _res = string_replace_all(_res,_temp[0],_temp[2]());
	    }
	    
		return _res;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		draw_text_bbox(bbox, str);
	}
}