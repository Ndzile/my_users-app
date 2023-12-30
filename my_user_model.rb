require 'sqlite3'

class User
  attr_accessor :id, :firstname, :lastname, :age, :email, :password

  def initialize (id = 0, firstname, lastname, age, email, password)
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @email = email
    @password = password
  end

  # Create a connection to the database and create the "users" table if it does not exist
  def self.connectDb()
    begin
      @db = SQLite3::Database.open 'db.sql'
      @db = SQLite3::Database.new 'db.sql' if !@db
      @db.results_as_hash = true
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY,
          firstname STRING,
          lastname STRING,
          age INTEGER,
          email STRING,
          password STRING
        );
      SQL
      return @db
    rescue SQLite3::Exception => e
      puts "Error occurred: #{e}"
    end
  end

  # Insert a new user record into the database and return a User object with the ID
  def self.create(user_info)
    @db = self.connectDb
    @db.execute "INSERT INTO users(firstname, lastname, age, email, password) VALUES (?, ?, ?, ?, ?)", user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:email], user_info[:password]
    user = User.new(user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:email], '' )
    user.id = @db.last_insert_row_id
    @db.close
    return user
  end

  # Retrieve all user records from the database and return an array of User objects
  def self.all()
    @db = self.connectDb()
    user = @db.execute "SELECT * FROM users"
    @db.close
    return user
  end

  # Retrieve a user record from the database by ID and return a User object without the password
  def self.find(user_id)
    @db = self.connectDb
    user = @db.execute "SELECT * FROM users WHERE id = ?", user_id
    user_info = User.new(user[0]["firstname"], user[0]["lastname"], user[0]["age"], user[0]["email"], user[0]["password"])
    @db.close
    return user_info
end

  # Update a user record in the database by ID and attribute
  def self.update(user_id, attribute, value)
    @db = self.connectDb
    @db.execute "UPDATE users SET #{attribute} = ? WHERE id = ? ", value, user_id
    user = @db.execute "SELECT * FROM users where id = ? ", user_id
    @db.close
    return user
  end

  # Authenticate a user by email and password and return a User object without the password
  def self.authenticate(password, email)
    @db = self.connectDb
    user = @db.execute "SELECT * FROM users WHERE  password = ? AND  email= ?", password , email
    @db.close
    return user
  end

  # Delete a user record from the database by ID
  def self.destroy(user_id)
    @db = self.connectDb()
    @db.execute "DELETE FROM users WHERE id = ?", user_id
    @db.close
    return true
  end
 end
 