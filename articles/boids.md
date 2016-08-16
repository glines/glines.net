% Simulating Bird Flocking Behavior with Boids

<!--
Outline:
- Implementing the boids algorithm
  - Boid is not an algorithm, it is an artificial intelligence stratey
    - Describe the definition of algorithm as per Knuth, CLRS
  - Modeling the three essential behaviors of boids (from Reynolds)
    - Alignment
    - Cohesion
    - Separation
    - Avoidance/Predation (fourth behavior optional)
  - Survey of existing implementations
    - Reynolds implementation <http://www.red3d.com/cwr/code/boids.lisp>
    - <https://processing.org/examples/flocking.html>
    - Blender
    - My implementation
  - Scripting boid behavior for quickly iterating
  - Artificial intelligence for improving upon boid behavior

Another article:
- Computer vision to count boids
-->

The boid "algorithm" does not necessarily fit the definition of an algorithm in
the strictest sense. There is no solution to the boid . The
"algorithm" is more like a set of guidelines we follow when designing boid particle
behavior, guidelines which result in boid behavior that mimics the flocking of
real birds.

This article is basically a survey of techniques for implementing the boid
algorithm which I have picked up while implementing the boid algorithm myself.

% Modeling Boid Motion
One point which has caused me a lot of headache while simulating flocking is
the question of how to model the motion of boids.

In the most simplistic model, boids are given

% References
Flocking: A Simple Technique for Simulating Group Behavior, Steven Woodcock

Artifical Life: A Report from the Frontier Where Computers Meet Biology, Steven Levy 1993

[C++ Boids, Christopher Kline](http://www.behaviorworks.com/people/ckline/boids)
