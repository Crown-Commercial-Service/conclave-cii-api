require 'rufus-scheduler'

s = Rufus::Scheduler.new

s.cron '0 2 * * *' do
  puts 
  Export.begin
end

#s.join
