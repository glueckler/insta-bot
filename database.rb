class Database
  require 'pg'
  require 'date'

  ACT_LIKE = 'like'.freeze
  UNIX_MONTH = 2629743
  UNIX_DAY = 86400

  def self.conn
    PG.connect :dbname => 'insta_bot', :user => 'shiftbean'
  end

  def self.exec(statement)
    conn = Database.conn
    conn.exec statement
  end

  def self.init_database
    conn = Database.conn
    conn.exec 'DROP TABLE IF EXISTS actions'
    conn.exec 'DROP TABLE IF EXISTS users'
    conn.exec "CREATE TABLE users(
      id SERIAL PRIMARY KEY,
      username VARCHAR(30) NOT NULL UNIQUE,
      private BOOLEAN,
      invalid BOOLEAN,
      interaction_ts INTEGER,
      relevance INTEGER
    )"

    # this is more of an audits table
    # we'll query this table to see if we've gone over max daily actions
    conn.exec "CREATE TABLE actions(
      id SERIAL PRIMARY KEY,
      type VARCHAR(30),
      username VARCHAR(30) REFERENCES users(username),
      time INTEGER,
      psql_time timestamptz NOT NULL DEFAULT now()
    )"
  end

  #  #  #

  def add_user(username)
    begin
      log_exec "INSERT INTO users (username, interaction_ts, relevance) VALUES ('#{username}', 0, 0)"
    rescue StandardError => what
      if what.exception.class == PG::UniqueViolation
        puts "user #{username} already found.."
      elsif what.exception.class == PG::StringDataRightTruncation
        puts "this is longer than 30 -> #{username}"
      else
        raise what
      end
    end
  end

  def add_action(type: ACT_LIKE, username: nil)
    ts = DateTime.now.strftime('%s')
    log_exec "INSERT INTO actions
    (type, time, username)
    VALUES
    ('#{type}',#{ts},'#{username}')"
  end

  def add_user_interaction_ts(username:)
    ts = DateTime.now.strftime('%s')
    log_exec "UPDATE users
    SET interaction_ts = #{ts}
    WHERE
    username = '#{username}'"
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

  def set_user_relevance(username, relevance)
    log_exec "UPDATE users
    SET relevance = #{relevance.to_i}
    WHERE
    username = '#{username}'"
  end

  def random_user
    # recent will be either 1,2,3,4,5,6 months and therefore older users will be more likely to come up
    recent = now - (UNIX_MONTH * [1,2,3,4,5,6].sample)
    username = log_exec "SELECT username AS username from users
    WHERE invalid IS NOT true
    AND private IS NOT true
    AND interaction_ts < #{recent}
    ORDER BY relevance DESC, interaction_ts ASC limit 1"

    return :no_user if username.values.empty?
    return username[0]['username']
  end

  def random_user_with_zero_rel
    username = log_exec "SELECT username AS username from users
    WHERE relevance = 0
    AND private IS NOT true
    ORDER BY random() limit 1"

    return :no_user if username.values.empty?
    return username[0]['username']
  end

  def recent_user_like_action?(username)

    result = log_exec "SELECT * FROM actions
    WHERE username = '#{username}'
    and time > #{recent}"
    # check it's empty
    !result.num_tuples.zero?
  end

  def exceeding_max_actions(type: ACT_LIKE, max: 380, max_hourly: 100)
    day_ago = now - UNIX_DAY
    hour_ago = now - (UNIX_DAY / 24)

    # daily
    res = log_exec "SELECT * FROM actions
    WHERE time > #{day_ago} AND type = '#{type}'"
    results_daily = res.num_tuples
    exceeded_daily = results_daily > max
    # hourly
    res = log_exec "SELECT * FROM actions
    WHERE time > #{hour_ago} AND type = '#{type}'"
    results_hourly = res.num_tuples
    exceeded_hourly = results_hourly > max_hourly

    puts "Daily likes: #{results_daily} .. Hourly likes: #{results_hourly}"

    exceeded_daily || exceeded_hourly
  end

  private

  def connect
    @conn = Database.conn
  end

  def disconnect
    @conn.close if @conn
  end

  def log_exec(query)
    connect
    begin
      unless Global::OPTS.quiet?
        puts 'PSQL -->'
        puts query
        puts '<--'
      end
    rescue => e
      puts '! ! !'
      puts 'if this is a NameError about Global.. its prolly fine..'
      puts e
      puts '! ! !'
    end
    results = @conn.exec query
    disconnect
    results
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

# Database.exec "ALTER TABLE users
# ADD COLUMN relevance INTEGER"


