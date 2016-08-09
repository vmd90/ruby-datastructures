=begin
--------------------------------------------------------------------------
 BTree implementation using Ruby     

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
# constantes
INVALID = -1
ERROR = -2
FOUND = 1
NOT_FOUND = 2
PROMOTION = 3
NO_PROMOTION = 4
KEY_ALREADY_ADDED = 5

# Representa um registro na arvore B
class Record
  attr_accessor :name, :RRN
  
  @@size = 56

  def initialize(_name="", rrn=INVALID)
    @name = _name
    @RRN = rrn
  end

  def Record.getSize
    @@size
  end
  def Record.setSize(size)
    @@size = size
  end
end

# Representa um node da arvore B
class Page
  attr_accessor :keys, :children, :keyCount

  def initialize(n)
    @keyCount = 0  # numero de chaves usadas neste node
    @keys = Array.new(n-1, nil) # array de N-1 chaves (Record)
    @children = Array.new(n, nil) # array de N filhos (Page)
  end

  # encontra o lugar onde a chave deve ser inserida
  def findPosition(keyName)
    i = 0
    j = @keyCount - 1
    while i <= j
      mid = ((i+j)/2).to_i
      if strcmp(@keys[mid].name, keyName) > 0
        j = mid - 1
      else
        i = mid + 1
      end
    end
    return i
  end

  # insere o registro na posicao certa da pagina atual
  def insert(record, rchild)
    pos = findPosition(record.name)
    i = @keyCount
    while i > pos and strcmp(record.name, @keys[i-1].name) < 0
      @keys[i] = @keys[i-1]
      @children[i+1] = @children[i]
      i -= 1
    end
    @keys[pos] = record
    @children[pos+1] = rchild
    @keyCount += 1
  end

  # faz o split da pagina atual e retorna o registro promovido e nova pagina
  def split(n, iRecord, iChild) #, promoRecord, promoRChild)
    midkey = ((n/2)+1).to_i  # chave do meio para pagina temporaria
    temp = Page.new(n+1)  # pagina temporaria extendida
    temp.keyCount = @keyCount
    keyPos = 0
    while keyPos < @keyCount
      temp.keys[keyPos] = @keys[keyPos]
      temp.children[keyPos] = @children[keyPos]
      temp.children[keyPos+1] = @children[keyPos+1]
      keyPos += 1
    end
    # inserindo nova chave na pagina temp
    temp.insert(iRecord, iChild)
    promoRecord = temp.keys[midkey-1]  # chave promovida
    # criando nova page
    newPage = Page.new(n)
    #promoRChild = newPage
    for i in 0..(n-2)
      @keys[i] = nil
      @children[i] = @children[i+1] = nil
    end
    @keyCount = 0
    # copiando chaves para curPage
    for i in 0..(midkey-2) 
      @keys[i] = temp.keys[i]
      @children[i] = temp.children[i]
      @children[i+1] = temp.children[i+1]
      @keyCount += 1
    end
    # copiando chaves para newPage
    i = midkey
    j = 0
    while i < n and j < (n-1) 
      newPage.keys[i] = temp.keys[i]
      newPage.children[i] = temp.children[i]
      newPage.children[i+1] = temp.children[i+1]
      newPage.keyCount += 1
      i += 1
      j += 1
    end
    return promoRecord, newPage
  end
end

