/// @macro {Real}
/// @private
#macro __BBMOD_SAVE_VERSION 0

/// @var {Id.DsMap<Asset.GMObject, Id.DsMap<String, Struct.BBMOD_Property>>}
/// @private
global.__bbmodObjectProperties = ds_map_create();

/// @func bbmod_object_add_property(_object, _property)
///
/// @desc Adds a serializable property to an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {Struct.BBMOD_Property} _property The property to add.
///
/// @see BBMOD_Property
function bbmod_object_add_property(_object, _property)
{
	if (!ds_map_exists(global.__bbmodObjectProperties, _object))
	{
		ds_map_add_map(global.__bbmodObjectProperties, _object, ds_map_create());
	}

	global.__bbmodObjectProperties[? _object][? _property.Name] = _property;
}

/// @func bbmod_object_add_bool(_object, _name)
///
/// @desc Adds a {@link BBMOD_EPropertyType.Bool} property to an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_bool(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Bool);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_color(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Color} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_color(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Color);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmfont(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMFont} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmfont(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMFont);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmobject(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMObject} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmobject(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMObject);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmpath(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMPath} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmpath(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMPath);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmroom(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMRoom} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmroom(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMRoom);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmscript(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMScript} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmscript(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMScript);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmshader(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMShader} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmshader(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMShader);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmsound(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMSound} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmsound(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMSound);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmsprite(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMSprite} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmsprite(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMSprite);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmtileset(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMTileSet} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmtileset(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMTileSet);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_gmtimeline(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.GMTimeline} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_gmtimeline(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.GMTimeline);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_matrix(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Matrix} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_matrix(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Matrix);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_path(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Path} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_path(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Path);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_quaternion(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Quaternion} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_quaternion(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Quaternion);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_real(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Real} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_real(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Real);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_real_array(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.RealArray} property to
/// an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_real_array(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.RealArray);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_string(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.String} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_string(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.String);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_vec2(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Vec2} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_vec2(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Vec2);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_vec3(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Vec3} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_vec3(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Vec3);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_add_vec4(_object, _name)
///
/// @desc Adds a serialiazble {@link BBMOD_EPropertyType.Vec4} property to an
/// object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {String} _name The property name.
///
/// @return {Struct.BBMOD_Property} The created property.
///
/// @note This is just a shorthand for {@link bbmod_object_add_property}.
///
/// @see bbmod_object_add_property
/// @see BBMOD_Property
function bbmod_object_add_vec4(_object, _name)
{
	gml_pragma("forceinline");
	var _property = new BBMOD_Property(_name, BBMOD_EPropertyType.Vec4);
	bbmod_object_add_property(_object, _property);
	return _property;
}

/// @func bbmod_object_get_property_map(_object, _dest)
///
/// @desc Retrieves a map of all serializable properties of an object.
///
/// @param {Asset.GMObject} _object The object to get serializable properties of.
/// @param {Id.DsMap<String, Struct.BBMOD_Property>} _dest A map to store the
/// properties to. It is not automatically cleared before the properties are added!
///
/// @return {Real} Number of serializable properties that the object has.
function bbmod_object_get_property_map(_object, _dest)
{
	var _count = 0;
	var _current = _object;

	while (object_exists(_current))
	{
		if (ds_map_exists(global.__bbmodObjectProperties, _current))
		{
			var _properties = global.__bbmodObjectProperties[? _current];
			var _propertyName = ds_map_find_first(_properties);

			repeat (ds_map_size(_properties))
			{
				if (!ds_map_exists(_dest, _propertyName))
				{
					_dest[? _propertyName] = _properties[? _propertyName];
					++_count;
				}

				_propertyName = ds_map_find_next(_properties, _propertyName);
			}
		}

		_current = object_get_parent(_current);
	}

	return _count;
}

/// @func bbmod_object_get_property_array(_object, _dest)
///
/// @desc Retrieves an array of all serializable properties of an object.
///
/// @param {Asset.GMObject} _object The object to get serializable properties of.
/// @param {Array<Struct.BBMOD_Property>} _dest An array to store the properties
/// to. It is not automatically cleared before the properties are added!
///
/// @return {Real} Number of serializable properties that the object has.
function bbmod_object_get_property_array(_object, _dest)
{
	static _map = ds_map_create();

	ds_map_clear(_map);
	bbmod_object_get_property_map(_object, _map);

	var _size = ds_map_size(_map);

	if (_size > 0)
	{
		var _propertyName = ds_map_find_first(_map);

		repeat (_size)
		{
			array_push(_dest, _map[? _propertyName]);
			_propertyName = ds_map_find_next(_map, _propertyName);
		}
	}

	return _size;
}

