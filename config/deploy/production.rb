set :user, "albert"
set :rails_env, "production"
server "localhost", :roles => %w(web app db), :primary => true, :user => "erik"

set :linked_files, fetch(:linked_files, []).push(".env.production")
