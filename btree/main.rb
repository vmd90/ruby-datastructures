#!/usr/bin/env ruby
=begin
--------------------------------------------------------------------------
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
require "./BTree"
#----------------------------------------------------------
# main entry point function
#----------------------------------------------------------
def main
  # lendo do teclado grau da arvore
  print "Grau da arvore (maior que 1): "
  n = gets.chomp.to_i
  print "Path do arquivo de dados: "
  dataFile = gets.chomp

  print "Comandos:\n\tBUSCA(arg)\n\tINSERE(arg)\n"
  begin
    btree = BTree.new(n)
    btree.buildFromFile(dataFile)
    
    loop {
      puts "passou"
      cmd = gets.chomp
      if cmd == "FIM"  # Termina o programa
        break
      end
      
      cmd = cmd.split(/[()]/)
      case cmd[0]
      when "BUSCA"
        if cmd.size <= 1
          puts "Argumento faltando: nome"
          next
        end
        print("-------------------------------\nNos percorridos:\n");
        retval, rrn = btree.search(cmd[1])
        if retval == NOT_FOUND
          puts "\nRegistro nao encontrado"
          next
        end
        print("\n");
        btree.printDataInfo(rrn);
        print("\n-------------------------------\n");
      when "INSERE"
        if cmd.size <= 1
          puts "\nRegistro para insercao faltando"
          next
        end
        name = cmd[4, cmd[1].size]
        btree.dataFile.seek(0, IO::SEEK_END)
        rrn = btree.dataFile.tell() / 56
        retval = btree.insert(name, rrn)
        if retval == KEY_ALREADY_ADDED
          puts "\nRegistro ja foi inserido"
          next
        end
        # write into file
        btree.dataFile.seek(0, IO::SEEK_END)
        btree.dataFile << cmd[1].to_s
        btree.dataFile.seek(0, IO::SEEK_SET)
        puts "\nRegistro inserido"
      else
        puts "Comando desconhecido"
      end
    }
  rescue => err
    puts("Erro: #{err}")
  end
end
main
