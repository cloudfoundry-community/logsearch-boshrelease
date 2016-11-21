require 'logstash/devutils/rspec/spec_helper'
require 'test/templates_test_helpers'

def verify_input_and_output(actual, expected)
  pipelineActual = LogStash::Pipeline.new(File.read(File.join('test/logstash-templates/target', actual)))
  pipelineExpected = LogStash::Pipeline.new(File.read(File.join('test/logstash-templates/input_and_output', expected)))

  verify_collection("input", pipelineExpected.inputs, pipelineActual.inputs, "config")
  verify_collection("output", pipelineExpected.outputs, pipelineActual.outputs, "config")
end

describe 'Parser input_and_output.conf' do

  context "default" do
    verify_input_and_output('input_and_output-default.conf', 'test_default-expected.conf')
  end

  context "enabled debug" do
    verify_input_and_output('input_and_output-enabled_debug.conf', 'test_enabled_debug-expected.conf')
  end

end
