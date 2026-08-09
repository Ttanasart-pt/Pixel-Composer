Create multiple pieces of rigidbody objects from a mask.

## Properties

[proptable]
Fracture
Fracture Map|Surface defining fracture pieces.
Fracture Threshold|How different the pixel color in the <junc Fracture Map> can be to be consider the same fragment.
Mesh Expansion|Expands each fragment outward.

Physics
Activate on Spawn|Activate physics (collision, gravity, etc.) on spawn.
Density|Object density, mass per fracture volume.
Air Resistance|Slow object when falling.
Rotation Resistance|Add force for rotating object.
Gravity Scale|Set custom gravity effect.

Joint
Use Joint|Add joint connecting between each fragment using minimum spaning tree.
Stiffness|How much force required to stretch the joit.
Breaking Force|Amount of force to break the joint, zero for unbreakable.
[/proptable]
