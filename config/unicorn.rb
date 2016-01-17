# -*- coding: utf-8 -*-
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true  # 更新時ダウンタイム無し

listen "/share/unicorn.sock", backlog: 1024
# listen 3000, tcp_nopush: true

pid "/tmp/unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end

# ログの出力
# TODO docker のログがわかるようにファイルと標準出力両方に出す
# stderr_path File.expand_path('../../log/unicorn.stderr.log', __FILE__)
# stdout_path File.expand_path('../../log/unicorn.stdout.log', __FILE__)