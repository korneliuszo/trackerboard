#!/bin/env python
import struct

class atag_intnums(object):
    def serialize(self):
        ret= struct.pack('II',len(self.arglist)+2,self.tagnum)
        for arg in self.arglist:
            ret+=struct.pack('I',arg);
        return ret

class atag_core(atag_intnums):
    def __init__(self,flags=1,pagesize=4096,rootdev=2040):
        self.tagnum=0x54410001
        self.arglist=[flags,pagesize,rootdev]

class atag_mem(atag_intnums):
    def __init__(self,size,start):
        self.tagnum=0x54410002
        self.arglist=[size,start]

class atag_initrd2(atag_intnums):
    def __init__(self,start,size):
        self.tagnum=0x54420005
        self.arglist=[start,size]

class atag_none(atag_intnums):
    def __init__(self):
        self.tagnum=0x0
        self.arglist=[]

class atag_cmdline(object):
    def __init__(self,cmdline):
        self.tagnum=0x54410009
        if len(cmdline)==0:
            raise ValueError("Cmdline cannot be empty")
        self.cmdline=cmdline
    def serialize(self):
        length=int((len(self.cmdline)+1+3)/4)+2
        ret= struct.pack('II',length,self.tagnum)
        ret+=self.cmdline.encode('ascii')
        ret+=b'\x00'*(length*4-len(ret))
        return ret

class ataglist(list):
    def serialize(self):
        ret= bytearray(b'')
        gotcore=False
        for tag in self:
            if tag.tagnum == 0x54410001:
                ret=tag.serialize()+ret
                gotcore=True
            else:
                ret=ret+tag.serialize()
        if not gotcore:
            raise ValueError("list does not include ATAG_CORE")
        ret=ret+atag_none().serialize()
        return ret

if __name__ == '__main__':
    import argparse, os
    parser = argparse.ArgumentParser(description='makes atags blob')
    parser.add_argument('--mem', type=str, nargs=2, 
        metavar=('start','size'), help='memory layout',action='append')
    parser.add_argument('dst', type=argparse.FileType('wb', 0), 
        help='place to save atags')
    parser.add_argument('--initrd', type=str, nargs=2, metavar=('file','start'),
        help='initrd info',action='append')
    parser.add_argument('cmdline', type=str, default='console=/dev/console', nargs='*',
        help='command line for kernel')
    args=parser.parse_args()
    print(args)
    atags=ataglist()
    if args.initrd is not None:
        for init in args.initrd:
            atags.append(atag_initrd2(start=int(init[1],0),size=os.stat(init[0]).st_size))
    if args.mem is not None:
        for mem in args.mem:
            atags.append(atag_mem(start=int(mem[0],0),size=int(mem[1],0)))
    atags.append(atag_core())
    cmdline=''
    for arg in args.cmdline:
        cmdline+=arg+' '
    atags.append(atag_cmdline(cmdline[0:-1]))
    args.dst.write(atags.serialize())
    args.dst.close()
#    print(atags)
    print(atags.serialize())