/// @func bbmod_instance_to_buffer(_instance, _buffer, _properties)
///
/// @desc Serializes an instance to a buffer.
///
/// @param {Id.Instance} _instance The instance to serialize.
/// @param {Id.Buffer} _buffer The buffer to serialize the instance to.
/// @param {Array<Struct.BBMOD_Property>} _properties Array of
/// properties to serialize.
///
/// @see bbmod_object_get_property_array
function bbmod_instance_to_buffer(_instance, _buffer, _properties)
{
	with (_instance)
	{
		buffer_write(_buffer, buffer_string, object_get_name(object_index));
		buffer_write(_buffer, buffer_f32, x);
		buffer_write(_buffer, buffer_f32, y);
		buffer_write(_buffer, buffer_string, layer_get_name(layer));

		var _propsCount = array_length(_properties);
		var _propertyIndex = 0;

		repeat (_propsCount)
		{
			var _property = _properties[_propertyIndex++];
			var _propertyName = _property.Name;
			var _propertyType = _property.Type;

			switch (_propertyType)
			{
			case BBMOD_EPropertyType.Bool:
				buffer_write(_buffer, buffer_bool, variable_instance_get(id, _propertyName));
				break;

			case BBMOD_EPropertyType.Color:
				var _color = variable_instance_get(id, _propertyName);
				buffer_write(_buffer, buffer_f32, _color.Red);
				buffer_write(_buffer, buffer_f32, _color.Green);
				buffer_write(_buffer, buffer_f32, _color.Blue);
				buffer_write(_buffer, buffer_f32, _color.Alpha);
				break;

			case BBMOD_EPropertyType.GMFont:
				buffer_write(_buffer, buffer_string, font_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMObject:
				buffer_write(_buffer, buffer_string, object_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMPath:
				buffer_write(_buffer, buffer_string, path_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMRoom:
				buffer_write(_buffer, buffer_string, room_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMScript:
				buffer_write(_buffer, buffer_string, script_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMShader:
				buffer_write(_buffer, buffer_string, shader_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMSound:
				buffer_write(_buffer, buffer_string, audio_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMSprite:
				buffer_write(_buffer, buffer_string, sprite_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMTileSet:
				buffer_write(_buffer, buffer_string, tileset_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.GMTimeline:
				buffer_write(_buffer, buffer_string, timeline_get_name(variable_instance_get(id, _propertyName)));
				break;

			case BBMOD_EPropertyType.Path:
				buffer_write(_buffer, buffer_string, variable_instance_get(id, _propertyName));
				break;

			case BBMOD_EPropertyType.Quaternion:
				var _quaternion = variable_instance_get(id, _propertyName);
				buffer_write(_buffer, buffer_f32, _quaternion.X);
				buffer_write(_buffer, buffer_f32, _quaternion.Y);
				buffer_write(_buffer, buffer_f32, _quaternion.Z);
				buffer_write(_buffer, buffer_f32, _quaternion.W);
				break;

			case BBMOD_EPropertyType.Matrix:
				var _matrix = variable_instance_get(id, _propertyName);
				var i = 0;
				repeat (16)
				{
					buffer_write(_buffer, buffer_f32, _matrix[i++]);
				}
				break;

			case BBMOD_EPropertyType.Real:
				buffer_write(_buffer, buffer_f32, variable_instance_get(id, _propertyName));
				break;

			case BBMOD_EPropertyType.RealArray:
				var _array = variable_instance_get(id, _propertyName);
				var _size = array_length(_size);
				buffer_write(_buffer, buffer_u32, _size);
				var i = 0;
				repeat (_size)
				{
					buffer_write(_buffer, buffer_f32, _array[i++]);
				}
				break;

			case BBMOD_EPropertyType.String:
				buffer_write(_buffer, buffer_string, variable_instance_get(id, _propertyName));
				break;

			case BBMOD_EPropertyType.Vec2:
				var _vec2 = variable_instance_get(id, _propertyName);
				buffer_write(_buffer, buffer_f32, _vec2.X);
				buffer_write(_buffer, buffer_f32, _vec2.Y);
				break;

			case BBMOD_EPropertyType.Vec3:
				var _vec3 = variable_instance_get(id, _propertyName);
				buffer_write(_buffer, buffer_f32, _vec3.X);
				buffer_write(_buffer, buffer_f32, _vec3.Y);
				buffer_write(_buffer, buffer_f32, _vec3.Z);
				break;

			case BBMOD_EPropertyType.Vec4:
				var _vec4 = variable_instance_get(id, _propertyName);
				buffer_write(_buffer, buffer_f32, _vec4.X);
				buffer_write(_buffer, buffer_f32, _vec4.Y);
				buffer_write(_buffer, buffer_f32, _vec4.Z);
				buffer_write(_buffer, buffer_f32, _vec4.W);
				break;

			default:
				throw new BBMOD_Exception("Invalid property type " + string(_propertyType) + "!");
			}
		}
	}
}

/// @func bbmod_instance_from_buffer(_buffer, _properties)
///
/// @desc Deserializes an instance from a buffer.
///
/// @param {Id.Buffer} _buffer The buffer to deserialize an instance from.
/// @param {Id.DsMap<String, Array<Struct.BBMOD_Property>>} _properties A mapping
/// from object name to an array of properties of the object.
///
/// @return {Id.Instance} The created instnace.
///
/// @throws {BBMOD_Exception} If an error occurs.
function bbmod_instance_from_buffer(_buffer, _properties)
{
	var _objectName = buffer_read(_buffer, buffer_string);
	var _objectIndex = asset_get_index(_objectName);

	if (_objectIndex == -1)
	{
		throw new BBMOD_Exception("Object \"" + _objectName + "\" not found!");
	}

	var _x = buffer_read(_buffer, buffer_f32);
	var _y = buffer_read(_buffer, buffer_f32);
	var _layerName = buffer_read(_buffer, buffer_string);
	var _instance = instance_create_layer(_x, _y, _layerName, _objectIndex);

	if (!ds_map_exists(_properties, _objectName))
	{
		return _instance;
	}

	var _objectProperties = _properties[? _objectName];

	with (_instance)
	{
		var _propertyIndex = 0;
		repeat (array_length(_objectProperties))
		{
			var _property = _objectProperties[_propertyIndex++];
			var _propertyName = _property.Name;
			var _propertyType = _property.Type;

			switch (_propertyType)
			{
			case BBMOD_EPropertyType.Bool:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_bool));
				break;

			case BBMOD_EPropertyType.Color:
				var _r = buffer_read(_buffer, buffer_f32);
				var _g = buffer_read(_buffer, buffer_f32);
				var _b = buffer_read(_buffer, buffer_f32);
				var _a = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Color(_r, _g, _b, _a));
				break;

			case BBMOD_EPropertyType.GMFont:
			case BBMOD_EPropertyType.GMObject:
			case BBMOD_EPropertyType.GMPath:
			case BBMOD_EPropertyType.GMRoom:
			case BBMOD_EPropertyType.GMScript:
			case BBMOD_EPropertyType.GMShader:
			case BBMOD_EPropertyType.GMSound:
			case BBMOD_EPropertyType.GMSprite:
			case BBMOD_EPropertyType.GMTileSet:
			case BBMOD_EPropertyType.GMTimeline:
				variable_instance_set(id, _propertyName, asset_get_index(buffer_read(_buffer, buffer_string)));
				break;

			case BBMOD_EPropertyType.Path:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_string));
				break;

			case BBMOD_EPropertyType.Quaternion:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _w = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Quaternion(_x, _y, _z, _w));
				break;

			case BBMOD_EPropertyType.Matrix:
				var _matrix = array_create(16, 0);
				var i = 0;
				repeat (16)
				{
					_matrix[@ i++] = buffer_read(_buffer, buffer_f32);
				}
				variable_instance_set(id, _propertyName, _matrix);
				break;

			case BBMOD_EPropertyType.Real:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_f32));
				break;

			case BBMOD_EPropertyType.RealArray:
				var _size = buffer_read(_buffer, buffer_u32);
				var _array = array_create(_size, 0);
				var i = 0;
				repeat (_size)
				{
					_array[@ i++] = buffer_read(_buffer, buffer_f32);
				}
				variable_instance_set(id, _propertyName, _array);
				break;

			case BBMOD_EPropertyType.String:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_string));
				break;

			case BBMOD_EPropertyType.Vec2:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec2(_x, _y));
				break;

			case BBMOD_EPropertyType.Vec3:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec3(_x, _y, _z));
				break;

			case BBMOD_EPropertyType.Vec4:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _w = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec4(_x, _y, _z, _w));
				break;

			default:
				throw new BBMOD_Exception("Invalid property type " + string(_propertyType) + "!");
			}
		}
	}

	return _instance;
}

