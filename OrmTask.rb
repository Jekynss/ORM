require 'pg'

$BD = PG::Connection.open(dbname: 'test')

class ApplicationRecord

  def initialize
    @table_name = "public.\"#{self.class.name}s\""
  end

  def create
    if @id.nil?
      make_good_strings
      @res = $BD.exec("INSERT INTO #{@table_name} (#{@keys}) VALUES (#{@values}) RETURNING id;")
      @id = @res.first['id']
    else
      puts "Запись уже существует"
    end
  end

  def read
    unless @id.nil?
      rows = $BD.exec("SELECT * from #{@table_name} where id = #{@id} order by id asc")
      rows.each{ |row| puts row }
      puts "-----------"
    else
      puts "Запись еще не существует"
    end
  end

  def update
    make_good_strings
    unless @id.nil?
      $BD.exec("update #{@table_name} set #{@update_str} where id = #{@id}")
    else
      puts "Запись еще не существует"
    end 
  end

  def delete
    unless @id.nil?
      $BD.exec("delete from #{@table_name} where id = #{@id.to_s}")
      @id = nil
    else
      puts "запись не существует"
    end
  end

  def make_good_strings(params = @params)
    @values = ""
    @keys = ""
    @update_str = ""


    params.values.each do |elem| 
      if elem.is_a?String
        @values+= "\'#{elem}\',"
      else
        @values+= "#{elem},"
      end
    end
    params.keys.each{|elem| @keys+= "#{elem},"}
    @keys[@keys.length-1] = ""
    @values[@values.length-1] = ""
    params.keys.each{|elem| @update_str+= " #{elem} = #{@values.split(',')[params.keys.index elem]}, "}
    @update_str[@update_str.length-2] = ""
  end

end


class Book<ApplicationRecord
  attr_reader :id
  attr_accessor :name,:surname,:age

  def initialize(params)
    @params = params
    @name = params[:name]
    @surname = params[:surname]
    @age = params[:age]
    @id = params.values[3]
    super()
  end

  def name=(value)
    @name = value
    @params[:name] = @name
  end

  def surname=(value)
    @surname = value
    @params[:surname] = @surname
  end

  def age=(value)
    @age = value
    @params[:age] = @age
  end

  def self.read_all
    rows = $BD.exec('SELECT * from public."Books" order by id asc')
    rows.each{|row| puts row}
    puts "-----------"
  end

  def self.find_by(param)
     res = $BD.exec("SELECT * from public.\"Books\" where #{param.keys[0]} = '#{param.values[0]}' order by id asc")
     retObj = Book.new(res[0].keys[1].to_sym => res[0].values[1].to_s,res[0].keys[2].to_sym => res[0].values[2].to_s,res[0].keys[3].to_sym => res[0].values[3].to_s,res[0].keys[0].to_sym => res[0].values[0].to_s)
  end

end

class User<ApplicationRecord
  attr_reader :id
  attr_accessor :name,:age
  
  def initialize(params)
    @params = params
    super()
  end

  def name=(value)
    @name = value
    @params[:name] = @name
  end

  def age=(value)
    @age = value
    @params[:age] = @age
  end

  def self.read_all
     rows = $BD.exec('SELECT * from public."Users" order by id asc')
     rows.each{|row| puts row}
     puts "-----------"
  end

end

t1 = Book.new(name:"JustName",surname:"Null",age:40)
t1.name = "Tett"
t1.create
t1.read
Book.read_all

