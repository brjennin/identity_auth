require "jwt"
require "active_support/hash_with_indifferent_access"

module IdentityAuth
  class WebTokenManager
    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, ENV["JWT_SECRET"])
    end

    def self.decode(token)
      body = JWT.decode(token, ENV["JWT_SECRET"])[0]
      HashWithIndifferentAccess.new body
    rescue JWT::ExpiredSignature, JWT::VerificationError => e
      raise ExpiredSignature, e.message
    end
  end
end
