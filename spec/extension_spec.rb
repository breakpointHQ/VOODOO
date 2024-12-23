require 'voodoo'

describe 'VOODOO Extension' do 
    browser = VOODOO::Browser.Chrome

    it 'should correctly save and delete the extension' do
        extension = browser.extension
        extension.add_service_worker content: 'console.log(123)'
        extension.save
        
        js_file_path = File.join(extension.folder, '1.js')
        manifest_file_path = File.join(extension.folder, 'manifest.json')

        expect(File.exist? js_file_path).to be_truthy
        expect(File.exist? manifest_file_path).to be_truthy

        extension.unlink

        expect(File.exist? js_file_path).to be_falsey
        expect(File.exist? manifest_file_path).to be_falsey
    end
end