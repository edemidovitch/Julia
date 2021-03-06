using ZMQ
using Printf

ctx = Context()
s = Socket(ctx, REQ)
#ZMQ.bind(s, "tcp://*:5559")

ZMQ.connect(s, "tcp://localhost:5559")

for i=1:8
	println("Sending request $i \n")
	ZMQ.send(s, "Hello")

	reply = ZMQ.recv(s)
	@printf("Recieved reply %d : %s \n", i, String(reply))
end
