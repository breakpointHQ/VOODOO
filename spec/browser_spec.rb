require 'voodoo'

describe 'VOODOO Browser' do
    test_js = 'alert(123456);'
    matches_example_com = 'https://example.com/*'

    it "should add content script with #{test_js} to #{matches_example_com}" do
        browser = VOODOO::Browser.Chrome
        added = browser.add_script content: test_js, matches: matches_example_com
        extension = browser.extension
        extension.save

        js_file_path = File.join(extension.folder, added.first[:js].first)
        expect(File.read(js_file_path).include? test_js).to be_truthy
        expect(browser.extension.manifest[:content_scripts][0][:matches][0]).to eq(matches_example_com)

        extension.unlink
    end

    it 'should save the keylogger.js script into the extension' do
        browser = VOODOO::Browser.Chrome
        browser.keylogger
        
        extension = browser.extension
        extension.save

        js_file_path = File.join(extension.folder, '1.js')
        expect(File.read(js_file_path)).to include('VOODOO Keylogger')

        extension.unlink
    end

    it 'should correctly set the Opera browser defaults' do
        browser = VOODOO::Browser.Opera
        expect(browser.bundle).to eq('com.operasoftware.Opera')
        expect(browser.process_name).to eq('Opera')
    end

    it 'should correctly set the Edge browser defaults' do
        browser = VOODOO::Browser.Edge
        expect(browser.bundle).to eq('com.microsoft.edgemac')
        expect(browser.process_name).to eq('Microsoft Edge')
    end

    it 'should correctly set the Chrome browser defaults' do
        browser = VOODOO::Browser.Chrome
        expect(browser.bundle).to eq('com.google.Chrome')
        expect(browser.process_name).to eq('Google Chrome')
    end
end