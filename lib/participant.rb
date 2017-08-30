require_relative 'hand'

class Participant
  include Hand

  attr_accessor :name, :cards

  def initialize
    @cards = []
    set_name
  end
end
