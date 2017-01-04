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
    verify_input_and_output('input_and_output-test_default.conf', 'test_default-expected.conf')
  end

  context "enabled debug" do
    verify_input_and_output('input_and_output-test_enabled_debug.conf', 'test_enabled_debug-expected.conf')
  end

  context "inputs" do
    verify_input_and_output('input_and_output-test_inputs.conf', 'test_inputs-expected.conf')
  end

  context "inputs - no redis" do
    verify_input_and_output('input_and_output-test_inputs_no_redis.conf', 'test_inputs_no_redis-expected.conf')
  end

  context "outputs" do
    verify_input_and_output('input_and_output-test_outputs.conf', 'test_outputs-expected.conf')
  end

  context "outputs - no elasticsearch" do
    verify_input_and_output('input_and_output-test_outputs_no_elasticsearch.conf', 'test_outputs_no_elasticsearch-expected.conf')
  end

  context "outputs - elasticsearch all properties" do
    verify_input_and_output('input_and_output-test_outputs_elasticsearch_all_properties.conf', 'test_outputs_elasticsearch_all_properties-expected.conf')
  end

 context "outputs - elasticsearch required properties" do
    verify_input_and_output('input_and_output-test_outputs_elasticsearch_required_properties.conf', 'test_outputs_elasticsearch_required_properties-expected.conf')
  end

end
