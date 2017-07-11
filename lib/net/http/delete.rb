require 'net/http'

# I know changing standard library behavior is very bad,
# but some CircleCI REST APIs need to send request body.
# So we have to override to allow DELETE request has request body.
class Net::HTTP::Delete
  def request_body_permitted?
    true
  end
end
