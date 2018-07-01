# Woah!
[![Build Status](https://travis-ci.org/knarka/woah.svg?branch=master)](https://travis-ci.org/knarka/woah)
[![Coverage Status](https://coveralls.io/repos/github/knarka/woah/badge.svg?branch=master)](https://coveralls.io/github/knarka/woah?branch=master)
[![Gem Version](https://badge.fury.io/rb/woah.svg)](https://badge.fury.io/rb/woah)

Woah! is an unobtrusive, (extremely) minimal web framework built on Rack.

## Installation
`gem install woah`

## What do I do with it???
Simple. You're gonna want to extend Woah::Base, which will be your app's, er, base.

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

There's two new blocks here: `before` and `after`. They do things before and after the relevant route gets executed. This example will increment a counter everytime a page is hit, regardless of what page it is.

Of course, getting pages isn't everything you can do on the Internet. There's other HTTP verbs as well, like POST. Behold:

```ruby
require 'woah'

class MyApp < Woah::Base
	before do
		@@content ||=
		'<form action="/" method="post">'\
			'<input type="submit" value="click me please" />'\
		'</form>'
	end

	on '/' do
		@@content
	end

	on '/', 'POST' do
		@@content = 'thanks for clicking!'
	end
end
```

As soon as you click the button on `/`, the message on the page will transform.

Of course, sometimes you want routes to be flexible, and to catch more than one expression. For this, you can use regular expressions instead of strings as your routes, just like this:

```ruby
require 'woah'

class MyApp < Woah::Base
	on %r{^/greet/(\w+)$} do
		"oh, hello, I didn't see you there #{match[1]}"
	end
end
```

Now, visiting `/greet/Socrates` will greet you with your own name. Wonderful. By the way, you may have noticed we're using `%r{}` to delimit our regex, instead of the more common `//`. This is because of how common slashes are in routes, so it's recommended to use this syntax. You can use slashes to delimit your regex though, if you like. I won't judge you.

Redirects are possible as well:

```ruby
require 'woah'

class MyApp < Woah::Base
	on '/' do
		redirect_to '/landing'
	end

	on '/landing' do
		'welcome'
	end
end
```

So are cookies:

```ruby
require 'woah'

class MyApp < Woah::Base
	on '/' do
		cookie['chunky'] || 'no cookie set'
	end

	on '/set' do
		cookie['chunky'] = 'bacon'
	end
end
```

Upon first visiting, this page will tell you there's no cookie set. After visiting `/set` however, it'll display `bacon`, as that is now the content of the `chunky` cookie.

We're nearing the end of this little guide already, I'm afraid. However, there's still one more trick you need to see. Look, sometimes, you might disagree with the things Woah! thinks up for you. That's why you can override everything Woah! is about to send, if you so please. Por exemplo:

```ruby
require_relative 'lib/woah'

class MyApp < Woah::Base
	on '/' do
		'(insert super secret information)'
	end

	on %r{^/pass/(\w+)$} do
		@password = match[1]
		'logged in! <a href="/">back to root</a>'
	end

	after do
		unless @password && @password == 'penguin'
			set :status, 403
			set :body, 'log in first!'
		end
	end
end

MyApp.run!
```

That's all. Have fun!
