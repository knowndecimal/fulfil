## 0.4.1

* @cdmwebs screwed up the release process, so this is a tiny bump to fix. No code changes.

## 0.4.0

* Add `Client#count` and `Model#count`.

## 0.3.0

* Add basic write support via `Fulfil::Client#post` and `Fulfil::Client#put`.

## 0.2.0

- Make token optional and allow specifying headers at least for enabling authentication via 'X-API-KEY' header
, because initially implemented in 0.1.0 bearer auth isn't working.

- Fix Query `build_search_term` and `build_exclude_term` to be compatible with Ruby < 2.4, analyzing value for 'Fixnum
' class.

- Fix the gem's name in gemspec to 'fulfil-io', as registered at RubyGems.

- Remove Rake version constraint from gemspec.

- Add Gemfile.lock to .gitignore and remove it from git-tree - it shouldn't be stored in git for a gem.

## 0.1.0

* Initial gem release
