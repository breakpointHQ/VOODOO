require 'voodoo'

describe 'VOODOO Extension' do 
    browser = VOODOO::Browser.Chrome
    it 'should correctly add a background script' do
        extension = browser.extension
        extension.add_background_script 'alert(1)'
        expect(extension.manifest[:background][:scripts][0]).to eq('1.js')
    end

    it 'should correctly save and delete the extension' do
        extension = browser.extension
        extension.add_background_script 'alert(1)'
        extension.save
        
        js_file_path = File.join(extension.folder, '1.js')
        manifest_file_path = File.join(extension.folder, 'manifest.json')

        expect(File.exists? js_file_path).to be_truthy
        expect(File.exists? manifest_file_path).to be_truthy

        extension.unlink

        expect(File.exists? js_file_path).to be_falsey
        expect(File.exists? manifest_file_path).to be_falsey
    end
end