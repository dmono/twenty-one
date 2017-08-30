module Hand
  def show_hand
    hand = ''
    cards.each do |card|
      hand << "#{card} "
    end
    puts "#{name}: #{hand}"
  end

  def total
    total = 0
    cards.each do |card|
      if card.ace?
        total += 11
      elsif card.jack? || card.queen? || card.king?
        total += 10
      else
        total += card.value.to_i
      end
    end

    #correct for Aces
    cards.select(&:ace?).count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def busted?
    total > 21
  end
end
