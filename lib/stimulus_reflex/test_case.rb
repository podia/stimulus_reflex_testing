require "active_support"
require "active_support/test_case"

class StimulusReflex::TestCase < ActiveSupport::TestCase
  class TestChannel < ActionCable::Channel::TestCase
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

    def build_reflex(opts = {}, stimulus_reflex_version = StimulusReflex::VERSION)
      channel = opts.fetch(:channel, TestChannel.new(opts.fetch(:connection, {})))
      element = opts.fetch(:element, StimulusReflex::Element.new)
      version = stimulus_reflex_version

      args_350_pre8 = { element: element, url: opts.fetch(:url, ""), method_name: method_name_from_opts(opts),
                        params: opts.fetch(:params, {}), client_attributes: {} }
      args_350_pre9 = { **args_350_pre8, client_attributes: { version: version } }

      if Gem::Version.new(version) > Gem::Version.new('3.5.0pre8')
        self.class.reflex_class.new(channel, args_350_pre9)
      else
        self.class.reflex_class.new(channel, args_350_pre8)
      end
    end

    private

    def method_name_from_opts(opts)
      opts.dig(:method_name).to_s.presence
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
