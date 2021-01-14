require "active_support"
require "active_support/test_case"

class StimulusReflex::TestCase < ActiveSupport::TestCase
  class TestChannel < ActionCable::Channel::TestCase
    _channel_class = StimulusReflex::Channel

    delegate :env, to: :connection

    def initialize(connection_opts = {})
      super("StimulusReflex::Channel")
      @connection = stub_connection(connection_opts.merge(env: {}))
    end

    def stream_name
      ids = connection.identifiers.map { |identifier| connection.send(identifier).try(:id) || connection.send(identifier) }
      [
        "StimulusReflex::Channel",
        ids.select(&:present?).join(";")
      ].select(&:present?).join(":")
    end
  end

  module Behavior
    extend ActiveSupport::Concern

    module ClassMethods
      def reflex_class
      end
    end

    def build_reflex(opts = {})
      channel = opts.fetch(:channel, TestChannel.new(opts.fetch(:connection, {})))
      element = opts.fetch(:element, StimulusReflex::Element.new)

      self.class.reflex_class.new(
        channel, element: element, url: opts.dig(:url), method_name: opts.dig(:method_name), params: opts.fetch(:params, {})
      )
    end
  end

  include Behavior
rescue NameError => e
  if e.missing_name == "ActionCable::Channel::TestCase"
    raise "Please install action-cable-testing https://github.com/palkan/action-cable-testing"
  else
    raise
  end
end
