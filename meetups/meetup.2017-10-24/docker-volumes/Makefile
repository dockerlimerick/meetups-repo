
build:
	docker build -t ruby-counter-app .

run:
	docker run --rm ruby-counter-app

count:
	docker run --rm -v $(PWD):/usr/src/count -w /usr/src/count ruby:2.1 ruby counter.rb
