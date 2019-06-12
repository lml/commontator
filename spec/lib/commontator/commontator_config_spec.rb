require 'rails_helper'

RSpec.describe Commontator::CommontatorConfig, type: :lib do
  it 'must respond to commontator attributes' do
    config = described_class.new
    Commontator::Config::COMMONTATOR_ATTRIBUTES.each do |attribute|
      expect(config).to respond_to(attribute)
    end
  end

  it "won't respond to engine or commontable attributes" do
    config = described_class.new
    (
      Commontator::Config::ENGINE_ATTRIBUTES + Commontator::Config::COMMONTABLE_ATTRIBUTES
    ).each do |attribute|
      expect(config).not_to respond_to(attribute)
    end
  end

  it 'must be configurable' do
    proc = ->(user) { 'Some name' }
    proc2 = ->(user) { 'Another name' }
    config = described_class.new(user_name_proc: proc)
    expect(config.user_name_proc).to eq proc
    config = described_class.new(user_name_proc: proc2)
    expect(config.user_name_proc).to eq proc2
  end
end
