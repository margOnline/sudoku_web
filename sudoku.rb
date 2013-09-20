require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions

helpers do
  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value == 0
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value

    if solution_to_check && must_be_guessed && tried_to_guess && guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value_provided'
    end
  end  

  def cell_value
    value.to_i == 0 ? '' : value
  end

end

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9,0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def puzzle(sudoku)
  sudoku
end

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution 
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

post '/' do
  cells = param["cells"]
  session[:current_solution] = cells.map{|value| value.to_i}.join
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
  @current_solution = session[:solution]
  erb :index
end

get '/last-visit' do
  "Previous visit to homepage: #{session[:last_visit]}"
end