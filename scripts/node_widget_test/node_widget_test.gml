function Node_Widget_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Widget Test";
	setDimension(96, 32 + 24 * 1);
	draw_padding = 8;
	
	newInput( 0, nodeValue("textBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0)                                      .setDisplay(VALUE_DISPLAY._default))
	newInput( 1, nodeValue("rangeBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [0, 0])                                .setDisplay(VALUE_DISPLAY.range))
	newInput( 2, nodeValue("vectorBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [0, 0])                               .setDisplay(VALUE_DISPLAY.vector))
	newInput( 3, nodeValue("vectorRangeBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [0, 0, 0, 0])                    .setDisplay(VALUE_DISPLAY.vector_range))
	newInput( 4, nodeValue("rotator", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0)                                      .setDisplay(VALUE_DISPLAY.rotation))
	newInput( 5, nodeValue("rotatorRange", self, CONNECT_TYPE.input, VALUE_TYPE.float, [0, 0])                            .setDisplay(VALUE_DISPLAY.rotation_range))
	newInput( 6, nodeValue_Float("rotatorRandom", [0, 0, 0, 0, 0])                  .setDisplay(VALUE_DISPLAY.rotation_random))
	newInput( 7, nodeValue("slider", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0)                                       .setDisplay(VALUE_DISPLAY.slider))
	newInput( 8, nodeValue("sliderRange", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0 ])                           .setDisplay(VALUE_DISPLAY.slider_range))
	newInput( 9, nodeValue("areaBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, DEF_AREA)						        .setDisplay(VALUE_DISPLAY.area))
	newInput(10, nodeValue("paddingBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                      .setDisplay(VALUE_DISPLAY.padding))
	newInput(11, nodeValue("cornerBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                       .setDisplay(VALUE_DISPLAY.corner))
	newInput(12, nodeValue("controlPointBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0, 0, 0 ])        .setDisplay(VALUE_DISPLAY.puppet_control))
	newInput(13, nodeValue("scrollBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0)                                    .setDisplay(VALUE_DISPLAY.enum_scroll, [ "Choice 1", "Choice 2" ]))
	newInput(14, nodeValue("buttonGroup", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0)                                  .setDisplay(VALUE_DISPLAY.enum_button, [ "Choice 1", "Choice 2" ]))
	newInput(15, nodeValue("matrixGrid", self, CONNECT_TYPE.input, VALUE_TYPE.float, array_create(9))                     .setDisplay(VALUE_DISPLAY.matrix, { size: 3 }))
	newInput(16, nodeValue("transformBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ])                 .setDisplay(VALUE_DISPLAY.transform))
	newInput(17, nodeValue("transformBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ])                 .setDisplay(VALUE_DISPLAY.transform))
	newInput(18, nodeValue("quarternionBox", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])                  .setDisplay(VALUE_DISPLAY.d3quarternion))

	newInput(19, nodeValue_Bool("checkBox", false)                               .setDisplay(VALUE_DISPLAY._default))

	newInput(20, nodeValue_Color("buttonColor", 0)                                  .setDisplay(VALUE_DISPLAY._default))
	newInput(21, nodeValue_Palette("buttonPalette", array_clone(DEF_PALETTE))                     .setDisplay(VALUE_DISPLAY.palette))
	newInput(22, nodeValue_Gradient("buttonGradient", new gradientObject(ca_white))  .setDisplay(VALUE_DISPLAY._default))

	newInput(23, nodeValue("pathArrayBox", self, CONNECT_TYPE.input, VALUE_TYPE.path, [])                                 .setDisplay(VALUE_DISPLAY.path_array, { filter: [ "image|*.png;*.jpg", "" ] }))
	newInput(24, nodeValue("pathLoad",     self, CONNECT_TYPE.input, VALUE_TYPE.path, "")                                 .setDisplay(VALUE_DISPLAY.path_load))
	newInput(25, nodeValue("pathSave",     self, CONNECT_TYPE.input, VALUE_TYPE.path, "")                                 .setDisplay(VALUE_DISPLAY.path_save))
	newInput(26, nodeValue("font",         self, CONNECT_TYPE.input, VALUE_TYPE.font, ""));
	
	newInput(27, nodeValue_Curve("curveBox", CURVE_DEF_11)                          .setDisplay(VALUE_DISPLAY._default))

	newInput(28, nodeValue_Text("textArea")                                     .setDisplay(VALUE_DISPLAY._default))
	newInput(29, nodeValue_Text("textBox")                                      .setDisplay(VALUE_DISPLAY.text_box))
	newInput(30, nodeValue_Text("textArea")                                     .setDisplay(VALUE_DISPLAY.codeLUA))
	newInput(31, nodeValue_Text("textArea")                                     .setDisplay(VALUE_DISPLAY.codeHLSL))
	newInput(32, nodeValue_Text("textArrayBox", [])                                 .setDisplay(VALUE_DISPLAY.text_array, { data: [ "Choice 1", "Choice 2" ] }))

	newInput(33, nodeValue_Surface("surfaceBox")                             .setDisplay(VALUE_DISPLAY._default))
	
	input_display_list = [
		["Number",  false], 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18,
		["Boolean", false], 19,  
		["Color",   false], 20, 21, 22,
		["Path",    false], 23, 24, 25, 26,
		["Curve",   false], 27,
		["Text",    false], 28, 29, 30, 31, 32,
		["Surface", false], 33,
	];
}