if base_name = ENV["STATSD_HOSTNAME"]
  hostname_and_port, namespace = base_name.split("@")
  hostname, port = hostname_and_port.split(":")
end

hostname  ||= "localhost"
namespace ||= "victorykit.test"
port      ||= "8125"

$statsd = Statsd.new(hostname, port.to_i).tap do |s|
  s.namespace = namespace
end