class Dog

  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).collect {|row|
      self.new(id: row[0], name: row[1], breed:row[2])
    }.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).collect {|row|
      self.new(id: row[0], name: row[1], breed: row[2])
    }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    already_exists = DB[:conn].execute(sql, name, breed).collect {|row|
      self.new(id: row[0], name: row[1], breed: row[2])
    }.first
    if already_exists == nil
      self.create(name: name, breed: breed)
    else
      already_exists
    end
  end


end
