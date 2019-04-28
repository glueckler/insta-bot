class Database
  require 'pg'
  require 'date'

  ACT_LIKE = 'like'.freeze
  MAX_DAILY_LIKES = 380
  UNIX_MONTH = 2629743
  UNIX_DAY = 86400

  attr_reader :daily_likes_ish
  
  def self.exec(statement)
    conn = PG.connect :dbname => 'insta_bot', :user => 'dbean'
    conn.exec statement
  end
  
  def initialize
    @conn = PG.connect :dbname => 'insta_bot', :user => 'dbean'
    exceeding_max_actions # just to update the daily likes
  end

  def add_user(username)
    return unless username.string?
    begin
      log_exec "INSERT INTO users (username) VALUES ('#{username}')"
    rescue StandardError => what
      if what.exception.class == PG::UniqueViolation
        puts "user #{username} already found.."
      elsif what.exception.class PG::StringDataRightTruncation
        puts "this is longer than 30 -> #{username}"
      else
        raise what
      end
    end
  end

  def add_action(type:, username:)
    ts = DateTime.now.strftime('%s')
    log_exec "INSERT INTO actions
    (type, time, username)
    VALUES
    ('#{type}',#{ts},'#{username}')"
  end

  def mark_user_private(username)
    puts "marking #{username} as private"
    log_exec "UPDATE users
    SET private = true
    WHERE
    username = '#{username}'"
  end

  def mark_user_invalid(username)
    puts "marking #{username} as invalid"
    log_exec "UPDATE users
    SET invalid = true
    WHERE
    username = '#{username}'"
  end

  def random_user
    username = log_exec "SELECT username AS username from users 
    WHERE invalid IS NOT true
    AND private IS NOT true
    ORDER BY random() limit 1"
    username[0]['username']
  end

  def recent_user_like_action?(username)
    recent = now - UNIX_MONTH
    result = log_exec "SELECT * FROM actions 
    WHERE username = '#{username}' 
    and time > #{recent}"
    # check it's empty
    !result.num_tuples.zero?
  end

  def exceeding_max_actions(type: ACT_LIKE, max: MAX_DAILY_LIKES) 
    day_ago = now - UNIX_DAY
    results = log_exec "SELECT * FROM actions
    WHERE time > #{day_ago} AND type = '#{type}'"
    @daily_likes_ish = results.num_tuples
    results.num_tuples > max
  end
  
  def init_database
    @conn.exec 'DROP TABLE IF EXISTS users'
    @conn.exec "CREATE TABLE users(
      id SERIAL PRIMARY KEY,
      username VARCHAR(30) NOT NULL UNIQUE,
      private BOOLEAN,
      invalid BOOLEAN
      )"
    @conn.exec "CREATE TABLE actions(
      id SERIAL PRIMARY KEY,
      type VARCHAR(30),
      username VARCHAR(30) REFERENCES users(username),
      time TIMESTAMP,
      psql_time timestamptz NOT NULL DEFAULT now()
      )"
  end

  def disconnect
    @conn.close if @conn
  end

  private

  def log_exec(query)
    unless Global::OPTS.quiet?
      puts 'PSQL -->'
      puts query
      puts '<--'
    end 
    @conn.exec query
  end

  def now
    DateTime.now.strftime('%s').to_i
  end

end

# Database.exec "ALTER TABLE actions 
# ADD COLUMN time INTEGER"

# Database.exec "ALTER TABLE actions
# ALTER COLUMN time INTEGER"

# Database.exec "ALTER TABLE actions
# DROP COLUMN user_id"

# puts Database.new.user "ashton.1012"


