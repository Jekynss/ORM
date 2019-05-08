require 'pg'

class Model
   @bd
   def initialize ()
     @bd=PG::Connection.open(dbname:'test')
     #@bd.exec(‘CREATE TABLE public.“Test1”(id SERIAL PRIMARY KEY ,Name text, Surname text,Age int);’)
   end

   def read()
     rows=@bd.exec('SELECT * from public."Test1" order by id asc')
     rows.each{|row| puts row}
   end
   def create
     @bd.exec('INSERT INTO public."Test1"(Name, surname, age)'+"VALUES ('Nam3','Sur3', 21);")
   end
   def update
     @bd.exec('update public."Test1"'+ "set name='name23' where id=8")
     puts "-----------"
   end
   def delete
     @bd.exec('delete from public."Test1"'+ "where id=10")
   end
end
class Table1<Model

 def read(*arg)
   @bd.exec("select*from")
 end

end

model1=Model.new;
#model1.create
model1.read
model1.update
model1.read