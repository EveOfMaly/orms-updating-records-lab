require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize (id = nil, name, grade )
    @id = id 
    @name = name
    @grade = grade 
  end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        grade INTEGER
        )
        SQL
        DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save 
    #use the insert method to safe 
    #use the primary id of the table and associate w/ the id of the object. 

    if self.id 
      self.update 
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.grade)

        @id =  DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end 

  def self.create(name, grade)
    new_song = self.new(name, grade)
    new_song.save
  end

  def self.new_from_db(row)
    student_id = row[0]
    student_name = row[1]
    student_grade = row[2]
    new_student = Student.new(student_id, student_name, student_grade)
    new_student
  end


  def self.find_by_name(name)

    sql = <<-SQL
      SELECT * 
      FROM students
      where name = ?
      LIMIT 1
      SQL

      #iterate over each row and return array of song objects = one song object will be returned. 
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row) #new 
      end.first
  end

  def update
    
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end






end