/// @func bbmod_save_instances_to_buffer(_object, _buffer)
///
/// @desc Saves all instances of an object to a buffer.
///
/// @param {Asset.GMObject} _object Use keyword `all` to save all existing
/// instances.
/// @param {Id.Buffer} _buffer The buffer to save the instances to.
///
/// @return {Real} Number of saved instances.
function bbmod_save_instances_to_buffer(_object, _buffer)
{
	var _properties = ds_map_create();

	// Write instances
	var _bufferInstances = buffer_create(1, buffer_grow, 1);
	var _instanceCount = instance_number(_object);
	buffer_write(_bufferInstances, buffer_u64, _instanceCount);

	with (_object)
	{
		var _instanceProps;
		if (!ds_map_exists(_properties, object_index))
		{
			_instanceProps = [];
			bbmod_object_get_property_array(object_index, _instanceProps);
			_properties[? object_index] = _instanceProps;
		}
		else
		{
			_instanceProps = _properties[? object_index];
		}
		bbmod_instance_to_buffer(id, _bufferInstances, _instanceProps);
	}

	// Write header
	var _objectCount = ds_map_size(_properties);
	buffer_write(_buffer, buffer_u8, __BBMOD_SAVE_VERSION);
	buffer_write(_buffer, buffer_u16, _objectCount);
	if (_objectCount > 0)
	{
		var _objectIndex = ds_map_find_first(_properties);
		repeat (_objectCount)
		{
			var _propertyArray = _properties[? _objectIndex];
			var _propertyArraySize = array_length(_propertyArray);
			buffer_write(_buffer, buffer_string, object_get_name(_objectIndex));
			buffer_write(_buffer, buffer_u16, _propertyArraySize);
			for (var i = 0; i < _propertyArraySize; ++i)
			{
				var _property = _propertyArray[i];
				buffer_write(_buffer, buffer_string, _property.Name);
				buffer_write(_buffer, buffer_u8, _property.Type);
			}
			_objectIndex = ds_map_find_next(_properties, _objectIndex);
		}
	}

	// Copy instances into the destination buffer
	buffer_copy(_bufferInstances, 0, buffer_get_size(_bufferInstances), _buffer, buffer_tell(_buffer));

	// Free data
	ds_map_destroy(_properties);
	buffer_delete(_bufferInstances);

	return _instanceCount;
}

