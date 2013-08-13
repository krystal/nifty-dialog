# Nifty Dialog

Nifty Dialog is a simple javascript library providing support for dialogs within
HTML applications.

This particular module is designed to tbe included within a Ruby on Rails application.
To use this, simply add this library to your Gemfile and include some references in
your appropriate files.

In your Gemfile:

```
gem 'nifty-dialog'
```

In your `app/assets/javascripts/application.js`:

```
#= require nifty/dialog
```

In your `app/assets/stylesheets/application.css`:

```
*= require nifty/dialog
```

Don't forget to run `bundle` after adding the item to your Gemfile.
