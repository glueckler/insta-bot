class HiBot
  require './action.rb'
  require './navigation.rb'
  require './brow.rb'
  require './database.rb'
  
  attr_reader :navigation, :action, :brow

  def initialize
    @brow = Brow.new.brow
    @navigation = Navigation.new(brow: brow)
    @action = Action.new(brow: brow)
  end

  def dream
    puts "~--`~-~~~____`~~~~"
  end
  
  def login
    navigation.login
  end

  def comb_usernames_from_rnd_main
    puts "let's find some usernames!"
    dream

    puts "going to a main account"
    navigation.goto_a_main_acct
    puts "finding a like modal"
    navigation.goto_rnd_img_with_likes_btn_and_click
    usernames = action.get_list_of_users_from_likes
    puts "found #{usernames.length} usernames, adding to usernames table.."
    db = Database.new
    usernames.each { |user| db.add_user(username: user) }
    db.disconnect
  end

  def go_like_something
    puts "going to like something - bot"
    dream

    db = Database.new
    puts "finding a user we haven't seen in a while.."
    recent_username = true
    while recent_username
      username = db.random_user
      puts "checking user #{username} for recent activity"
      recent_username = false unless db.recent_user_like_action?(username)
    end
    puts "found fresh user: #{username}"
    navigation.goto_acct(username)

    # do some checks
    if Utils.private_acct?(brow)
      puts "user: #{username} is private.."
      db.mark_user_private(username)
      return false
    elsif !Utils.insta_acct_page?(brow)
      puts "#{username} doesn't seem to be an account"
      db.mark_user_invalid(username)
      return false
    end

    # passed all checks..
    navigation.goto_rnd_img
    action.like_img
    db.add_action(type: Database::ACT_LIKE, username: username)

    db.disconnect
  end
end