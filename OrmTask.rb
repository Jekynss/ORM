require 'pg'

class ApplicationRecord
   protected
   @bd

   public
   def initialize ()
    @bd=PG::Connection.open(dbname:'test')
    @table_name='public."'+self.class.name+'"'
    #make_good_strings
    #@bd.exec('CREATE TABLE public."Test1"(id SERIAL PRIMARY KEY ,Name text, Surname text,Age int);')
   end

   def  read_all
       rows=@bd.exec('SELECT * from '+@table_name+' order by id asc')
     rows.each{|row| puts row}
     puts "-----------"
   end

   def create()
    if @id.nil?
     make_good_strings
     @res=@bd.exec('INSERT INTO '+@table_name+" (#{@keys})"+"VALUES (#{@values}) RETURNING id;")
     @id = @res.first['id']
    else
    puts "Запись уже создана"
    end
   end
   def read()
    unless @id.nil?
        rows=@bd.exec('SELECT * from '+@table_name+" where id=#{@id} order by id asc")
     rows.each{|row| puts row}
     puts "-----------"

    else
      puts "Запись еще не создана"
    end
   end
   def update()
    make_good_strings
    unless @id.nil?
        @bd.exec('update '+@table_name+' set'+ "#{@update_str} where id="+@id)
    else
    puts "Запись еще не создана"
    end 
   end
   def delete()
       @bd.exec('delete from '+@table_name+"where id="+@id.to_s)
     @id=nil
   end

   def make_good_strings
    @values=""
    @keys=""
    @update_str=""


    @params.values.each do |elem| 
      if elem.is_a?String
        @values+="\'#{elem}\',"
      else
        @values+=elem.to_s+","
      end
    end
    @params.keys.each{|elem| @keys+=elem.to_s+","}
    @keys[@keys.length-1]=""
    @values[@values.length-1]=""

    @params.keys.each{|elem| @update_str+=" #{elem}=#{@values.split(',')[@params.keys.index elem]}, "}
    @update_str[@update_str.length-2]=""
   end
end


class Test1<ApplicationRecord
  attr_reader :id
  attr_accessor :name,:surname,:age
  def initialize(params)
    @params=params
    super()
  end
  def name=(value)
    @name=value
    @params[:name]=@name
  end
  def surname=(value)
    @surname=value
    @params[:surname]=@surname
  end
  def age=(value)
    @age=value
    @params[:age]=@age
  end
end

class Test2<ApplicationRecord
end

#model1=ApplicationRecord.new;
t1=Test1.new(name:"JustName",surname:"Null",age:40)
t1.name="Text"
t1.create
t1.read
t1.name="Test"
t1.age=100
t1.update()
t1.read
#t1.delete
#t1.read_all

