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

class Deck
	attr_accessor :cards

	def initialize
		@cards = []
		Card::SUITS.each do |suit|
			Card::DECK_VALUES.each do |value|
				@cards << Card.new(suit, value)
			end
		end

		scramble!
	end

	def scramble!
		cards.shuffle!
	end

	def deal_one
		cards.pop
	end
end

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

class Participant
	include Hand

	attr_accessor :name, :cards

	def initialize
		@cards = []
		set_name
	end
end

class Player < Participant
	def set_name
		name = ''
		loop do
			puts "What's your name?"
			name = gets.chomp
			break unless name.empty?
			puts "Sorry, you must enter a value."
		end
		self.name = name
	end

	def show_flop
		show_hand
	end
end

class Dealer < Participant
	ROBOTS = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5']

	def set_name
		self.name = ROBOTS.sample
	end

	def show_flop
		puts "#{name}: #{cards.first} [??]"
	end
end

class TwentyOne
	attr_accessor :deck, :player, :dealer

	def initialize
		@deck = Deck.new
		@player = Player.new
		@dealer = Dealer.new
	end

	def reset
		self.deck = Deck.new
		player.cards = []
		dealer.cards = []
	end

	def deal_cards
		2.times do
			player.add_card(deck.deal_one)
			dealer.add_card(deck.deal_one)
		end
	end

	def show_flop
		player.show_flop
		dealer.show_flop

		puts "-" * 48
		puts "Points = #{player.name}: #{player.total} | #{dealer.name}: #{dealer.cards.first.value}"
		puts "-" * 48
	end

	def player_turn
		puts "#{player.name}'s turn..."

		loop do
			puts "(h)it or (s)tay?"
			answer = nil
			loop do
				answer = gets.chomp.downcase
				break if %w(h s).include?(answer)
				puts "That's not a valid answer. Please enter h or s."
			end

			if answer == 's'
				puts "#{player.name} stays!"
				puts ""
				break
			elsif player.busted?
				break
			else
				player.add_card(deck.deal_one)
				puts "#{player.name} hits!"
				puts ""
				show_cards
				show_totals
				break if player.busted?
			end
		end
	end

	def dealer_turn
		puts "#{dealer.name}'s turn..."

		loop do
			if dealer.total >= 17 && !dealer.busted?
				break
			elsif dealer.busted?
				break
			else
				dealer.add_card(deck.deal_one)
			end
		end
	end

	def show_busted
		if player.busted?
			puts "#{player.name} has busted! #{dealer.name} wins!"
			puts ""
		elsif dealer.busted?
			puts "#{dealer.name} has busted! #{player.name} wins!"
			puts ""
		end
	end

	def show_cards
		player.show_hand
		dealer.show_hand
	end

	def show_totals
		puts "-" * 48
		puts "Points = #{player.name}: #{player.total} | #{dealer.name}: #{dealer.total}"
		puts "-" * 48
	end

	def show_result
		if player.total > dealer.total
			puts "#{player.name} wins!"
			puts ""
		elsif player.total < dealer.total
			puts "#{dealer.name} wins!"
			puts ""
		else
			puts "It's a tie!"
			puts ""
		end
	end

	def play_again?
		answer = nil
		loop do
			puts "Play another game? Enter (y)es or (n)o."
			answer = gets.chomp.downcase
			break if %w(y n).include?(answer)
			puts "That's not a valid answer. Please enter y or n."
		end

		answer == 'y'
	end

	def start
		loop do
			system 'clear'
			deal_cards
			show_flop

			player_turn
			if player.busted?
				show_busted
				if play_again?
					reset
					next
				else
					break
				end
			end

			dealer_turn
			if dealer.busted?
				show_cards
				show_totals
				show_busted
				if play_again?
					reset
					next
				else
					break
				end
			end

			show_cards
			show_totals
			show_result
			play_again? ? reset : break
		end
		puts "Thank you for playing Twenty One. Good bye!"
	end
end

game = TwentyOne.new
game.start