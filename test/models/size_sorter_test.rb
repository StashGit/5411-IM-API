require 'test_helper'

class SizeNameValidatorTest < ActiveSupport::TestCase
  include SizeNameSorter

  test "can sort stock merged_sizes" do
    sorted_sizes = sort_by_size_order merged_sizes

    expected = [8, 8.5, 10, 10.5, 12]
    actual   = sorted_sizes.values.map {|value| value["size_order"] }

    assert expected == actual
  end

  test "can sort shoes sizes" do
    supported_sizes = [
      35, 35.5, 36, 36.5, 37, 37.5, 38, 38.5, 39,
      39.5, 40, 40.5, 41, 41.5, 42, 43, 44, 45, 46
    ]

    size_order = []
    supported_sizes.each do |size|
      size_order << size_order_for(size.to_s)
    end

    size_order.each do |size_order|
      assert size_order != -1
    end
  end

  private

  # Utilizamos este json porque es el payload de una llamada real donde se
  # producia el error al ordenar los talles.
  # Si no cambiamos el nombre del attributo **size_order** este payload deberia
  # seguir funcionando sin ningun problema.
  # TODO: Despues, con tiempo, podemos llegar a reemplazar este string + json parse
  #       por una instancia de la estructura que utilizamos para representar stock by brand.
  def merged_sizes
    merged_sizes_json =
      "{\"AU10 US6\":{\"size\":\"AU10 US6\",\"size_order\":10.5,\"total_units\":21,\"boxes\":[{\"reference_id\":\"NO REF\",\"box_id\":\"NO BOX\",\"units\":21}]},\"AU12 US8\":{\"size\":\"AU12 US8\",\"size_order\":12,\"total_units\":14,\"boxes\":[{\"reference_id\":\"NO REF\",\"box_id\":\"NO BOX\",\"units\":14}]},\"AU14 US10\":{\"size\":\"AU14 US10\",\"size_order\":10,\"total_units\":6,\"boxes\":[{\"reference_id\":\"NO REF\",\"box_id\":\"NO BOX\",\"units\":6}]},\"AU6 US2\":{\"size\":\"AU6 US2\",\"size_order\":8,\"total_units\":21,\"boxes\":[{\"reference_id\":\"NO REF\",\"box_id\":\"NO BOX\",\"units\":21}]},\"AU8 US4\":{\"size\":\"AU8 US4\",\"size_order\":8.5,\"total_units\":41,\"boxes\":[{\"reference_id\":\"NO REF\",\"box_id\":\"NO BOX\",\"units\":41}]}}"

    JSON.parse(merged_sizes_json)
  end
end

