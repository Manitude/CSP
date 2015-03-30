#!/usr/bin/env ruby -w
$:.unshift(File.dirname(__FILE__) + '/lib/')
require 'ldap/server'
require 'thread'

module RosettaStone

  VALID_LDAP_RECORDS = { 'ggironda' => 'ldappass',
              'mpatton'  => 'test',
              'ops'      => 'test',
              'teacher'  => 'test',
              'teacherops'  => 'test',
              'testuser' => 'P2ssw0rd' }

  module MockLDAP
    BASEDN = "dc=trstone,dc=com"
    LDAP_PORT = 1389

    class HashOperation < LDAP::Server::Operation
      # Handle searches of the form "(uid=<foo>)"
      def search(basedn, scope, deref, filter)
        raise LDAP::ResultError::UnwillingToPerform, "Bad base DN" unless basedn == BASEDN
        raise LDAP::ResultError::UnwillingToPerform, "Bad filter" unless filter[0..1] == [:eq, "uid"]
        uid = filter[3]
        send_SearchResultEntry("uid=#{uid},#{BASEDN}", {"maildir"=>["/netapp/#{uid}/"]}) if VALID_LDAP_RECORDS[uid]
      end

      # Validate passwords
      def simple_bind(version, dn, password)
        return if dn.nil?

        raise LDAP::ResultError::UnwillingToPerform unless dn =~ /\Auid=(.*?),#{BASEDN}\z/
        login_id = $1

        pw = VALID_LDAP_RECORDS[login_id]
        raise LDAP::ResultError::InvalidCredentials unless pw && pw == password
      end
    end

    def self.start(options = {})
      options[:port] ||= LDAP_PORT
      @server = LDAP::Server.new(:port => options[:port], :nodelay => true, :listen => 10, :operation_class => HashOperation)
      @server.run_tcpserver
    end

    def self.stop
      @server.stop
    end

    def self.join
      @server.join
    end
  end

  # FIXME - This is using most of the stuff from the MockLDAP module (mostly just search that's different). make this a class and have it inherit from that thing, which should also be a class.
  module MockAD
    include MockLDAP
    BASEDN = "dc=trstone,dc=com"
    LDAP_PORT = 1389

    class ADOperation < HashOperation
      def search(basedn, scope, deref, filter)
        raise LDAP::ResultError::UnwillingToPerform, "Bad base DN" unless basedn == BASEDN
        raise LDAP::ResultError::UnwillingToPerform, "Bad filter" unless filter[0..1] == [:eq, "uid"] || filter[0..1] == [:eq, "name"]
        # TODO - Fix the group search stuff here
        hot_dns = ["CN=@RS OLLC Editors,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local",
                  "CN=@RS Tracking Service Administrators,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local",
                  "CN=@TEST KBurnett Test1,OU=Test,DC=rosettastone,DC=local",
                  "CN=@TEST KBurnett Test2,OU=Test,DC=rosettastone,DC=local",
                  "CN=@RS OPXteam,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local",
                  "CN=@RS V3 Teams,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local",
                  "CN=@RS Dogwalk Team,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local",
                  "CN=@RS Viper Team,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local"]
        if filter[1] == 'name'
          group_name = filter[3]
          send_SearchResultEntry("uid=#{group_name},#{BASEDN}", {"maildir"=>["/netapp/#{group_name}/"], "distinguishedname" => hot_dns})
        else
          uid = filter[3]
          send_SearchResultEntry("uid=#{uid},#{BASEDN}", {"maildir"=>["/netapp/#{uid}/"], "memberof" => ["CN=~RS VPN Users,OU=Security Groups,DC=rosettastone,DC=local", "CN=@RS AppLauncher Editors,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local", "CN=@RS OLLC Editors,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local", "CN=@HBG Web Team,OU=Web Team,OU=Software Development,OU=Users,OU=Harrisonburg (HQ),OU=US,OU=Corporate,DC=rosettastone,DC=local", "CN=~HBG Project,OU=Security Groups,DC=rosettastone,DC=local", "CN=@RS Web Team,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local", "CN=@RS Website Rollout,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local", "CN=@RS OPX,OU=Trans Organizational Groups & Mail Users,DC=rosettastone,DC=local", "CN=@HBG Software Development,OU=Software Development,OU=Users,OU=Harrisonburg (HQ),OU=US,OU=Corporate,DC=rosettastone,DC=local"]}) if VALID_LDAP_RECORDS[uid]
        end
      end
    end

    def self.start(options = {})
      options[:port] ||= LDAP_PORT
      @server = LDAP::Server.new(:port => options[:port], :nodelay => true, :listen => 10, :operation_class => ADOperation)
      @server.run_tcpserver
    end

    def self.stop
      @server.stop
    end

    def self.join
      @server.join
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0] == 'ad'
    RosettaStone::MockAD.start
    RosettaStone::MockAD.join
  else
    RosettaStone::MockLDAP.start
    RosettaStone::MockLDAP.join
  end
end
