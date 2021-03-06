#Gaussian numbers
#Project Euler Problem 153


function real_divs(n)
    s = 0
    for i = 1:n
        for j = i:n
            p = i * j
            if p > n
                break
            end
            #@show p, i, j
            s += i + (i != j ? j : 0)
        end
    end
    return s
end

function complex_divs(n)
    s = 0
    for i = 1:n
        for j = 1:n
            rp = i * j
            if rp > n
                break
            end
            for ii = 1:n
                for ji = 1:n
                    ip = ii * ji
                    if rp + ip > n
                        break
                    end
                    d1 = i + (ii)im
                    d2 = j  - (ji)im

                    p = d1 * d2
                    if real(p) > n
                        break
                        #@show real(s)
                    end
                    if imag(p) == 0

                        #@show d1, d2, p
                        s += i + j  #+ (d1 != d2 ? j + i : 0)
                        #@show p, i, ii, j, ji
                    end
                end
            end
        end

    end
    return real(s)
end

function f2(n)
    #(a+bi)*(c-di)
    s=0
    for a=1:n-1
        for c=a:n
            p1=a*c
            if p1>n
                break
            end
            for b=1:n
                for d=b:n
                    if p1+b*d > n
                        break
                    end
                    if b*c-a*d == 0
                        s+=a+c + (a != c ? a + c : 0)
                    end
                end
            end
        end
    end
    return s
end

function f4_old(n)
    #(a+bi)*(c-di)
    s=0
    for a=1:n-1
        for c=a:n
            p1=a*c
            if p1>n
                break
            end
            for b=1:n
                for d=b:n
                    if p1+b*d > n
                        break
                    end
                    if b*c-a*d == 0
                        s+=a+c + (a != c ? a + c : 0)
                    end
                end
            end
        end
    end
    return s
end

function f3(n)
    #(a+bi)*(c-di)
    s = 0
    for b = 1:n
        for c = 1:n
            p1 = b * c
            for a = c:n
                # if a^ 2 > n
                #     break
                # end
                #p2 = a * c

                if rem(p1, a) == 0
                    d = p1 ÷ a
                    #if p2 + b * d > n
                    #@show b,c,a,d
                    if real((a+(b)im)*(c-(d)im)) <= n
                        # if real((a+(b)im)*(c-(d)im)) == 4
                        #     @show a,b,c,d
                        # end
                        s += a + c + ((a == c && b == d ) ?  0 : a + c)
                    end

                end
            end
        end
    end
    return s
end


#########
# (n, f4(n)) = (100.0, 8450.0)
# ("f4", c4time) = ("f4", 0.046156475)
# (n, f4(n)) = (1000.0, 929460.0)
# ("f4", c4time) = ("f4", 0.045571104)
# (10000.0, 9.5975212e7)
# ("f4", c4time) = ("f4", 0.058479059)


# (n, real_divs(n)) = (100000.0, 8.224740835e9)
# ("real", rtime) = ("real", 0.040325623)
# (100000.0, 9.69991632e9)
# ("f4", c4time) = ("f4", 0.277818925)
# julia> 8.224740835e9+9.69991632e9
# 1.7924657155e10

# (1.0e8, 8.224670422194237e15)
# ("real", rtime) = ("real", 5.793869252)
# (n, f4(n)) = (1.0e8, 9.746583700166398e15)
# ("f4", c4time) = ("f4", 3490.96181985)
#
# julia> 8.224670422194237e15+9.746583700166398e15
# 1.7971254122360636e16

function f4(n)
    #(a+bi)*(c-di)
    s = 0
    for a = 1:n-1
        ac = a * a - a
        for c = a:n
            ac += a
            if ac > n
                break
            end
            b2 = n/c
            bc = 0
            for b = 1:b2
                bc += c

                dr = bc/a
                d = trunc(Int, dr)
                if ac + b * d > n
                    break
                end
                if dr == d
                    s += a + c + (a != c ? a + c : 0)
                end
            end
        end
    end
    return s
end


for k = 1:22
    @show k, real_divs(k), complex_divs(k), f2(k), f3(k), f4(k)
end

N=1e5

show_real(n) = @show n, real_divs(n)
rtime=@elapsed show_real(N)
@show "real", rtime


show_complex(n) = @show n, complex_divs(n)
show_f2(n) = @show n, f2(n)
show_f3(n) = @show n, f3(n)
show_f4(n) = @show n, f4(n)

# ctime=@elapsed show_complex(N)
# @show "complex", ctime

# c2time=@elapsed show_f2(N)
# @show "f2", c2time

# c3time=@elapsed show_f3(N)
# @show "f3", c3time
#
c4time=@elapsed show_f4(N)
@show "f4", c4time
