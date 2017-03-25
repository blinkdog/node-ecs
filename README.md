# node-ecs
Entity-Component-System for Node.js

## Motivation
Entity-Component-System (ECS) is a software architecture pattern that
originated in the game industry. It emphasizes separation of concerns
to make software more maintainable for software engineers, and more
flexible for game designers.

Object-Oriented Programming (OOP) has been the gold standard in
software architecture for a long time. In complicated and creative
endeavors like games, software engineers noticed that OOP class
hierarchies became difficult to modify the larger and more coupled
they grew. Moreover, game designers often needed code changes in
order to modify the game content.

The ECS pattern emphasizes separation of concerns by organizing things
into three areas:

* `Entity` - An identified collection of Components; typically any
object in a game. These could be a wall, a rock, a tree, a power-up,
the player, the enemies, the weather, etc. Entities contain no code,
they have some ID value, and reference a collection of Components.
All of the entities that exist are said to live in a World.

* `Component` - A set of data that defines an aspect / attribute / facet
of existence. Things that exist somewhere might have a "position" component
with data "x", "y", and "z" components. Things that have health and can
be damaged and/or killed might have a "health" component with a data element
"hit-points". Components do not contain code, they are simply a type-named
collection of related data.

* `System` - Code that operates on Component(s). All of the code lives here,
and uses the existence of components to decide which entities to operate
upon. For example, a Mover system might look for all entities with "position"
and "velocity" components and then update the positions according to the
velocities. A System operates only on the entities that contain relevant
Components, and ignores the others.

## Usage
This library provides support for the `Entity` and `Component` aspects
of an ECS implementation. A `System` is simply code, and it is assumed
that developers know how to write and organize functions for themselves.

node-ecs provides one component: `World`

    var World = require('node-ecs').World;

This component `World` provides several methods. The purpose of these
methods are summarized below. API details along with examples are
covered in the section to follow.

* `addComponent` - Add a Component to an Entity
* `createEntity` - Create a new Entity and add it to the World
* `find` - Find Entities by the Component(s) they contain
* `findAll` - Find ALL Entities contained in the World
* `remove` - Remove ALL Entities from the World
* `removeComponent` - Remove a Component from an Entity
* `removeEntity` - Remove an Entity from the World
* `size` - Determine how many Entities exist in the World

## API: World

### addComponent(entity, component, data) -> entity
Add a component to an entity, optionally providing data with which
to populate the component.

* `entity` Object: The entity to which to add the component
* `component` String: The name of the component to add
* `data` Object [Optional]: The data with which to populate the component

The provided `entity` is returned by the call.

Example:

    var world = new World();
    var dog = world.createEntity();
    // nobody has named this poor doggie yet
    world.addComponent(dog, "name");
    // dog.name = {}

Example 2:

    var world = new World();
    var dog = world.createEntity();
    world.addComponent(dog, "breed", {
      type: "Labrador",
      color: "Black"
    });
    // dog.breed = { type: "Labrador", color: "Black" }

### createEntity(id) -> entity
Create a new entity, and add that entity to the world.

* `id` String (UUID v4) [Optional]: The ID to be used by the Entity.

The `id` value is optional, and intended only for very advanced use-cases.
It is recommended that you allow the `World` to generate an ID for the
entity. Systems concern themselves with components, so access to an
entity by a known ID is something of an anti-pattern in ECS architecture.

The created `entity` is returned by the call.

Example:

    var world = new World();
    var dog = world.createEntity();
    // dog.uuid = "<some generated UUID v4 value>"

### find(components) -> [entity]
Find entities that contain the all of the provided components.

* `components` String or [String]: The components an entity must contain

An array of [Entity] (possibly empty) is returned by the call. All of the
entities contained in the array will have all of components specified in
the call to find.

Example:

    // some other code has added entities and game has been going for awhile
    var world = new World();

    // this is a Mover system that uses two components: position and velocity
    //
    // position:
    //   x: the current x position of the entity
    //   y: the current y position of the entity
    //
    // velocity:
    //   dx: delta-x, how fast the x position of the entity is changing
    //   dy: delta-y, how fast the y position of the entity is changing

    var i, len, movingThing, movingThings, pos, vel;

    // let's find all of the things that need to move
    movingThings = world.find(["position", "velocity"]);

    // now let's update the "position" component of all of them
    for (i = 0, len = movingThings.length; i < len; i++) {
      movingThing = movingThings[i];
      pos = movingThing.position;
      vel = movingThing.velocity;
      pos.x = pos.x + vel.dx;
      pos.y = pos.y + vel.dy;
    }

    // all moving entities have had their positions updated
    // now we might run a system to check for collisions?

### findAll() -> [entity]
Find all of the entities contained in the World.

