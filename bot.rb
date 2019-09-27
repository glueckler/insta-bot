require 'pry'
require 'slop'
require './hi_bot.rb'

class Global
  OPTS = Slop.parse do |o|
    o.bool '-q', '--quiet', 'suppress output (quiet mode)'
  end

  attr_accessor :errors, :bot

  def initialize
    @bot_on           = true
    @last_bot_refresh = Time.now.to_i
    @errors           = []
    @bot              = HiBot.new
    @bot.login
    bot_do
  end

  def nap
    puts "\nGOING TO TAKE A NAP...\n..\n."
    sleep(2000) # over an hour
  end

  def dream
    puts "~--`~-~~~____`~~~~"
  end

  def the_loop
    while @bot_on
      dream

      nap if [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2].sample == 1 #random naps


      if Time.now.to_i > (@last_bot_refresh + 4000)
        @last_bot_refresh = Time.now.to_i
        puts "restarting the browser. .. ..."
        @bot.bot_refresh
        @bot.login
      end

      puts "oh man, we have: #{errors.length} errors.." unless errors.empty?

      # status      = bot.bot_checks
      # stop_liking = status[:error] == HiBot::ERR_MAX_LIKES
      stop_liking = true

      status = if stop_liking
                 bot.find_user_to_relevate
               else
                 bot.find_user_to_interact
               end

      if status[:error] == HiBot::ERR_NO_USER_FOUND
        puts status[:error]
        bot.comb_usernames_from_rnd_main
        next
      end

      status = bot.go_like_something_and_relevate(status[:user], stop_liking)

      if status[:error]
        puts "! ! !"
        puts status[:error]
        puts "! ! !"
      end
    end
  end

  def bot_do
    begin
      the_loop
    rescue => e
      puts "! ! ~ - ~ ! !"
      puts e.message
      puts "! ! ~ - ~ ! !"
      errors << e
      sleep(5)
      bot_do
    end
  end
  end

  Global.new
