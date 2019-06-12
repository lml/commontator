require 'rails_helper'

RSpec.describe Commontator::CommontableConfig, type: :lib do
  it 'must respond to commontable attributes' do
    config = described_class.new
    Commontator::Config::COMMONTABLE_ATTRIBUTES.each do |attribute|
      expect(config).to respond_to(attribute)
    end
  end

  it "won't respond to engine or commontator attributes" do
    config = described_class.new
    (
      Commontator::Config::ENGINE_ATTRIBUTES + Commontator::Config::COMMONTATOR_ATTRIBUTES
    ).each do |attribute|
      expect(config).not_to respond_to(attribute)
    end
  end

  it 'must be configurable' do
    proc = ->(thread) { 'Some name' }
    proc2 = ->(thread) { 'Another name' }
    config = described_class.new(commontable_name_proc: proc)
    expect(config.commontable_name_proc).to eq proc
    config = described_class.new(commontable_name_proc: proc2)
    expect(config.commontable_name_proc).to eq proc2
  end
end
