# frozen_string_literal: true

module Fulfil
  class InteractiveReport
    def initialize(client:, report:)
      @client = client
      @report = report
    end

    def execute(**params)
      body = {}

      params.each do |key, value|
        body[key] = if value.is_a?(Date)
                      serialize_date(value)
                    else
                      value
                    end
      end

      @client.interactive_report(
        endpoint: report_url,
        body: [body]
      )
    end

    private

    def report_url
      "#{@report}/execute"
    end

    def serialize_date(date)
      {
        __class__: 'date',
        year: date.year,
        month: date.month,
        day: date.day
      }
    end
  end
end