# Representa a arvore B
class BTree
  attr_accessor :root, :N, :dataFile
  
  def initialize(n, fileName=nil)
    @root = nil     # raiz da arvore
    @N = 0          # numero de filhos (grau da arvore)
    @dataFile = nil # nome do arquivo de dados
    # arvore nao pode ter grau menor que 2
    if n < 2
      raise "Arvore nao pode ter grau menor que 2"
    end
    @N = n
    if fileName != nil
      @dataFile = File.new(fileName, "r+")
    end
  end

  # monta a arvore B a partir de um arquivo
  def buildFromFile(fileName=nil)
    # verificar se arquivo ja foi aberto
    if fileName != nil
      @dataFile = File.new(fileName, "r+")
    end

    rrn = 0
    begin
      r = Record.new
      # Ler arquivo, cada linha
      @dataFile.each_line(Record.getSize) { |line| 
        name = line.slice(4, 29).gsub(/[#]/, "")
        self.insert(name, rrn)
        rrn += 1
      }
    rescue  => err
      raise err
    end
  end
  
  # retorna se achou ou nao e o RRN
  def search(key)
    return searchPage(@root, key)
  end
  
  def searchPage(curPage, key)
    foundRRN = INVALID
    if curPage == nil
      foundRRN = INVALID
      return NOT_FOUND, foundRRN # impossivel encontrar chave
    end
    print("\n")
    pos = 0
    # busca pela chave
    for k in curPage.keys
      if k != nil  # verifica se existe
        print("#{k.name}")
        if strcmp(k.name, key) >= 0
          break
        end
      end
      print(", ")
      pos += 1
    end
    
    if curPage.keys[pos] != nil
      if key == curPage.keys[pos].name
        foundRRN = curPage.keys[pos].RRN
        return FOUND, foundRRN  # chave encontrada
      end
    end
    return self.searchPage(curPage.children[pos], key)
  end
  
  def insert(key, rrn)
    record = Record.new(key, rrn)
    
    retval, promoRecord, promoRChild = insertKey(@root, record) #, promoRecord, promoRChild)
    if retval == PROMOTION  # criando uma nova raiz
      newRoot = Page.new(@N)
      pos = newRoot.keyCount
      newRoot.keyCount += 1
      newRoot.keys[pos] = promoRecord
      newRoot.children[pos] = @root
      newRoot.children[pos+1] = promoRChild
      @root = newRoot
    end
    return retval
  end
  
  # insere novo registro na pagina e retorna o registro e a pagina promovida
  def insertKey(curPage, record) #, promoRecord, promoRChild)
    pos = 0
    nkeys = @N - 1  # numero de chaves
    newPage = nil  # pagina resultante do particionamento
    pbRecord = nil
    pbChild = nil

    if curPage == nil
      return PROMOTION, record, nil
    else
      while pos < nkeys
        if curPage.keys[pos] != nil
          if strcmp(curPage.keys[pos].name, record.name) >= 0
            break
          end
        else
          break
        end
        pos += 1
      end
    end
    # verifica se chave foi inserida
    if pos < nkeys
      if curPage.keys[pos] != nil
        if record.name == curPage.keys[pos].name
          return KEY_ALREADY_ADDED, nil, nil
        end
      end
    end

    retval, pbRecord, pbChild = self.insertKey(curPage.children[pos], record) #, pbRecord, pbChild)
    if retval == NO_PROMOTION or retval == ERROR or retval == KEY_ALREADY_ADDED
      return retval, nil, nil
    elsif curPage.keyCount < nkeys  # verifica se tem espaco na pagina atual
      curPage.insert(pbRecord, pbChild)
      return NO_PROMOTION, nil, nil
    else
      promoRecord, newPage = curPage.split(@N, pbRecord, pbChild) #, promoRecord, promoRChild)
      return PROMOTION, promoRecord, newPage
    end
  end
  
  def printDataInfo(rrn)
    @dataFile.seek(Record.getSize * rrn, IO::SEEK_SET)
    # lendo o registro
    reg = @dataFile.read(Record.getSize)
    id = reg[0,4]
    arr = []
    reg[4, reg.size].split("#").each { |word|
      arr.push(word) unless word == ""
    }
    puts "\nDados do piloto:"
    puts "ID = #{id}"
    puts "Nome = #{arr[0]}"
    puts "Pais = #{arr[1]}"
    puts "Titulos = #{arr[2]}"
    puts "Corridas = #{arr[3]}"
    puts "Poles = #{arr[4]}"
    puts "Vitorias = #{arr[5]}"
    @dataFile.rewind()
  end
end

# implementacao do metodo strcmp de C
# se s1 < s2, retorna negativo
# se = , retorna 0
# se > , retorna positivo
def strcmp(s1, s2)
  if s1 == nil and s2 == nil
    return 0
  elsif s1 == nil and s2 != nil
    return -1
  elsif s1 != nil and s2 == nil
    return 1
  end
  len1 = s1.length
  len2 = s2.length
  if len1 == 0 and len2 == 0
    return 0
  elsif len1 == 0 and len2 != 0
    return -1
  elsif len1 != 0 and len2 == 0
    return 1
  else
    size = len1
    if len1 > len2
      size = len2
    end
    for i in 0..(size-1)
      if s1[i] != s2[i]
        return s1[i].ord - s2[i].ord
      end
    end
    if len1 == len2
      return 0 # sao iguais
    elsif len1 > len2
      return 1
    else
      return -1
    end
  end
end
