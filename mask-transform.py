#!/usr/bin/python
import sys


def connect(tmp_list):
    string = ""
    for i in tmp_list:
        string += str(i)
    return string


preffix = 0
bin_bcmask = ""
bin_bc = ""
mask = sys.argv[1]
broadcast = sys.argv[2]
mask_list = mask.split('.')
bc_list = broadcast.split('.')
# transforming mask to binary form
for octet in mask_list:
    temp = bin(int(octet))
    clear_temp = temp[2:len(temp)]
    new = clear_temp.zfill(8)
    bin_bcmask += new
# counting preffix length
for bit in bin_bcmask:
    if bit == "1":
        preffix += 1
# getting binary form of broadcast address
for octet in bc_list:
    temp = bin(int(octet))
    clear_temp = temp[2:len(temp)]
    new = clear_temp.zfill(8)
    bin_bc += new

# transform broadcast address to network ip
bin_bc = list(bin_bc)
for bit in range(preffix, len(bin_bc)):
    bin_bc[bit] = 0
net_addr = bin_bc
# adding dots to bin broadcast mask
counter = 1
for i in range(0, len(net_addr)):
    if counter == 9:
        net_addr.insert(i, '.')
        counter = 0
    counter += 1
# transform net addr to decimal form
net_addr = connect(net_addr)
net_addr_list = net_addr.split(".")
dec_net = []
dots = 0
for octet in net_addr_list:
    temp = int(octet, 2)
    dec_net.append(temp)
    if dots < 3:
        dec_net.append(".")
        dots += 1
net_ip = connect(dec_net)
print(net_ip, "/", preffix, sep='')
