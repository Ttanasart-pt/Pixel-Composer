function Node_Widget_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Widget Test";
	setDimension(96, 32 + 24 * 1);
	draw_padding = 8;
	
	newInput( 0, nodeValue_Float(        "floatBox",        0                             ));
	newInput( 1, nodeValue_Range(        "rangeBox",       [0,0]                          ));
	newInput( 2, nodeValue_Vec2(         "vectorBox",      [0,0]                          ));
	newInput( 3, nodeValue_Vec2_Range(   "vectorRangeBox", [0,0,0,0]                      ));
	newInput( 4, nodeValue_Rotation(     "rotator",         0                             ));
	newInput( 5, nodeValue_RotRange(     "rotatorRange",   [0,0]                          ));
	newInput( 6, nodeValue_RotRand(      "rotatorRandom",  [0,0,0,0,0]                    ));
	newInput( 7, nodeValue_Slider(       "slider",          0                             ));
	newInput( 8, nodeValue_Slider_Range( "sliderRange",    [0,0]                          ));
	newInput( 9, nodeValue_Area(         "areaBox",        DEF_AREA                       ));
	newInput(10, nodeValue_Padding(      "paddingBox",     [0,0,0,0]                      ));
	newInput(11, nodeValue_EScroll(      "scrollBox",       0, [ "Choice 1", "Choice 2" ] ));
	newInput(12, nodeValue_EButton(      "buttonGroup",     0, [ "Choice 1", "Choice 2" ] ));
	newInput(13, nodeValue_Quaternion(   "quarternionBox", [0,0,0,0]                      ));
	newInput(14, nodeValue_Matrix(       "matrixGrid"));
	
	newInput(15, nodeValue_Float("controlPointBox", [0,0,0,0,0,0,0]) ).setDisplay(VALUE_DISPLAY.puppet_control)
	newInput(16, nodeValue_Float("transformBox",    [0,0,0,0,0])     ).setDisplay(VALUE_DISPLAY.transform)

	newInput(17, nodeValue_Bool("checkBox", false))

	newInput(18, nodeValue_Color("buttonColor",   0 )            ).setDisplay(VALUE_DISPLAY._default)
	newInput(19, nodeValue_Palette("buttonPalette"  )            ).setDisplay(VALUE_DISPLAY.palette)
	newInput(20, nodeValue_Gradient("buttonGradient", gra_white) ).setDisplay(VALUE_DISPLAY._default)

	newInput(21, nodeValue("pathArrayBox", self, CONNECT_TYPE.input, VALUE_TYPE.path, []).setDisplay(VALUE_DISPLAY.path_array, { filter: [ FILE_SEL_IMAGE, "" ] }))
	newInput(22, nodeValue("pathLoad",     self, CONNECT_TYPE.input, VALUE_TYPE.path, "").setDisplay(VALUE_DISPLAY.path_load))
	newInput(23, nodeValue("pathSave",     self, CONNECT_TYPE.input, VALUE_TYPE.path, "").setDisplay(VALUE_DISPLAY.path_save))
	newInput(24, nodeValue("font",         self, CONNECT_TYPE.input, VALUE_TYPE.font, ""));
	
	newInput(25, nodeValue_Curve("curveBox", CURVE_DEF_11) .setDisplay(VALUE_DISPLAY._default))

	newInput(26, nodeValue_Text("textArea")                .setDisplay(VALUE_DISPLAY._default))
	newInput(27, nodeValue_Text("textBox")                 .setDisplay(VALUE_DISPLAY.text_box))
	newInput(28, nodeValue_Text("textArea")                .setDisplay(VALUE_DISPLAY.codeLUA))
	newInput(29, nodeValue_Text("textArea")                .setDisplay(VALUE_DISPLAY.codeHLSL))
	newInput(30, nodeValue_Text("textArrayBox", [])        .setDisplay(VALUE_DISPLAY.text_array, { data: [ "Choice 1", "Choice 2" ] }))

	newInput(31, nodeValue_Surface("surfaceBox")           .setDisplay(VALUE_DISPLAY._default))
	
	input_display_list = [
		["Number",  false],  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 
		["Boolean", false], 17, 
		["Color",   false], 18, 19, 20, 
		["Path",    false], 21, 22, 23, 24, 
		["Curve",   false], 25, 
		["Text",    false], 26, 27, 28, 29, 30, 
		["Surface", false], 31, 
	];
}