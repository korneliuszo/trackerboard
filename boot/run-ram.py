#!/usr/bin/env python
import atags,epboot,os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('port', metavar='port', type=str, nargs=1,
                   help='Port to use to comunicate with tracker')
parser.add_argument('path', metavar='path', type=str, nargs=1,
                           help='Port to use to comunicate with tracker')
args = parser.parse_args()

a=epboot.epboot(args.port)
a.enterboot()
a.inittracker()
PATH=args.path[0]
a.writefile(0xc0038000, os.path.join(PATH,'zImage-ram'))
a.writefile(0xc0c00000, os.path.join(PATH,'rootfs-ram.lzma'))
al=atags.ataglist()
al.append(atags.atag_initrd2(start=0xc0c00000,size=os.stat(PATH+'rootfs-ram.lzma').st_size))
al.append(atags.atag_mem(start=0xc0000000, size=0x01000000))
al.append(atags.atag_core())
al.append(atags.atag_cmdline(' '))
a.writeblock(0xc0001000,al.serialize())
#a.setbaud(9600)
a.run(0xc0038000,0,0x5b,0xc0001000,0)
a.port.close()
os.execvp('picocom',('picocom','/dev/ttyUSB0'))
