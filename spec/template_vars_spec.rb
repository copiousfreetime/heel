require 'spec_helper'
require 'pathname'

describe Heel::TemplateVars do
  before do
    @template = ERB.new( "<%= foo %> && <%= bar %>" )
  end

  it "exposes all its data members in a binding" do
    t = Heel::TemplateVars.new( :foo => 'foo', :bar => 'bar' )
    s = @template.result( t.binding_for_template )
    _(s).must_equal( "foo && bar")
  end

  it "data members may be added after instantiation" do
    t = Heel::TemplateVars.new
    t.foo = 'foo'
    t.bar = 'bar'
    s = @template.result( t.binding_for_template )
    _(s).must_equal( "foo && bar")
  end
end
