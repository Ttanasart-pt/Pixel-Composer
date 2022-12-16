function __initFontFolder() {
	var root = DIRECTORY + "Fonts";
	if(!directory_exists(root))
		directory_create(root);
}