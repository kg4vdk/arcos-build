require 'gpsd_client'
require 'maidenhead'
require 'socket'
require 'json'

gpsd = GpsdClient::Gpsd.new()
gpsd.start()

# Get maidenhead if GPS is ready
if gpsd.started?
  pos = gpsd.get_position
  maid = Maidenhead.to_maidenhead(pos[:lat], pos[:lon], precision = 4)
end
# Verify fix
unless maid == "JJ00aa00"
  File.open("/tmp/coords.log", "w") { |f| f.write "#{pos[:lat]},#{pos[:lon]}" }
  File.open("/tmp/grid.log", "w") { |f| f.write "#{maid}".upcase }
else
  File.delete("/tmp/coords.log") if File.exist?("/tmp/coords.log")
  File.delete("/tmp/grid.log") if File.exist?("/tmp/grid.log")
  File.delete("/tmp/clock.log") if File.exist?("/tmp/clock.log")
end
