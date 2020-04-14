require 'test_helper'

class QrcodeTest < ActiveSupport::TestCase
  test "mass prepare qr codes" do
    params = { qrs: [ { id: 1, copies: 1 }, {id: 2, copies: 6 } ] }
    codes = Qrcode.mass_prepare params
    
    assert_equal 2, codes.count
    assert_equal 1, codes.first[:copies]
    assert_equal 6, codes.second[:copies]
  end

  test "prints the right number of copies" do
    qr = Qrcode.new
    def qr.print(copies, opts)
    end
    qrcodes = [{ qr: qr, copies: 3 }, { qr: qr, copies: 4 }]
    Qrcode.print_all qrcodes
  end
end
