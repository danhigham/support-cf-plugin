require "support-cf-plugin"

module SupportCfPlugin

  class Plugin < CF::CLI

    def precondition
      # skip all default preconditions
    end

    desc "Send an applications logs to Pivotal.IO Support"
    group :admin
    input :app, :desc => "Application the logs belong to", :argument => true,
          :from_given => by_name(:app)
    input :instance, :desc => "Instance of application to get the logs of",
          :default => "0"
    def send_logs

      app = input[:app]

      instances =
        if input[:all] || input[:instance] == "all"
          app.instances
        else
          app.instances.select { |i| i.id == input[:instance] }
        end

      if instances.empty?
        if input[:all]
          fail "No instances found."
        else
          fail "Instance #{app.name} \##{input[:instance]} not found."
        end
      end

      instances.each do |i|
        send_instance_logs app, i
      end

    end

    private

    def send_instance_logs(app, i)

      return unless i.id

      logs =
        with_progress(
            "Getting logs for #{c(app.name, :name)} " +
              c("\##{i.id}", :instance)) do
          i.files("logs")
        end

      line unless quiet?

      spaced(logs) do |log|
        begin
          body =
            with_progress("Reading " + b(log.join("/"))) do |s|
              i.file(*log)
            end

          post_to_support_bucket(app, log, body)

        rescue CFoundry::NotFound
        end
      end
    end

    def post_to_support_bucket(app, log, body)
      log_name = log.last

      headers = { 'content-type' => 'text/plain' }

      with_progress("Uploading #{b(log_name)}") do

        req, res =
        client.base.rest_client.request(
          'POST',
          "https://support-log-bucket.run.pivotal.io/#{app.name}/#{log.join("/")}",
          :headers => headers,
          :payload => body)
      end

    end

    def login_as_uaa_user(user, password)
      begin
        invoke :login, :username => user, :password => password
      rescue CF::UserFriendlyError, /There are no (organizations|spaces)/
      end
    end

  end
end