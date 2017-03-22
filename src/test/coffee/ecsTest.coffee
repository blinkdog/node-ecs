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

should = require "should"

mut = require "../lib/ecs"

describe "ecs", ->
  it "should obey the laws of logic", ->
    true.should.equal true

  it "should export a class World", ->
    mut.should.have.property "World"
    mut.World.should.be.a.Function()

  describe "World", ->
    world = null

    beforeEach ->
      world = new mut.World()

    it "should emit when an entity is created", (done) ->
      world.on "entity-created", (e) ->
        return done() if e?
        done new Error "e == null"
      world.size().should.equal 0
      world.createEntity()
      world.size().should.equal 1

    it "should emit when an entity is removed", (done) ->
      world.on "entity-removed", (e) ->
        return done() if e?
        done new Error "e == null"
      world.size().should.equal 0
      x = world.createEntity()
      world.size().should.equal 1
      world.removeEntity x
      world.size().should.equal 0

    it "should emit when removing all entities", (done) ->
      count = 0
      world.on "entity-removed", (e) ->
        count++
        done() if count is 4
      world.size().should.equal 0
      world.createEntity()
      world.createEntity()
      world.createEntity()
      world.size().should.equal 3
      world.remove()
      world.size().should.equal 0
      world.createEntity()
      world.size().should.equal 1
      world.remove()

    it "should create entities with custom ID values", ->
      x = world.createEntity "266921d3-5466-4d67-aa14-a5bfdc5515f3"
      x.should.have.property "uuid"
      x.uuid.should.equal "266921d3-5466-4d67-aa14-a5bfdc5515f3"

    it "should emit when a component is added", (done) ->
      count = 0
      world.on "component-added", (component, entity) ->
        count++
        done() if count is 3
      world.size().should.equal 0
      entity = world.createEntity()
      world.addComponent entity, "name",
        name: "Bob"
      world.addComponent entity, "position",
        x: 5
        y: 10
      world.addComponent entity, "notes"
      world.size().should.equal 1

    it "should emit when a component is removed", (done) ->
      world.on "component-removed", (component, entity) ->
        done() if entity?
      world.size().should.equal 0
      entity = world.createEntity()
      world.addComponent entity, "name",
        name: "Bob"
      world.addComponent entity, "position",
        x: 5
        y: 10
      world.addComponent entity, "notes"
      world.size().should.equal 1
      world.removeComponent entity, "notes"

    it "should be able to find entities by components", ->
      world.size().should.equal 0

      player = world.createEntity()
      world.addComponent player, "name",
        name: "Bob"
      world.addComponent player, "position",
        x: 255
        y: 174
      world.addComponent player, "velocity",
        x: 0
        y: -1
      world.addComponent player, "health",
        hp: 22
      world.addComponent player, "armor",
        ac: 15
        dr: 2

      arrow = world.createEntity()
      world.addComponent arrow, "position",
        x: 200
        y: 173
      world.addComponent arrow, "velocity",
        x: 55
        y: 0
      world.addComponent arrow, "damage",
        hp: 5

      powerup = world.createEntity()
      world.addComponent powerup, "name",
        name: "Health Potion"
      world.addComponent powerup, "position",
        x: 123
        y: 73
      world.addComponent powerup, "damage",
        hp: -20

      world.size().should.equal 3

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal player
      movers[1].should.equal arrow

      movers2 = world.find ["velocity", "position"]
      movers2.length.should.equal 2
      movers2[0].should.equal player
      movers2[1].should.equal arrow

      named = world.find "name"
      named.length.should.equal 2
      named[0].should.equal player
      named[1].should.equal powerup

      damagePlace = world.find ["position", "damage"]
      damagePlace.length.should.equal 2
      damagePlace[0].should.equal arrow
      damagePlace[1].should.equal powerup

    it "should find entities after component mutation", ->
      world.size().should.equal 0

      player = world.createEntity()
      world.addComponent player, "name",
        name: "Bob"
      world.addComponent player, "position",
        x: 255
        y: 174
      world.addComponent player, "velocity",
        x: 0
        y: -1
      world.addComponent player, "health",
        hp: 22
      world.addComponent player, "armor",
        ac: 15
        dr: 2

      arrow = world.createEntity()
      world.addComponent arrow, "position",
        x: 200
        y: 173
      world.addComponent arrow, "velocity",
        x: 55
        y: 0
      world.addComponent arrow, "damage",
        hp: 5

      powerup = world.createEntity()
      world.addComponent powerup, "name",
        name: "Health Potion"
      world.addComponent powerup, "position",
        x: 123
        y: 73
      world.addComponent powerup, "damage",
        hp: -20

      world.size().should.equal 3

      healthMods = world.find "damage"
      healthMods.length.should.equal 2
      healthMods[0].should.equal arrow
      healthMods[1].should.equal powerup

      armored = world.find "armor"
      armored.length.should.equal 1
      armored[0].should.equal player

      world.removeComponent player, "armor"

      world.size().should.equal 3

      armored = world.find "armor"
      armored.length.should.equal 0

      world.addComponent player, "armor",
        ac: 25
        dr: 5

      armored = world.find "armor"
      armored.length.should.equal 1
      armored[0].should.equal player

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal player
      movers[1].should.equal arrow

      world.removeComponent player, "armor"

      armored = world.find "armor"
      armored.length.should.equal 0

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal player
      movers[1].should.equal arrow

      world.addComponent player, "armor",
        ac: 35
        dr: 10

      armored = world.find "armor"
      armored.length.should.equal 1
      armored[0].should.equal player

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal player
      movers[1].should.equal arrow

      world.removeComponent player, "velocity"

      armored = world.find "armor"
      armored.length.should.equal 1
      armored[0].should.equal player

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 1
      movers[0].should.equal arrow

      world.addComponent player, "velocity",
        x: 0
        y: 1

      armored = world.find "armor"
      armored.length.should.equal 1
      armored[0].should.equal player

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal arrow
      movers[1].should.equal player

      flag = world.createEntity()
      world.size().should.equal 4

      world.addComponent flag, "position",
        x: 25
        y: 25

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal arrow
      movers[1].should.equal player

    it "should not find entities after entity removal", ->
      world.size().should.equal 0

      player = world.createEntity()
      world.addComponent player, "name",
        name: "Bob"
      world.addComponent player, "position",
        x: 255
        y: 174
      world.addComponent player, "velocity",
        x: 0
        y: -1
      world.addComponent player, "health",
        hp: 22
      world.addComponent player, "armor",
        ac: 15
        dr: 2

      arrow = world.createEntity()
      world.addComponent arrow, "position",
        x: 200
        y: 173
      world.addComponent arrow, "velocity",
        x: 55
        y: 0
      world.addComponent arrow, "damage",
        hp: 5

      powerup = world.createEntity()
      world.addComponent powerup, "name",
        name: "Health Potion"
      world.addComponent powerup, "position",
        x: 123
        y: 73
      world.addComponent powerup, "damage",
        hp: -20

      world.size().should.equal 3

      healthMods = world.find "damage"
      healthMods.length.should.equal 2
      healthMods[0].should.equal arrow
      healthMods[1].should.equal powerup

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 2
      movers[0].should.equal player
      movers[1].should.equal arrow

      world.removeEntity arrow

      movers = world.find ["position", "velocity"]
      movers.length.should.equal 1
      movers[0].should.equal player

      world.removeEntity arrow

    it "should find all entities", ->
      world.size().should.equal 0

      player = world.createEntity()
      world.addComponent player, "name",
        name: "Bob"
      world.addComponent player, "position",
        x: 255
        y: 174
      world.addComponent player, "velocity",
        x: 0
        y: -1
      world.addComponent player, "health",
        hp: 22
      world.addComponent player, "armor",
        ac: 15
        dr: 2

      arrow = world.createEntity()
      world.addComponent arrow, "position",
        x: 200
        y: 173
      world.addComponent arrow, "velocity",
        x: 55
        y: 0
      world.addComponent arrow, "damage",
        hp: 5

      powerup = world.createEntity()
      world.addComponent powerup, "name",
        name: "Health Potion"
      world.addComponent powerup, "position",
        x: 123
        y: 73
      world.addComponent powerup, "damage",
        hp: -20

      world.size().should.equal 3

      everything = world.findAll()
      everything.length.should.equal 3
      everything[0].should.equal player
      everything[1].should.equal arrow
      everything[2].should.equal powerup

      world.removeEntity player

      everything = world.findAll()
      everything.length.should.equal 2
      everything[0].should.equal powerup
      everything[1].should.equal arrow

    it "should remove entities sequentially", ->
      world.size().should.equal 0

      player = world.createEntity()
      world.addComponent player, "name",
        name: "Bob"
      world.addComponent player, "position",
        x: 255
        y: 174
      world.addComponent player, "velocity",
        x: 0
        y: -1
      world.addComponent player, "health",
        hp: 22
      world.addComponent player, "armor",
        ac: 15
        dr: 2

      arrow = world.createEntity()
      world.addComponent arrow, "position",
        x: 200
        y: 173
      world.addComponent arrow, "velocity",
        x: 55
        y: 0
      world.addComponent arrow, "damage",
        hp: 5

      powerup = world.createEntity()
      world.addComponent powerup, "name",
        name: "Health Potion"
      world.addComponent powerup, "position",
        x: 123
        y: 73
      world.addComponent powerup, "damage",
        hp: -20

      world.size().should.equal 3

      everything = world.findAll()
      everything.length.should.equal 3
      everything[0].should.equal player
      everything[1].should.equal arrow
      everything[2].should.equal powerup

      world.removeEntity player

      everything = world.findAll()
      everything.length.should.equal 2
      everything[0].should.equal powerup
      everything[1].should.equal arrow

      world.removeEntity powerup

      everything = world.findAll()
      everything.length.should.equal 1
      everything[0].should.equal arrow

#----------------------------------------------------------------------
# end of ecsTest.coffee
