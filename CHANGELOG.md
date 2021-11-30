## 0.4.8

* Feature: Allow more params with InteractiveReport.

## 0.4.7

* Bugfix: Accidentally removed the model parameter from the URL.

## 0.4.6

* Add InteractiveReport support.

## 0.4.5

* Add #delete to client.
* Set up Dependabot on GitHub.

## 0.4.4

* Pin http dependency to ~> 4.4.0. 5.0+ introduces a frozen string error.

## 0.4.3

* Add Client errors for more granular handling.
* Send along info when a `NotAuthorizedError` is raised.

## 0.4.2

* Raise an `UnhandledTypeError` and reveal the offender.
* Convert timedelta data types to Decimals.
* Don't use `.present?` to check if response is a Hash.

## 0.4.1

* @cdmwebs screwed up the release process, so this is a tiny bump to fix. No
  code changes.

## 0.4.0

* Add `Client#count` and `Model#count`.

## 0.3.0

* Add basic write support via `Fulfil::Client#post` and `Fulfil::Client#put`.

## 0.2.0

* Make token optional and allow specifying headers at least for enabling
  authentication via 'X-API-KEY' header , because initially implemented in
  0.1.0 bearer auth isn't working.
* Fix Query `build_search_term` and `build_exclude_term` to be compatible with
  Ruby < 2.4, analyzing value for 'Fixnum ' class.
* Fix the gem's name in gemspec to 'fulfil-io', as registered at RubyGems.
* Remove Rake version constraint from gemspec.
* Add Gemfile.lock to .gitignore and remove it from git-tree - it shouldn't be
  stored in git for a gem.

## 0.1.0

* Initial gem release.
