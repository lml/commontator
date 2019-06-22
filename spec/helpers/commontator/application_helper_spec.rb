require 'rails_helper'

RSpec.describe Commontator::ApplicationHelper, type: :helper do
  it 'prints output of javascript proc' do
    expect(javascript_proc).to eq '// Some javascript'
  end
end
