# Macro definition..
macro unless(test_expr, branch_expr)
  quote
    if !$test_expr
      $branch_expr
    end
  end
end

# Macro call..
array = [1, 2, 'b']
@unless 3 in array println("array does not contain 3") # here test_expr is "3 in array"

# We can reuse the macro for different expressions..
@unless length(array) >= 10 println("array has fewer than 10 elements")
