# encoding: utf-8
require 'test/filter_test_helpers'

describe "@source.deployment lookup" do

  before(:all) do
    # change path of the source.deployment translation table so it works in test
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/deployment.conf")}
      }
    CONFIG
  end

  context "when source is a logsearch job" do
    when_parsing_log(
      "@source" => { "job" => "kibana-123123123" }
    ) do

      it "adds the deployment tagger tag" do
        expect(subject["tags"]).to include "auto_deployment"
      end

      it "sets @source.deployment" do
        expect(subject["@source"]["deployment"]).to eq "logsearch"
      end
    end
  end

  context "when there is [@source][deployment] set" do
    when_parsing_log(
        "@source" => { "deployment" => "deployment123", 
                       "job" => "kibana-123123123" }
    ) do

      it "no deployment tag" do
        expect(subject["tags"]).to be_nil
      end

      it "keeps @source.deployment" do
        expect(subject["@source"]["deployment"]).to eq "deployment123"
      end
    end
  end
end
