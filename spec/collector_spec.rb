require 'voodoo'
require 'net/http'

describe 'VOODOO Collector' do
    it 'should return 400 status code when token is missing' do
        collector = VOODOO::Collector.new
        collector.on_json {|_|}
        
        uri = URI("http://localhost:#{collector.port}/")
        res = Net::HTTP.get_response(uri)
        expect(res.code).to eq('400')
    end
    it 'should return 204 status code with token' do
        collector = VOODOO::Collector.new
        collector.on_json {|_|}
        
        uri = URI(collector.url)
        res = Net::HTTP.get_response(uri)
        expect(res.code).to eq('204')
    end
    it 'should return diff port for each instance' do
        ports = Set.new
        
        for i in 0...5
            collector = VOODOO::Collector.new
            collector.on_json {|_|}
            expect(ports.include? collector.port).to be_falsey
            ports.add collector.port
        end
    end
end