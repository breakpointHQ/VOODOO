lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'voodoo/browser'