require 'matrix'

def regression_for_ratios(old_ratios)
  new_ratios = Array.new
	(0..(old_ratios.length - 2)).each do |i|
    new_ratio = Hash.new

		old_ratios[i].each do |key, value|
			new_ratio[key] = find_function(value)
		end
      
    new_ratios << new_ratio
	end
  new_ratios << old_ratios[old_ratios.length - 1] 
  new_ratios
end

# =============================================================================
# Internal 'private' methods ==================================================
# =============================================================================

def find_function(ratio)
	x = Array.new
	y = Array.new

	ratio.each do |r| 
		x << r[0]
		y << r[1]
	end

  function = best_fit(x, y)

	[volatile?(x, y, function), derivatives(x, function)]
end

def volatile?(x, y, function)
	two_s = 2 * function.last
	y_exp = nil

	case function[0]
	when 'exponential'
		y_exp = x.map { |xi| function[1] * function[2]**xi }
	when 'power'
		y_exp = x.map { |xi| function[1] * xi**function[2] }
	when 'log'
		y_exp = x.map { |xi| function[1] + function[2] * Math.log(xi) }
	when 'cubic'
		y_exp = x.map { |xi| function[1] + function[2] * xi + function[3] * xi**2 + function[4] * xi**3 }
	when 'quadratic'
		y_exp = x.map { |xi| function[1] + function[2] * xi + function[3] * xi**2 }
	when 'linear'
		y_exp = x.map { |xi| function[1] + function[2] * xi }
	end

	s_diffs = (Matrix[y_exp] - Matrix[y]).map { |y_dif| y_dif.abs - two_s }
	function.last = s_diffs.any? { |s_diff| s_diff < 0 }
end

def best_fit(x, y)
	fits = [exponential_regression(x, y), power_regression(x, y), log_regression(x, y), 
	 			  cubic_regression(x, y), quadratic_regression(x, y), linear_regression(x, y)]
	fits = fits.sort_by { |fit| fit.last }

	fits.first
end

#exponential eq'n = y = a * b^x 
def exponential_regression(x, y)
	y 						 = y.collect { |yi| Math.log(yi) }
	semi_log_coeff = regression(x, y, 1)
	eqn 			 		 = ['exponential', Math::E**semi_log_coeff[0], Math::E**semi_log_coeff[1]]
	y_expected		 = x.map { |xi| eqn[1]*(eqn[2]**xi) }

	eqn << s_value(y, y_expected)	
end

#power eq'n = y = a * x^b
def power_regression(x, y)
	x 						= x.collect { |xi| Math.log(xi) }
	y 						= y.collect { |yi| Math.log(yi) }
	log_log_coeff = regression(x, y, 1)
	eqn 				  = ['power', Math::E**log_log_coeff[0], log_log_coeff[1]]
	y_expected		= x.map { |xi| eqn[1]*(xi**eqn[2]) }

	eqn << s_value(y, y_expected)
end	

#log eq'n = y = a + blnx
def log_regression(x, y)
	x 						 = x.collect { |xi| Math.log(xi) }
	semi_log_coeff = regression(x, y, 1)
	eqn  					 = ['log', semi_log_coeff[0], semi_log_coeff[1]]
	y_expected		 = x.map { |xi| eqn[1] + (Math.log(xi)*eqn[2]) }

	eqn << s_value(y, y_expected)
end	

#cubic eq'n = y = ax^3 + bx^2 + cx + d
def cubic_regression(x, y)
  eqn = ["cubic"] + regression(x, y, 3)
  y_expected = x.map { |xi| eqn[1] + (eqn[2] * xi) + (eqn[3] * xi**2) + (eqn[4] * xi**3) }

  eqn << s_value(y, y_expected)
end

#quadratic eq'n = y = ax^2 + bx + c
def quadratic_regression(x, y)
  eqn = ["quadratic"] + regression(x, y, 2)
  y_expected = x.map { |xi| eqn[1] + (eqn[2] * xi) + (eqn[3] * xi**2) }

  eqn << s_value(y, y_expected)
end

#linear eq'n = y = ax + b
def linear_regression(x, y)
  eqn = ["linear"] + regression(x, y, 1)
  y_expected = x.map { |xi| eqn[1] + (eqn[2] * xi) }

  eqn << s_value(y, y_expected)
end

#returns coefficients from a0x^0 upwards...
def regression(x, y, degree)
  x_data = x.map { |xi| (0..degree).map { |pow| (xi**pow).to_f } }
  mx 		 = Matrix[*x_data]
  my 		 = Matrix.column_vector(y)
 
  ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
end

def s_value(observed_y, expected_y)
	difference = (Matrix[observed_y] - Matrix[expected_y]).map { |item| item**2 }
	difference = difference.inject { |sum, i| sum + i }
	Math.sqrt(difference.to_f/observed_y.length)
end

def derivatives(x, fit)
	case fit[0]
	when 'exponential'
		[fit[1] * Math.log(fit[2]) * fit[2]**x.last, fit[1] * (Math.log(fit[2]))**2 * fit[2]**x.last]
	when 'power'
		[fit[1] * fit[2] * x.last**(fit[2] - 1), fit[1] * fit[2] * (fit[2] - 1) * x.last**(fit[2] - 2)]
	when 'log'
		[fit[2] / x.last.to_f, - (fit[2] / ((x.last**2).to_f))]
	when 'cubic'
		[fit[2] + 2 * fit[3] * x.last + 3 * fit[4] * x.last**2, 2 * fit[3] + 6 * fit[4] * x.last]
	when 'quadratic'
		[fit[2] + 2 * fit[3] * x.last, 2 * fit[3]]
	when 'linear'
		[fit[2], 0]
	end
end
