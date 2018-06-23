# Woah!
[![Build Status](https://travis-ci.org/knarka/woah.svg?branch=master)](https://travis-ci.org/knarka/woah)
[![Gem Version](https://badge.fury.io/rb/woah.svg)](https://badge.fury.io/rb/woah)

Woah! is a minimal web framework built on Rack. It's primary design goal is to be unobtrusive, and to just let you do your thing, dude.

## Installation
`gem install woah`

## What now???
Easy. You're gonna want to extend Woah::Base, which will be your app's, er, base.

```ruby
require 'woah'

class MyApp < Woah::Base
end
```

Woah, that's easy. Now let's add a route.

```ruby
require 'woah'

class MyApp < Woah::Base
	on '/hello' do
		"hey, what's up"
	end
end
```

When someone stumbles upon `/hello` now, they'll be greeted properly. Nice. We call these blocks of code **routes**. There's more types of blocks than just routes though. Check this out:

```ruby
require 'woah'

class MyApp < Woah::Base
	before do
		@@num ||= 1
	end

	on '/' do
		"this is the root of this app, and page hit nr. #{@@num}"
	end

	on '/hello' do
		"hey, what's up. this is page hit nr. #{@@num}"
	end

	after do
		@@num += 1
	end
end
```

There's two new blocks here: `before` and `after`. They do things before and after the relevant route gets executed (duh!). This example will increment a counter everytime a page is hit, regardless of what page it is.

More to come.
