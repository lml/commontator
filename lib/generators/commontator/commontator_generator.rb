require 'rails/generators'
require 'rails/generators/migration'

class CommontatorGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/commontator.rb'
  end
end
