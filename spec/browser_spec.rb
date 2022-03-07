require 'voodoo'

describe 'VOODOO Browser' do
    matches_example_com = 'https://example.com/*'
    it "should add content script with alert(1) to #{matches_example_com}" do
        browser = VOODOO::Browser.Chrome
        browser.add_script 'alert(1)', matches: matches_example_com
        extension = browser.extension
        extension.save

        js_file_path = File.join(extension.folder, '1.js')
        expect(File.read(js_file_path)).to eq('alert(1)')
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
        expect(extension.manifest[:background][:scripts].length).to eq(0)
        expect(extension.manifest[:content_scripts].length).to eq(1)

        extension.unlink
    end

    it 'should save the intercept.js script into the extension' do
        browser = VOODOO::Browser.Chrome
        browser.intercept
        
        extension = browser.extension
        extension.save

        js_file_path = File.join(extension.folder, '1.js')      
        expect(File.read(js_file_path)).to include('VOODOO Intercept')
        expect(extension.manifest[:background][:scripts].length).to eq(1)
        expect(extension.manifest[:content_scripts].length).to eq(0)

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