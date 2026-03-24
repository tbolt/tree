class Rack::Attack
  # Throttle login attempts by IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/login" && req.post?
  end

  # Throttle login attempts by email
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/login" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle signup by IP
  throttle("signups/ip", limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == "/sign_up" && req.post?
  end

  # Throttle password reset requests by IP
  throttle("password_resets/ip", limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == "/passwords" && req.post?
  end

  # Throttle post creation by IP
  throttle("posts/ip", limit: 10, period: 60.seconds) do |req|
    req.ip if req.path == "/posts" && req.post?
  end

  # Custom throttle response
  self.throttled_responder = lambda do |_env|
    [429, { "Content-Type" => "text/plain" }, ["Too many requests. Please try again later.\n"]]
  end
end
