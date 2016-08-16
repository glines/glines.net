% Matrix Palette Skinning
% Jonathan Glines
% 2016-04-14

<!--
Outline:
  - Obtaining an animated mesh (COLLADA)
  - Reading the mesh with assimp
    - Read the vertex data and bone weights
    - Read the skeletal animation data
  - 
  - Make the matrix palettes
  - Send the vertices and palettes to the GL

-->
## Introduction
This tutorial describes how to implement the classic matrix palette skinning
technique for animating meshes. It assumes some background in C/C++ and OpenGL.

### Overview
We start by going over the theory behind skinning and skeletal animation. This
allows us to form a clear understanding of matrix palette skinning before
introducing any C++ code.

## Theory
### Triangle Meshes

### Skeletal Animation


### Skinning
Skeletal animation is a widely used animation technique which uses an
approximation of how bones work in the real world. Note that this is just an
approximation; very few modeling programs will use 

When it comes time to apply the mesh to the skeleton, each bone is actually a
control point that influences a number of vertices on the mesh near that point.
The artist determines how much influence each bone has where, but typically
bones will influence the vertices one would expect them to influence. For
example, a forearm bone would have nearly 100\% influence over vertices located
around your wristwatch. Remember that, as explained above, bones higher up in
the hierarchy, such as the upper arm bone, will affect the position of the
forearm.

It is relatively easy to draw a mesh without animation, and it is similarly
easy to draw the bones of an animation. The difficulty arises in combining the
mesh with the bones in order to actually animate the mesh.

It is easiest to first think of a skeleton with a single bone. The vertices 


### LERP and SLERP

### Skinning with Matrix Palettes
The something [@Gregory2009], [@Deloura2000] please

## Setup
Now that we have seen some of the theory behind skeletal animation, it's time
to get started with our example code. I will be using OpenGL and C++ for this
example, but the process should be similar with many other languages or
graphics API's. I will also be making heavy use of a C/C++ library called Open
Asset Import Library, a.k.a. assimp, which is essential for reading meshes and
animation data.

### Obtaining an Animated Mesh
One of the first difficulties one encounters is how to obtain an animated mesh.
This is easier said than done for someone who is not a 3D artist by trade.
Fortunately, there are some free tools that make animated mesh creation
relatively easy.

This section is just to point you to the tools you need to get a mesh.  If you
already have access to an animated mesh that you want to use, or if you are
already familiar with 3D animation tools, go ahead and skip this section. 

First, install a copy of the MakeHuman software, which is an open source tool
for generating custom human meshes and armatures. Open MakeHuman and make a
human mesh to your liking. You can set up your mesh however you like, but make
sure to choose a relatively simple skeleton rig. I chose the `game.json` rig,
as it is the simplest rig provided. Export your human mesh in Collada
(dae) format, as this format is well supported by both assimp and Blender.

Second, install Blender, which is a popular open source 3D animating tool.
Import your Collada mesh file 

## Implementation
Now that we have the theory and the assets we need, let's get started
implementing the palette skinning algorithm.

### Reading the Mesh with assimp
We start out by reading the mesh and animation data that our 3D animation tool
created. The Open Asset Import Library, usually referred to as assimp, is a C/C++
library that intends to make it easy to read mesh and animation files in a
variety of formats. This is the perfect tool for getting started because, as we
will soon see, the assimp library does most of the hard work of parsing ugly
mesh files for us.

We could choose from a variety of mesh formats supported by assimp, but we have
decided to stick with the industry standard OpenCollada mesh format. While not
the most optimal format (parsing XML files is expensive), OpenCollada is well
supported by both Blender and assimp, along with many other tools.

#### Reading the Vertex Data
<!-- Show how to read vertex position, normal, and texture coordinates -->
<!-- Show how to read bone weights -->
#### Reading the Skeletal Animation Data

## Resources

---
references:
- type: book
  id: JasonGregory2009
  author:
  - family: Gregory
    given: Jason
  issued:
    date-parts:
    - - 2009
  title: 'Game Engine Architecture'
  page: 737-738
  language: en-US
---
