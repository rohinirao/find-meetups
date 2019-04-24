# README

# System dependencies 
  * ruby 2.5
  * rails 5
  * yarn
  * redis

# System Setup 
  * Set environment variable MEETUP_KEY `export MEETUP_KEY=< your personal meetup API key>`. API key can be found [here](https://secure.meetup.com/meetup_api/key/)
  * Start rails server `rails s`
  * Start resque worker `QUEUE=* rake resque:work`
  * start cache cleanup scheduler `rake meetup:cleanup`

# How to run the test suite
  `rspec spec`

# Enhancements
  * GUI improvements - better CSS, display more meetup results with pagination.
  * Research and Implement image cleanup with redis expire callbacks.
  * To allow the users to be able to choose the location for search.
  * not to use API key but to implement better authentication method.