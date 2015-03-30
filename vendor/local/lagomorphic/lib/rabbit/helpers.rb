# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

class Rabbit::Helpers
  cattr_accessor :output_commands # whether to show the commands we're running on stdout
  self.output_commands = true

  class << self
    def check_system?
      brew? || rabbitmq_system_user_exists?
      # could also check for if rabbitmq_command_exists?, but stopped doing
      # that since it's in /usr/sbin/ on linux, which might not be in the path
      # for the current user
    end

    # accepts a configuration name or a Rabbit::Config instance.  nil => default_configuration.
    def setup!(config = nil)
      configurations = Rabbit::Config.get(config)
      configurations = {config => configurations} if configurations.is_a?(Rabbit::Config)

      configurations.each do |name, configuration|
        add_vhost!(configuration.vhost)
        add_user!(configuration.user, configuration.password)
        set_permissions(configuration.user, configuration.vhost)
      end
    end

    # man be careful, don't run this unless you're sure
    # accepts a configuration name or a Rabbit::Config instance.  nil => default_configuration.
    def remove_setup!(configuration = nil)
      configuration = Rabbit::Config.get(configuration)
      delete_vhost!(configuration.vhost)
      delete_user!(configuration.user)
    end

    def vhosts
      rabbitmqctl_execute("list_vhosts").split("\n")
    end

    def vhost_exists?(vhost_name)
      vhosts.include?(vhost_name.to_s)
    end

    def add_vhost!(vhost_name)
      if vhost_exists?(vhost_name)
        puts "vhost '#{vhost_name}' already exists"
        false
      else
        rabbitmqctl_execute(%Q[add_vhost "#{vhost_name}"])
        true
      end
    end

    def delete_vhost!(vhost_name)
      if !vhost_exists?(vhost_name)
        puts "vhost '#{vhost_name}' does not exist"
        false
      else
        rabbitmqctl_execute(%Q[delete_vhost "#{vhost_name}"])
        true
      end
    end

    def add_user!(user_name, password)
      if user_exists?(user_name)
        puts "user '#{user_name}' already exists"
        false
      else
        rabbitmqctl_execute(%Q[add_user "#{user_name}" "#{password}"])
        true
      end
    end

    def delete_user!(user_name)
      if !user_exists?(user_name)
        puts "user '#{user_name}' does not exist"
        false
      else
        rabbitmqctl_execute(%Q[delete_user "#{user_name}"])
        true
      end
    end

    def user_exists?(user_name)
      users.include?(user_name)
    end

    def users
      rabbitmqctl_execute("list_users").split("\n").map {|line| line.split("\t").first }
    end

    def set_permissions(user, vhost, configuration = ".*", write = ".*", read = ".*")
      rabbitmqctl_execute(%Q[set_permissions -p "#{vhost}" "#{user}" "#{configuration}" "#{write}" "#{read}"])
      true
    end

    def list_permissions(vhost)
      rabbitmqctl_execute(%Q[list_permissions -p "#{vhost}"])
    end

    def queues(configuration = nil)
      vhost = Rabbit::Config.get(configuration).vhost
      rabbitmqctl_execute(%Q[list_queues -p #{vhost} name]).split("\n")
    end

    def exchanges(configuration = nil)
      vhost = Rabbit::Config.get(configuration).vhost
      rabbitmqctl_execute(%Q[list_exchanges -p #{vhost} name]).split("\n")
    end

    def bindings(configuration = nil)
      vhost = Rabbit::Config.get(configuration).vhost
      rabbitmqctl_execute(%Q[list_bindings -p #{vhost} destination_name]).split("\n")
    end

    # for why we sometime don't use the exchange see:
    # http://rajith.2rlabs.com/2007/10/13/amqp-in-10-mins-part4-standard-exchange-types-and-supporting-common-messaging-use-cases/
    def message_in_queue?(message, queue, exchange = nil, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |b|
        bqueue = b.queue(queue, :passive => true)
        if exchange
          bexchange = b.exchange(exchange, :passive => true)
          bqueue.bind(exchange)
        end
        messages = []
        while (mess = bqueue.pop[:payload] and mess != :queue_empty) do
          messages << mess
        end
        messages.include?(message)
      end
    end

    def test_connection(configuration = nil)
      Rabbit.connection_class.get(configuration).establish_connection
    end

    # limited usage. but nice for tests.
    def publish_message(message, queue, exchange = nil, configuration = nil, opts = {})
      exchange_options = {:type => :fanout, :durable => true, :auto_delete => false}.merge(opts)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        if exchange
          bexchange = bunny.exchange(exchange, exchange_options)
          bexchange.publish(message, opts)
        else
          bqueue = bunny.queue(queue)
          # create a direct exchange and publish with a :key of the queue name
          bunny.exchange('').publish(message, {:key => bqueue.name}.merge(opts))
          #bqueue.publish(message, opts)
        end
      end
    end

    def status_for_queue(queue_name, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        queue = bunny.queue(queue_name, :passive => true)
        queue.status
      end
    end

    def message_count(queue_name, configuration = nil)
      status_for_queue(queue_name, configuration).if_hot {|status| status[:message_count]}
    end

    def consumer_count(queue_name, configuration = nil)
      status_for_queue(queue_name, configuration).if_hot {|status| status[:consumer_count]}
    end

    def purge_queue(queue_name, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        queue = bunny.queue(queue_name, :passive => true)
        queue.purge
      end
    end

    def delete_queue(queue_name, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        queue = bunny.queue(queue_name, :passive => true)
        queue.delete
      end
    end

    def create_exchange(exchange_name, configuration = nil, opts = {})
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        exch = bunny.exchange(exchange_name, opts)
      end
    end

    # we assume the exchange is created
    def create_queue(queue_name, exchange_name, configuration = nil, opts = {}, bind_opts = {})
      opts = {:durable => false, :auto_delete => false}.merge(opts)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        exch = bunny.exchange(exchange_name, :passive => true)
        queue = bunny.queue(queue_name, opts)
        queue.bind(exch, bind_opts)
      end
    end

    def unbind_queue_from_exchange_with_binding_key(queue_name, exchange_name, binding_key, configuration = nil)
      raise ArgumentError.new("Must specify binding key") if binding_key.nil?

      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        exchange = bunny.exchange(exchange_name, :passive => true)
        queue = bunny.queue(queue_name, :passive => true)
        queue.unbind(exchange, :key => binding_key)
      end
    end 

    def delete_exchange(exchange_name, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        exchange = bunny.exchange(exchange_name, :passive => true)
        exchange.delete
      end
    end

    def unbind_queue_from_exchange_with_key(queue_name, exchange_name, binding_key, configuration = nil)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        exchange = bunny.exchange(exchange_name, :passive => true)
        queue = bunny.queue(queue_name, :passive => true)
        queue.unbind(exchange, binding_key)
      end
    end

    # ack_manually => true means that you, dear user, intend to ack this message yourself. Since
    # this is a helper method meant to check the top message of a queue for testing purposes,
    # we default it to true. Use caution in changing it because if this method is used in
    # a production environment to peep on a queue and you set ack_manually = false, the
    # message WILL BE REMOVED FROM THE QUEUE FOR GOOD.
    #
    # returns: a hash with :header and :payload keys
    def get_first_message(queue, configuration = nil, ack_manually = true)
      Rabbit.connection_class.get(configuration).with_bunny_connection do |bunny|
        bunny.queue(queue, :passive => true).pop(:ack => ack_manually)
      end
    end
    alias_method :pop, :get_first_message

    def empty_queue_into_other_queue(queue1, queue2, config1 = nil, config2 = nil, opts1 = {}, opts2 = {}, copy_reply_to = false, timeout = Rabbit::Connection::DEFAULT_MAXIMUM_RABBIT_OPERATION_TIMEOUT)
      count = 0
      Rabbit.connection_class.get(config1).with_bunny_connection(:operation_timeout => timeout) do |bunny1|
        q1 = bunny1.queue(queue1, {:passive => true}.merge(opts1))

        bunny2 = Rabbit.connection_class.get(config2).connection
        q2 = bunny2.queue(queue2, {:passive => true}.merge(opts2))
        while (message = q1.pop and message[:payload] != :queue_empty) do
          if copy_reply_to
            # create a direct exchange and publish with a :key of the queue name
            bunny2.exchange('').publish(message[:payload], :key => q2.name, :reply_to => message[:header].properties[:reply_to])
          else
            bunny2.exchange('').publish(message[:payload], :key => q2.name)
          end
          count += 1
        end
      end
      count
    end

  private
  
    def brew?
      File.directory?('/usr/local/Cellar/rabbitmq')
    end

    def rabbitmqctl_execute(command)
      puts "Whoa, it looks like you're not set up to run rabbitmqctl.  https://trac.lan.flt/swdev/wiki/Rails/SettingUpRailsOnMacOSX#InstallingRabbitMQ" unless check_system?

      shell_command = if brew?
        %Q[#{rabbitmqctl_executable} -q #{command}]
      else
       %Q[sudo -E -u #{rabbitmq_system_user} -H /bin/sh -c '#{rabbitmqctl_executable} -q #{command}']
      end  
      
      puts "Executing: #{shell_command}" if output_commands
      output = `#{shell_command}`
      if $?.exitstatus != 0
        raise RuntimeError, "Command '#{shell_command}' failed."
      end
      output
    end

    def rabbitmqctl_executable
      'rabbitmqctl'
    end

    def rabbitmq_system_user
      'rabbitmq'
    end

    def rabbitmqctl_command_exists?
      unless defined?(@rabbitmqctl_command_exists)
        `which #{rabbitmqctl_executable}`
        @rabbitmq_command_exists = ($?.exitstatus == 0)
      end
      @rabbitmq_command_exists
    end

    def rabbitmq_system_user_exists?
      unless defined?(@rabbitmq_system_user_exists)
        `id #{rabbitmq_system_user}`
        @rabbitmq_system_user_exists = ($?.exitstatus == 0)
      end
      @rabbitmq_system_user_exists
    end
  end
end
