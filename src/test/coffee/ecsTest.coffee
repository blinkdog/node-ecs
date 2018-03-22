# ecsTest.coffee
# Copyright 2017 Patrick Meade.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------

_ = require "underscore"
should = require "should"

mut = require "../lib/ecs"

describe "node-ecs", ->
  it "should export a class World", ->
    mut.should.have.property "World"
    mut.World.should.be.a.Function()

  describe "World", ->
    world = null

    beforeEach ->
      world = new mut.World()

    it "should be able to create a world", ->
      world.should.be.ok()
      world.should.have.properties [
        "addComponent"
        "createEntity"
        "find"
        "findAll"
        "remove"
        "removeComponent"
        "removeEntity"
        "size"
      ]

    it "should be able to report the number of entities", ->
      world.size().should.equal 0

    it "should be able to create an entity", ->
      entity = world.createEntity()
      entity.should.be.ok()
      entity.should.have.property "uuid"
      world.size().should.equal 1

    it "should be able to create an entity with a specific id", ->
      entity = world.createEntity "330f6aa3-fbf3-48f0-b00f-3cafaedc353f"
      entity.should.be.ok()
      entity.should.have.property "uuid"
      entity.uuid.should.equal "330f6aa3-fbf3-48f0-b00f-3cafaedc353f"
      world.size().should.equal 1

    it "should be able to remove an entity", ->
      entity = world.createEntity()
      entity.should.be.ok()
      entity.should.have.property "uuid"
      world.size().should.equal 1
      world.removeEntity entity
      world.size().should.equal 0

    it "should be able to create multiple entities", ->
      world.size().should.equal 0
      world.createEntity()
      world.createEntity()
      world.createEntity()
      world.size().should.equal 3

    it "should be able to remove all entities", ->
      world.size().should.equal 0
      world.createEntity()
      world.createEntity()
      world.createEntity()
      world.size().should.equal 3
      world.remove()
      world.size().should.equal 0

    it "should be able to remove specific entities", ->
      world.size().should.equal 0
      e1 = world.createEntity()
      e2 = world.createEntity()
      e3 = world.createEntity()
      e4 = world.createEntity()
      e5 = world.createEntity()
      world.size().should.equal 5
      world.removeEntity e2
      world.removeEntity e4
      world.size().should.equal 3

    it "should be able to find all entities", ->
      world.size().should.equal 0
      e1 = world.createEntity()
      e2 = world.createEntity()
      e3 = world.createEntity()
      e4 = world.createEntity()
      e5 = world.createEntity()
      world.size().should.equal 5
      world.removeEntity e2
      world.removeEntity e4
      world.size().should.equal 3
      es = world.findAll()
      es.length.should.equal 3
      es[0].should.equal e1
      es[1].should.equal e5
      es[2].should.equal e3

    it "should add a component to an entity", ->
      player = world.createEntity()
      world.size().should.equal 1
      world.addComponent player, "name",
        first: "Fred"
        last: "Bloggs"
      player.should.have.property "name"
      player.name.should.eql
        first: "Fred"
        last: "Bloggs"

    it "should add empty data if no component is provided", ->
      player = world.createEntity()
      world.size().should.equal 1
      world.addComponent player, "name"
      player.should.have.property "name"
      player.name.should.eql {}

    it "should be able to find entities by component", ->
      player = world.createEntity()
      world.size().should.equal 1
      world.addComponent player, "name",
        first: "Fred"
        last: "Bloggs"
      players = world.find "name"
      players.length.should.equal 1
      players[0].name.should.eql
        first: "Fred"
        last: "Bloggs"

    it "should be able to find entities by multiple components", ->
      electron = world.createEntity()
      world.addComponent electron, "velocity", {dx:-10, dy:20}
      dog = world.createEntity()
      world.addComponent dog, "position", {x:25, y:25}
      world.addComponent dog, "velocity", {dx:5, dy:0}
      flag = world.createEntity()
      world.addComponent flag, "position", {x:25, y:25}
      moving = world.find "velocity"
      moving.length.should.equal 2
      located = world.find "position"
      located.length.should.equal 2
      movers = world.find ["position", "velocity"]
      movers.length.should.equal 1

    it "should be able to find entities by id", ->
      player = world.createEntity()
      player.uuid.should.be.a.String()
      {uuid} = player
      world.size().should.equal 1
      world.addComponent player, "name",
        first: "Fred"
        last: "Bloggs"
      players = world.find "name"
      players.length.should.equal 1
      players[0].name.should.eql
        first: "Fred"
        last: "Bloggs"
      myPlayer = world.findById uuid
      myPlayer.should.be.an.Object()
      myPlayer.name.should.eql
        first: "Fred"
        last: "Bloggs"
      myPlayer.uuid.should.equal uuid
      myPlayer.should.equal players[0]
      myPlayer.should.equal player

    it "should not return entities by id that don't exist", ->
      player = world.createEntity()
      player.uuid.should.be.a.String()
      {uuid} = player
      world.size().should.equal 1
      world.addComponent player, "name",
        first: "Fred"
        last: "Bloggs"
      players = world.find "name"
      players.length.should.equal 1
      players[0].name.should.eql
        first: "Fred"
        last: "Bloggs"
      myPlayer = world.findById "47d11ff8-b121-494f-9a5a-9a261ec3f243"
      should(myPlayer).equal undefined

    it "should not create unnecessary indexes", ->
      electron = world.createEntity()
      world.addComponent electron, "velocity", {dx:-10, dy:20}
      dog = world.createEntity()
      world.addComponent dog, "position", {x:25, y:25}
      world.addComponent dog, "velocity", {dx:5, dy:0}
      flag = world.createEntity()
      world.addComponent flag, "position", {x:25, y:25}
      _.size(world.indexes).should.equal 0
      movers = world.find ["position", "velocity"]
      _.size(world.indexes).should.equal 1
      movers2 = world.find ["velocity", "position"]
      _.size(world.indexes).should.equal 1
      movers.should.eql movers2

    it "should not index removed entities", ->
      electron = world.createEntity()
      world.addComponent electron, "velocity", {dx:-10, dy:20}
      dog = world.createEntity()
      world.addComponent dog, "position", {x:25, y:25}
      world.addComponent dog, "velocity", {dx:5, dy:0}
      flag = world.createEntity()
      world.addComponent flag, "position", {x:25, y:25}
      located = world.find "position"
      located.length.should.equal 2
      world.removeEntity dog
      located = world.find "position"
      located.length.should.equal 1

    it "should not affect indexes not containing removed entities", ->
      electron = world.createEntity()
      world.addComponent electron, "velocity", {dx:-10, dy:20}
      dog = world.createEntity()
      world.addComponent dog, "position", {x:25, y:25}
      world.addComponent dog, "velocity", {dx:5, dy:0}
      flag = world.createEntity()
      world.addComponent flag, "position", {x:25, y:25}
      speedy = world.find "velocity"
      speedy.length.should.equal 2
      located = world.find "position"
      located.length.should.equal 2
      speedy.length.should.equal 2
      world.removeEntity flag
      located = world.find "position"
      located.length.should.equal 1
      speedy.length.should.equal 2

    it "should not affect indexes not indexing added components", ->
      electron = world.createEntity()
      world.addComponent electron, "velocity", {dx:-10, dy:20}
      dog = world.createEntity()
      world.addComponent dog, "position", {x:25, y:25}
      world.addComponent dog, "velocity", {dx:5, dy:0}
      flag = world.createEntity()
      world.addComponent flag, "position", {x:25, y:25}
      speedy = world.find "velocity"
      speedy.length.should.equal 2
      typed = world.find "nationality"
      typed.length.should.equal 0
      world.addComponent flag, "nationality", {nation:"United States"}
      typed = world.find "nationality"
      typed.length.should.equal 1
      speedy = world.find "velocity"
      speedy.length.should.equal 2

    it "should not index until all components are present", ->
      person = world.createEntity()
      world.size().should.equal 1
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "name",
        name: "Logan"
        codename: "Wolverine"
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "mutant",
        mutant: true
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "team",
        team: "X-Men"
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 1
      xmen[0].should.equal person

    it "should de-index if a component is removed", ->
      person = world.createEntity()
      world.size().should.equal 1
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "name",
        name: "Logan"
        codename: "Wolverine"
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "mutant",
        mutant: true
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0
      world.addComponent person, "team",
        team: "X-Men"
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 1
      xmen[0].should.equal person
      world.removeComponent person, "team"
      xmen = world.find ["mutant", "name", "team"]
      xmen.length.should.equal 0

    it "should not return an internal index from findAll()", ->
      thing1 = world.createEntity()
      world.size().should.equal 1
      thing2 = world.createEntity()
      world.size().should.equal 2
      thing3 = world.createEntity()
      world.size().should.equal 3
      allThings = world.findAll()
      thing4 = world.createEntity()
      world.size().should.equal 4
      allThings2 = world.findAll()
      allThings.length.should.equal 3
      allThings2.length.should.equal 4
      allThings.should.not.equal allThings2

    it "should not return an internal index from find()", ->
      world.size().should.equal 0
      for i in [1..5]
        thing = world.createEntity()
        world.addComponent thing, "monster", { id: i }
        world.addComponent thing, "health", { hp: 100 }
      world.size().should.equal 5
      thing = world.createEntity()
      world.addComponent thing, "hero", { id: 0 }
      world.addComponent thing, "health", { hp: 100 }
      world.size().should.equal 6
      monsters = world.find "monster"
      monsters.length.should.equal 5
      thing = world.createEntity()
      world.addComponent thing, "monster", { id: i }
      world.addComponent thing, "health", { hp: 100 }
      world.size().should.equal 7
      monsters.length.should.equal 5
      monsters2 = world.find "monster"
      monsters2.length.should.equal 6
      monsters.should.not.equal monsters2

    describe "loadEntity", ->
      it "should be able to load an entity without a uuid", ->
        entity =
          position:
            x: 1
            y: 2
            z: 3
          velocity:
            dx: -1
            dy: 0
            dz: +1
          name:
            name: "Fred Bloggs"
        ent = world.loadEntity entity
        ent.should.have.properties [ "uuid", "position", "velocity", "name" ]
        entity.uuid = ent.uuid
        ent.should.eql entity

      it "should be able to load an entity using a uuid", ->
        entity =
          uuid: "7df19fa0-4674-49aa-8c28-765ac034978c"
          position:
            x: 1
            y: 2
            z: 3
          velocity:
            dx: -1
            dy: 0
            dz: +1
          name:
            name: "Fred Bloggs"
        ent = world.loadEntity entity
        ent.should.have.properties [ "uuid", "position", "velocity", "name" ]
        ent.should.eql entity

#----------------------------------------------------------------------
# end of ecsTest.coffee