An array of [Entity] (possibly empty) is returned by the call. The entities
contained in the array have no specific components.

Example:

    var world = new World();
    var everything = world.findAll();
    // everything = [] // we haven't added any entities yet!

This method is intended for advanced use-cases only; perhaps debugging,
logging, metrics, monitoring, serialization, etc. Note that it is an
anti-pattern to obtain all of the entities and iterate over each one
looking for specific components. Use the `find()` method instead.

### remove() -> World
Remove all entities from the World.

The world object is returned from this call.

Example:

    var world = new World();
    world.remove();

This method is pretty extreme and intended for advanced use-cases only.
A faster way to obtain an empty World object would simply be to call
the constructor and make a fresh one.

### removeComponent(entity, component) -> entity
Remove a component from an entity.

* `entity` Object: The entity from which to remove the component
* `component` String: The name of the component to be removed

The provided `entity` is returned by the call.

Example:

    var world = new World();
    var dog = world.createEntity();
    world.addComponent(dog, "breed", {
      type: "Corgi",
      color: "tuxedo"
    });
    // dog.breed = { type: "Corgi", color: "tuxedo" }
    world.removeComponent(dog, "breed");
    // dog.breed = undefined

### removeEntity(entity) -> World
Removes an entity from the World.

* `entity` Object: The entity to remove from the World.

The world object is returned by the call.

Example:

    var world = new World();
    var dog = world.createEntity();
    world.addComponent(dog, "breed", {
      type: "Corgi",
      color: "tuxedo"
    });
    // dog.breed = { type: "Corgi", color: "tuxedo" }
    world.removeEntity(dog);
    // gone to doggie heaven

### size() -> number
Determine how many entities exist in the World.

The number returned is the number of entities in the world.

Example:

    var world = new World();
    var dog = world.createEntity();
    var count = world.size();
    // count = 1

## Events: World
For advanced use-cases, one can listen on a World object for events
involving Entities and Components. World is an [EventEmitter] object.

### component-added -> (entity, component)
Fired when a Component is added to an Entity.

* `entity` Object: The entity to which a Component was added.
* `component` String: The name of the Component added to the Entity

Example:

    var world = new World();
    world.on("component-added", function(entity, component) {
      if (component === "breed") {
        return console.log("Breed is: " + entity.breed.type);
      }
    });
    var dog = world.createEntity();
    world.addComponent(dog, "breed", {
      type: "Corgi",
      color: "tuxedo"
    });
    // Breed is: Corgi

### component-removed -> (entity, component)
Fired when a Component is removed from an Entity.

* `entity` Object: The entity to which a Component was removed
* `component` String: The name of the Component removed from the Entity

Example:

    var world = new World();
    world.on("component-removed", function(entity, component) {
      if (component === "breed") {
        return console.log("Breed is: " + entity.breed.type);
      }
    });
    var dog = world.createEntity();
    world.addComponent(dog, "breed", {
      type: "Corgi",
      color: "tuxedo"
    });
    world.removeComponent(dog, "breed");
    // Breed is: Corgi

### entity-created -> (entity)
Fired when an entity is created in the world.

* `entity` Object: The entity which is newly created

Example:

    var world = new World();
    world.on("entity-created", function(entity) {
      return console.log("ID is: " + entity.uuid);
    });
    var dog = world.createEntity();
    // ID is: <some generated UUID v4 value>

### entity-removed -> (entity)
Fired when an entity is removed from the world.

* `entity` Object: The entity which is removed from the world

Example:

    var world = new World();
    world.on("entity-removed", function(entity) {
      return console.log("Goodbye ID " + entity.uuid);
    });
    var dog = world.createEntity();
    // Goodbye ID <some generated UUID v4 value>

## Development
In order to make modifications to node-ecs, you'll need to establish a
development environment:

    git clone https://github.com/blinkdog/node-ecs.git
    cd node-ecs
    npm install
    cake rebuild

### Code Coverage
You can see the [istanbul] coverage report for node-ecs with a task
in the cake file:

    cake coverage

This task will attempt to open the coverage report in a new tab in
Mozilla Firefox. If you use another browser, you'll need to modify
the `Cakefile` to specify your preferred command for viewing the
coverage report.

### Source files
The source files are located in `src/main/coffee`.

The test source files are located in `src/test/coffee`.

## License
node-ecs  
Copyright 2017 Patrick Meade.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the [GNU Affero General Public License]
along with this program.  If not, see <http://www.gnu.org/licenses/>.

[EventEmitter]: https://nodejs.org/api/events.html
[GNU Affero General Public License]: https://www.gnu.org/licenses/agpl-3.0.txt
[istanbul]: https://www.npmjs.com/package/istanbul
