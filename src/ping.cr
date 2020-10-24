require "time"
require "socket"
require "http"
require "openssl"
require "uri"
require "option_parser"

uri = URI.new
OptionParser.parse do |parser|
  parser.invalid_option do
  end
  parser.unknown_args do |args|
    if args.empty?
      STDERR.puts "No URI passed"
      exit(1)
    end
    uri = URI.parse args.first
  end
end

tcp_sock = Socket.tcp(Socket::Family::INET)

if !uri.host || !uri.scheme || !uri.path
  STDERR.puts "Invalid URI"
  exit(1)
end

host = uri.host || ""
scheme = uri.scheme || ""
path = uri.path == "" ? "/" : uri.path

time_before_dns = Time.utc
addrinfos = Socket::Addrinfo.resolve(host, scheme, type: Socket::Type::STREAM, protocol: Socket::Protocol::TCP)
time_after_dns = Time.utc

dns_lookup_time = (time_after_dns - time_before_dns)
puts "> DNS lookup took: #{dns_lookup_time.milliseconds}ms"

time_before_connect = Time.utc
tcp_sock.connect(addrinfos.last)

if scheme == "https"
  time_before_tls = Time.utc
  tls = OpenSSL::SSL::Context::Client.new
  sock = OpenSSL::SSL::Socket::Client.new(tcp_sock, context: tls, sync_close: true, hostname: host)
  time_after_tls = Time.utc
  tls_time = (time_after_tls - time_before_tls)
else
  sock = tcp_sock
end

time_after_connect = Time.utc
connect_time = (time_after_connect - time_before_connect)
puts "> Connecting took: #{connect_time.milliseconds}ms"
if tls_time
  puts ">> TLS handshake took: #{tls_time.milliseconds}ms"
end

headers = HTTP::Headers.new
headers["Host"] = host
headers["Accept"] = "text/html"
headers["Accept-Encoding"] = "gzip, deflate, br"

req = HTTP::Request.new("GET", path, headers: headers)
req.to_io(sock)
sock.flush

time_before_request = Time.utc
HTTP::Client::Response.from_io?(sock, ignore_body: false, decompress: true) do |res|
  time_after_request = Time.utc
  if scheme == "https" && tls_time
    request_time = (time_after_request - time_before_request)
    request_time = request_time - tls_time unless tls_time >= request_time
  else
    request_time = (time_after_request - time_before_request) - connect_time
  end
  outp = ""
  if res
    outp = res.body_io.gets_to_end
  end
  puts "> Request took: #{request_time.milliseconds}ms"

  total_time = (dns_lookup_time + connect_time + request_time)
  puts "> Total time: #{total_time.milliseconds}ms"
  puts
  puts ">> Status: #{res.try &.status_code}"
  puts ">> Content length: #{outp.bytes.size} bytes"

  sock.close
end
