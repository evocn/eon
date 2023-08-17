Everett
Todo
Alex Hartford
June 2023

FIRST PRIORITIES:
* Gameplay Code (Almost all of it). We want a working demo ASAP.
* Visualization of directing, so the user knows what is happening.
* Quick switch from directing into attack targeting.
* OBJ Files
* Animations

EASY STUFF:
* Gamepad Support
* Basic Menu UI for start screen, pause menu, etc.
* Start out on Audio
* Texture Catalogue

# GAMEPLAY
Port over mechanics from Emblem.
* Algorithms for pathing, ranges, ranged attacks, etc.

# ENGINE
Meshes
* Load OBJs
* Load FBXs
* Animations
  * Animation Player (Probably from scratch)

Materials?
* Look into the pros/cons of having a more particular system like this one.

Textures
* Load Obj Files/FBX files for the sake of texture coordinates.
* Make a nice Texture Catalogue system.

Text
* Load Bitmap Fonts
* Render Them (Efficiently)

# EDITOR
* Build everything with Undo/Redo in mind.
* Arbitrary entity editing? Reflection?
* Pick Entities? (Either Stencil Buffer or Raycasting to be agnostic)
* Gizmos to move, rotate, scale objects
  * BUT This needn't be arbitrarily complicated. We can have it be
    locked to the grid if we're making a grid-based game, etc.
  * This constraint means we could probably code em up ourselves.
* Entity Palette. Maybe defined in a file?

* Animation Viewer

Hotloading
(File Watcher)
* Meshes
* Animations
* Textures

# GRAPHICS
Decide on the look, and plan out which graphics features will be needed.
* Keep in mind the constraints I have.

Seek out meshes...

Particles
* Instanced Rendering

Water
* Start Flat
* Deformations
* Normal Maps
* Reflections
* Refractions
* Fancy Shit

Framebuffers
* Outlines?
* Shadows?
* Post-Processing in general?
* Should we even bother with a project of this scale?

# AUDIO
* Music
* SFX
* Mixer
* Ambient sounds
* Spatial audio

# DEVELOPMENT AIDS
Hotloaded Variable Tweaks File
Think of what Josh/Brett will need to work on this game...

# WAY DOWN THE PIPELINE
Camera System.
* Rotate around the board, like in Chess.
* Maybe give it like four angles, which you can snap around to
* Zoom in at different levels, like in FE.

UI System.

Menu System.

AI.

Gamepad Support.

Cutscenes.

Start Screen.

Credits.
