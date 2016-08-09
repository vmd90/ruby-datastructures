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
require 'matrix'

class Vertex
  attr_accessor :value, :next
  def initialize(value)
    @value = value
    @next = nil
  end
end
# Matrix class, modification of the original Matrix class
# This one allows to set single element
class Matrix
  def []=(row, column, value)
    @rows[row][column] = value
  end
end

# Abstract class Graph (is empty)
class Graph
  def empty?
  end
  def addEdge(v1, v2)
  end
  def edge?(v1, v2)
  end
end

# Graph implementation with adjacency list
# Use: g = LGraph.new(['Node1','Node2','Node3'])
class LGraph < Graph
  attr_reader :list
  
  # Initialize with array of names for each graph node
  # @param name_vertices Array of names
  def initialize(name_vertices)
    @list = Array.new(name_vertices.size)
    i = 0
    while i < name_vertices.size
      @list[i] = LinkedList.new(Vertex.new(name_vertices[i]))
      i += 1
    end
  end

  def empty?
    @list.empty?
  end

  def addEdge(value1, value2)
    if !edge?(value1, value2)
      i = 0
      @list.each { |v1|
        if value1 == v1.first.value
          break
        end
        i += 1
      }
      @list[i].push(value2)
    end
  end

  def edge?(value1, value2)
    if !empty?
      vertex1 = nil
      @list.each { |v1|
        if value1 == v1.first.value
          vertex1 = v1
        end
      }
      if vertex1 == nil
        return false
      end
      # searching in the list
      n = vertex1.first.next
      while n != nil
        if n.value == value2
          return true
        end
        n = n.next
      end
    end
    return false # no edge found
  end
  
  def to_s
    for i in @list
      print "#{i.first.value} => "
      n = i.first.next
      while n != nil
        print "#{n.value}, "
        n = n.next
      end
      print "\n"
    end
  end
end

# Graph implementation with adjacency matrix
class MGraph < Graph
  def initialize(num_vertices=0)
    @matrix = (num_vertices == 0) ? nil : Matrix.zero(num_vertices)
  end

  def empty?
    @matrix == nil
  end

  def addEdge(v1, v2)
    @matrix[v1,v2] = 1
  end

  def edge?(v1, v2)
    @matrix[v1,v2] == 1
  end
  
  def to_s
    puts @matrix
  end
end

class LinkedList
  attr_reader :first
  def initialize(obj=nil)
    @first = obj
  end

  def empty?
    @first == nil
  end

  def push(value)
    if empty?
      @first = Vertex.new(value) # first node in list
      return
    end
    n = @first
    until n.next == nil
      n = n.next
    end
    # push new vertex
    n.next = Vertex.new(value)
  end

  def to_s
    n = @first
    while n != nil
      puts "#{n.value}"
      n = n.next
    end
  end
end
