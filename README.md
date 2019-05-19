# bot

## cli

__bot life..__

INSTA_USER=organismanize INSTA_PASS=<pass> ruby ./bot.rb

__quiet sql queries__

INSTA_USER=organismanize INSTA_PASS=<pass> ruby ./bot.rb -q 

__init database tables__

ruby ./database_init.rb


## bot flow

__wake up (assuming a logged in state)__

bot checks:

-- bot hasn't liked over 400 imgs today

if any bot checks fail: __bot sleeps__

if bots check pass, bot assumes: __find a user to interact flow__

---

__find a user to interact flow__

bot queries database for user

-- user must be active

-- user must not be flagged private

-- bot must not have interacted with user in X number of days

if no user is found: bot assumes: __bulk user collection flow__

if user is found: bot assumes: __user interaction flow__

---

__bulk user collection flow__

bot navigates to a related page (listed)

bot clicks on an image to see likes

bot scrapes user account names from list

---

__user interaction flow__

bot navigates to user's page

if user is following bot's page, __bot sleeps__

if user page is private, bot flags user as private, and __bot sleeps__

if user has over 2500 likes, bot flags user as `busy_user`, and __bot sleeps__

bot clicks on random user image, and sets last interaction time with user to now (in database)

if bot hasn't followed new user in over 1 hour, bot assumes __user follow flow__

bot __sleeps__

---

__user follow flow__

bot checks the user's followers

if user follows more than 2 accounts which bot also follows, bot follows user

---


## related pages
Add related (related to your style) pages to the main_accts.txt

## todo

-> check if user has more than 2000 follows

-> check if user follows me
