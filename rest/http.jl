using HTTP, JSON
function make_API_call(url)
    try
        response = HTTP.get(url)
        return String(response.body)
    catch e
        return "Error occurred : $e"
    end
end

#response = make_API_call("http://jsonplaceholder.typicode.com/users")
response = make_API_call("http://127.0.0.1:5000/todo/api/v1.0/tasks")
println(s)
dict = JSON.parse(response)
@show dict
