module SizeNameValidator
  def valid_size_name?(name)
    str_name = name.to_s
    is_number?(str_name)           ||
    valid_us_size_name?(str_name)  ||
    valid_au_size_name?(str_name)  ||
    valid_std_size_name?(str_name) ||
    valid_beaumont_size?(str_name) ||
    valid_shoe_size?(str_name)     ||
    valid_tu_name?(str_name)       ||
    valid_only_size_name?(str_name)
  end

  def valid_only_size_name?(name)
    !!(/^OS$/i =~ name)
  end

  def valid_shoe_size?(name)
    /^(\d(.\d)?)+$/ =~ name
  end

  def valid_beaumont_size?(name)
    !!(/^XS\/34$|^S\/36$|^M\/38$|^L\/40$|^XS\/S$|^S\/M$|^M\/L$/ =~ name)
  end

  def is_number?(name)
    !!(/^[\+\-]?\d+(\.\d*)?$/ =~ name)
  end

  def valid_std_size_name?(name)
    !!(/^XXS$|^XS$|^S$|^M$|^L$|^XL$|^XXL$/i =~ name)
  end

  def valid_us_size_name?(name)
    !!(/US[0-9]([0-9])?/i =~ name)
  end

  def valid_au_size_name?(name)
    !!(/AU[0-9]([0-9])?/i =~ name)
  end

  def valid_tu_name?(name)
    !!(/TU|T:U/i =~ name)
  end
end
