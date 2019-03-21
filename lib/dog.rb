class Dog

  attr_reader :breed
  attr_accessor :name, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    if !id.nil?
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed) VALUES
        (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.create(dogject)
    Dog.new(dogject).save
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by_id(target_id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL

    self.parse_query_first_result(DB[:conn].execute(sql, target_id))
  end

  def self.find_or_create_by(name:, breed:)
    dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if dogs.empty?
      self.create({name: name, breed: breed})
    else
      self.new_from_db(dogs[0])
    end
  end

  def self.find_by_name(target_name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL

    self.parse_query_first_result(DB[:conn].execute(sql, target_name))
  end

  def self.parse_query_first_result(query_results)
    query_results.map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

end
