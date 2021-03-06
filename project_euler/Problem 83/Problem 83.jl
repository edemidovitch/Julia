#Problem 83
using DelimitedFiles

file_name = "/Users/eugene/Programming/Julia/project_euler/Problem 81/p081_matrix.txt"
int_matrix= readdlm(file_name, ',', Int, '\n')

function shortest_path(n, matrix)
    function neibour_path(i, j)
        if haskey(path_dict, (i - 1, j)) &&  path_dict[(i - 1,j)] > path_dict[(i,j)] + matrix[i - 1, j]
            path_dict[(i - 1,j)] = path_dict[(i, j)] + matrix[i - 1, j]
            neibour_path(i - 1, j)
        end
        if haskey(path_dict, (i + 1, j)) && path_dict[(i + 1,j)] > path_dict[(i,j)] + matrix[i + 1, j]
            path_dict[(i + 1,j)] = path_dict[(i, j)] + matrix[i + 1, j]
            neibour_path(i + 1, j)
        end
        if haskey(path_dict, (i, j - 1)) && path_dict[(i,j - 1)] > path_dict[(i,j)] + matrix[i, j - 1]
            path_dict[(i,j - 1)] = path_dict[(i, j)] + matrix[i, j - 1]
            neibour_path(i, j - 1)
        end
        if haskey(path_dict, (i, j + 1)) && path_dict[(i,j + 1)] > path_dict[(i,j)] + matrix[i, j + 1]
            path_dict[(i,j + 1)] = path_dict[(i, j)] + matrix[i, j + 1]
            neibour_path(i, j + 1)
        end
    end

    path_dict = Dict()
    for i = 1:n
        for j = 1:n
            if i == 1 && j == 1
                path_dict[(i,j)] =  matrix[i, j]
                continue
            end
            path_dict[(i,j)] =  matrix[i, j] + min(get(path_dict, (i - 1, j), typemax(Int64)), get(path_dict, (i, j - 1), typemax(Int64)))
            neibour_path(i, j)

        end
    end
    return path_dict[(n,n)]
end
n = 80
@show   shortest_path(n, int_matrix)
