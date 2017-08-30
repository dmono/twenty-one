class Card
  SUITS = %w(h d c s).freeze
  DECK_VALUES = %w(A 2 3 4 5 6 7 8 9 10 J Q K).freeze

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "[#{@value}#{@suit}]"
  end

  def value
    case @value
    when 'J' then 'J'
    when 'Q' then 'Q'
    when 'K' then 'K'
    when 'A' then 'A'
    else
      @value
    end
  end

  def suit
    case @suit
    when 'H' then 'H'
    when 'D' then 'D'
    when 'S' then 'S'
    when 'C' then 'C'
    end
  end

  def ace?
    value == 'A'
  end

  def king?
    value == 'K'
  end

  def queen?
    value == 'Q'
  end

  def jack?
    value == 'J'
  end
end
