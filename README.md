# StimulusReflex Testing

So, you've started using the magic that is StimulusReflex. Neat, us too!

At this time, there aren't official testing helpers in the StimulusReflex library. We wanted to unit-test our reflexes, so we thought we share what we've been working on.

Things we'd like to add/improve on:

- MiniTest support
- Integration style testing?
- The ability to run assertions/expectations against the HTML re-rendered by a reflex
  - `expect(subject.to_html).to include('Hi, I rendered from a Reflex!')`
- Session is stubbed out (Rspec) right now, but we'd love to find a way to support sessions in testing
- Things you find useful that we can't think of, yet

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stimulus_reflex_testing', require: false
```

### Using 5.2 or below? Or using a version of RSpec Rails lower than 4?

Both Rails 6 and RSpec Rails 4 introduce the `action-cable-testing` library. If you're using Rails 5.2 and a version of RSpec Rails lower than 4, include the `action-cable-testing` gem in your Gemfile.

```ruby
gem 'stimulus_reflex_testing', require: false
gem 'action-cable-testing'
```

And then execute:

    $ bundle install

### RSpec instructions

Require the library into your `rails_helper`:

```ruby
require 'stimulus_reflex_testing/rspec'
```

Rspec tests include the reflex testing functionality when `type: :reflex` is provided. If this type is not provided, your Reflex tests won't work.

## Usage

### `build_reflex`

To build an instance of your reflex with the required setup handled (channel, url, element, etc) you can use the `build_reflex` method.

```ruby
# With a valid URL so StimulusReflex can build the correct request
build_reflex(url: posts_url)

# Does your test rely on a `current_user` (or similar) defined in `ApplicationCable::Connection`?
build_reflex(url: posts_url, connection: { current_user: create(:user) })

# Do you rely on form params?
build_reflex(url: edit_post_url(post), params: { post: { title: 'A new title!' } })

# Need to give your element some data?
reflex = build_reflex(url: posts_url)
reflex.element.value = "Hello"
reflex.element.dataset.id = "123"
```

### `#run`

To unit test a reflex, we provide a method (when using `build_reflex`) called `#run`. This method takes a method name, and any arguments.

```ruby
reflex = build_reflex(url: posts_url)
reflex.run(:method, arg1, arg2)
```

**Why can't I just call the method directly?**

You're more than welcome to call the method directly. But, be advised you will lose callbacks. If you need to run `before_reflex` (etc) use the run method.

_`#run` is a wrapper around the underlying `#process` method in StimulusReflex that runs callbacks._

### `#get`

To grab an instance variable set by a reflex, you can use the `#get` method when using a reflex built with `build_reflex`.

```ruby
# app/reflexes/post_reflex.rb
class PostReflex < ApplicationReflex
  def find_post
    @post = Post.find(params[:id])
  end
end

reflex = build_reflex(url: edit_post_url(post), params: { id: post.id })
reflex.run(:find_post)
reflex.get(:post) #=> returns the @post instance variable
```

## RSpec example

```ruby
# app/reflexes/post_reflex.rb
class PostReflex < ApplicationReflex
  def validate
    @post = Post.find(element.dataset.post_id)
    @post.validate
  end
end

# spec/reflexes/post_reflex_spec.rb
require 'rails_helper'

RSpec.describe PostReflex, type: :reflex do
  let(:post) { create(:post) }
  let(:reflex) { build_reflex(url: edit_post_url(post)) }

  describe '#validate' do
    subject { reflex.run(:validate) }

    before do
      reflex.element.dataset.post_id = post.id
      subject
    end

    it 'should find the post' do
      expect(reflex.get(:post)).to eq(post)
    end

    it 'should validate the post' do
      expect(reflex.get(:post).errors).to be_present
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/podia/stimulus_reflex_testing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/podia/stimulus_reflex_testing/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StimulusReflexTesting project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/podia/stimulus_reflex_testing/blob/master/CODE_OF_CONDUCT.md).
