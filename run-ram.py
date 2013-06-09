import atags,epboot,os
a=epboot.epboot('/dev/ttyUSB0')
a.enterboot()
a.inittracker()
PATH='../output/target/'
a.writefile(0xc0038000, PATH+'zImage-ram')
a.writefile(0xc0c00000, PATH+'rootfs-ram.lzma')
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
