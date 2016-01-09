% Simulating Flocking Behavior with Boids

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
