module Fulfil
  class InteractiveReport
    def initialize(client:, report:)
      @client = client
      @report = report
    end

    def execute(start_date:, end_date:)
      @client.interactive_report(
        endpoint: report_url,
        body: [{
          start_date: serialize_date(start_date),
          end_date: serialize_date(end_date)
        }]
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