/// @func bbmod_load_instances_from_buffer(_buffer[, _idsOut])
///
/// @desc Loads instances from a buffer.
///
/// @param {Id.Buffer} _buffer A buffer to load instances from.
/// @param {Array<Id.Instance>} [_idsOut] An array to hold all loaded
/// instances.
///
/// @return {Real} Returns number of loaded instances.
///
/// @throws {BBMOD_Exception} If an error occurs.
function bbmod_load_instances_from_buffer(_buffer, _idsOut=undefined)
{
	var _saveVersion = buffer_read(_buffer, buffer_u8);

	if (_saveVersion != __BBMOD_SAVE_VERSION)
	{
		throw new BBMOD_Exception("Invalid save version " + string(_saveVersion) + "!");
	}

	var _objectCount = buffer_read(_buffer, buffer_u16);
	var _propertyMap = ds_map_create();

	repeat (_objectCount)
	{
		var _objectName = buffer_read(_buffer, buffer_string);
		var _propertyCount = buffer_read(_buffer, buffer_u16);
		var _propertyArray = [];
		repeat (_propertyCount)
		{
			var _propertyName = buffer_read(_buffer, buffer_string);
			var _propertyType = buffer_read(_buffer, buffer_u8);
			array_push(_propertyArray, new BBMOD_Property(_propertyName, _propertyType));
		}
		_propertyMap[? _objectName] = _propertyArray;
	}

	var _instanceCount = buffer_read(_buffer, buffer_u64);

	if (_idsOut == undefined)
	{
		repeat (_instanceCount)
		{
			bbmod_instance_from_buffer(_buffer, _propertyMap);
		}
	}
	else
	{
		repeat (_instanceCount)
		{
			array_push(_idsOut, bbmod_instance_from_buffer(_buffer, _propertyMap));
		}
	}

	ds_map_destroy(_propertyMap);

	return _instanceCount;
}
