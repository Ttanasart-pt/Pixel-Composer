/// @enum An enumeration of all property types.
/// @see BBMOD_Property
enum BBMOD_EPropertyType
{
	/// @member A boolean.
	Bool,
	/// @member A {@link BBMOD_Color}.
	Color,
	/// @member A GameMaker Font asset.
	GMFont,
	/// @member A GameMaker Object asset.
	GMObject,
	/// @member A GameMaker Path asset.
	GMPath,
	/// @member A GameMaker Room asset.
	GMRoom,
	/// @member A GameMaker Script asset.
	GMScript,
	/// @member A GameMaker Shader asset.
	GMShader,
	/// @member A GameMaker Sound asset.
	GMSound,
	/// @member A GameMaker Sprite asset.
	GMSprite,
	/// @member A GameMaker Tile Set asset.
	GMTileSet,
	/// @member A GameMaker Timeline asset.
	GMTimeline,
	/// @member A matrix.
	Matrix,
	/// @member A path to a file or a directory.
	Path,
	/// @member A {@link BBMOD_Quaternion}.
	Quaternion,
	/// @member A real number.
	Real,
	/// @member An array of real numbers.
	RealArray,
	/// @member A string.
	String,
	/// @member A {@link BBMOD_Vec2}.
	Vec2,
	/// @member A {@link BBMOD_Vec3}.
	Vec3,
	/// @member A {@link BBMOD_Vec4}.
	Vec4,
	// WARNING: Any new property type must be added at the end of this enum,
	// otherwise save files would be corrupted!!!
};
