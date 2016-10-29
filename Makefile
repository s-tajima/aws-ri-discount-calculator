BUNDLE_PATH=vendor/bundle

setup:
	bundle install --path $(BUNDLE_PATH)

test:
	bundle exec rake spec

travis: test
