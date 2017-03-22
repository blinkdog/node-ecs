# helloTest.coffee
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

mut = require "../lib/hello"

describe "hello", ->
  it "should obey the laws of logic", ->
    true.should.equal true

  it "should have a message", ->
    mut.message.should.be.ok()
    mut.message.should.equal "Hello, world!"

#----------------------------------------------------------------------
# end of helloTest.coffee
