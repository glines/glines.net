% Building an Octree in C++

<!--
Outline:
-->

## Introduction
I assume anyone reading this has at least passing familiarity with octrees.
They're one of the most beautiful (in my opinion) datastructures around.
Octrees are very handy for anything to do with negotiating objects in a three
dimensional space ^[This is an inline note. I wonder if it even works. Hopefully
it shows up in the margin.]; ray tracing, collision detection, voxel rendering,
etc.  They're also appear to be quite intuitive, but the devil is in the
details.

I'm writing this article as a sort of catch-all for showcasing the beauty of
octrees, as well as for pointing out the hairy details that can ruin your
day.^[Something about this is a little bit fishy to me. You can find out more
at some site on the internet, yay!] Only a tiny fraction of this article can be
considered original research, as I'm certain many others have beaten this
subject to death long before I .  References are provided towards the end of
the article.

The de

## Getting Started
