class PrintLabelJob < ApplicationJob
  queue_as :default

  def perform(*args)
    qr   = args[0]
    opts = args[1]

    qr.create_img

    result = Label::create(
      qr_path:  qr.path, 
      style:    qr.style, 
      size:     qr.size,
      color:    qr.color)
    
    if result.ok
      pdf_path = File.join(Label::labels_path, result.pdf_path)
      printer = opts[:printer_name] || select_printer
      # Para ver mas opciones sobre el comando print:
      # https://www.cups.org/doc/options.html
      if printer
        `lp -d #{printer} -o media=Custom.108x72 #{pdf_path}`
      else
        `lp -o media=Custom.108x72 #{pdf_path}`
      end
      puts "ERROR: #{$?.exitstatus}" unless $?.success?
    else
      puts "ERROR creating label for QR ##{qr.id}."
      puts "QR's path ##{qr.path}."
      result.errors.each { |e| puts e }
    end
  end

  def select_printer
    ENV["PRINTER"]
  end

end
