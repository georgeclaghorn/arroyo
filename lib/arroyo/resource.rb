require "nokogiri"

module Arroyo
  class Resource
    attr_reader :response
    delegate :status, :mime_type, to: :response

    def initialize(response)
      @response = response
    end

    def body
      @body ||= Nokogiri::XML.parse(response.body)
    end

    def find(query)
      body.at(query)
    end


    def etag
      response.headers["ETag"]
    end
  end
end
