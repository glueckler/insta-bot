class HiBot
  require './action.rb'
  require './navigation.rb'
  require './brow.rb'
  require './database.rb'

  ERR_MAX_LIKES     = 'too many like actions'
  ERR_PRIV_ACCT     = 'account is private'
  ERR_INACTIVE_ACCT = 'account is inactive'
  ERR_NO_USER_FOUND = 'could not find a random user in database'
  ERR_WAIT_ERROR    = 'instagram is not cooperating'
  MAX_DAILY_LIKES   = 100
  MAX_HOURLY_LIKES  = 5

  attr_reader :navigation, :action, :brow

  def initialize
    @brow       = Brow.new.brow
    @navigation = Navigation.new(brow: brow)
    @action     = Action.new(brow: brow)
    @db         = Database.new
  end

  def login
    navigation.login
  end

  def bot_refresh
    @brow.close
    @brow       = Brow.new.brow
    @navigation = Navigation.new(brow: brow)
    @action     = Action.new(brow: brow)
  end

  def bot_checks
    # skip this check for now
    # if @db.exceeding_max_actions(max: MAX_DAILY_LIKES, max_hourly: MAX_HOURLY_LIKES)
    #   return { error: ERR_MAX_LIKES }
    # end

    { error: nil }
  end

  def find_user_to_relevate
    puts "finding a user to relevate.."

    username = @db.random_user_with_zero_rel

    return { error: ERR_NO_USER_FOUND } if username == :no_user

    puts "found user with no relevance: '#{username}'"

    { error: nil, user: username }
  end

  def find_user_to_interact
    puts "finding a user to interact with.."

    username = @db.random_user

    return { error: ERR_NO_USER_FOUND } if username == :no_user

    puts "found fresh user: '#{username}'"

    { error: nil, user: username }
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

  def find_user_relevance(username)
    relevant_usernames       = []
    relevant_username_values = {}
    f                        = open('relevant_accts.txt')
    f.each_line do |line|
      relevant_username = line.strip.split(',')[0]
      relevant_value    = line.strip.split(',')[1]
      relevant_usernames << relevant_username
      relevant_username_values[relevant_username] = relevant_value
    end
    f.close

    puts "finding user relevance"
    navigation.goto_following_modal

    usernames                = action.get_list_of_users_from_following
    usernames.each do |u|
      @db.add_to_following(u, username)
    end

    usernames_add_to_network = []
    relevance_score          = 0
    for user in usernames do
      if relevant_usernames.include?(user.strip)
        relevance_score = relevance_score + relevant_username_values[user].to_i
        usernames_add_to_network.push user.strip
      end
    end

    puts "found #{usernames.length} usernames"
    @db.set_user_follow_count(username, usernames.length)
    puts "relevance score for #{username} is #{relevance_score}"
    usernames_add_to_network.each do |u|
      puts u + " +" + relevant_username_values[u]
    end
    usernames_add_to_network.each do |u|
      @db.add_network_connection(u, username)
    end

    @db.set_user_relevance(username, relevance_score)
  end

  def go_like_something_and_relevate(username, stop_liking)
    navigation.goto_acct(username)

    # do some checks
    if Utils.private_acct?(brow)
      puts "user: #{username} is private.."
      @db.mark_user_private(username)
      return { error: ERR_PRIV_ACCT }
    elsif !Utils.insta_acct_page?(brow)
      puts "#{username} doesn't seem to be an account"
      @db.mark_user_invalid(username)
      return { error: ERR_INACTIVE_ACCT }
    elsif Utils.should_wait_a_while(brow)
      puts '!!! shit is blocked'
      return { error: ERR_WAIT_ERROR }
    end

    find_user_relevance(username) if @db.user_relevance_unknown(username)

    unless stop_liking
      begin
        puts "going to like something"
        navigation.goto_acct(username)
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
    end

    { error: nil }
  end

  def go_visit_a_relevant_user
    relevant_usernames = @db.get_relevant_user_list
    usar = relevant_usernames.sample[0]
    puts "navigating to following page.."
    puts "https://www.instagram.com/#{usar}"

    navigation.goto_acct(usar)
  end
end
