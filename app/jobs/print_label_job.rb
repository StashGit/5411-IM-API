class PrintLabelJob < ApplicationJob
  queue_as :default

  def perform(*args)
    qr = args[0]
    qr.create_img

    result = Label::create(
      qr_path:  qr.path, 
      style: qr.style, 
      size:  qr.size,
      color: qr.color)
    
    if result.ok
      pdf_path = File.join(Label::labels_path, result.pdf_path)
      puts "TODO: Send #{pdf_path} to the printer."
    else
      puts "ERROR creating label for QR ##{qr.id}."
      puts "QR's path ##{qr.path}."
      result.errors.each { |e| puts e }
    end
  end
end
