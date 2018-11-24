require 'sinatra'
require './lib/Circle'
require './lib/Line'
require './lib/BoardFunctions'
require './lib/LineFunctions'
require './lib/PlayerFunctions'

class App < Sinatra::Base

    $board_functions = BoardFunctions.new
    $line_functions = LineFunctions.new
    $player_functions = PlayerFunctions.new
    $circles_global = $board_functions.generate_circles(5)
    $lines_global = $board_functions.generate_lines(5)
    $marks_global = $board_functions.generate_marks(5)
    $players = $player_functions.generate_players(["Laura", "Andrea"])
    $showable_players = $players.clone
    $current_turn = 0

    def validate_positions(x, y, direction)
        if direction == "horizontal"
            return x<5 && y<=5
        else
            return x<=5 && y<5
        end
    end

    def reset()
        $circles_global = $board_functions.generate_circles(5)
        $lines_global = $board_functions.generate_lines(5)
        $marks_global = $board_functions.generate_marks(5)
        $players = $player_functions.generate_players(["Laura", "Andrea"])
        $showable_players = $players.clone
        $current_turn = 0
    end

    get '/mainMenu' do
        reset()
        erb :main_menu
    end

    get '/game' do
        @circles = $circles_global
        @lines = $lines_global
        @marks = $marks_global
        @size = 5
        @current_turn = $current_turn
        @players = $players
        @showable_players = $showable_players
        erb :game
    end

    get '/finalScores' do
        @showable_players = $players.clone
        $player_functions.sort_by_score(@showable_players)
        erb :final_scores
    end

    post '/game' do
        if validate_positions(params[:x].to_i, params[:y].to_i, params[:direction])
            line_id = $line_functions.generate_id(params[:x].to_i * 100, params[:y].to_i * 100, params[:direction])
            $board_functions.mark_line(line_id, $lines_global, $current_turn)
            formed_squares = $board_functions.get_directions_of_formed_squares($lines_global, line_id, 5)
            $board_functions.make_marks_visible(formed_squares, $marks_global, line_id, $current_turn)
            no_new_squares_formed = formed_squares.empty?
            $player_functions.increase_score($players[$current_turn], formed_squares)
            $showable_players = $players.clone
            $current_turn = $board_functions.get_current_turn($current_turn, no_new_squares_formed, $players)
            $player_functions.sort_by_score($showable_players)
        end
        redirect "/game"
    end
    
    run! if app_file == $0;

end