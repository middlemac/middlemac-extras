middlemac-extras readme
-----------------------
[![Gem Version](https://badge.fury.io/rb/middlemac-extras.svg)](https://badge.fury.io/rb/middlemac-extras)


`middlemac-extras`

 : This gem provides conveniences to Middleman projects such as CSS-based image
   size limits; easy-to-use Markdown link references (including title!);
   easy-to-use Markdown image references; and an enhanced `image_tag` helper
   that includes @2x images automatically.

   It is standalone and can be used in any Middleman project.


Install the Gem
---------------

Install the gem in your preferred way, typically:

~~~ bash
gem install middlemac-extras
~~~

From git source:

~~~ bash
rake install
~~~


Documentation
-------------

The complete documentation leverages the features of this gem in order to better
document them. Having installed the gem, read the full documentation in your
web browser:

~~~ bash
middlemac-extras documentation
cd middlemac-extras-docs/
bundle install
bundle exec middleman server
~~~
   
And then open your web browser to the address specified (typically
`localhost:4567`).


Middlemac
---------

This Middleman extension is a critical part of
[Middlemac](https://github.com/middlemac), the Mac OS X help building system
for Mac OS X applications. However this gem is not Mac OS X specific and can be
useful in any application for which you want to provide structure and
navigation.


License
-------

MIT. See `LICENSE.md`.


Changelog
---------

See `CHANGELOG.md` for point changes, or simply have a look at the commit
history for non-version changes (such as readme updates).
