class Result
  attr_reader :ok, :id, :errors

  def initialize(ok, id, errors=[])
    @ok = ok
    @id = id
    @errors = errors
  end
end
