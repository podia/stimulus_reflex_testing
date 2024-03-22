# StimulusReflex Testing

🚨🚨🚨🚨🚨🚨 **We are no longer maintining this gem.** 🚨🚨🚨🚨🚨🚨

If you're interested in taking ownership of this project, please reach out. Otherwise we'll likely archive it soon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stimulus_reflex_testing'
```

### Using 5.2 or below? Or using a version of RSpec Rails lower than 4?

Both Rails 6 and RSpec Rails 4 introduce the `action-cable-testing` library. If you're using Rails 5.2 and a version of RSpec Rails lower than 4, include the `action-cable-testing` gem in your Gemfile.

```ruby
gem 'stimulus_reflex_testing'
gem 'action-cable-testing'
```

And then execute:

    $ bundle install

### RSpec instructions

In `spec/rails_helper.rb` make sure to add: `require "stimulus_reflex_testing/rspec"`

Rspec tests include the reflex testing functionality when `type: :reflex` is provided. If this type is not provided, your Reflex tests won't work.

## Usage

### `build_reflex`

To build an instance of your reflex with the required setup handled (channel, url, element, etc) you can use the `build_reflex` method.

**Note:** In previous versions of the library you didn't have to provide the action you want to test in `build_reflex`. You would build the reflex and then provide the action to the `run` method. Now, the "proper" way to do this is to pass the action as `method_name` to `build_reflex`.

```ruby
# With a valid URL so StimulusReflex can build the correct request
build_reflex(method_name: :create, url: posts_url)

# Does your test rely on a `current_user` (or similar) defined in `ApplicationCable::Connection`?
build_reflex(method_name: :create, url: posts_url, connection: { current_user: create(:user) })

# Do you rely on form params?
build_reflex(method_name: :create, url: edit_post_url(post), params: { post: { title: 'A new title!' } })

# Need to give your element some data?
reflex = build_reflex(method_name: :create, url: posts_url)
reflex.element.value = "Hello"
reflex.element.dataset.id = "123"
```

### `#run`

To unit test a reflex, we provide a method (when using `build_reflex`) called `#run`. This method takes a method name, and any arguments.

**Note:** The method name is now optional if you provide the action to `build_reflex`, which is now the "correct" way setup your reflex test.

```ruby
# Providing the action during setup
reflex = build_reflex(method_name: :create, url: posts_url)
reflex.run

# Providing the action during setup with arguments
reflex = build_reflex(method_name: :create, url: posts_url)
reflex.run(nil, arg1, arg2)

# Legacy: Providing the action at "runtime" with arguments
reflex = build_reflex(url: posts_url)
reflex.run(:create, arg1, arg2)
```

**Why does the action need to be in `build_reflex` now?**

If we wait don't provide the Reflex action until after we've built the reflex, the callbacks do not setup correctly. If you're using callbacks (especially with :only or :except) you may run into issues if you don't provide the action until calling `#run`.

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

reflex = build_reflex(method_name: :find_post, url: edit_post_url(post), params: { id: post.id })
reflex.run
reflex.get(:post) #=> returns the @post instance variable
```

## Matchers

### `morph(selector)`

You can assert that a "run" reflex morphed as you expected:

```ruby
# app/reflexes/post_reflex.rb
class PostReflex < ApplicationReflex
  def delete
    @post = Post.find(params[:id])
    @post.destroy
    morph dom_id(@post), ""
  end
end

# spec/reflexes/post_reflex_spec.rb
require 'rails_helper'

RSpec.describe PostReflex, type: :reflex do
  let(:post) { create(:post) }
  let(:reflex) { build_reflex(method_name: :delete) }

  describe '#delete' do
    it 'morphs the post' do
      subject = reflex.run
      expect(subject).to morph("#post_#{post.id}")
    end
  end
end
```

You can also assert the content you provided to morph:

```ruby
# spec/reflexes/post_reflex_spec.rb
require 'rails_helper'

RSpec.describe PostReflex, type: :reflex do
  let(:post) { create(:post) }
  let(:reflex) { build_reflex(method_name: :delete) }

  describe '#delete' do
    it 'morphs the post with an empty string' do
      subject = reflex.run
      expect(subject).to morph("#post_#{post.id}").with("")
    end
  end
end
```

You can also run the expecation as a block:

```ruby
# spec/reflexes/post_reflex_spec.rb
require 'rails_helper'

RSpec.describe PostReflex, type: :reflex do
  let(:post) { create(:post) }
  let(:reflex) { build_reflex(method_name: :delete) }

  describe '#delete' do
    it 'morphs the post with an empty string' do
      expect { reflex.run }.to morph("#post_#{post.id}").with("")
    end
  end
end
```

### `broadcast(operations)` (Experimental)

You can assert that a reflex will perform the CableReady operations you anticipate:

```ruby
# app/reflexes/post_reflex.rb
class PostReflex < ApplicationReflex
  def delete
    @post = Post.find(params[:id])
    @post.destroy
    cable_ready[PostsChannel].remove(selector: dom_id(@post)).broadcast
  end
end

# spec/reflexes/post_reflex_spec.rb
require 'rails_helper'

RSpec.describe PostReflex, type: :reflex do
  let(:post) { create(:post) }
  let(:reflex) { build_reflex(method_name: :delete) }

  describe '#delete' do
    it 'broadcasts the CableReady operations' do
      expect { reflex }.to broadcast(:remove, :broadcast)
    end

    it 'removes the post' do
      expect { reflex }.to broadcast(remove: { selector: "#post_#{post.id}" }, broadcast: nil)
    end
  end
end
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
  let(:reflex) { build_reflex(method_name: :validate, url: edit_post_url(post)) }

  describe '#validate' do
    subject { reflex.run }

    before do
      reflex.element.dataset.post_id = post.id
      subject
    end

    it 'finds the post' do
      expect(reflex.get(:post)).to eq(post)
    end

    it 'validates the post' do
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
