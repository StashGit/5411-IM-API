module SizeNameValidator
  def valid_size_name?(name)
    is_number?(name)          ||
    valid_us_size_name?(name) ||
    valid_au_size_name?(name) ||
    valid_std_size_name?(name)
  end

  def is_number?(name)
    !!(/^(\d)+$/ =~ name)
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
end
