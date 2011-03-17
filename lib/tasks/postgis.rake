namespace :postgis do
  task :read_config do
    begin
      @postgis_config = YAML.load_file(Rails.root.to_s + "/config/postgis.yml")
    rescue => error
      puts "#{error.class} - #{error.message}"
      puts "Error during :read_config"
    end
  end

  desc 'Create Database and Initialize PostGIS'
  task :create => [:read_config, :environment, :"db:create"] do
    begin
      ### edit config/postgis.yml to specify postgis dir
      postgis_dir = @postgis_config['postgis_dir']
      config = ActiveRecord::Base.configurations[RAILS_ENV]
      #system("/usr/bin/env createdb -U #{config['username']} #{config['database']}")
      ActiveRecord::Base.establish_connection(config)
      begin
        ActiveRecord::Base.connection.execute("CREATE LANGUAGE plpgsql")
      rescue => error
        if !(error.class == ActiveRecord::StatementInvalid && error.message =~ /PGError: ERROR:  language \"plpgsql\" already exists/)
          raise error
        end
      end
      #system("/usr/bin/env createlang -U #{config['username']} plpgsql #{config['database']}")
      f = File.open("#{postgis_dir}/postgis.sql")
      #f = File.open("#{postgis_dir}/lwpostgis.sql")
      begin
        ActiveRecord::Base.connection.execute(f.read)
      rescue => error
        if !(error.class == ActiveRecord::StatementInvalid && error.message =~ /PGError: ERROR:  [^\s]+\s[^\s]+\salready exists/)
          raise error
        end
      end
      f.close
      #system("/usr/bin/env psql -U #{config['username']} -d #{config['database']} -f #{postgis_dir}/lwpostgis.sql")
      f = File.open("#{postgis_dir}/spatial_ref_sys.sql")
      begin
        ActiveRecord::Base.connection.execute(f.read)
      rescue => error
        if !(error.class == ActiveRecord::StatementInvalid && (error.message =~ /PGError: ERROR:  [^\s]+\s[^\s]+\salready exists/ || error.message =~ /PGError: ERROR:  current transaction is aborted, commands ignored until end of transaction block/))
          raise error
        end
      end
      f.close

      f = File.open("#{postgis_dir}/postgis_comments.sql")
      begin
        ActiveRecord::Base.connection.execute(f.read)
      rescue => error
        if !(error.class == ActiveRecord::StatementInvalid && (error.message =~ /PGError: ERROR:  [^\s]+\s[^\s]+\salready exists/ || error.message =~ /PGError: ERROR:  current transaction is aborted, commands ignored until end of transaction block/))
          raise error
        end
      end
      f.close

      f = File.open("#{Rails.root}/db/functions.sql")
      begin
        ActiveRecord::Base.connection.execute(f.read)
      rescue => error
        if !(error.class == ActiveRecord::StatementInvalid && (error.message =~ /PGError: ERROR:  [^\s]+\s[^\s]+\salready exists/ || error.message =~ /PGError: ERROR:  current transaction is aborted, commands ignored until end of transaction block/))
          raise error
        end
      end

      #vacuum = sql.match(/^(VACUUM.+;\n)/).to_a[1]
      #sql = sql.gsub(vacuum, '')
      #ActiveRecord::Base.connection.execute(vacuum)
      
      #system("/usr/bin/env psql -U #{config['username']} -d #{config['database']} -f #{postgis_dir}/spatial_ref_sys.sql")
      #f = File.open(RAILS_ROOT + "/db/")
      #f = File.open(RAILS_ROOT + "/db/functions.sql")
      #ActiveRecord::Base.connection.execute(f.read)
      #f.close
    rescue => error
      puts "#{error.class} - #{error.message}"
      puts "Error during initializing PostGIS database"
    end
  end
end
