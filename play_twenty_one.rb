require './lib/deck'
require './lib/player'
require './lib/dealer'

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
