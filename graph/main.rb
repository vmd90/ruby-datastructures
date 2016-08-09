#!/usr/bin/env ruby
=begin
--------------------------------------------------------------------------
 Graph implementation using Ruby     

  Copyright 2015, Victor Municelli Dario

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--------------------------------------------------------------------------
=end

require "./Graph"

g = MGraph.new(5)
g.addEdge(2, 3)
g.addEdge(2, 4)
g.addEdge(2, 2)
g.addEdge(1, 1)
g.addEdge(1, 3)
g.addEdge(4, 3)
g.addEdge(3,3)
g.to_s()
puts g.edge?(1,4)

g = LGraph.new(["Red", "Yellow", "Green", "Blue"])
g.addEdge("Yellow", "Green")
g.addEdge("Blue", "Green")
g.to_s
puts g.edge?("Blue", "Green")

