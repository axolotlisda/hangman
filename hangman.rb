require 'yaml'
require 'erb'

# class game
class Game
  def initialize
    @lives = 10
    @word = starts.split('')
    @guessed = Array.new(@word.length)
    @used_letter = Array.new(0)
    @alpha = 'a b c d e f g h i j k l m n o p q r s t u v w x y z'
  end

  def starts
    a = []
    file = File.open('google-10000-english-no-swears.txt')
    File.foreach(file) { |line| a.push(line) }
    random = a[rand(0..9894)].chomp!
    if random.length.between?(5, 12)
      random
    else
      starts # restart and it works hehe
    end
  end

  def player
    print "\nput a letter: "
    turn = gets.chomp.downcase
    if turn.length == 1 && turn.match?(/[[:alpha:]]/)
      turn
    elsif turn == 'save'
      save_game()
      puts "\nsaving file..."
      player()
    elsif turn == 'load'
      puts "\nloading file..."
      load_game()
      player()
    else
      puts "please put an alphabet\n"
      player()
    end
  end

  def lives_left
    @lives -= 1
  end

  def winner?(guessed, word)
    return unless guessed == word

    puts 'you win!'
    true
  end

  def game_over
    puts "\n Game Over! The word is \'#{@word.join}\'"
  end

  def guessed_word()
    # puts "guessed: #{@guessed.to_s.gsub(',','').gsub('nil','_')}"
    cont = @guessed.each_with_index do |v, i|
      if @guessed[i].nil? == true
        @guessed[i] = '_ '
      end
    end
    puts "guessed: #{cont.join}"
  end

  def check_word(word, turn)
    any_letter = false
    word.each_with_index do |v, i|
      if v == turn
        @guessed[i] = turn
        any_letter = true # any letter that equals with v will set the value to true
      end
    end
    # if any_letter == true
    #   any_letter = false 
    if any_letter == false && @used_letter.include?(turn) == false
      @lives -= 1
    end
    guessed_word()
  end

  def included?
    if @alpha.include?(@turn) == true
      @alpha.gsub!(@turn, '_')
      @used_letter.push(@turn)
      # puts "used letter #{@used_letter}"
    elsif @used_letter.include?(@turn) == true
      puts "\nYou already used that letter!"
    end
    puts "\nalpha: #{@alpha}"
  end

  def save_game
    Dir.mkdir 'output' unless Dir.exist? 'output'
    puts 'slot 1 to 3'
    slot = gets.chomp!
      if slot.between?('1','3') then
        filename = "saved_game#{slot}.yaml"
        File.open("output/#{filename}", 'w') { |file| file.write save_to_yaml }
        puts 'saved'
      else puts 'invalid slot'
      end
  end

  def save_to_yaml
    YAML.dump(
      'lives' => @lives,
      'word' => @word,
      'alpha' => @alpha,
      'guessed' => @guessed,
      'used_letter' => @used_letter
    )
  end

  def load_game
    puts 'load game slot(1 to 3): '
    slot = gets.chomp!
      if slot.between?('1','3') then
      file = YAML.safe_load(File.read("output/saved_game#{slot}.yaml"))
      @lives = file['lives']
      @word = file['word']
      @alpha = file['alpha']
      @guessed = file['guessed']
      @used_letter = file['used_letter']
      guessed_word()
      puts "alpha: #{@alpha}\nlives: #{@lives}"
      else puts 'invalid slot'
      end
  end

  def playing
    guessed_word()
    puts "\nalpha: #{@alpha}"
    while @lives > 0 do
      if winner?(@guessed, @word) == true
        break
      end
          puts "lives #{@lives}"
          @turn = player
          check_word(@word, @turn)
          included?()
     end
     game_over() if @lives == 0
    end
  end

Game.new.playing
