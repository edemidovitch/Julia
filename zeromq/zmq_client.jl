using ZMQ

ctx = Context()
reciever = Socket(ctx, REQ)
ZMQ.connect(reciever, "tcp://localhost:5555")
while true
msg = ZMQ.recv(reciever)

reply = ZMQ.reply(requester)
println("Recieved reply $i : [$(reply)] \n")
end
