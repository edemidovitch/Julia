# Julia program to illustrate
# the use of while loop

# Declaring Array
a = ["Geeks", "For", "Geeks"]

# Iterator Variable
i = 1

# while loop
while i <= length(a)

	# Assigning value to object
	object = a[i]

	# Printing object
	println("$object")

	# Updating iterator globally
	global i += 1

# Ending Loop
end
