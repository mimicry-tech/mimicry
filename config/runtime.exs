import Config

if ip = Mimicry.Config.ip!("MIMICRY_IP") do
  config :mimicry, MimicryApi.Endpoint, http: [ip: ip]
end

if port = Mimicry.Config.port!("MIMICRY_PORT") do
  config :mimicry, MimicryApi.Endpoint, http: [port: port]
end
