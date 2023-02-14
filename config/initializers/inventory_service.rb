# frozen_string_literal: true

# Stablish the connection with the Inventory WS
module InventoryService
  def self.connect
    ws_host = ENV['INVENTORY_WS_HOST']

    websocket_block = proc do
      ws = Faye::WebSocket::Client.new(ws_host)

      ws.on :message do |event|
        parsed_event = JSON.parse(event.data)
        InventoryUpdateJob.perform_later(parsed_event)
      end
    end

    Thread.new { EM.run { websocket_block.call } }

    die_gracefully_on_signal
  end

  def self.die_gracefully_on_signal
    Signal.trap('INT')  { EM.stop }
    Signal.trap('TERM') { EM.stop }
  end
end

InventoryService.connect
