require 'rufus-scheduler'

s = Rufus::Scheduler.new

s.cron '0 2 * * *' do
  Export.begin
end

#s.join
