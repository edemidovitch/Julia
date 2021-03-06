#Problem 81

using DelimitedFiles

file_name = "/Users/eugene/Programming/Julia/project_euler/Problem 81/p081_matrix.txt"
int_matrix= readdlm(file_name, ',', Int, '\n')

#@show int_matrix

function accumulation(int_matrix)
    l = 80
    s = Dict()
    s[1,1] = int_matrix[1,1]
    for i = 1:l
        for j = 1:l
            if i == 1
                s[i, j] =  int_matrix[i,j] + get(s, (i, j - 1), 0)
                continue
            end
            if j == 1
                s[i, j] =  int_matrix[i,j] + get(s, (i - 1, j), 0)
                continue
            end
                s[i, j] = int_matrix[i,j] + min(get(s, (i - 1, j), int_matrix[i - 1,j] ), get(s, (i, j - 1), int_matrix[i,j - 1] ))

        end
    end

    return s[l, l]
end

@show accumulation(int_matrix)
