max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count


# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port 3000 

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }


workers ENV.fetch("WEB_CONCURRENCY") { 4 }

preload_app!


plugin :tmp_restart