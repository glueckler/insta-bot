require 'pry'
require './hi_bot.rb'

bot = HiBot.new

bot.login

while true
  bot.go_like_something
end
