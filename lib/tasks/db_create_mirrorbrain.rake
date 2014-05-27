namespace :db do

  desc 'create mirrorbrain database'
  task 'create_mirrorbrain' => :environment do
    abcs = ActiveRecord::Base.configurations

    Mirror.connection.execute(<<-SQL)
      CREATE TABLE server (
          id integer NOT NULL,
          identifier character varying(64) NOT NULL,
          baseurl character varying(128) NOT NULL,
          baseurl_ftp character varying(128) NOT NULL,
          baseurl_rsync character varying(128) NOT NULL,
          enabled boolean NOT NULL,
          status_baseurl boolean NOT NULL,
          region character varying(2) NOT NULL,
          country character varying(2) NOT NULL,
          asn integer NOT NULL,
          prefix character varying(18) NOT NULL,
          score smallint NOT NULL,
          scan_fpm integer NOT NULL,
          last_scan timestamp with time zone,
          comment text NOT NULL,
          operator_name character varying(128) NOT NULL,
          operator_url character varying(128) NOT NULL,
          public_notes character varying(512) NOT NULL,
          admin character varying(128) NOT NULL,
          admin_email character varying(128) NOT NULL,
          lat numeric(6,3),
          lng numeric(6,3),
          country_only boolean NOT NULL,
          region_only boolean NOT NULL,
          as_only boolean NOT NULL,
          prefix_only boolean NOT NULL,
          other_countries character varying(512) NOT NULL,
          file_maxsize integer DEFAULT 0 NOT NULL
      );
    SQL
  end

end
