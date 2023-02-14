function fd_GUIDE() {
	/*
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    Thank you for purchasing the GameMaker Studio 2 version of Fluid Dynamics. Here's some information on how to use the asset.

	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

		Before you start:
	
		If you have imported this marketplace asset into a clean project and want to test the examples either move the "Fluid Dynamics" folder in the "Rooms"
		resources to the top so it's above all other rooms, or delete the rooms above the folder.

	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    The resources:
    
	    If you've imported all the resources from the asset into your project you'll see that they're all organized into folders called "Fluid Dynamics".
	    Inside these folders you can find occurrences of three types of folders: "API", "Example", and "Internal". "API" and "Internal" contain the essential
	    resources needed to use the Fluid Dynamics asset. "Example" contains resources used in the example that shows up when you run the game. Resources in the
	    "Example" folders show you how you can use most aspects of the Fluid Dynamics asset in a game.
    
	    To use Fluid Dynamics all you have to do is to call scripts from the "API" folder. All of the scripts are commented with a general
	    description of what the script does as well as descriptions specific to each parameter. It's recommended that you read through these whenever
	    you want to use them. When they are referred to later in this guide, open them and read them if you're unsure what they do.
    
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    Implementing Fluid Dynamics into your game - the essential steps:
    
	    First off you'll have to create a fluid dynamics rectangle with fd_rectangle_create. This script returns an instance id that you will use with the
	    other scripts in the asset later. A fluid dynamics rectangle represents an area that the fluid can move around in. All simulation and visualization
	    is done via a fluid dynamics rectangle.
    
	    After you have created a fluid dynamics rectangle, you should find a step event that you can call fd_rectangle_update in. This will make
	    the fluid dynamics rectangle regularly get updated so it moves the fluid around.
    
	    Then you should find a draw event to call fd_rectangle_draw in. This will draw your fluid dynamics rectangle to the screen.
    
	    After these three steps, you have a working fluid dynamics rectangle implemented, but it won't show you anything special because it doesn't have any
	    fluid in it yet. To add fluid, you can call fd_rectangle_replace_material or fd_rectangle_add_material. Material is the term used for the visual content
	    of a fluid dynamics rectangle. In a left mouse button event, you can for example do
	    fd_rectangle_replace_material("your fluid dynamics rectangle", "the sprite to add", "image index of sprite", "relative x", "relative y", 1, 1, c_white, 1)
	    which will continuously add fluid where you click with your mouse. "relative x" and "relative y" is the mouse coordinate relative to the fluid dynamics
	    rectangle. If you draw the fluid dynamics rectangle with 1 in scale, you can use mouse_x and mouse_y directly, but if you're scaling the fluid dynamics
	    rectangle (which is recommended, as it's much faster), you have to scale the mouse as well. If you're unsure on how to do this, see the example code
	    for how it is done.

	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    How can I improve the performance of the simulation?
    
	    One way to improve performance is by reducing the fluid dynamics rectangle size. This can be done by using a smaller size when calling
	    fd_rectangle_create. This will set all internal textures to the size entered. Alternatively, you can change the sizes of individual elements of the fluid
	    dynamics rectangle after creation. This can be done with the scripts fd_rectangle_set_pressure_size, fd_rectangle_set_material_size, and
	    fd_rectangle_set_velocity_size.
    
	    Another way to improve performance is by reducing the quality of the simulation by lowering the number of pressure iterations. The largest bottleneck of the
	    simulation is to solve for pressure. You can reduce the number of pressure iterations with fd_rectangle_set_pressure_iteration_type.
    
	    If you are using multiple fluid dynamics rectangles at the same time over the same region in the world, you might want to look into
	    fd_rectangle_inherit_velocity. The slowest part of the simulation is to update the velocity field, and with multiple fluid dynamics rectangles you will by
	    default have multiple velocity fields being solved individually. If it's okay that the fluids inside these rectangles follow the same directions, you
	    can use fd_rectangle_inherit_velocity to reuse a velocity field, thereby removing a velocity field update and greatly improving performance.

	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    Can I use this asset for a large or even infinite game world?
    
	    Yes, you can for example shift the content of the fluid dynamics rectangle as the view moves around with fd_rectangle_shift_content, and draw it at
	    the view's position. This will only make fluid near the view get simulated, allowing for highly detailed fluids even in large or infinite worlds. You
	    can make the fluid dynamics rectangle slightly bigger than the view size so that fluid outside the view disappears in an elegant way. The folder in the
	    API folder named "SimenGames' View Extension" contains some very useful scripts that can do all of this for you.
    
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------

	    If you want to know more, there are several comments with explanations in the example code and the scripts themselves. If you need more help, you can
	    visit the forum thread at "https://forum.yoyogames.com/index.php?threads/fluid-dynamics-gm-studio-2.26605/" or contact me by sending a mail to
	    asbjorn.lystrup@gmail.com or messaging Dragon47 on the GameMaker Community.
    
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	*/



}
