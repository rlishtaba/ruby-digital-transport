require 'spec_helper'

describe Digital::Transport do
  it 'should have :VERSION constant defined' do
    expect(described_class.constants.include?(:VERSION)).to be_truthy
  end

  it 'should have :Adapters constant defined' do
    expect(described_class.constants.include?(:Adapters)).to be_truthy
  end
end
