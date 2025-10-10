Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  if ENV["ARCHER_OIDC_NAME"]
    provider :openid_connect, {
      name: ENV.fetch("ARCHER_OIDC_NAME"),
      scope: [ :openid, :email ],
      discovery: true,
      response_type: :code,
      uid_field: "email",
      client_options: {
        port: 443,
        scheme: "https",
        host: ENV.fetch("ARCHER_OIDC_HOST"),
        identifier: ENV.fetch("ARCHER_OIDC_CLIENT_ID"),
        secret: ENV.fetch("ARCHER_OIDC_SECRET_KEY"),
        redirect_uri: ENV.fetch("ARCHER_OIDC_CALLBACK_URI")
      }
    }
  end
end
