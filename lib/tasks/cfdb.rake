namespace :cfdb do
  desc 'Erase all tables'
  task clear: :environment do
    delete_tables = ['organisation_scheme_identifiers', 'schema_migrations', 'scheme_registers']
    conn = ActiveRecord::Base.connection
    tables = conn.tables
    tables.each do |table|
      if delete_tables.include? table
        puts "Deleting #{table}"
        conn.drop_table(table)
      end
    end
  end
end
