# JWTea

The goal of JWTea is to simplify authentication in web apps without coupling it with any specific strategy. It is a simple lightweight ruby wrapper around the [JWT](https://github.com/jwt/ruby-jwt) gem, which allows for storing jti claims so that tokens can be revoked and validated. If that sounds like your cup of tea, then this gem is for you.
Comes with a Redis store built-in, but allows for custom stores as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jw_tea'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jw_tea

## Usage

Brewing a JWTea token (encode)

```ruby
kettle = JWTea::Kettle.new(
    secret: 'MY_SECRET_KEY',
    store: JWTea::Stores::RedisStore.new,
    algorithm: 'HS256',
    expires_in: 3600 # seconds
)
#=> #<JWTea::Kettle expires_in: 3600, store: #<JWTea::Stores::RedisStore:0x00007f86bc05f8d0>>
data = { some: 'data' }
token = kettle.brew(data)
#=> #<JWTea::Token:0x00007f86bd0ff780>
token.encoded
#=> "eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7InNvbWUiOiJkYXRhIn0sImp0aSI6IjczZWI5YTBjNDgwOTIwZGY5ZTM0ZWQ0MTRlOWFhOTA4IiwiaWF0IjoxNTcyODQ4OTQ0LCJleHAiOjE1NzM0NTM3NDR9.UmPwCXusG65VNXPxdCLKMC8gyUsGkTDIcaSw1R6_YZQ"
token.jti
#+> "73eb9a0c480920df9e34ed414e9aa908"
token.exp
#=> 1573453744
```

Or, if you don't really care about jti/exp and just want the encoded token

```ruby
data = { some: 'data' }
encoded_token = kettle.encode(data)
#=> "eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7InNvbWUiOiJkYXRhIn0sImp0aSI6ImNiMGZiOWQ3NzVmYjM4NTYzYTJjMDgxZTZkNzhlNzAwIiwiaWF0IjoxNTcyODQ5MzQ4LCJleHAiOjE1NzM0NTQxNDh9.xrps_lCz0FNWNmEVFbxNR4TcssOAtTS1EuQO2JffQB0"
```

Pouring a JWTea token (decoding)

```ruby
token = kettle.pour(encoded_token)
#=> #<JWTea::Token:0x00007feba6a33330>
#=> #<JWTea::Token:0x00007feba592ef08>
token.jti
#=> "1571bb5d8ac64b7b087b65350b530e0d"
token.data
#=> {"some"=>"data"}
```

Again, if you just want the data you can do

```ruby
data = kettle.decode(encoded_token)
#=> {"some"=>"data"}
```

If using a store, you can validate that the token hasn't been revoked (trying to pour/decode a revoked token will yield an error)

```ruby
kettle.valid?(encoded_token)
#=> true
```

Revoking a token

```ruby
kettle.revoke(encoded_token)
#=> true
kettle.valid?(encoded_token)
#=> false
```

You can also define your own method of storage, which just needs to respond to `save`, `exists?` and `delete`

```ruby
class MyCustomStore
    def save(jti, exp, ttl_in_seconds)
        # Some logic to store the token
    end

    def exists?(jti, exp)
        # Some logic to verify the token hasn't been revoked
    end

    def delete(jti)
        # Some logic to revoke the token
    end
end

JWTea::Kettle.new(
    secret: 'MY_SECRET_KEY',
    store: MyCustomStore.new,
)
#=> #<JWTea::Kettle expires_in: 3600, store: #<MyCustomStore:0x00007feba696e2b0>>
```

That's pretty much it!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/b-loyola/jw_tea. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JWTea project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/b-loyola/jw_tea/blob/master/CODE_OF_CONDUCT.md).
