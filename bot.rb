require 'pry'
require 'slop'
require './hi_bot.rb'

class Global
  OPTS = Slop.parse do |o|
    o.bool '-q', '--quiet', 'suppress output (quiet mode)'
    o.bool '-t', '--tour', 'go visit some relevant accounts'
  end

  attr_accessor :errors, :bot

  def initialize
    @bot_on           = true
    @last_bot_refresh = Time.now.to_i
    @errors           = []
    @bot              = HiBot.new
    @bot.login
    if Global::OPTS.tour?
      puts "bot tour mode...."
      bot_tour
    else
      bot_do
    end
  end

  def nap
    puts "\nGOING TO TAKE A NAP...\n..\n."
    sleep(360) # 6mins
  end

  def long_nap
    puts "\nTAKING A LONG SLEEP...\n..\n."
    sleep(4000)
  end

  def dream
    puts "~--`~-~~~____`~~~~"
  end

  def sleep_cycle
    nap
    @cycle_count = 0
  end

  def the_loop
    while @bot_on
      dream

      @cycle_count ||= 0
      @cycle_count += 1
      puts "cycle count: " + @cycle_count.to_s
      sleep_cycle if @cycle_count == 10


      # if Time.now.to_i > (@last_bot_refresh + 4000)
      #   @last_bot_refresh = Time.now.to_i
      #   puts "restarting the browser. .. ..."
      #   @bot.bot_refresh
      #   @bot.login
      # end

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

      if status[:error] == HiBot::ERR_WAIT_ERROR
        long_nap
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

  def the_tour_loop
    while @bot_on
      bot.go_visit_a_relevant_user
      input = STDIN.gets.chomp
    end
  end

  def bot_tour
    begin
      the_tour_loop
    rescue => e
      puts "! ! ~ - ~ ! !"
      puts e.message
      puts "! ! ~ - ~ ! !"
      errors << e
      sleep(5)
      bot_tour
    end
  end
end

Global.new
