function Node_Randomizer_Varient_Selector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Variant Selector";
	always_pad = true;
	reactive_on_hover = true;
	setDimension(96, 48);
	
	////- =Track
	newInput( 0, nodeValue_Text( "Section Name", "" ));
	
	newOutput( 0, nodeValue_Output( "Value",  VALUE_TYPE.any, 0  ));
	newOutput( 1, nodeValue_Output( "Variant Index",  VALUE_TYPE.integer, 0  ));
	newOutput( 1, nodeValue_Output( "Variant Amount", VALUE_TYPE.integer, 0  )).setVisible(false);
	newOutput( 2, nodeValue_Output( "Variants",       VALUE_TYPE.struct,  [] )).setVisible(false);
	
}