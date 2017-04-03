# encoding: utf-8
require 'spec_helper'

def future_timestamp
 LogStash::Timestamp.new(Time.parse("2515-12-22T11:00:00.000Z")) # 500 years in the future
end
def past_timestamp
 LogStash::Timestamp.new(Time.parse("1871-10-18T15:00:00.000Z")) # A significant date from the distant past
end

describe "Rules sanitising @timestamp" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read('src/logstash-filters/timecop.conf')}
      }
    CONFIG
    ENV['TIMECOP_REJECT_LESS_THAN_HOURS'] = '1'
  end

  context 'when parsing messages from the future' do

    when_parsing_log(
      '@timestamp' => future_timestamp,
      '@raw' => "#{future_timestamp} Hello from the future!",
      "@source" => {"host" => "source"},
      "@shipper" => {"host" => "shipper"},
      'extracted_field' => 'value',
      'tags' => ['sometag']
    ) do

      it "adds a timecop triggered tag" do
        expect(parsed_result.get('tags')).to include("fail/timecop")
      end

      it "retains the original tags" do
        expect(parsed_result.get("tags")).to include "sometag"
      end

      it "retains the source informaiton" do
        expect(parsed_result.get("@source")).to eq({"host" => "source"})
      end

      it "retains the shipper informaiton" do
        expect(parsed_result.get("@shipper")).to eq({"host" => "shipper"})
      end

      it "moves the invalid timestamp into invalid_fields.@timestamp" do
        expect(parsed_result.get('invalid_fields')['@timestamp']).to eq future_timestamp
      end

      it "resets the @timestamp to the current time" do
        expect(parsed_result.get('@timestamp')).to be_within(60).of Time.now
      end

      it "removes all the extracted fields leaving just @raw" do
        expect(parsed_result.get('@raw')).to eq("#{future_timestamp} Hello from the future!")
        expect(parsed_result.get('extracted_field')).to be_nil
      end

    end
  end

  context 'when parsing messages from the distant past' do

    when_parsing_log(
      '@timestamp' => past_timestamp,
      '@raw' => "#{past_timestamp} Hello from the past!",
      "@source" => {"host" => "source"},
      "@shipper" => {"host" => "shipper"},
      'extracted_field' => 'value',
      'tags' => ['sometag']
    ) do

      it "adds a timecop triggered tag" do
        expect(parsed_result.get('tags')).to include("fail/timecop")
      end

      it "retains the original tags" do
        expect(parsed_result.get("tags")).to include "sometag"
      end

      it "retains the source informaiton" do
        expect(parsed_result.get("@source")).to eq({"host" => "source"})
      end

      it "retains the shipper informaiton" do
        expect(parsed_result.get("@shipper")).to eq({"host" => "shipper"})
      end

      it "moves the invalid timestamp into invalid_fields.@timestamp" do
        expect(parsed_result.get('invalid_fields')['@timestamp']).to eq past_timestamp
      end

      it "resets the @timestamp to the current time" do
        expect(parsed_result.get('@timestamp')).to be_within(60).of Time.now
      end

      it "removes all the extracted fields leaving just @raw" do
        expect(parsed_result.get('@raw')).to eq("#{past_timestamp} Hello from the past!")
        expect(parsed_result.get('extracted_field')).to be_nil
      end

    end
  end

end
