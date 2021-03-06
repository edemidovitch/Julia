using ZMQ

ctx = Context()
s = Socket(ctx, REQ)
ZMQ.bind(s, "tcp://*:5559")

for i=1:8
	println("Sending request $i \n")
	ZMQ.send(s, "Hello")

	reply = ZMQ.recv(s)
	println("Recieved reply $i : [$(reply)] \n")
end

context = zmq.Context()
print("Connecting to Server on port 5555")
socket = context.socket(zmq.REQ)
#socket.connect("tcp://*:5555")
#socket.connect("tcp://localhost:5555")
socket.connect("tcp://localhost:5559") # to communicate with GO
print('Sending Hello')
socket.send(b"Hello")
print('Waiting for answer')
message = socket.recv()
print(f"Received: {message}")
