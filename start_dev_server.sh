# export RAILS_ENV=staging
# export RAILS_ENV=production
# export RAILS_MASTER_KEY=$(cat config/credentials/${RAILS_ENV}.key)
# 要restart!

bundle check || bundle install &&
rm -f tmp/pids/server.pid &&
rails s -p 3000 -b '0.0.0.0'
