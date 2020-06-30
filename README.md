About
=
The project is one part of a microservice based on RabbitMQ message broker 


Developer Setup Guide
=

1. Install [RVM](https://rvm.io/)
2. Install ruby 2.7.1
3. `bundle install`
4. Install&Run [RabbitMQ](https://www.rabbitmq.com/install-homebrew.html)
5. `.env.sample` -> `.env`, set proper values

Run the app
---

  1. Run rails server `$ bundle exec rails`
  2. Run message broker `hutch`
  3. The app is available now at http://localhost:3000   

Todo:
-----
- Move tweets parsing to background
- Add an integration test
- Expand test coverage for parsing
