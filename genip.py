#!/usr/bin/python
import sys
import random as rd


def connect(tmp_list):
    string = ""
    for index in tmp_list:
        string += str(index)
    return string


def ip_to_dec(string):
    counter = 0
    dots = 0
    str_list = list(string)
    for i in range(0, len(str_list)):
        if counter >= 8 and dots < 3:
            str_list.insert(i, ".")
            dots += 1
            counter = -1
        counter += 1
    bin_dot = connect(str_list)
    bin_list = bin_dot.split(".")
    dec_ip = ""
    dots = 0
    for octet in bin_list:
        tmp = "0b"+octet
        tmp = int(octet, 2)
        if dots < 3:
            dec_ip += str(tmp)+"."
            dots += 1
        else:
            dec_ip += str(tmp)
    return dec_ip


def find_random_ip(mask, net):
    host_space = 32 - int(mask)
    host_num = 2**host_space
    random_host = rd.randint(2, host_num - 2)
    random_host = str(bin(random_host))[2:]
    net = net[:int(mask)]
    new_ip = net+random_host
    return new_ip


ip = sys.argv[1]
ip_list = ip.split("/")
net = ip_list[0]
mask = ip_list[1]
# mask_bin = ""
# for bit in range(0, 32):
#     if bit < int(mask):
#         mask_bin += "1"
#     else:
#         mask_bin += "0"
net_list = net.split(".")
net_bin = []
for octet in net_list:
    tmp = bin(int(octet))
    tmp = tmp[2:].zfill(8)
    net_bin.append(tmp)
net_str = connect(net_bin)
rd_ip = find_random_ip(mask, net_str)
rd_ip = ip_to_dec(rd_ip)
print(rd_ip)
