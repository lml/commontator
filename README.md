# Commontator

[![Gem Version](https://badge.fury.io/rb/commontator.svg)](http://badge.fury.io/rb/commontator)
[![Build Status](https://travis-ci.org/lml/commontator.svg?branch=master)](https://travis-ci.org/lml/commontator)
[![Code Climate](https://codeclimate.com/github/lml/commontator/badges/gpa.svg)](https://codeclimate.com/github/lml/commontator)
[![Code Coverage](https://codeclimate.com/github/lml/commontator/badges/coverage.svg)](https://codeclimate.com/github/lml/commontator)

Commontator is a Rails engine for comments. It is compatible with Rails 5.
Being an engine means it is fully functional as soon as you install and
configure the gem, providing models, views and controllers of its own.
At the same time, almost anything about it can be configured or customized to suit your needs.

## Installation

There are 4 steps you must follow to install Commontator:

1. Gem

  Add this line to your application's Gemfile:

  ```rb
  gem 'commontator'
  ```

  You will also need jquery-ujs and a sass compiler, which can be either be installed through
  the webpacker gem and yarn/npm/bower or through the jquery-rails and sass[c]-rails gems:

  ```rb
  gem 'jquery-rails'
  gem 'sassc-rails'
  ```

  Then execute:

  ```sh
  $ bundle install
  ```

2. Initializer and Migration

  Run the following command to copy Commontator's initializer and migration to your app:

  ```sh
  $ rake commontator:install
  ```

  Or alternatively:

  ```sh
  $ rake commontator:install:initializers

  $ rake commontator:install:migrations
  ```

  And then execute:

  ```sh
  $ rake db:migrate
  ```

3. Configuration

  Change Commontator's configurations to suit your needs by editing `config/initializers/commontator.rb`.
  Make sure to check that your configuration file is up to date every time you update the gem, as available options can change with each minor version.
  If you have deprecated options in your initializer, Commontator will issue warnings (usually printed to your console).

  Commontator relies on Rails's `sanitize` helper method to sanitize user input before display.
  The default allowed tags and attributes are very permissive, basically
  only blocking tags, attributes and attribute values that could be used for XSS.
  [Read more about configuring the Rails sanitize helper.](https://edgeapi.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html).

4. Routes

  Add this line to your Rails application's `routes.rb` file:

  ```rb
  mount Commontator::Engine => '/commontator'
  ```

  You can change the mount path if you would like a different one.

5. Javascripts

  Make sure your application.js requires jquery and jquery-ujs:

  ```js
  //= require jquery
  // If jquery-ujs was installed through jquery-rails
  //= require jquery_ujs
  // If jquery-ujs was installed through webpacker and yarn/npm/bower
  //= require jquery-ujs
  ```

  If using Commontator's mentions functionality, also require Commontator's application.js:

  ```js
  //= require commontator/application
  ```

6. Stylesheets

  In order to display comment threads properly, you must
  require Commontator's application.scss in your `application.[s]css`:

  ```css
  *= require commontator/application
  ```

## Usage

Follow the steps below to add Commontator to your models and views:

1. Models

  Add this line to your user model(s) (or any models that should be able to post comments):

  ```rb
  acts_as_commontator
  ```

  Add this line to any models you want to be able to comment on (i.e. models that have comment threads):

  ```rb
  acts_as_commontable
  ```
  if you want the thread and all its comments removed when your commontable model is destroyed pass
  :destroy as the :dependent option to`acts_as_commontable`:

  ```rb
  acts_as_commontable dependent: :destroy
  ```

  instead of `:destroy` you may use any other supported `:dependent` option from rails `has_one`
  association.

2. Views

  In the following instructions, `@commontable` is an instance of a model that `acts_as_commontable`.
  You must supply this variable to the views that will use Commontator.

  Wherever you would like to display comments, call `commontator_thread(@commontable)`:

  ```erb
  <%= commontator_thread(@commontable) %>
  ```

  This will create a link that can be clicked to display the comment thread.

  Note that model's record must already exist in the database, so do not use this in `new.html.erb`, `_form.html.erb` or similar views.
  We recommend you use this in the model's `show.html.erb` view or the equivalent for your app.

3. Controllers

  By default, the `commontator_thread` method only provides a link to the desired comment thread.
  Sometimes it may be desirable to have the thread display right away when the corresponding page is loaded.
  In that case, just add the following method call to the controller action that displays the page in question:

  ```rb
  commontator_thread_show(@commontable)
  ```

  Note that the call to `commontator_thread` in the view is still necessary in either case.

  The `commontator_thread_show` method checks the current user's read permission on the thread and will display the thread if the user is allowed to read it, according to the options in the initializer.

That's it! Commontator is now ready for use.

## Emails

When you enable subscriptions, emails are sent automatically by Commontator. If sending emails, remember to add your host URL's to your environment files (test.rb, development.rb and production.rb):

```rb
config.action_mailer.default_url_options = { host: "https://www.example.com" }
```

Batch sending through Mailgun is also supported and automatically detected.

You may need to customize the mailer views with `rake commontator:copy:views` though only `app/views/commontator/subscriptions_mailer/` may be necessary. These in turn may require that you customize the localizations as well (see below for more details on that).

Sometimes you may need to add users automatically upon some event. For example, you may wish to automatically "subscribe" a (commontator) `user` to a (commontable) `event` so they get messages sent to the event automatically after joining the event. To do this you call `event.thread.subscribe(user)` when adding that `user` to that `event`.

## Voting

You can allow users to vote on each others' comments by adding the `acts_as_votable` gem to your Gemfile:

```rb
gem 'acts_as_votable'
```

And enabling the relevant option in Commontator's initializer:

```rb
config.comment_voting = :ld # See the initializer for available options
```

## Mentions

You can allow users to mention other users in the comments.
Mentioned users are automatically subscribed to the thread and receive email notifications.

First make sure you required Commontator's application.js
in your `application.js` as explained in the Javascripts section.
Then enable mentions in Commontator's initializer:

```rb
config.mentions_enabled = true
```

Finally configure the user_mentions_proc, which receives the current user, the current thread,
and the search query inputted by that user and should return a relation containing the users
that can be mentioned and match the query string:

```rb
config.user_mentions_proc = ->(current_user, thread, query) { ... }
```

Please be aware that with mentions enabled, any registered user
can use the `user_mentions_proc` to search for other users.
Make sure to properly escape SQL in this proc and do not allow searches on sensitive fields.

Use '@' with at least three other characters to mention someone in a new/edited comment.

The mentions script assumes that Commontator is mounted at `/commontator`,
so make sure that is indeed the case if you plan to use mentions.

## Browser Support

Commontator should work properly on any of the major browsers.
The mentions functionality won't work with IE before version 8.
To function properly, this gem requires that visitors to the site have javascript enabled.

## Customization

Copy Commontator's files to your app using any of the following commands:

```sh
$ rake commontator:copy:locales

$ rake commontator:copy:images
$ rake commontator:copy:javascripts
$ rake commontator:copy:stylesheets

$ rake commontator:copy:views
$ rake commontator:copy:helpers

$ rake commontator:copy:controllers
$ rake commontator:copy:mailers

$ rake commontator:copy:models
```

You are now free to modify them and have any changes made manifest in your application.

If copying Commontator's locales, please note that by default Rails will not autoload locales in subfolders of `config/locales` (like ours) unless you add the following to your `application.rb`:

```rb
config.i18n.load_path += Dir[root.join('config', 'locales', '**', '*.yml')]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests for your feature
4. Implement your new feature
5. Test your feature (`rake`)
6. Commit your changes (`git commit -am 'Added some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

## Development Environment Setup

1. Use bundler to install all dependencies:

  ```sh
  $ bundle install
  ```

2. Load the schema:

  ```sh
  $ rake db:schema:load
  ```

  Or if the above fails:

  ```sh
  $ bundle exec rake db:schema:load
  ```

## Testing

To run all existing tests for Commontator, simply execute the following from the main folder:

```sh
$ rake
```

Or if the above fails:

```sh
$ bundle exec rake
```

## License

This gem is distributed under the terms of the MIT license.
See the MIT-LICENSE file for details.
