require 'thread'

class Factory
  def initialize data
    @data = data # Hash { key: row }
    @senders_pool = Thread.pool Cleaner.config[:workers][:count]
    @listeners_pool = Thread.pool Cleaner.config[:workers][:count]
  end

  def launch
    @data.each do |key, row|
      row_info = analyze row
      @senders_pool.process(row_info) { |arg| spawn_sender(arg) }
      @listeners_pool.process(row_info) { |arg| spawn_listener(arg) } if row_info[:service] == :apns
    end
  end

  private

  def analyze row
    # stub
    { service: :gcm }
  end

  def spawn_sender row_info
    Sender.new(row_info).send_notification
  end

  def spawn_listener row_info
    Listener.new(row_info).launch
  end
end
