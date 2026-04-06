Armature system is a way to create bone-based animation.



## Armature Editor


The main functionalities of this node is in the preview panel. There're 5 tools in the tool rack:


<img armature_tools>


### Adding Bones


When using the "Add bones" tools, click and drag on an empty area to add a new parent bone.


Click and drag from the end of a bone to create a child.

Click on a bone to split it.


### Deleting Bones


Select the "Revome bones" and click on a bone you want to delete. Note that deleting a bone with children will 
reattach the children to the parent of the deleted bone, if the deleted bone has no parent, then the children 
will becomes new parents.


### Detach Bones


Detach bones is used to detach a bone from its constrain. This does not mean removing the parent, but 
allowing the bone to move freely. Select the detach bones tool and click on the bone you want to detach.


<img-deco armature_bone_detach>


### Inverse Kinematics


Inverse Kinematics (IK) is a way to control the movement of a bone by moving its child. 

Select the IK 
tool, click on the last bone of the chain, that bone will be highlighted with green color, drag it to the first 
bone of the chain and release the mouse. A new IK target object will appear and you can move it to control the chain.


<img-deco armature_ik>




## Inspector


Armature node comes with custom inspector widget for viewing and managing the bones properties.


<img-deco armature_inspector>


<table class="cc4060">
    <tr>
        <th>Property</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Name</td>
        <td>Unique name of the bone, can be rename by clicking on the name</td>
    </tr>
    <tr>
        <td>Inherit scale</td>
        <td>Whether to scale the children with it's own scale when posing.</td>
    </tr>
    <tr>
        <td>Inherit rotation</td>
        <td>Whether to rotate the children with it's own rotation when posing.</td>
    </tr>
</table>




## Armature System


This node only create a bone structure, to pose it or attach a surface onto it, you need the <node armature_pose> 
and <node armature_bind> nodes respectively.


To see the tutorial for the entire armature system, please check out the <a href="">Armature tutorial</a> page.