class HiBot
  require './action.rb'
  require './navigation.rb'
  require './brow.rb'
  require './database.rb'

  ERR_MAX_LIKES = 'too many like actions'
  ERR_PRIV_ACCT = 'account is private'
  ERR_INACTIVE_ACCT = 'account is inactive'
  ERR_NO_USER_FOUND = 'could not find a random user in database'
  MAX_DAILY_LIKES = 380
  
  attr_reader :navigation, :action, :brow

  def initialize
    @brow = Brow.new.brow
    @navigation = Navigation.new(brow: brow)
    @action = Action.new(brow: brow)
    @db = Database.new
  end
  
  def login
    navigation.login
  end

  def bot_checks
    puts "daily likes.. roughly.. #{@db.daily_likes_ish}" if @db.daily_likes_ish
    
    if @db.exceeding_max_actions(max: MAX_DAILY_LIKES)
      return { error: ERR_MAX_LIKES, continue: false }     
    end
    
    { error: nil, continue: true }
  end

  def find_user_to_interact
    puts "finding a user to interact with.."

    username = @db.random_user
    
    return { error: ERR_NO_USER_FOUND, continue: false } if username == :no_user

    puts "found fresh user: '#{username}'"

    { error: nil, continue: true, user: username }
  end

  def comb_usernames_from_rnd_main
    puts "let's find some usernames!"
    navigation.goto_a_main_acct
    
    puts "finding a like modal"
    navigation.goto_rnd_img_with_likes_btn_and_click
    usernames = action.get_list_of_users_from_likes
    
    puts "found #{usernames.length} usernames, adding to usernames table.."
    usernames.each { |user| @db.add_user(user.to_s) }
  end

  def go_like_something(username)
    navigation.goto_acct(username)

    # do some checks
    if Utils.private_acct?(brow)
      puts "user: #{username} is private.."
      @db.mark_user_private(username)
      return { error: ERR_PRIV_ACCT, continue: true }
    elsif !Utils.insta_acct_page?(brow)
      puts "#{username} doesn't seem to be an account"
      @db.mark_user_invalid(username)
      return { error: ERR_INACTIVE_ACCT, continue: true }
    end

    begin
      navigation.goto_rnd_img
      action.like_img
      @db.add_action(type: Database::ACT_LIKE, username: username)
      @db.add_user_interaction_ts(username: username)
    rescue StandardError => e
      puts "! ! !"
      puts "issues clicking the like button:"
      puts e
      puts "! ! !"
      @db.mark_user_invalid(username)
    end

    { error: nil, continue: true }
  end
end