require "arroyo/buckets"
require "arroyo/configuration"
require "arroyo/endpoint"
require "arroyo/service"
require "arroyo/session"

require "concurrent/executors"

module Arroyo
  class Client
    def initialize(**options)
      @configuration = Configuration.new(**options)
    end

    def buckets
      Buckets.new self
    end


    # Internal
    def service_for(bucket:)
      Service.new session: session_for(bucket: bucket), executor: executor
    end

    private
      attr_reader :configuration
      delegate :credentials, :region, to: :configuration

      def session_for(bucket:)
        Session.new credentials: credentials, region: region, endpoint: endpoint_for(bucket: bucket)
      end

      def endpoint_for(bucket:)
        Endpoint.new scheme: configuration.scheme, host: "#{bucket}.#{configuration.host}"
      end


      def executor
        @executor ||= Concurrent::ThreadPoolExecutor.new \
          min_threads: configuration.min_thread_count,
          max_threads: configuration.max_thread_count,
          idletime:    configuration.thread_idle_timeout,
          max_queue:   0
      end
  end
end
