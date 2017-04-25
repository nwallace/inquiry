# Taken from https://gist.github.com/rsutphin/af06c9e3dadf658d2293
module ActiveRecord
  class QueryCounter
    attr_reader :query_count

    def initialize
      @query_count = 0
    end

    def to_proc
      lambda(&method(:callback))
    end

    def callback(name, start, finish, message_id, values)
      @query_count += 1 unless %w(CACHE SCHEMA).include?(values[:name])
    end
  end
end

RSpec::Matchers.define :exceed_query_limit do |expected|
  supports_block_expectations

  match do |block|
    query_count(&block) > expected
  end

  failure_message_when_negated do |actual|
    "Expected to run maximum #{expected} queries, got #{@counter.query_count}"
  end

  def query_count(&block)
    @counter = ActiveRecord::QueryCounter.new
    ActiveSupport::Notifications.subscribed(@counter.to_proc, "sql.active_record", &block)
    @counter.query_count
  end
end
