require 'httparty'
require 'json'
require 'rqrcode'
require 'prawn'
require 'fileutils'
require 'optparse'
require_relative '../app/lib/qr.rb'
require_relative '../app/lib/label.rb'

class Tester
  include ::Qr
  include ::Label

  def initialize()
    root_path = ENV['PRINT_ROOT'] || "/Users/amiralles/dev/stash/5411-IM-API/services/tests"
    @qrs_path  = File.join(root_path, "qr")
    set_qr_root root_path
    set_lbl_root root_path
  end

  def create_label img_path, style, color, size
    Label::experimental_create(
      qr_path:  File.join(@qrs_path, img_path),
      style:    style, 
      size:     size,
      color:    color)
  end
end


options = {}
OptionParser.new do |opt|
  opt.on('--printer-name PRINTER') { |o| options[:printer] = o }
end.parse!


tester = Tester.new

label = tester.create_label "0000000317.png", "TEST", "L", "RED"

if ARGV[0] == "p" && label.ok
  puts "Printing..."
  label_path = File.join("tests", "labels", label.pdf_path)
  if options.key? :printer
    `./sumatra_pdf.exe -print-to-#{options[:printer]} #{label_path}`
  else
    `./sumatra_pdf.exe -print-to-default #{label_path}`
  end
end

puts label.ok
puts label.pdf_path
puts label.errors







