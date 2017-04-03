# encoding: utf-8

require 'spec_helper'


describe 'Metric filters' do

  before(:all) do
    load_filters <<-CONFIG
      filter {
    #{File.read('target/logstash-filters-default.conf')}
    #{File.read('target/logstash-filters-monitor.conf')}
      }
    CONFIG
  end

  describe 'when parsing metrics from logsearch components' do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => ' <13>1 2016-01-04T12:03:31.236204+00:00 4fe781f0-30ed-4961-9aca-3efb9d73121a - - - [NXLOG@14506 bosh_director="default" bosh_deployment="logsearch" bosh_job="queue/0" bosh_template="logsearch-shipper" type="metric"] logstash.queue_size 100 1451909010'
    ) do

      it 'applies the metric parsers successfully' do
        expect(parsed_result.get('tags')).to include 'metric'
      end

      it 'extracts the metric @timestamp' do
        expect(parsed_result.get('@timestamp').time).to eq(Time.at(1451909010))
        expect(parsed_result.get('metric')['timestamp']).to be_nil
      end

      it 'extracts the metric name' do
        expect(parsed_result.get('metric')['name']).to eq 'logstash.queue_size'
      end

      it 'extracts the metric value' do
        expect(parsed_result.get('metric')['value']).to eq 100.0
      end
    end
  end

  context "when parsing metrics from unknown vms" do
    when_parsing_log(
      "@type" => "syslog",
      "@source" => {"job" => "landing_computer"},
      "@message" => ' <13>1 2016-01-04T12:03:31.236204+00:00 4fe781f0-30ed-4961-9aca-3efb9d73121a - - - [NXLOG@14506 bosh_director="default" bosh_deployment="logsearch" bosh_job="queue/0" bosh_template="logsearch-shipper" type="metric"] logstash.queue_size 100 1451909010'
    ) do

      it "drops the message" do
        expect(parsed_result).to be_cancelled
      end
    end
  end

  when_parsing_log(
    "@type" => "syslog",
    "@message" => ' <13>1 2016-01-04T12:03:31.236204+00:00 4fe781f0-30ed-4961-9aca-3efb9d73121a - - - [NXLOG@14506 type="metric"] INVALID 1451909010'
  ) do

    it "applies the fail/metric tags for invalid logs" do
      expect(parsed_result.get('tags')).to include 'fail/metric'
    end
  end

  context "when parsing messages from the router" do
    when_parsing_log(
      '@type' => "syslog",
      '@message' => "<46>Dec 16 15:24:05 ls-router[9252]: 52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 SC 8/8/8/0/3 0/0",
    ) do

      it "applies the haproxy parsers successfully" do
        expect(parsed_result.get('tags')).to include("haproxy")
      end
    end
  end
end
