require 'pg'

class Model
   protected
   @bd

   public

   def initialize (params)
    @bd=PG::Connection.open(dbname:'test')
    @params=params
    make_good_strings
     #@bd.exec(‘CREATE TABLE public.“Test1”(id SERIAL PRIMARY KEY ,Name text, Surname text,Age int);’)
   end

   def read_all
     rows=@bd.exec('SELECT * from public."'+self.class.name+'" order by id asc')
     rows.each{|row| puts row}
     puts "-----------"
   end

   def create()
    if @id.nil?
     @res=@bd.exec('INSERT INTO public."'+self.class.name+"\"(#{@keys})"+"VALUES (#{@values}) RETURNING id;")
     @id = @res.first['id']
    else
    puts "Запись уже существует"
    end
   end
   def read()
    unless @id.nil?
     rows=@bd.exec('SELECT * from public."'+self.class.name+"\" where id=#{@id} order by id asc")
     rows.each{|row| puts row}
     puts "-----------"

    else
      puts "запись не создана"
    end
   end
   def update(pk)
     @bd.exec('update public."'+self.class.name+'" set'+ "#{@update_str} where id="+pk.to_s)
   end
   def delete()
     @bd.exec('delete from public."Test1"'+ "where id="+@id.to_s)
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


class Test1<Model
  attr_reader :id
  attr_accessor :name,:surname,:age
  def initialize(params)
    @name=params[:name]
    @surname=params[:surname]
    @age=params[:age]
    super
  end
end

class Test2<Model
end

#model1=Model.new;
t1=Test1.new(name:"JustName",surname:"Null",age:40)
t1.create
t1.read
#t1.update(43)
t1.delete
t1.read_all

