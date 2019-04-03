require 'open3'
def is_up?(host)
    host, port = host.split(':')
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    b.scan(/succeeded/).length > 0
end

Online.all.each do |d|
	online = is_up?("#{d.ip}:#{d.port}") rescue false

  if online
    d.online = true
    d.time_seen = Time.now
    d.save
  else
    d.online = false
    d.save
  end
end