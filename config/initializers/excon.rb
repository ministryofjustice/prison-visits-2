# Replace the default Idempotent middleware with our version that doesn't retry
# timeouts.
require 'excon/middleware/custom_idempotent'

Excon.defaults[:middlewares].map! do |middleware|
  if middleware == Excon::Middleware::Idempotent
    Excon::Middleware::CustomIdempotent
  else
    middleware
  end
end
