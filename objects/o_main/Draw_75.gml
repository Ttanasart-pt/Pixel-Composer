/// @description tooltip filedrop
#region tooltip
	if(is_array(TOOLTIP) || TOOLTIP != "") {
		if(is_array(TOOLTIP)) {
			var content = TOOLTIP[0];
			var type    = TOOLTIP[1];
			
			switch(type) {
				case VALUE_TYPE.float :
				case VALUE_TYPE.integer :
				case VALUE_TYPE.text :
				case VALUE_TYPE.path :
					draw_tooltip_text(string(content));
					break;
				case VALUE_TYPE.boolean :
					draw_tooltip_text(content? "True" : "False");
					break;
				case VALUE_TYPE.curve :
					draw_tooltip_text("[Curve]");
					break;
				case VALUE_TYPE.color :
					draw_tooltip_color(content);
					break;
				case VALUE_TYPE.d3object :
					draw_tooltip_text("[3D object]");
					break;
				case VALUE_TYPE.object :
					draw_tooltip_text("[Object]");
					break;
				case VALUE_TYPE.surface :
					draw_tooltip_surface(content);
					break;
			}
		} else 
			draw_tooltip_text(TOOLTIP);
	}
	TOOLTIP = "";
#endregion