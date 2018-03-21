# ecs.coffee
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
EventEmitter = require "events"
uuid = require "uuid/v4"

class Index
  constructor: (properties, world) ->
    # get everything set up for indexing
    @concerns = properties
    @entities = []
    @uuidIndexMap = {}
    world.on "component-added", @updateComponentAdded
    world.on "component-removed", @updateComponentRemoved
    world.on "entity-removed", @updateEntityRemoved
    # if this is the master index, stop here
    return if not world.index?
    # otherwise check each entity that already exists
    for entity in world.index.entities
      # if the entity has everything we require
      checkMe = _.intersection @concerns, _.keys(entity)
      if checkMe.length is @concerns.length
        # add it to this index
        @uuidIndexMap[entity.uuid] = @entities.length
        @entities.push entity

  updateEntityRemoved: (entity) =>
    # if don't have it, we're done
    return if not @uuidIndexMap[entity.uuid]?
    # bye, bye cruel entity
    index = @uuidIndexMap[entity.uuid]
    lastIndex = @entities.length-1
    lastEntity = @entities[lastIndex]
    @entities[index] = lastEntity
    @uuidIndexMap[lastEntity.uuid] = index
    @entities.pop()
    delete @uuidIndexMap[entity.uuid]

  updateComponentAdded: (entity, component) =>
    # if we've already got it, we're done
    return if @uuidIndexMap[entity.uuid]?
    # if we don't care about that component, we're done
    return if not (component in @concerns)
    # if the entity doesn't have everything we require, we're done
    for comp in @concerns
      return if not entity[comp]?
    # looks like we've got a winner
    @uuidIndexMap[entity.uuid] = @entities.length
    @entities.push entity

  updateComponentRemoved: (entity, component) =>
    # if don't have it, we're done
    return if not @uuidIndexMap[entity.uuid]?
    # if we don't care about that component, we're done
    return if not (component in @concerns)
    # we have it and we care about the removed component
    index = @uuidIndexMap[entity.uuid]
    lastIndex = @entities.length-1
    lastEntity = @entities[lastIndex]
    @entities[index] = lastEntity
    @uuidIndexMap[lastEntity.uuid] = index
    @entities.pop()
    delete @uuidIndexMap[entity.uuid]

class exports.World extends EventEmitter
  constructor: ->
    super()
    @index = new Index ["uuid"], this
    @indexes = {}

  addComponent: (entity, component, data) ->
    cleanData = data || {}
    entity[component] = cleanData
    @emit "component-added", entity, component
    return entity

  createEntity: (id) ->
    id ?= uuid()
    entity =
      uuid: id
    @emit "entity-created", entity
    @emit "component-added", entity, "uuid"
    return entity

  find: (components) ->
    concerns = _.flatten [components]
    concerns = concerns.sort()
    concerns = _.uniq concerns, true
    indexName = concerns.join ":"
    if not @indexes[indexName]?
      @indexes[indexName] = new Index concerns, this
    return @indexes[indexName].entities.slice 0

  findAll: ->
    return @index.entities.slice 0

  findById: (id) ->
    return @index.entities[@index.uuidIndexMap[id]]

  remove: ->
    while @index.entities.length > 0
      @removeEntity _.last @index.entities
    return this

  removeComponent: (entity, component) ->
    @emit "component-removed", entity, component
    delete entity[component]
    return entity

  removeEntity: (entity) ->
    @emit "entity-removed", entity
    @removeComponent entity, "uuid"
    return this

  size: ->
    return @index.entities.length

#----------------------------------------------------------------------
# end of ecs.coffee
