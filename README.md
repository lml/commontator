# Commontator

Commontator is a Rails engine for comments. It is compatible with Rails 3.1+ and Rails 4.
Being an engine means it is fully functional as soon as you install and
configure the gem, providing models, views and controllers of its own.
At the same time, almost anything about it can be configured or customized to suit your needs.

## Installation

There are 4 steps you must follow to install commontator:

1. Gem

  Add this line to your application's Gemfile:

  ```ruby
  gem 'commontator', '~> 4.2.0'
  ```

  And then execute:

  ```sh
  $ bundle
  ```

  Or install it yourself as:

  ```sh
  $ gem install commontator
  ```

2. Initializer and Migration

  Run the following command to copy commontator's initializer and migration to your own app:

  ```sh
  $ rake commontator:install
  ```

  And then execute:

  ```sh
  $ rake db:migrate
  ```

  Or run each rake task manually:

  ```sh
  $ rake commontator:install:initializers

  $ rake commontator:install:migrations

  $ rake db:migrate
  ```

3. Configuration

  Change commontator's configurations to suit your needs by editing config/intializers/commontator.rb.

4. Routes

  Add this line to your application's routes file:

  ```ruby
  mount Commontator::Engine => '/commontator'
  ```

  You can change the mount path if you would like a different one.

## Usage

Follow the steps below to add commontator to your models and views:

1. Models

  Add this line to your user model(s) (or any models that should be able to post comments):

  ```ruby
  acts_as_commontator
  ```
    
  Add this line to any models you want to be able to comment on:

  ```ruby
  acts_as_commontable
  ```
    
2. Views

  In the following instructions, `commontable` is an instance of a model that `acts_as_commontable`.

  Add the following line to any erb view where you would like to display comments:

  ```erb
  <%= commontator_thread(commontable) %>
  ```

  This will create a link in the view that the user will be able to click to display the comment thread.

  Note that model's record must already exist in the database, so do not use this in new.html.erb, _form.html.erb or similar.
  We recommend you use this in the model's show.html.erb.

3. Controllers

  By default, the `commontator_thread` function only links to the desired comment thread.
  If you want, instead, to have the thread display right away when the corresponding view page is loaded,
  just add the following function call to the controller action that displays the view in question:
  
  ```ruby
  commontator_thread_show(commontable)
  ```

  Note that the call to `commontator_thread` in the view is still necessary in either case.

  The `commontator_thread_show` method checks the current user's read permission on the thread and will raise an
  exception if the user is not allowed to read it according to the configuration options in the initializer.
  It is up to you to ensure that this method is only called if the user is authorized to read the thread.

That's it! Commontator is now ready for use.

## Voting

You can allow users to vote on each others' comments by adding the acts_as_votable gem to your gemfile:

```ruby
gem 'acts_as_votable'
```

And enabling the relevant option in commontator's initializer:

```ruby
config.can_vote_on_comments = true
```

Note that acts_as_votable is currently incompatible with the protected_attributes
gem if config.active_record.whitelist_attributes is set to true.

## Browser Support

Commontator should work properly on any of the major browsers.
To function properly, this gem requires that visitors to the site have javascript enabled.

## Customization

Copy commontator's files to your app using any of the following commands:

```sh
$ rake commontator:copy:images
$ rake commontator:copy:stylesheets

$ rake commontator:copy:views
$ rake commontator:copy:mailers
$ rake commontator:copy:helpers

$ rake commontator:copy:controllers
$ rake commontator:copy:models
```

You are now free to modify them and have any changes made manifest in your application.

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

1. Browse to commontator's spec/dummy folder
2. Use bundler to install all dependencies:

  ```sh
  $ bundle install
  ```

3. Load the schema:

  ```sh
  $ rake db:schema:load
  ```

  Or if the above fails:

  ```sh
  $ bundle exec rake db:schema:load
  ```

## Testing

To run all existing tests for commontator, simply execute the following from the main folder:

```sh
$ rake
```

Or if the above fails:

```sh
$ bundle exec rake
```

## License

This engine is distributed under the terms of the MIT license.
See the MIT-LICENSE file for details.
