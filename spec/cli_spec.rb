require 'voodoo/CLI'

describe 'VOODOO CLI' do
    it 'should list the voodoo commands' do
        expect { VOODOO::CLI.start([]) }.to output(
            a_string_including("Commands:")
          ).to_stdout
    end
    it 'should return the help screen for the script command' do
        expect { VOODOO::CLI.start(['help', 'script']) }.to output(
            a_string_including("script <js/path>")
          ).to_stdout
    end

    if File.exist? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        it 'Google Chrome is installed' do
            expect(1).to eq(1)
        end

        it 'keylogger should collect the example.com title' do
            expect { VOODOO::CLI.start('keylogger -b chrome -x https://example.com https://example.com/onemore --max-events 1'.split(' ')) }.to output(
                a_string_including('Example Domain')
            ).to_stdout
        end

        it 'execute the script command and collect h1 text from example.com' do
            expect { VOODOO::CLI.start('script V.send(document.querySelector("h1").innerText) -f payload -m https://example.com/* -b chrome -x https://example.com https://example.com/123 --max-events 1'.split(' ')) }.to output(
                a_string_including('Example Domain')
            ).to_stdout
        end

        it 'execute the script command with custom parameters' do
            expect { VOODOO::CLI.start('script V.send("%{custom}") -f payload -m https://example.com/* -p custom:a-custom-value -b chrome -x https://example.com https://example.com/123 --max-events 1'.split(' ')) }.to output(
                a_string_including('a-custom-value')
            ).to_stdout
        end

        it 'execute the template command and detect tabs updates' do
            expect { VOODOO::CLI.start('template ./templates/tabs-spy.yaml -f payload -x https://example.net https://example.com/onemore --max-events 3'.split(' ')) }.to output(
                a_string_including('{"status":"loading",')
            ).to_stdout
        end
    end
end