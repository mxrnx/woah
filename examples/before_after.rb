require 'woah'

# simple app demonstrating before and after
class MyApp < Woah::Base
	before do
		@@time ||= "34 o' clock"
	end

	on '/test' do
		"hi hi :B<br />the time is #{@@time}"
	end

	after do
		@@time = "12 o' clock"
	end
end

MyApp.run!
