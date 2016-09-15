require 'spec_helper'

class Foo < ActiveRecord::Base; end

describe Eyeballs do
  it 'has a version number' do
    expect(Eyeballs::VERSION).not_to be nil
  end

  describe '.eyeballs' do
    it 'returns an inspector' do
      expect(Foo.all.eyeballs).to be_a Eyeballs::Inspector
    end
  end

end
