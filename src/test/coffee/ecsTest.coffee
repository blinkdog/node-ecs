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

#----------------------------------------------------------------------
# end of ecsTest.coffee
